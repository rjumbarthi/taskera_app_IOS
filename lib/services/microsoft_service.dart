import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'secure_store.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../util/platform_layout.dart';

/// Microsoft Graph OAuth2 service using PKCE.
///
/// Platform notes:
/// - Android / iOS : registers `taskeraapp://` custom scheme via AndroidManifest / Info.plist
/// - Windows / macOS: flutter_web_auth_2 spins up a localhost server for the callback
///
/// Azure Portal setup: register `taskeraapp://microsoft-auth` (mobile) and
/// `http://localhost` (desktop) as redirect URIs for the app registration.
class MicrosoftService {
  MicrosoftService(this._storage);
  final FlutterSecureStorage _storage;

  static const _authBase  = 'https://login.microsoftonline.com/${AppConfig.azureTenantId}/oauth2/v2.0/authorize';
  static const _tokenBase = 'https://login.microsoftonline.com/${AppConfig.azureTenantId}/oauth2/v2.0/token';
  static const _scopes    = 'openid email profile offline_access Calendars.Read Mail.Read';

  static const _keyAccess  = 'ms_access_token';
  static const _keyRefresh = 'ms_refresh_token';

  // Desktop uses http://localhost (flutter_web_auth_2 handles port selection).
  // Mobile uses the taskeraapp:// custom scheme registered in AndroidManifest/Info.plist.
  static String get _redirectUri =>
      isDesktop ? 'http://localhost' : AppConfig.microsoftRedirectUri;
  static String get _callbackScheme => isDesktop ? 'http' : 'taskeraapp';

  Future<bool> get isConnected async =>
      (await _storage.read(key: _keyAccess)) != null;

  // ── OAuth flow ─────────────────────────────────────────────────────────────

  Future<bool> connect() async {
    try {
      final verifier   = _codeVerifier();
      final challenge  = _codeChallenge(verifier);

      final authUri = Uri.parse(_authBase).replace(queryParameters: {
        'client_id'            : AppConfig.azureClientId,
        'response_type'        : 'code',
        'redirect_uri'         : _redirectUri,
        'scope'                : _scopes,
        'code_challenge'       : challenge,
        'code_challenge_method': 'S256',
        'state'                : _randomString(16),
        'prompt'               : 'select_account',
      });

      final result = await FlutterWebAuth2.authenticate(
        url: authUri.toString(),
        callbackUrlScheme: _callbackScheme,
      );

      final code = Uri.parse(result).queryParameters['code'];
      if (code == null) return false;
      return _exchangeCode(code, verifier);
    } catch (_) {
      return false;
    }
  }

  Future<void> disconnect() async {
    await _storage.delete(key: _keyAccess);
    await _storage.delete(key: _keyRefresh);
  }

  // ── Microsoft Graph ────────────────────────────────────────────────────────

  /// Next [days] days of calendar events.
  Future<List<Map<String, dynamic>>> fetchCalendarEvents({int days = 7}) async {
    final token = await _validToken();
    if (token == null) return [];

    final now = DateTime.now().toUtc().toIso8601String();
    final end = DateTime.now().toUtc().add(Duration(days: days)).toIso8601String();
    final uri = Uri.parse(
      'https://graph.microsoft.com/v1.0/me/calendarView'
      '?\$top=50'
      '&startDateTime=$now'
      '&endDateTime=$end'
      '&\$select=subject,start,end,location,isOnlineMeeting,organizer'
      '&\$orderby=start/dateTime',
    );

    final res = await http.get(uri,
        headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'});
    if (res.statusCode != 200) return [];
    return List<Map<String, dynamic>>.from(
        (jsonDecode(res.body) as Map<String, dynamic>)['value'] ?? []);
  }

  /// Up to [top] unread inbox messages.
  Future<List<Map<String, dynamic>>> fetchMailMessages({int top = 20}) async {
    final token = await _validToken();
    if (token == null) return [];

    final uri = Uri.parse(
      'https://graph.microsoft.com/v1.0/me/mailFolders/inbox/messages'
      '?\$top=$top'
      '&\$select=subject,from,receivedDateTime,isRead,bodyPreview'
      '&\$filter=isRead eq false'
      '&\$orderby=receivedDateTime desc',
    );

    final res = await http.get(uri,
        headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'});
    if (res.statusCode != 200) return [];
    return List<Map<String, dynamic>>.from(
        (jsonDecode(res.body) as Map<String, dynamic>)['value'] ?? []);
  }

  // ── Token management ───────────────────────────────────────────────────────

  Future<String?> _validToken() async {
    final stored = await _storage.read(key: _keyAccess);
    if (stored != null) return stored;

    final refresh = await _storage.read(key: _keyRefresh);
    if (refresh == null) return null;
    return (await _refreshToken(refresh)) ? _storage.read(key: _keyAccess) : null;
  }

  Future<bool> _exchangeCode(String code, String verifier) async {
    final res = await http.post(
      Uri.parse(_tokenBase),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'grant_type'   : 'authorization_code',
        'client_id'    : AppConfig.azureClientId,
        'code'         : code,
        'redirect_uri' : _redirectUri,
        'code_verifier': verifier,
        'scope'        : _scopes,
      },
    );
    return _saveTokens(res);
  }

  Future<bool> _refreshToken(String refresh) async {
    final res = await http.post(
      Uri.parse(_tokenBase),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'grant_type'   : 'refresh_token',
        'client_id'    : AppConfig.azureClientId,
        'refresh_token': refresh,
        'scope'        : _scopes,
      },
    );
    return _saveTokens(res);
  }

  Future<bool> _saveTokens(http.Response res) async {
    if (res.statusCode != 200) return false;
    final data    = jsonDecode(res.body) as Map<String, dynamic>;
    final access  = data['access_token']  as String?;
    final refresh = data['refresh_token'] as String?;
    if (access == null) return false;
    await _storage.write(key: _keyAccess, value: access);
    if (refresh != null) await _storage.write(key: _keyRefresh, value: refresh);
    return true;
  }

  // ── PKCE helpers ───────────────────────────────────────────────────────────

  static String _codeVerifier() => _randomString(64);

  static String _codeChallenge(String verifier) {
    final digest = sha256.convert(utf8.encode(verifier));
    return base64Url.encode(digest.bytes).replaceAll('=', '');
  }

  static String _randomString(int len) {
    const chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~';
    final rng = Random.secure();
    return List.generate(len, (_) => chars[rng.nextInt(chars.length)]).join();
  }
}

final microsoftServiceProvider = Provider<MicrosoftService>(
  (ref) => MicrosoftService(kSecureStorage),
);
