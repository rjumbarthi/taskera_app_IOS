import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../config/app_config.dart';
import '../../l10n/app_l10n.dart';
import '../../routing/routes.dart';
import '../../services/auth_service.dart';
import 'otp_cooldown.dart';
import '../../settings/app_launch_prefs.dart';
import '../../settings/prefs_provider.dart';
import '../../data/providers/feature_flags_provider.dart';
import '../../theme/taskera_colors.dart';
import '../../theme/taskera_theme.dart';
import '../../util/platform_layout.dart';
import '../../widgets/wallpaper_background.dart';

// Screen: p-signin — Sign In (01-02)

class SigninScreen extends ConsumerStatefulWidget {
  const SigninScreen({super.key});

  @override
  ConsumerState<SigninScreen> createState() => _SigninScreenState();
}

class _SigninScreenState extends ConsumerState<SigninScreen>
    with OtpCooldownMixin {
  final _email    = TextEditingController();
  final _password = TextEditingController();
  final _otp      = TextEditingController();
  bool _otpMode   = false;
  bool _loading   = false;
  bool _accepted  = false; // Terms of Service + Privacy Policy consent
  String? _error;

  /// Blocks any sign-in path until the user has accepted the legal terms.
  bool _consentOk() {
    if (_accepted) return true;
    setState(() => _error =
        'Please accept the Terms of Service and Privacy Policy to continue.');
    return false;
  }

  @override
  void initState() {
    super.initState();
    // On web, OAuth is a full-page redirect: if it fails (cancelled, provider
    // not configured, callback error), Supabase sends the browser back with the
    // error encoded in the URL. Surface it instead of failing silently.
    if (isWeb) _checkOAuthReturnError();
  }

  void _checkOAuthReturnError() {
    final uri = Uri.base;
    final params = <String, String>{
      ...uri.queryParameters,
      if (uri.fragment.isNotEmpty) ...Uri.splitQueryString(uri.fragment),
    };
    final raw = params['error_description'] ?? params['error'];
    if (raw == null || raw.isEmpty) return;
    final decoded = raw.replaceAll('+', ' ');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _error = _friendlyError(decoded));
    });
  }

  @override
  void dispose() {
    disposeOtpCooldown();
    _email.dispose();
    _password.dispose();
    _otp.dispose();
    super.dispose();
  }

  AuthService get _auth => ref.read(authServiceProvider);

  // After auth: send first-run users through onboarding, else straight to Focus.
  String get _postAuthRoute =>
      AppLaunchPrefs.onboardingDone(ref.read(sharedPreferencesProvider))
          ? TaskEraRoutes.focus
          : TaskEraRoutes.onboard;

  static final _emailRe = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  bool get _emailValid => _emailRe.hasMatch(_email.text.trim());
  bool get _emailTouched => _email.text.isNotEmpty;

  bool get _backendConfigured =>
      !AppConfig.supabaseUrl.contains('YOUR_PROJECT_REF') &&
      !AppConfig.supabaseAnonKey.contains('YOUR_SUPABASE');

  Future<void> _run(Future<void> Function() fn, {String? successRoute}) async {
    if (!_backendConfigured) {
      if (mounted) context.go(TaskEraRoutes.focus);
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      await fn();
      if (mounted && successRoute != null) {
        // Any real sign-in means the user is no longer local-only — the
        // mandatory-paywall gate must stop applying regardless of how
        // skipAuth got set previously (e.g. an earlier "Skip" tap).
        AppLaunchPrefs.clearSkipAuth(ref.read(sharedPreferencesProvider));
        context.go(successRoute);
      }
    } catch (e) {
      if (mounted) setState(() => _error = _friendlyError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _signIn() async {
    if (!_consentOk()) return;
    return _run(
      () => _auth.signInWithEmail(_email.text, _password.text),
      successRoute: _postAuthRoute,
    );
  }

  Future<void> _signInOtp() async {
    if (!_consentOk()) return;
    return _run(
      () => _auth.verifyOtp(_email.text, _otp.text),
      successRoute: _postAuthRoute,
    );
  }

  Future<void> _sendOtp() async {
    if (!_consentOk()) return;
    if (!_backendConfigured) {
      if (mounted) context.go(TaskEraRoutes.focus);
      return;
    }
    if (_email.text.trim().isEmpty) {
      setState(() => _error = 'Enter your email first');
      return;
    }
    if (otpOnCooldown) return;
    setState(() { _loading = true; _error = null; });
    try {
      await _auth.sendOtp(_email.text);
      if (mounted) {
        setState(() { _otpMode = true; _loading = false; });
        startOtpCooldown();
      }
    } catch (e) {
      if (mounted) setState(() { _error = _friendlyError(e); _loading = false; });
    }
  }

  Future<void> _resendOtp() async {
    if (otpOnCooldown) return;
    await _run(() => _auth.sendOtp(_email.text));
    if (mounted) startOtpCooldown();
  }

  Future<void> _forgotPassword() async {
    if (!_emailValid) {
      setState(() => _error = 'Enter your email address first');
      return;
    }
    return _run(() => _auth.resetPassword(_email.text));
  }

  Future<void> _googleSignIn() async {
    if (!_consentOk()) return;
    return _run(
      () => _auth.signInWithGoogle(),
      successRoute: _postAuthRoute,
    );
  }

  Future<void> _microsoftSignIn() async {
    if (!_consentOk()) return;
    return _run(
      () => _auth.signInWithMicrosoft(),
      successRoute: _postAuthRoute,
    );
  }

  Future<void> _appleSignIn() async {
    if (!_consentOk()) return;
    return _run(
      () => _auth.signInWithApple(),
      successRoute: _postAuthRoute,
    );
  }

  static String _friendlyError(Object e) {
    final msg = e.toString().toLowerCase();
    if (msg.contains('invalid login') || msg.contains('invalid credentials')) {
      return 'Wrong email or password';
    }
    if (msg.contains('email not confirmed')) return 'Please confirm your email first';
    // ── OAuth-specific (Google / Microsoft via Supabase) ──────────────────────
    if (msg.contains('access_denied') ||
        msg.contains('cancelled') ||
        msg.contains('canceled')) {
      return 'Sign-in cancelled';
    }
    if (msg.contains('provider is not enabled') ||
        msg.contains('provider_disabled') ||
        msg.contains('unsupported provider') ||
        msg.contains('validation_failed')) {
      return 'Google sign-in isn\'t set up yet. Use email, or tap "Skip — use local storage".';
    }
    if (msg.contains('redirect') &&
        (msg.contains('mismatch') || msg.contains('not allowed') || msg.contains('invalid'))) {
      return 'Sign-in redirect not allowed — this site must be whitelisted in Supabase → Auth → URL Configuration.';
    }
    if (msg.contains('bad_oauth_state') || msg.contains('flow_state')) {
      return 'Sign-in session expired — please try again.';
    }
    if (msg.contains('timed out')) {
      return 'Sign-in timed out — please try again.';
    }
    if (msg.contains('server_error') ||
        msg.contains('unable to exchange') ||
        msg.contains('oauth')) {
      return 'Google sign-in failed. Check the provider setup and try again.';
    }
    if (msg.contains('no such host') || msg.contains('your_project_ref') ||
        msg.contains('socketfailed')) {
      return 'Backend not configured — fill in lib/config/app_config.dart (see SETUP.md)';
    }
    if (msg.contains('network') || msg.contains('socketexception')) {
      return 'No internet connection';
    }
    if (msg.contains('android and ios') || msg.contains('mobile')) {
      return 'Google sign-in is only available on Android and iOS';
    }
    return e.toString().replaceAll('Exception: ', '');
  }

  @override
  Widget build(BuildContext context) {
    final colors = TaskEraTheme.of(context).colors;
    final microsoftEnabled = ref.watch(microsoftSignInEnabledProvider);

    return Stack(
      children: [
        const Positioned.fill(child: WallpaperBackground()),
        Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            top: true,
            bottom: true,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 22, 18, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Header ────────────────────────────────────────────────
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: const BoxDecoration(shape: BoxShape.circle),
                        clipBehavior: Clip.antiAlias,
                        child: Image.asset(
                          'assets/logo/taskera_icon_glass.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                      Text(
                        'TaskEra',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: TaskEraTheme.of(context).type.numberFontFamily,
                          fontVariations: const [FontVariation('wght', 500)],
                          fontSize: 26,
                          color: colors.ink,
                          height: 1,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Focus & Task Planner',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: TaskEraTheme.of(context).fontFamily,
                          fontSize: 12,
                          color: colors.ink2,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 14),

                  // ── EMAIL ─────────────────────────────────────────────────
                  _Flbl('EMAIL', colors),
                  _FinputField(
                    controller: _email,
                    hint: AppL10n.of(context).emailHint,
                    isPassword: false,
                    colors: colors,
                    readOnly: _otpMode,
                    onChanged: _otpMode ? null : (_) => setState(() {}),
                  ),
                  if (_emailTouched && !_emailValid) ...[
                    SizedBox(height: 4),
                    Text(
                      'Enter a valid email address',
                      style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 12, color: Color(0xFFFF453A)),
                    ),
                  ],
                  SizedBox(height: 10),

                  // ── PASSWORD / OTP ────────────────────────────────────────
                  _Flbl(_otpMode ? 'ONE-TIME PASSWORD' : 'PASSWORD', colors),
                  _otpMode
                      ? _FinputField(
                          controller: _otp,
                          hint: AppL10n.of(context).otpHint,
                          isPassword: false,
                          keyboardType: TextInputType.number,
                          colors: colors,
                          onChanged: (_) => setState(() {}),
                        )
                      : _FinputField(
                          controller: _password,
                          hint: '••••••••',
                          isPassword: true,
                          colors: colors,
                          onChanged: (_) => setState(() {}),
                        ),
                  SizedBox(height: 3),

                  // ── Forgot password (left) | New here? (right) ────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: _otpMode
                            ? (otpOnCooldown ? null : _resendOtp)
                            : _forgotPassword,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: Text(
                            _otpMode ? resendLabel() : 'Forgot password?',
                            style: TextStyle(
                              fontFamily: TaskEraTheme.of(context).fontFamily,
                              fontSize: 12,
                              color: (_otpMode && otpOnCooldown)
                                  ? TaskEraColors.acc.withAlpha(0x80)
                                  : TaskEraColors.acc,
                            ),
                          ),
                        ),
                      ),
                      if (!_otpMode)
                        GestureDetector(
                          onTap: () => context.go(TaskEraRoutes.signup),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'New here? ',
                                  style: TextStyle(
                                    fontFamily: TaskEraTheme.of(context).fontFamily,
                                    fontSize: 12,
                                    color: colors.ink2,
                                  ),
                                ),
                                Text(
                                  'Create account',
                                  style: TextStyle(
                                    fontFamily: TaskEraTheme.of(context).fontFamily,
                                    fontSize: 12,
                                    color: TaskEraColors.acc,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 10),

                  // ── Sign in | Email OTP  (two-col) or OTP-only (full) ─────
                  // ── Error message ─────────────────────────────────────────
                  if (_error != null) ...[
                    SizedBox(height: 4),
                    Text(
                      _error!,
                      style: TextStyle(
                        fontFamily: TaskEraTheme.of(context).fontFamily,
                        fontSize: 12,
                        color: Color(0xFFFF453A),
                      ),
                    ),
                    SizedBox(height: 4),
                  ],

                  if (_otpMode) ...[
                    SizedBox(height: 4),
                    Text(
                      'Check your email — enter the 6-digit code or click the sign-in link',
                      style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 12, color: colors.ink3),
                    ),
                    SizedBox(height: 4),
                  ],
                  if (_otpMode)
                    Opacity(
                      opacity: (_emailValid && _otp.text.isNotEmpty && !_loading) ? 1.0 : 0.4,
                      child: GestureDetector(
                        onTap: (_emailValid && _otp.text.isNotEmpty && !_loading) ? _signInOtp : null,
                        child: Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          decoration: BoxDecoration(
                            color: TaskEraColors.acc,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: _loading
                              ? SizedBox(width: 16, height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : Text(
                                  'Sign in with email OTP',
                                  style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 14,
                                      fontWeight: FontWeight.w600, color: Colors.white),
                                ),
                        ),
                      ),
                    )
                  else
                    Row(
                      children: [
                        Expanded(
                          child: Opacity(
                            opacity: (_emailValid && _password.text.isNotEmpty && !_loading) ? 1.0 : 0.4,
                            child: GestureDetector(
                              onTap: (_emailValid && _password.text.isNotEmpty && !_loading) ? _signIn : null,
                              child: Container(
                                alignment: Alignment.center,
                                padding: const EdgeInsets.symmetric(vertical: 11),
                                decoration: BoxDecoration(
                                  color: TaskEraColors.acc,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: _loading
                                    ? SizedBox(width: 16, height: 16,
                                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                    : Text(
                                        'Sign in',
                                        style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 14,
                                            fontWeight: FontWeight.w600, color: Colors.white),
                                      ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Opacity(
                            opacity: (_emailValid && !_loading) ? 1.0 : 0.4,
                            child: GestureDetector(
                              onTap: (_emailValid && !_loading) ? _sendOtp : null,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 11),
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    width: 1.5,
                                    color: TaskEraColors.acc.withValues(alpha: 0.5),
                                  ),
                                ),
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    'Sign in with email OTP',
                                    style: TextStyle(
                                      fontFamily: TaskEraTheme.of(context).fontFamily,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: TaskEraColors.acc,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  SizedBox(height: 12),

                  // ── "or continue with" ────────────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: Container(height: 0.5, color: colors.bdr),
                      ),
                      Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'or continue with',
                          style: TextStyle(
                            fontFamily: TaskEraTheme.of(context).fontFamily,
                            fontSize: 11,
                            color: colors.ink3,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(height: 0.5, color: colors.bdr),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),

                  // ── Google | Apple (same row) ─────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: _SocialBtn(
                          label: 'Google',
                          icon: SvgPicture.string(_kGoogleSvg, width: 18, height: 18),
                          colors: colors,
                          // Browser-OAuth can't return to a desktop app via the
                          // deep-link scheme — guide desktop users to the mobile app.
                          onTap: _loading
                              ? null
                              : isDesktop
                                  ? () => setState(() => _error =
                                      'Google sign-in is only available on the mobile app')
                                  : _googleSignIn,
                        ),
                      ),
                      SizedBox(width: 6),
                      Expanded(
                        child: _SocialBtn(
                          label: 'Apple',
                          icon: SvgPicture.string(_appleSvg(colors.ink), width: 18, height: 18),
                          colors: colors,
                          // Native Sign in with Apple is Apple-platforms only.
                          comingSoon: !_auth.appleSignInSupported,
                          onTap: _loading
                              ? null
                              : _auth.appleSignInSupported
                                  ? _appleSignIn
                                  : () => _comingSoon(context, 'Apple sign-in'),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 5),

                  // ── Microsoft | Skip (same row) ───────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: _SocialBtn(
                          label: 'Microsoft',
                          icon: SvgPicture.string(_kMicrosoftSvg, width: 18, height: 18),
                          colors: colors,
                          comingSoon: !microsoftEnabled,
                          onTap: microsoftEnabled
                              ? _microsoftSignIn
                              : () => _comingSoon(context, 'Microsoft sign-in'),
                        ),
                      ),
                      SizedBox(width: 6),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            if (!_consentOk()) return;
                            final prefs = ref.read(sharedPreferencesProvider);
                            AppLaunchPrefs.markSkipAuth(prefs);
                            // Local-storage users run through onboarding too; the
                            // mandatory Pro upsell is shown right after it.
                            context.go(TaskEraRoutes.onboard);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 11,
                            ),
                            decoration: BoxDecoration(
                              color: colors.surf,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                width: 0.5,
                                color: colors.bdr,
                              ),
                            ),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                'Skip — use local storage',
                                style: TextStyle(
                                  fontFamily: TaskEraTheme.of(context).fontFamily,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: colors.ink2,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),

                  // ── Info card ─────────────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: colors.surf,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(width: 0.5, color: colors.bdr),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SvgPicture.string(_kLockSvg, width: 18, height: 18),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text.rich(
                            TextSpan(
                              style: TextStyle(
                                fontFamily: TaskEraTheme.of(context).fontFamily,
                                fontSize: 11,
                                color: colors.ink2,
                                height: 1.5,
                              ),
                              children: const [
                                TextSpan(text: 'Tasks save '),
                                TextSpan(
                                  text: 'locally on this device',
                                  style: TextStyle(color: TaskEraColors.acc),
                                ),
                                TextSpan(text: '. Sign in for free cloud sync. '),
                                TextSpan(
                                  text: 'Skip (local storage) requires a TaskEra Pro subscription.',
                                  style: TextStyle(color: TaskEraColors.acc2, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 8),

                  // ── Terms & Privacy — required consent checkbox ───────────
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => setState(() { _accepted = !_accepted; if (_accepted) _error = null; }),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 18, height: 18,
                          margin: const EdgeInsets.only(top: 1),
                          decoration: BoxDecoration(
                            color: _accepted ? TaskEraColors.acc : Colors.transparent,
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(width: 1.2, color: _accepted ? TaskEraColors.acc : colors.ink3),
                          ),
                          child: _accepted ? Icon(Icons.check_rounded, size: 13, color: Colors.white) : null,
                        ),
                        SizedBox(width: 9),
                        Expanded(
                          child: Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text('I agree to the ',
                                  style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 11, color: colors.ink2, height: 1.45)),
                              GestureDetector(
                                onTap: () => context.push(TaskEraRoutes.legal),
                                child: Text('Terms of Service',
                                    style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 11, fontWeight: FontWeight.w600, color: TaskEraColors.acc, height: 1.45)),
                              ),
                              Text(' and ',
                                  style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 11, color: colors.ink2, height: 1.45)),
                              GestureDetector(
                                onTap: () => context.push('${TaskEraRoutes.legal}?tab=privacy'),
                                child: Text('Privacy Policy',
                                    style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 11, fontWeight: FontWeight.w600, color: TaskEraColors.acc, height: 1.45)),
                              ),
                              Text('.',
                                  style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 11, color: colors.ink2, height: 1.45)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Private widgets ───────────────────────────────────────────────────────────

class _Flbl extends StatelessWidget {
  final String label;
  final TaskEraColors colors;
  const _Flbl(this.label, this.colors);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: TaskEraTheme.of(context).fontFamily,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
          color: colors.ink3,
        ),
      ),
    );
  }
}

class _FinputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool isPassword;
  final TaskEraColors colors;
  final TextInputType? keyboardType;
  final bool readOnly;
  final ValueChanged<String>? onChanged;
  const _FinputField({
    required this.controller,
    required this.hint,
    required this.isPassword,
    required this.colors,
    this.keyboardType,
    this.readOnly = false,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: keyboardType,
      readOnly: readOnly,
      onChanged: onChanged,
      style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 14, color: colors.ink),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          fontFamily: TaskEraTheme.of(context).fontFamily,
          fontSize: 14,
          color: colors.ink3,
        ),
        filled: true,
        fillColor: colors.surf,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 11,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.bdr, width: 0.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.bdr, width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: TaskEraColors.acc, width: 1),
        ),
      ),
    );
  }
}

// Social button — used both standalone (full width) and inside Row (Expanded).
// Floating "coming soon" toast — used for providers that aren't wired yet.
void _comingSoon(BuildContext context, String what) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text('$what — coming soon',
        style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 13, color: Colors.white)),
    backgroundColor: const Color(0xFF1C1C1E),
    behavior: SnackBarBehavior.floating,
    duration: const Duration(seconds: 2),
  ));
}

class _SocialBtn extends StatelessWidget {
  final String label;
  final Widget icon;
  final TaskEraColors colors;
  final VoidCallback? onTap;
  final bool comingSoon; // dim like a disabled button but still tappable for the toast
  const _SocialBtn({
    required this.label,
    required this.icon,
    required this.colors,
    this.onTap,
    this.comingSoon = false,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: (onTap == null || comingSoon) ? 0.4 : 1.0,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            color: colors.surf,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(width: 0.5, color: colors.bdr),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(width: 18, height: 18, child: icon),
              SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontFamily: TaskEraTheme.of(context).fontFamily,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: colors.ink,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── SVG assets ────────────────────────────────────────────────────────────────

const _kGoogleSvg = '''
<svg width="18" height="18" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
  <path fill="#4285F4" d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"/>
  <path fill="#34A853" d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"/>
  <path fill="#FBBC05" d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z"/>
  <path fill="#EA4335" d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z"/>
</svg>
''';

const _kMicrosoftSvg = '''
<svg width="18" height="18" viewBox="0 0 21 21" xmlns="http://www.w3.org/2000/svg">
  <rect x="1" y="1" width="9" height="9" fill="#f25022"/>
  <rect x="11" y="1" width="9" height="9" fill="#7fba00"/>
  <rect x="1" y="11" width="9" height="9" fill="#00a4ef"/>
  <rect x="11" y="11" width="9" height="9" fill="#ffb900"/>
</svg>
''';

String _appleSvg(Color color) {
  final hex =
      '#${color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
  return '''
<svg width="18" height="18" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
  <path fill="$hex" d="M18.71 19.5c-.83 1.24-1.71 2.45-3.05 2.47-1.34.03-1.77-.79-3.29-.79-1.53 0-2 .77-3.27.82-1.31.05-2.3-1.32-3.14-2.53C4.25 17 2.94 12.45 4.7 9.39c.87-1.52 2.43-2.48 4.12-2.51 1.28-.02 2.5.87 3.29.87.78 0 2.26-1.07 3.8-.91.65.03 2.47.26 3.64 1.98-.09.06-2.17 1.28-2.15 3.81.03 3.02 2.65 4.03 2.68 4.04-.03.07-.42 1.44-1.38 2.83M13 3.5c.73-.83 1.94-1.46 2.94-1.5.13 1.17-.34 2.35-1.04 3.19-.69.85-1.83 1.51-2.95 1.42-.15-1.15.41-2.35 1.05-3.11z"/>
</svg>
''';
}

const _kLockSvg = '''
<svg width="18" height="18" viewBox="0 0 22 22" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="2" y="11" width="18" height="9" rx="2" stroke="#0A84FF" stroke-width="1.6" stroke-linecap="round"/>
  <path d="M6 11V7a5 5 0 0 1 10 0v4" stroke="#0A84FF" stroke-width="1.6" stroke-linecap="round"/>
  <circle cx="11" cy="15.5" r="1" fill="#0A84FF"/>
</svg>
''';
