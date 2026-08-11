import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/app_config.dart';

class AuthService {
  AuthService(this._client);

  final SupabaseClient _client;

  /// OAuth/redirect target: on web, Supabase must redirect back to the page
  /// origin (the web client then consumes the auth tokens on load); on native
  /// it returns via the app's deep-link scheme. [path] is the native callback
  /// host (e.g. `login-callback`).
  String _redirect(String path) =>
      kIsWeb ? Uri.base.origin : '${AppConfig.deepLinkScheme}://$path/';

  User?   get currentUser => _client.auth.currentUser;
  bool    get isSignedIn  => _client.auth.currentUser != null;
  String? get userId      => _client.auth.currentUser?.id;
  String? get userEmail   => _client.auth.currentUser?.email;
  String? get displayName =>
      _client.auth.currentUser?.userMetadata?['full_name'] as String? ??
      _client.auth.currentUser?.userMetadata?['name']      as String? ??
      _client.auth.currentUser?.email?.split('@').first;

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  // ── Email / password ───────────────────────────────────────────────────────

  Future<void> signInWithEmail(String email, String password) =>
      _client.auth.signInWithPassword(email: email.trim(), password: password);

  Future<void> signUpWithEmail(String email, String password) =>
      _client.auth.signUp(email: email.trim(), password: password);

  Future<AuthResponse> signUpWithEmailResult(String email, String password) =>
      _client.auth.signUp(email: email.trim(), password: password);

  // ── Email OTP ──────────────────────────────────────────────────────────────

  Future<void> sendOtp(String email) =>
      _client.auth.signInWithOtp(email: email.trim());

  Future<void> verifyOtp(String email, String token) =>
      _client.auth.verifyOTP(
        email: email.trim(),
        token: token.trim(),
        type: OtpType.email,
      );

  // ── Google (browser-based PKCE via Supabase OAuth) ─────────────────────────

  Future<void> signInWithGoogle() async {
    await _client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: _redirect('login-callback'),
    );
  }

  // ── Apple (native Sign in with Apple → Supabase id-token) ─────────────────
  // Required by App Store Guideline 4.8 because the app offers Google login.
  // Uses the native Apple sheet (not a browser) and exchanges the returned
  // identity token with Supabase. A nonce binds the two: Apple signs the SHA-256
  // of the raw nonce into the token, and Supabase re-hashes the raw nonce we
  // pass to verify it — defeating token replay.

  static String _rawNonce([int length = 32]) {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-._';
    final rand = Random.secure();
    return List.generate(length, (_) => chars[rand.nextInt(chars.length)]).join();
  }

  Future<void> signInWithApple() async {
    final rawNonce    = _rawNonce();
    final hashedNonce = sha256.convert(utf8.encode(rawNonce)).toString();

    final credential = await SignInWithApple.getAppleIDCredential(
      scopes: const [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: hashedNonce,
    );

    final idToken = credential.identityToken;
    if (idToken == null) {
      throw const AuthException('No identity token returned from Apple.');
    }

    await _client.auth.signInWithIdToken(
      provider: OAuthProvider.apple,
      idToken: idToken,
      nonce: rawNonce,
    );

    // Apple only sends the full name on the FIRST authorization, and never in
    // the id-token — persist it to user metadata so the profile isn't blank.
    final given  = credential.givenName;
    final family = credential.familyName;
    if ((given != null && given.isNotEmpty) || (family != null && family.isNotEmpty)) {
      final full = [given, family].where((s) => s != null && s.isNotEmpty).join(' ').trim();
      if (full.isNotEmpty && (currentUser?.userMetadata?['full_name'] == null)) {
        await _client.auth.updateUser(UserAttributes(data: {'full_name': full}));
      }
    }
  }

  /// Native Sign in with Apple is only available on Apple platforms.
  bool get appleSignInSupported =>
      !kIsWeb && (defaultTargetPlatform == TargetPlatform.iOS ||
                  defaultTargetPlatform == TargetPlatform.macOS);

  // ── Microsoft (browser-based PKCE via Supabase OAuth) ─────────────────────

  Future<void> signInWithMicrosoft() async {
    await _client.auth.signInWithOAuth(
      OAuthProvider.azure,
      redirectTo: _redirect('login-callback'),
    );
  }

  // ── Sign out ──────────────────────────────────────────────────────────────

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  // ── Delete account ──────────────────────────────────────────────────────────

  /// Permanently deletes the signed-in user's account and all synced data.
  /// Calls the `delete-account` edge function (which deletes the auth user;
  /// every table cascades from auth.users), then clears the local session.
  /// Throws on failure so the UI can surface an error and keep the user signed in.
  Future<void> deleteAccount() async {
    final res = await _client.functions.invoke('delete-account');
    if (res.status != 200) {
      final msg = (res.data is Map && (res.data as Map)['error'] != null)
          ? (res.data as Map)['error'].toString()
          : 'status ${res.status}';
      throw Exception('Account deletion failed: $msg');
    }
    // The auth user is gone; clear the now-invalid local session.
    await _client.auth.signOut();
  }

  // ── Password reset ────────────────────────────────────────────────────────

  Future<void> resetPassword(String email) =>
      _client.auth.resetPasswordForEmail(
        email.trim(),
        redirectTo: _redirect('reset-callback'),
      );
}

final authServiceProvider = Provider<AuthService>(
  (ref) => AuthService(Supabase.instance.client),
);
