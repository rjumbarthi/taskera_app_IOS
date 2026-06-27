import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
