import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../routing/routes.dart';
import '../../settings/app_launch_prefs.dart';
import '../../settings/taskera_settings.dart';
import '../../settings/prefs_provider.dart';
import '../../theme/taskera_colors.dart';

// Screen: p-quote — Quote Splash
//
// Full-screen black (overrides the wallpaper — this is the only screen that does).
// Tap anywhere or wait 3.2 s to advance to the correct next screen.
// Progress bar animates linearly over 3.2 s.

class QuoteSplashScreen extends ConsumerStatefulWidget {
  const QuoteSplashScreen({super.key});

  @override
  ConsumerState<QuoteSplashScreen> createState() => _QuoteSplashScreenState();
}

class _QuoteSplashScreenState extends ConsumerState<QuoteSplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _progress;

  @override
  void initState() {
    super.initState();
    _progress = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    );

    final showSplash = ref.read(taskeraSettingsProvider).sw('quoteSplash');
    if (!showSplash) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _advance();
      });
    } else {
      _progress.forward();
      _progress.addStatusListener((status) {
        if (status == AnimationStatus.completed && mounted) {
          _advance();
        }
      });
    }
  }

  @override
  void dispose() {
    _progress.dispose();
    super.dispose();
  }

  void _advance() {
    if (!mounted) return;
    final prefs = ref.read(sharedPreferencesProvider);
    final isSignedIn = Supabase.instance.client.auth.currentUser != null;
    // Flow: splash → sign in → onboarding → focus. Unauthenticated users sign in
    // FIRST; onboarding runs only after they're authenticated (or chose skip).
    if (!(AppLaunchPrefs.skipAuth(prefs) || isSignedIn)) {
      context.go(TaskEraRoutes.signin);
      return;
    }
    if (!AppLaunchPrefs.onboardingDone(prefs)) {
      context.go(TaskEraRoutes.onboard);
      return;
    }
    // End-of-day reflection is NEVER shown on app open — it appears only when
    // the user exits the app (double-back) after their chosen EOD time. See the
    // exit handler in app_router.dart (_RouterShell).
    context.go(TaskEraRoutes.focus);
  }

  void _skip() => _advance();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _skip,
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Center(
          child: SingleChildScrollView(
          child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ── Logo ───────────────────────────────────────────────────
              Container(
                width: 72,
                height: 72,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: const BoxDecoration(shape: BoxShape.circle),
                clipBehavior: Clip.antiAlias,
                child: Image.asset(
                  'assets/logo/taskera_logo.png',
                  fit: BoxFit.cover,
                ),
              ),

              // ── "TaskEra" wordmark ────────────────────────────────────────
              Text(
                'TaskEra',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Fraunces',
                  fontVariations: const [FontVariation('wght', 500)],
                  fontSize: 19,
                  color: const Color(0xE0FFFFFF), // rgba(255,255,255,.88)
                  height: 1,
                ),
              ),
              const SizedBox(height: 2),

              // ── "FOCUS & TASK PLANNER" ─────────────────────────────────
              const Text(
                'FOCUS & TASK PLANNER',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  color: Color(0x33FFFFFF), // rgba(255,255,255,.20)
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 20),

              // ── "ON PRIORITIES" ────────────────────────────────────────
              const Text(
                'ON PRIORITIES',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: Color(0x2EFFFFFF), // rgba(255,255,255,.18)
                  letterSpacing: 0.7,
                ),
              ),
              const SizedBox(height: 11),

              // ── Accent underline ───────────────────────────────────────
              Container(
                width: 22,
                height: 2,
                decoration: BoxDecoration(
                  color: TaskEraColors.acc,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
              const SizedBox(height: 14),

              // ── Quote main ─────────────────────────────────────────────
              // font-variation-settings:"opsz" 72,"SOFT" 50 from CSS
              const Text(
                '"Didn\'t plan this week? Q1 will plan it for you."',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Fraunces',
                  fontVariations: [
                    FontVariation('wght', 500),
                    FontVariation('opsz', 72),
                    FontVariation('SOFT', 50),
                  ],
                  fontSize: 19,
                  color: Colors.white,
                  height: 1.48,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 9),

              // ── Quote subtitle ─────────────────────────────────────────
              const Text(
                'Neglecting Q2 creates urgency everywhere.\n'
                'The calendar fills with fire.\n'
                'And the important work never gets done.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  color: Color(0x5CFFFFFF), // rgba(255,255,255,.36)
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 18),

              // ── Progress bar ───────────────────────────────────────────
              // 170×2 px, track rgba(255,255,255,.10), fill accent, animates
              // linearly over 3200 ms.
              SizedBox(
                width: 170,
                height: 2,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(1),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      const ColoredBox(color: Color(0x1AFFFFFF)), // track
                      AnimatedBuilder(
                        animation: _progress,
                        builder: (context, child) => FractionallySizedBox(
                          widthFactor: _progress.value,
                          alignment: Alignment.centerLeft,
                          child: child,
                        ),
                        child: const ColoredBox(color: TaskEraColors.acc),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // ── "Opening app…" ─────────────────────────────────────────
              const Text(
                'Opening app…',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  color: Color(0x1FFFFFFF), // rgba(255,255,255,.12)
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          ),
          ),
          ),
        ),
      ),
    );
  }
}
