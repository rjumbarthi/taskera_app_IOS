import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../config/app_config.dart';
import '../../l10n/app_l10n.dart';
import '../../routing/routes.dart';
import '../../services/auth_service.dart';
import '../../theme/kaal_colors.dart';
import '../../theme/kaal_theme.dart';
import '../../util/platform_layout.dart';
import '../../widgets/wallpaper_background.dart';

// Screen: p-signup — Create Account

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _email    = TextEditingController();
  final _password = TextEditingController();
  final _confirm  = TextEditingController();
  final _otp      = TextEditingController();
  bool _otpMode             = false;
  bool _loading             = false;
  bool _confirmationPending = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    _otp.dispose();
    super.dispose();
  }

  AuthService get _auth => ref.read(authServiceProvider);

  bool get _backendConfigured =>
      !AppConfig.supabaseUrl.contains('YOUR_PROJECT_REF') &&
      !AppConfig.supabaseAnonKey.contains('YOUR_SUPABASE');

  Future<void> _run(Future<void> Function() fn, {String? successRoute}) async {
    if (!_backendConfigured) {
      if (mounted) context.go(successRoute ?? KaalRoutes.onboard);
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      await fn();
      if (mounted && successRoute != null) context.go(successRoute);
    } catch (e) {
      if (mounted) setState(() => _error = _friendlyError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _createAccount() async {
    if (_password.text != _confirm.text) {
      setState(() => _error = 'Passwords do not match');
      return;
    }
    if (!_backendConfigured) {
      if (mounted) context.go(KaalRoutes.onboard);
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      final res = await _auth.signUpWithEmailResult(_email.text, _password.text);
      if (!mounted) return;
      if (res.session != null) {
        context.go(KaalRoutes.onboard);
      } else {
        setState(() { _loading = false; _confirmationPending = true; });
      }
    } catch (e) {
      if (mounted) setState(() { _error = _friendlyError(e); _loading = false; });
    }
  }

  Future<void> _sendOtp() async {
    if (!_backendConfigured) {
      if (mounted) context.go(KaalRoutes.onboard);
      return;
    }
    if (_email.text.trim().isEmpty) {
      setState(() => _error = 'Enter your email first');
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      await _auth.sendOtp(_email.text);
      if (mounted) setState(() { _otpMode = true; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = _friendlyError(e); _loading = false; });
    }
  }

  Future<void> _verifyAndCreate() => _run(
    () => _auth.verifyOtp(_email.text, _otp.text),
    successRoute: KaalRoutes.onboard,
  );

  Future<void> _resendOtp() => _run(() => _auth.sendOtp(_email.text));

  Future<void> _googleSignUp() => _run(
    () => _auth.signInWithGoogle(),
    successRoute: KaalRoutes.onboard,
  );

  Future<void> _microsoftSignUp() => _run(
    () => _auth.signInWithMicrosoft(),
  );

  static String _friendlyError(Object e) {
    final msg = e.toString().toLowerCase();
    if (msg.contains('already registered') || msg.contains('already exists')) {
      return 'An account with this email already exists';
    }
    if (msg.contains('weak password')) return 'Password is too weak (min 6 chars)';
    if (msg.contains('invalid email')) return 'Invalid email address';
    if (msg.contains('cancelled')) return 'Sign-up cancelled';
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
    final colors = KaalTheme.of(context).colors;

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
                          'assets/logo/kaal_logo.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                      Text(
                        'Kaal',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Fraunces',
                          fontVariations: const [FontVariation('wght', 500)],
                          fontSize: 26,
                          color: colors.ink,
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Create your account',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          color: colors.ink2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // ── EMAIL ─────────────────────────────────────────────────
                  _Flbl('EMAIL', colors),
                  _FinputField(
                    controller: _email,
                    hint: AppL10n.of(context).emailHint,
                    isPassword: false,
                    keyboardType: TextInputType.emailAddress,
                    colors: colors,
                  ),
                  const SizedBox(height: 10),

                  // ── PASSWORD / OTP ────────────────────────────────────────
                  if (_otpMode) ...[
                    _Flbl('ONE-TIME PASSWORD', colors),
                    _FinputField(
                      controller: _otp,
                      hint: AppL10n.of(context).otpHint,
                      isPassword: false,
                      keyboardType: TextInputType.number,
                      colors: colors,
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: _resendOtp,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            child: const Text(
                              'Resend OTP',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 12,
                                color: KaalColors.acc,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    _Flbl('PASSWORD', colors),
                    _FinputField(
                      controller: _password,
                      hint: '••••••••',
                      isPassword: true,
                      colors: colors,
                    ),
                    const SizedBox(height: 10),
                    _Flbl('CONFIRM PASSWORD', colors),
                    _FinputField(
                      controller: _confirm,
                      hint: '••••••••',
                      isPassword: true,
                      colors: colors,
                    ),
                    const SizedBox(height: 3),
                    // Already have account link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () => context.go(KaalRoutes.signin),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Have an account? ',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 12,
                                    color: colors.ink2,
                                  ),
                                ),
                                const Text(
                                  'Sign in',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 12,
                                    color: KaalColors.acc,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 10),

                  // ── Error message ─────────────────────────────────────────
                  if (_error != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      _error!,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: Color(0xFFFF453A),
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],

                  // ── Primary action button(s) ──────────────────────────────
                  if (_confirmationPending) ...[
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0x127FBA00),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(width: 0.5, color: const Color(0x337FBA00)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('✓ Account created!',
                            style: TextStyle(fontFamily: 'Inter', fontSize: 14,
                                fontWeight: FontWeight.w700, color: colors.successFg)),
                          const SizedBox(height: 4),
                          Text(
                            'Check your email to verify your account. Once confirmed, sign in with your credentials.',
                            style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: colors.ink2),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () => context.go(KaalRoutes.signin),
                      child: Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(vertical: 11),
                        decoration: BoxDecoration(
                          color: KaalColors.acc,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text('Go to Sign In',
                          style: TextStyle(fontFamily: 'Inter', fontSize: 14,
                              fontWeight: FontWeight.w600, color: Colors.white)),
                      ),
                    ),
                  ] else if (_otpMode)
                    Opacity(
                      opacity: (_otp.text.isNotEmpty && !_loading) ? 1.0 : 0.4,
                      child: GestureDetector(
                      onTap: (_otp.text.isNotEmpty && !_loading) ? _verifyAndCreate : null,
                      child: Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(vertical: 11),
                        decoration: BoxDecoration(
                          color: KaalColors.acc,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: _loading
                            ? const SizedBox(width: 16, height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Text(
                                'Verify & Create Account',
                                style: TextStyle(fontFamily: 'Inter', fontSize: 14,
                                    fontWeight: FontWeight.w600, color: Colors.white),
                              ),
                      ),
                    ),
                  )
                  else
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: _loading ? null : _createAccount,
                            child: Container(
                              alignment: Alignment.center,
                              padding: const EdgeInsets.symmetric(vertical: 11),
                              decoration: BoxDecoration(
                                color: KaalColors.acc,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: _loading
                                  ? const SizedBox(width: 16, height: 16,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                  : const Text(
                                      'Create Account',
                                      style: TextStyle(fontFamily: 'Inter', fontSize: 14,
                                          fontWeight: FontWeight.w600, color: Colors.white),
                                    ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: GestureDetector(
                            onTap: _loading ? null : _sendOtp,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 11,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  width: 1.5,
                                  color: KaalColors.acc.withValues(alpha: 0.5),
                                ),
                              ),
                              child: const FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  'Sign up with email OTP',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: KaalColors.acc,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 12),

                  // ── "or continue with" ────────────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: Container(height: 0.5, color: colors.bdr),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'or continue with',
                          style: TextStyle(
                            fontFamily: 'Inter',
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
                  const SizedBox(height: 10),

                  // ── Google | Apple ────────────────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: _SocialBtn(
                          label: 'Google',
                          icon: SvgPicture.string(_kGoogleSvg, width: 18, height: 18),
                          colors: colors,
                          onTap: _loading
                              ? null
                              : isDesktop
                                  ? () => setState(() =>
                                      _error = 'Google sign-in is only available on the mobile app')
                                  : _googleSignUp,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: _SocialBtn(
                          label: 'Apple',
                          icon: SvgPicture.string(_appleSvg(colors.ink), width: 18, height: 18),
                          colors: colors,
                          onTap: null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),

                  // ── Microsoft (full width) ────────────────────────────────
                  _SocialBtn(
                    label: 'Microsoft',
                    icon: SvgPicture.string(_kMicrosoftSvg, width: 18, height: 18),
                    colors: colors,
                    onTap: _loading ? null : _microsoftSignUp,
                  ),
                  const SizedBox(height: 10),

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
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text.rich(
                            TextSpan(
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 11,
                                color: colors.ink2,
                                height: 1.5,
                              ),
                              children: const [
                                TextSpan(text: 'Your data saves '),
                                TextSpan(
                                  text: 'locally on this device',
                                  style: TextStyle(color: KaalColors.acc),
                                ),
                                TextSpan(text: '. Create an account for cloud sync across devices.'),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // ── Terms · Privacy ───────────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'By signing up you agree to our ',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          color: colors.ink3,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => context.push(KaalRoutes.legal),
                        child: const Text(
                          'Terms',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 11,
                            color: KaalColors.acc,
                          ),
                        ),
                      ),
                      Text(
                        ' · ',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          color: colors.ink3,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => context.push(KaalRoutes.legal),
                        child: const Text(
                          'Privacy',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 11,
                            color: KaalColors.acc,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // ── Back to sign in ───────────────────────────────────────
                  Center(
                    child: GestureDetector(
                      onTap: () => context.go(KaalRoutes.signin),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Text(
                          '← Back to sign in',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            color: colors.ink2,
                          ),
                        ),
                      ),
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
  final KaalColors colors;
  const _Flbl(this.label, this.colors);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Inter',
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
  final KaalColors colors;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  const _FinputField({
    required this.controller,
    required this.hint,
    required this.isPassword,
    required this.colors,
    this.keyboardType,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: keyboardType,
      onChanged: onChanged,
      style: TextStyle(fontFamily: 'Inter', fontSize: 14, color: colors.ink),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          fontFamily: 'Inter',
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
          borderSide: const BorderSide(color: KaalColors.acc, width: 1),
        ),
      ),
    );
  }
}

class _SocialBtn extends StatelessWidget {
  final String label;
  final Widget icon;
  final KaalColors colors;
  final VoidCallback? onTap;
  const _SocialBtn({
    required this.label,
    required this.icon,
    required this.colors,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: onTap == null ? 0.38 : 1.0,
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
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Inter',
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
