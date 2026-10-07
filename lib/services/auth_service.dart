import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
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

  /// [signInWithOAuth]'s Future resolves as soon as the browser/webview is
  /// launched, not when the user actually finishes (or abandons) the flow —
  /// the real outcome arrives later via the deep-link callback: a
  /// [AuthChangeEvent.signedIn] event on success, or a stream error on
  /// failure (supabase_flutter's deep-link handler calls `notifyException`
  /// for a failed `getSessionFromUrl`, e.g. cancelled/misconfigured/bad
  /// state). This waits for that real outcome so callers can safely navigate
  /// only once sign-in has actually completed. Mirrors the pattern already
  /// used in GoogleService._oauthViaSupabase.
  Future<void> _oauthSignInAndWait(
    Future<void> Function() launch, {
    Duration timeout = const Duration(minutes: 3),
  }) async {
    // Subscribe before launching so a fast callback can't be missed.
    final signedIn = authStateChanges
        .where((s) => s.event == AuthChangeEvent.signedIn)
        .first
        .timeout(timeout, onTimeout: () => throw const AuthException(
            'Sign-in timed out — please try again.'));
    await launch();
    await signedIn;
  }

  // ── Google ──────────────────────────────────────────────────────────────
  // Native sign-in sheet on iOS AND Android (matches Sign in with Apple's UX,
  // no browser hop); browser-based PKCE via Supabase OAuth everywhere else
  // (desktop/web). Both mobile platforms verify via Supabase's list-based
  // "Authorized Client IDs" field rather than its single shared Client
  // ID/Secret pair — that's what lets TaskEra's own Google Cloud project
  // coexist with Kaal's in one Supabase project without either stepping on
  // the other's OAuth consent-screen branding.

  bool get _isIOS     => !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;
  bool get _isAndroid => !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  Future<void> signInWithGoogle() => (_isIOS || _isAndroid)
      ? _signInWithGoogleNative()
      : _signInWithGoogleBrowser();

  Future<void> _signInWithGoogleNative() async {
    final googleSignIn = GoogleSignIn(
      // iOS needs its own client id explicitly; Android resolves its client
      // implicitly from the app's package name + signing cert registered in
      // Cloud Console, and instead needs serverClientId (a Web client) so
      // the id token it returns carries a verifiable, server-checkable
      // audience — without it Android's token audience wouldn't match
      // anything in Supabase's Authorized Client IDs list.
      clientId: _isIOS ? AppConfig.googleClientIdIos : null,
      serverClientId: _isAndroid ? AppConfig.googleClientIdWeb : null,
      scopes: const ['email'],
    );
    final account = await googleSignIn.signIn();
    if (account == null) throw const AuthException('Sign-in cancelled.');
    final auth = await account.authentication;
    final idToken = auth.idToken;
    if (idToken == null) {
      throw const AuthException('No identity token returned from Google.');
    }
    await _client.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: auth.accessToken,
    );
  }

  Future<void> _signInWithGoogleBrowser() => _oauthSignInAndWait(() async {
        await _client.auth.signInWithOAuth(
          OAuthProvider.google,
          redirectTo: _redirect('login-callback'),
        );
      });

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

  Future<void> signInWithMicrosoft() => _oauthSignInAndWait(() async {
        await _client.auth.signInWithOAuth(
          OAuthProvider.azure,
          redirectTo: _redirect('login-callback'),
        );
      });

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
