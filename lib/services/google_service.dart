import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'secure_store.dart';
import 'package:googleapis/calendar/v3.dart' as gcal;
import 'package:googleapis/gmail/v1.dart' as gml;
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

class _GoogleAuthClient extends http.BaseClient {
  _GoogleAuthClient(this._headers);
  final Map<String, String> _headers;
  final http.Client _inner = http.Client();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) =>
      _inner.send(request..headers.addAll(_headers));

  @override
  void close() {
    _inner.close();
    super.close();
  }
}

class GoogleService {
  GoogleService(this._storage);

  final FlutterSecureStorage _storage;
  final _supabase = Supabase.instance.client;

  // Least-privilege scopes (Google OAuth verification). Calendar uses the
  // narrower events-only read scope — the app only calls events.list, never
  // reads calendar lists/settings. Gmail needs full readonly because the inbox
  // feature reads message BODIES (gmail.metadata returns headers only).
  static const _scopeCalendar    = 'https://www.googleapis.com/auth/calendar.events.readonly';
  static const _scopeGmail       = 'https://www.googleapis.com/auth/gmail.readonly';
  static const _keyCalToken      = 'google_cal_token';
  static const _keyCalRefresh    = 'google_cal_refresh';
  static const _keyGmailToken    = 'google_gmail_token';
  static const _keyGmailRefresh  = 'google_gmail_refresh';

  Future<bool> get isAnyConnected async =>
      await _storage.read(key: _keyCalToken) != null ||
      await _storage.read(key: _keyGmailToken) != null;

  /// True when the current app session was created with Google sign-in, so a
  /// Gmail/Calendar token can be obtained without switching accounts.
  bool get isGoogleAccount {
    final user = _supabase.auth.currentUser;
    if (user == null) return false;
    if (user.appMetadata['provider'] == 'google') return true;
    final providers = (user.appMetadata['providers'] as List?)?.cast<String>() ?? const [];
    if (providers.contains('google')) return true;
    return user.identities?.any((i) => i.provider == 'google') ?? false;
  }

  /// True when there is any signed-in (non-local) account at all.
  bool get isSignedIn => _supabase.auth.currentUser != null;

  Future<bool> get isCalConnected async =>
      await _storage.read(key: _keyCalToken) != null;

  Future<bool> get isGmailConnected async =>
      await _storage.read(key: _keyGmailToken) != null;

  // ── Connect ────────────────────────────────────────────────────────────────

  Future<bool> connectCalendar() async {
    final result = await _oauthViaSupabase(scope: _scopeCalendar);
    if (result == null) return false;
    await _storage.write(key: _keyCalToken, value: result.token);
    if (result.refresh != null) await _storage.write(key: _keyCalRefresh, value: result.refresh!);
    return true;
  }

  Future<bool> connectGmail() async {
    final result = await _oauthViaSupabase(scope: _scopeGmail);
    if (result == null) return false;
    await _storage.write(key: _keyGmailToken, value: result.token);
    if (result.refresh != null) await _storage.write(key: _keyGmailRefresh, value: result.refresh!);
    return true;
  }

  Future<void> disconnect() async {
    await _storage.delete(key: _keyCalToken);
    await _storage.delete(key: _keyCalRefresh);
    await _storage.delete(key: _keyGmailToken);
    await _storage.delete(key: _keyGmailRefresh);
  }

  Future<void> disconnectCalendar() async {
    await _storage.delete(key: _keyCalToken);
    await _storage.delete(key: _keyCalRefresh);
  }

  Future<void> disconnectGmail() async {
    await _storage.delete(key: _keyGmailToken);
    await _storage.delete(key: _keyGmailRefresh);
  }

  // Returns a fresh access token, using the stored refresh token if the Supabase
  // session has rotated since connect time.
  Future<String?> _validToken(String tokenKey, String refreshKey) async {
    final stored = await _storage.read(key: tokenKey);
    if (stored != null) return stored;
    // No stored token — try pulling from current Supabase session.
    final session = _supabase.auth.currentSession;
    if (session?.providerToken != null) {
      await _storage.write(key: tokenKey, value: session!.providerToken!);
      return session.providerToken;
    }
    return null;
  }

  // ── Calendar ───────────────────────────────────────────────────────────────

  Future<List<gcal.Event>> fetchCalendarEvents({int days = 7}) async {
    final token = await _validToken(_keyCalToken, _keyCalRefresh);
    if (token == null) return [];
    final client = _GoogleAuthClient({'Authorization': 'Bearer $token'});
    try {
      final api = gcal.CalendarApi(client);
      final now = DateTime.now().toUtc();
      final response = await api.events.list(
        'primary',
        timeMin: now,
        timeMax: now.add(Duration(days: days)),
        singleEvents: true,
        orderBy: 'startTime',
        maxResults: 50,
      );
      return response.items ?? [];
    } catch (_) {
      return [];
    } finally {
      client.close();
    }
  }

  // ── Gmail ──────────────────────────────────────────────────────────────────

  Future<List<gml.Message>> fetchUnreadMessages({int maxResults = 20}) async {
    final token = await _validToken(_keyGmailToken, _keyGmailRefresh);
    if (token == null) return [];
    final client = _GoogleAuthClient({'Authorization': 'Bearer $token'});
    try {
      final api  = gml.GmailApi(client);
      final list = await api.users.messages.list(
        'me',
        maxResults: maxResults,
        q: 'is:unread',
      );
      final messages = <gml.Message>[];
      for (final ref in list.messages ?? []) {
        try {
          messages.add(await api.users.messages.get(
            'me', ref.id!,
            format: 'metadata',
            metadataHeaders: ['Subject', 'From', 'Date'],
          ));
        } catch (_) {}
      }
      return messages;
    } finally {
      client.close();
    }
  }

  /// Fetches the full message (with body parts) for [id].
  Future<gml.Message?> fetchMessageFull(String id) async {
    final token = await _validToken(_keyGmailToken, _keyGmailRefresh);
    if (token == null) return null;
    final client = _GoogleAuthClient({'Authorization': 'Bearer $token'});
    try {
      return await gml.GmailApi(client).users.messages.get('me', id, format: 'full');
    } finally {
      client.close();
    }
  }

  /// Decodes the readable plain-text body of a Gmail message (falls back to the
  /// snippet). Handles multipart bodies and strips HTML when only HTML exists.
  static String plainTextBody(gml.Message msg) {
    String decode(String? data) {
      if (data == null) return '';
      try {
        return utf8.decode(base64.decode(base64.normalize(
            data.replaceAll('-', '+').replaceAll('_', '/'))));
      } catch (_) {
        return '';
      }
    }

    String? walk(gml.MessagePart? part) {
      if (part == null) return null;
      if (part.mimeType == 'text/plain') {
        final t = decode(part.body?.data).trim();
        if (t.isNotEmpty) return t;
      }
      for (final p in part.parts ?? const <gml.MessagePart>[]) {
        final t = walk(p);
        if (t != null && t.isNotEmpty) return t;
      }
      if (part.mimeType == 'text/html') {
        final html = decode(part.body?.data);
        if (html.isNotEmpty) {
          return html
              .replaceAll(RegExp(r'<(script|style)[^>]*>[\s\S]*?</\1>', caseSensitive: false), ' ')
              .replaceAll(RegExp(r'<[^>]+>'), ' ')
              .replaceAll('&nbsp;', ' ')
              .replaceAll(RegExp(r'[ \t]+'), ' ')
              .replaceAll(RegExp(r'\n\s*\n\s*\n+'), '\n\n')
              .trim();
        }
      }
      return null;
    }

    final body = walk(msg.payload);
    if (body != null && body.isNotEmpty) return body;
    return (msg.snippet ?? '').trim();
  }

  // ── Supabase Google OAuth ──────────────────────────────────────────────────

  Future<({String token, String? refresh})?> _oauthViaSupabase({required String scope}) async {
    await _supabase.auth.signInWithOAuth(
      OAuthProvider.google,
      scopes: scope,
      redirectTo: 'io.supabase.taskeraapp://login-callback',
      authScreenLaunchMode: LaunchMode.externalApplication,
      // Force Google to always render the full consent screen listing every
      // requested scope, even for an account that authorized TaskEra before.
      // Without prompt=consent, a returning account skips the scope screen —
      // which is why OAuth verification couldn't see the scopes in the demo.
      // access_type=offline also ensures a refresh token is issued.
      queryParams: const {
        'access_type': 'offline',
        'prompt': 'consent',
      },
    );

    // Only signedIn carries a providerToken — tokenRefreshed does not.
    final event = await _supabase.auth.onAuthStateChange
        .where((e) => e.event == AuthChangeEvent.signedIn)
        .first
        .timeout(const Duration(minutes: 3));

    final providerToken = event.session?.providerToken;
    if (providerToken == null) return null;
    return (token: providerToken, refresh: event.session?.providerRefreshToken);
  }
}

final googleServiceProvider = Provider<GoogleService>((ref) {
  return GoogleService(kSecureStorage);
});
