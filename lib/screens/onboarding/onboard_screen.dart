import 'dart:ui' show ImageFilter;

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/database.dart';
import '../../data/providers/database_provider.dart';
import '../../l10n/app_l10n.dart';
import '../../routing/routes.dart';
import '../../settings/app_launch_prefs.dart';
import '../../settings/kaal_settings.dart';
import '../../settings/prefs_provider.dart';
import '../../theme/kaal_colors.dart';
import '../../theme/kaal_theme.dart';
import '../../widgets/wallpaper_background.dart';

// Screen: p-onboard — 7-step onboarding flow
// Step 0=Language, 1=AgeGate, 2=Who, 3=FocusStyle, 4=PeakHours, 5=FirstTask, 6=Upsell

class OnboardScreen extends ConsumerStatefulWidget {
  const OnboardScreen({super.key});

  @override
  ConsumerState<OnboardScreen> createState() => _OnboardScreenState();
}

class _OnboardScreenState extends ConsumerState<OnboardScreen> {
  int _step = 0; // 0=Language, 1=AgeGate, 2=Who, 3=FocusStyle, 4=PeakHours, 5=FirstTask, 6=Upsell
  int _langIdx = 0;
  int? _role;
  int? _focus;
  int? _peak;
  int? _quadrant;
  final _taskCtrl = TextEditingController();

  @override
  void dispose() {
    _taskCtrl.dispose();
    super.dispose();
  }

  void _next() => setState(() => _step++);
  void _back() => setState(() => _step--);

  Future<void> _finish() async {
    final prefs = ref.read(sharedPreferencesProvider);

    // Persist the persona answers so they're remembered and can drive
    // personalization later (currently surfaced via these prefs keys).
    if (_role     != null) await prefs.setInt('kaal.onboard.role',       _role!);
    if (_focus    != null) await prefs.setInt('kaal.onboard.focusStyle', _focus!);
    if (_peak     != null) await prefs.setInt('kaal.onboard.peakHours',  _peak!);
    if (_quadrant != null) await prefs.setInt('kaal.onboard.quadrant',   _quadrant!);

    // Save the typed first task into the chosen quadrant so the user lands on
    // Focus/Tasks with their first task already captured.
    final taskText = _taskCtrl.text.trim();
    if (taskText.isNotEmpty) {
      final quad = (_quadrant ?? 1) + 1; // picker 0–3 → Q1–Q4; default Q2 (Schedule)
      await ref.read(appDatabaseProvider).tasksDao.insertTask(
            TasksCompanion(title: Value(taskText), quadrant: Value(quad)),
          );
    }

    AppLaunchPrefs.completeOnboarding(prefs);
    if (mounted) context.go(KaalRoutes.focus);
  }

  @override
  Widget build(BuildContext context) {
    final colors = KaalTheme.of(context).colors;
    final safeTop = MediaQuery.of(context).padding.top;
    final safeBottom = MediaQuery.viewPaddingOf(context).bottom;

    return Stack(
      children: [
        const Positioned.fill(child: WallpaperBackground()),
        Scaffold(
          backgroundColor: Colors.transparent,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: safeTop),
              // Scrollable step content — wallpaper blurred+dimmed behind this area
              Expanded(
                child: ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                    child: Container(
                      color: const Color(0x33000000),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                        child: _buildStep(colors),
                      ),
                    ),
                  ),
                ),
              ),
              // Progress bar pinned at bottom — all 4 filled on step 5
              Padding(
                padding: EdgeInsets.fromLTRB(20, 12, 20, safeBottom + 14),
                child: _ProgressBar(step: _step, colors: colors),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStep(KaalColors colors) {
    switch (_step) {
      case 0:
        return _StepLang(
          selected: _langIdx,
          onSelect: (i) {
            setState(() => _langIdx = i);
            ref.read(kaalSettingsProvider.notifier).setLang(i);
          },
          onContinue: _next,
          onBack: () => context.go(KaalRoutes.signin),
          colors: colors,
        );
      case 1:
        return _Step0(
          onConfirm: _next,
          onBack: _back,
          colors: colors,
        );
      case 2:
        return _Step1(
          selected: _role,
          onSelect: (i) => setState(() => _role = i),
          onContinue: _next,
          colors: colors,
        );
      case 3:
        return _Step2(
          selected: _focus,
          onSelect: (i) => setState(() => _focus = i),
          onBack: _back,
          onContinue: _next,
          colors: colors,
        );
      case 4:
        return _Step3(
          selected: _peak,
          onSelect: (i) => setState(() => _peak = i),
          onBack: _back,
          onContinue: _next,
          colors: colors,
        );
      case 5:
        return _Step4(
          taskCtrl: _taskCtrl,
          quadrant: _quadrant,
          onSelectQuad: (i) => setState(() => _quadrant = i),
          onBack: _back,
          onContinue: _next,
          colors: colors,
        );
      case 6:
        return _Step5(onPro: _finish, onFree: _finish, colors: colors);
      default:
        return const SizedBox();
    }
  }
}

// ── Progress bar ──────────────────────────────────────────────────────────────

class _ProgressBar extends StatelessWidget {
  final int step; // 0-3
  final KaalColors colors;
  const _ProgressBar({required this.step, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(7, (i) {
        final active = i <= step;
        return Expanded(
          child: Container(
            height: 4,
            margin: EdgeInsets.only(left: i == 0 ? 0 : 4),
            decoration: BoxDecoration(
              color: active ? KaalColors.acc : const Color(0x40FFFFFF),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }
}

// ── Step 0 — Language selection ───────────────────────────────────────────────

class _StepLang extends StatefulWidget {
  final int selected;
  final ValueChanged<int> onSelect;
  final VoidCallback onContinue;
  final VoidCallback onBack;
  final KaalColors colors;
  const _StepLang({
    required this.selected,
    required this.onSelect,
    required this.onContinue,
    required this.onBack,
    required this.colors,
  });

  @override
  State<_StepLang> createState() => _StepLangState();
}

class _StepLangState extends State<_StepLang> {
  bool _indiaOpen = false;

  static const _worldLangs = [
    'English', '日本語', 'Deutsch', '한국어', 'Français',
    '中文', 'Español', 'Português', 'Italiano', 'Nederlands', 'العربية',
  ];
  static const _indiaLangs = [
    'हिन्दी', 'తెలుగు', 'தமிழ்', 'ಕನ್ನಡ',
    'മലയാളം', 'मराठी', 'ગુજરાતી', 'বাংলা',
  ];
  static const _indiaOffset = 11;

  Widget _chip(int idx, String label) {
    final sel = widget.selected == idx;
    return GestureDetector(
      onTap: () => widget.onSelect(idx),
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 6, 10, 6),
        decoration: BoxDecoration(
          color: sel ? KaalColors.accBg : widget.colors.surf2,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(width: 0.5,
              color: sel ? const Color(0x4D0A84FF) : widget.colors.bdr0),
        ),
        child: Text(label, style: TextStyle(
          fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w500,
          color: sel ? KaalColors.acc2 : widget.colors.ink2,
          height: 1,
        )),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final str = AppL10n.of(context);
    final indiaSelected = widget.selected >= _indiaOffset;
    if (indiaSelected && !_indiaOpen) _indiaOpen = true;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 20),
        Text(
          str.chooseLanguage,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Fraunces',
            fontVariations: const [FontVariation('wght', 700)],
            fontSize: 22,
            color: widget.colors.ink,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Pick the language you\'d like to use',
          textAlign: TextAlign.center,
          style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: widget.colors.ink3),
        ),
        const SizedBox(height: 24),

        // World languages
        Wrap(
          spacing: 6, runSpacing: 6,
          children: [
            for (int i = 0; i < _worldLangs.length; i++) _chip(i, _worldLangs[i]),
          ],
        ),
        const SizedBox(height: 8),

        // Indian languages group
        GestureDetector(
          onTap: () => setState(() => _indiaOpen = !_indiaOpen),
          child: Container(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
            decoration: BoxDecoration(
              color: indiaSelected ? KaalColors.accBg : widget.colors.surf2,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(width: 0.5,
                  color: indiaSelected ? const Color(0x4D0A84FF) : widget.colors.bdr0),
            ),
            child: Row(
              children: [
                Text('🇮🇳  Indian Languages', style: TextStyle(
                  fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w500,
                  color: indiaSelected ? KaalColors.acc2 : widget.colors.ink2,
                  height: 1,
                )),
                const Spacer(),
                Icon(_indiaOpen ? Icons.expand_less : Icons.expand_more,
                    size: 16,
                    color: indiaSelected ? KaalColors.acc2 : widget.colors.ink3),
              ],
            ),
          ),
        ),
        if (_indiaOpen) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 6, runSpacing: 6,
            children: [
              for (int i = 0; i < _indiaLangs.length; i++)
                _chip(_indiaOffset + i, _indiaLangs[i]),
            ],
          ),
        ],

        const SizedBox(height: 32),
        // Continue button
        GestureDetector(
          onTap: widget.onContinue,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: KaalColors.accBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(width: 0.5, color: const Color(0x4D0A84FF)),
            ),
            alignment: Alignment.center,
            child: Text(str.continueLabel, style: const TextStyle(
              fontFamily: 'Inter', fontSize: 15, fontWeight: FontWeight.w600,
              color: KaalColors.acc2,
            )),
          ),
        ),
        const SizedBox(height: 12),
        // Back link
        GestureDetector(
          onTap: widget.onBack,
          child: Center(
            child: Text('← Back to sign in', style: TextStyle(
              fontFamily: 'Inter', fontSize: 12, color: widget.colors.ink3,
            )),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

// ── Step 1 (was Step 0) — Age gate ────────────────────────────────────────────

class _Step0 extends StatelessWidget {
  final VoidCallback onConfirm;
  final VoidCallback onBack;
  final KaalColors colors;
  const _Step0({
    required this.onConfirm,
    required this.onBack,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 40),
        // Lock icon + title + body — centered
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text('🔒', style: TextStyle(fontSize: 30)),
            const SizedBox(height: 12),
            Text(
              'Age confirmation',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Fraunces',
                fontVariations: const [FontVariation('wght', 700)],
                fontSize: 19,
                color: colors.ink,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 240),
              child: Text(
                'Kaal collects task data to help you stay productive. '
                'You must be 13 or older to use this app.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  color: colors.ink3,
                  height: 1.6,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        // Primary — I am 13 or older
        GestureDetector(
          onTap: onConfirm,
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 13),
            decoration: BoxDecoration(
              color: KaalColors.acc,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x4D0A84FF),
                  blurRadius: 14,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: const Text(
              'I am 13 or older →',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 7),
        // Secondary — I am under 13
        GestureDetector(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'You must be 13 or older to use Kaal.',
                  style: TextStyle(fontFamily: 'Inter'),
                ),
                behavior: SnackBarBehavior.floating,
                duration: Duration(seconds: 2),
              ),
            );
          },
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 11),
            decoration: BoxDecoration(
              color: colors.surf2,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'I am under 13',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: colors.ink3,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Legal text
        Text.rich(
          TextSpan(
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 9,
              color: colors.ink3,
              height: 1.6,
            ),
            children: const [
              TextSpan(text: 'By continuing you agree to our '),
              TextSpan(
                text: 'Terms',
                style: TextStyle(color: KaalColors.acc2),
              ),
              TextSpan(text: ' and '),
              TextSpan(
                text: 'Privacy Policy',
                style: TextStyle(color: KaalColors.acc2),
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        // Back to sign in
        GestureDetector(
          onTap: onBack,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Text(
              '← Back to sign in',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                color: colors.ink3,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

// ── Option card ───────────────────────────────────────────────────────────────

class _ObOpt extends StatelessWidget {
  final String emoji;
  final String title;
  final String? subtitle;
  final bool selected;
  final VoidCallback onTap;
  final KaalColors colors;

  const _ObOpt({
    required this.emoji,
    required this.title,
    this.subtitle,
    required this.selected,
    required this.onTap,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? KaalColors.accBg : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            width: 1,
            color: selected ? KaalColors.acc : colors.bdr,
          ),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 15)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: colors.ink,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 1),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11,
                        color: colors.ink3,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Shared nav row ────────────────────────────────────────────────────────────

class _NavRow extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onContinue;
  final String continueLabel;
  final Color? continueBg;
  final KaalColors colors;

  const _NavRow({
    required this.onBack,
    required this.onContinue,
    this.continueLabel = 'Continue →',
    this.continueBg,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final bg = continueBg ?? KaalColors.acc;
    return Row(
      children: [
        GestureDetector(
          onTap: onBack,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
            decoration: BoxDecoration(
              color: colors.surf2,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Text(
              '← Back',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: colors.ink2,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: GestureDetector(
            onTap: onContinue,
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(vertical: 13),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(11),
              ),
              child: Text(
                continueLabel,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Step 1 — Who are you? ──────────────────────────────────────────────────────

class _Step1 extends StatelessWidget {
  final int? selected;
  final ValueChanged<int> onSelect;
  final VoidCallback onContinue;
  final KaalColors colors;
  const _Step1({
    required this.selected,
    required this.onSelect,
    required this.onContinue,
    required this.colors,
  });

  static const _opts = [
    ('💼', 'Professional / PM / Founder', 'Projects, meetings, deadlines'),
    ('📚', 'Student', 'Exams, assignments, study goals'),
    ('🚀', 'Freelancer / Solopreneur', 'Clients, income goals, time tracking'),
    ('⚡', 'ADHD / Overwhelmed', 'Focus, one task at a time, gentle nudges'),
    ('💪', 'Building discipline', 'Habits, routines, consistency'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Who are you?',
          style: TextStyle(
            fontFamily: 'Fraunces',
            fontVariations: const [FontVariation('wght', 700)],
            fontSize: 23,
            color: colors.ink,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Kaal adapts to your workflow',
          style: TextStyle(fontSize: 13, color: colors.ink3, height: 1.5),
        ),
        const SizedBox(height: 20),
        for (var i = 0; i < _opts.length; i++) ...[
          if (i > 0) const SizedBox(height: 6),
          _ObOpt(
            emoji: _opts[i].$1,
            title: _opts[i].$2,
            subtitle: _opts[i].$3,
            selected: selected == i,
            onTap: () => onSelect(i),
            colors: colors,
          ),
        ],
        const SizedBox(height: 20),
        GestureDetector(
          onTap: onContinue,
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 13),
            decoration: BoxDecoration(
              color: KaalColors.acc,
              borderRadius: BorderRadius.circular(11),
            ),
            child: const Text(
              'Continue →',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Step 2 — Your focus style ─────────────────────────────────────────────────

class _Step2 extends StatelessWidget {
  final int? selected;
  final ValueChanged<int> onSelect;
  final VoidCallback onBack;
  final VoidCallback onContinue;
  final KaalColors colors;
  const _Step2({
    required this.selected,
    required this.onSelect,
    required this.onBack,
    required this.onContinue,
    required this.colors,
  });

  static const _opts = [
    ('🎯', 'Deep work blocks', '2–4h uninterrupted sessions'),
    ('🍅', 'Pomodoro (25/5 min)', 'Short bursts with breaks'),
    ('✅', 'Task-by-task', 'One at a time, no timers'),
    ('🌊', 'Flexible / Flow state', 'No structure, just track time'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Your focus style',
          style: TextStyle(
            fontFamily: 'Fraunces',
            fontVariations: const [FontVariation('wght', 700)],
            fontSize: 23,
            color: colors.ink,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'How do you work best?',
          style: TextStyle(fontSize: 13, color: colors.ink3, height: 1.5),
        ),
        const SizedBox(height: 20),
        for (var i = 0; i < _opts.length; i++) ...[
          if (i > 0) const SizedBox(height: 6),
          _ObOpt(
            emoji: _opts[i].$1,
            title: _opts[i].$2,
            subtitle: _opts[i].$3,
            selected: selected == i,
            onTap: () => onSelect(i),
            colors: colors,
          ),
        ],
        const SizedBox(height: 20),
        _NavRow(
          onBack: onBack,
          onContinue: onContinue,
          colors: colors,
        ),
      ],
    );
  }
}

// ── Step 3 — Your peak hours ──────────────────────────────────────────────────

class _Step3 extends StatelessWidget {
  final int? selected;
  final ValueChanged<int> onSelect;
  final VoidCallback onBack;
  final VoidCallback onContinue;
  final KaalColors colors;
  const _Step3({
    required this.selected,
    required this.onSelect,
    required this.onBack,
    required this.onContinue,
    required this.colors,
  });

  static const _opts = [
    ('🌅', 'Early bird · 5–9 AM', null),
    ('☀️', 'Morning · 9 AM–12 PM', null),
    ('🌤', 'Afternoon · 1–5 PM', null),
    ('🌙', 'Night owl · 6 PM–midnight', null),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Your peak hours',
          style: TextStyle(
            fontFamily: 'Fraunces',
            fontVariations: const [FontVariation('wght', 700)],
            fontSize: 23,
            color: colors.ink,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'When are you most productive?',
          style: TextStyle(fontSize: 13, color: colors.ink3, height: 1.5),
        ),
        const SizedBox(height: 20),
        for (var i = 0; i < _opts.length; i++) ...[
          if (i > 0) const SizedBox(height: 6),
          _ObOpt(
            emoji: _opts[i].$1,
            title: _opts[i].$2,
            subtitle: _opts[i].$3,
            selected: selected == i,
            onTap: () => onSelect(i),
            colors: colors,
          ),
        ],
        const SizedBox(height: 20),
        _NavRow(onBack: onBack, onContinue: onContinue, colors: colors),
      ],
    );
  }
}

// ── Step 4 — Add your first task ──────────────────────────────────────────────

class _Step4 extends StatelessWidget {
  final TextEditingController taskCtrl;
  final int? quadrant;
  final ValueChanged<int> onSelectQuad;
  final VoidCallback onBack;
  final VoidCallback onContinue;
  final KaalColors colors;
  const _Step4({
    required this.taskCtrl,
    required this.quadrant,
    required this.onSelectQuad,
    required this.onBack,
    required this.onContinue,
    required this.colors,
  });

  static const _quads = [
    (
      label: 'Q1 · Do Now',
      sub: 'Urgent',
      bg: Color(0x1AF25022),
      border: Color(0x40F25022),
      color: KaalColors.q1,
    ),
    (
      label: 'Q2 · Schedule',
      sub: 'Important',
      bg: Color(0x1A7FBA00),
      border: Color(0x407FBA00),
      color: KaalColors.q2,
    ),
    (
      label: 'Q3 · Delegate',
      sub: 'Do Later',
      bg: Color(0x1400A4EF),
      border: Color(0x3300A4EF),
      color: KaalColors.q3,
    ),
    (
      label: 'Q4 · Eliminate',
      sub: 'Remove',
      bg: Color(0x14FFB900),
      border: Color(0x33FFB900),
      color: KaalColors.q4,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Add your first task',
          style: TextStyle(
            fontFamily: 'Fraunces',
            fontVariations: const [FontVariation('wght', 700)],
            fontSize: 23,
            color: colors.ink,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          "What's one thing you want to get done?",
          style: TextStyle(fontSize: 13, color: colors.ink3, height: 1.5),
        ),
        const SizedBox(height: 16),
        // Task text input
        TextField(
          controller: taskCtrl,
          style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: colors.ink),
          decoration: InputDecoration(
            hintText: 'e.g. Finish the project proposal',
            hintStyle: TextStyle(fontSize: 13, color: colors.ink3),
            filled: true,
            fillColor: colors.surf2,
            isDense: true,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(11),
              borderSide: BorderSide(width: 1.5, color: colors.bdr2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(11),
              borderSide: BorderSide(width: 1.5, color: colors.bdr2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(11),
              borderSide:
                  const BorderSide(width: 1.5, color: KaalColors.acc),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Which quadrant does this task belong to?',
          style: TextStyle(fontSize: 11, color: colors.ink3),
        ),
        const SizedBox(height: 6),
        // 2×2 quadrant grid
        Row(
          children: [
            Expanded(child: _QuadBtn(idx: 0, quad: _quads[0], selected: quadrant == 0, onTap: () => onSelectQuad(0))),
            const SizedBox(width: 6),
            Expanded(child: _QuadBtn(idx: 1, quad: _quads[1], selected: quadrant == 1, onTap: () => onSelectQuad(1))),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(child: _QuadBtn(idx: 2, quad: _quads[2], selected: quadrant == 2, onTap: () => onSelectQuad(2))),
            const SizedBox(width: 6),
            Expanded(child: _QuadBtn(idx: 3, quad: _quads[3], selected: quadrant == 3, onTap: () => onSelectQuad(3))),
          ],
        ),
        const SizedBox(height: 16),
        // AI tip
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0x120A84FF),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              width: 0.5,
              color: const Color(0x330A84FF),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '✦ Kaal AI tip',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: KaalColors.acc2,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                "Most important tasks live in Q2. Don't let urgent Q1 tasks crowd them out.",
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  color: colors.ink3,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _NavRow(
          onBack: onBack,
          onContinue: onContinue,
          continueLabel: 'Start using Kaal 🚀',
          continueBg: KaalColors.q2,
          colors: colors,
        ),
      ],
    );
  }
}

class _QuadBtn extends StatelessWidget {
  final int idx;
  final ({String label, String sub, Color bg, Color border, Color color}) quad;
  final bool selected;
  final VoidCallback onTap;
  const _QuadBtn({
    required this.idx,
    required this.quad,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? quad.bg.withValues(alpha: 0.25) : quad.bg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            width: 1.5,
            color: selected ? quad.color : quad.border,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              quad.label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: quad.color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              quad.sub,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 9,
                color: Color(0xFF7A7A86),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Step 5 — One more thing (upsell) ─────────────────────────────────────────

class _Step5 extends StatelessWidget {
  final VoidCallback onPro;
  final VoidCallback onFree;
  final KaalColors colors;
  const _Step5({
    required this.onPro,
    required this.onFree,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ✦ + title + subtitle (centered)
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              '✦',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 23,
                color: KaalColors.acc2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'One more thing',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Fraunces',
                fontVariations: const [FontVariation('wght', 700)],
                fontSize: 19,
                color: colors.ink,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Your first task has been created. Kaal AI just scored and sorted it — this is what Pro does for every task, every day.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                color: colors.ink3,
                height: 1.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Feature list
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(width: 0.5, color: colors.bdr2),
          ),
          child: Column(
            children: [
              _FeatureRow(
                dotColor: KaalColors.q2,
                label: 'Unlimited AI task scoring',
                badge: 'vs 5/day free',
                badgeColor: colors.ink3,
                colors: colors,
              ),
              const SizedBox(height: 7),
              _FeatureRow(
                dotColor: KaalColors.acc,
                label: 'Home screen widget',
                badge: 'Exclusive',
                badgeColor: KaalColors.q2,
                colors: colors,
              ),
              const SizedBox(height: 7),
              _FeatureRow(
                dotColor: const Color(0xFFBF5AF2),
                label: 'Brain Dump + auto-schedule',
                badge: 'Exclusive',
                badgeColor: KaalColors.q2,
                colors: colors,
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        // Try Pro button (gradient)
        GestureDetector(
          onTap: onPro,
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 13),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF5856D6), KaalColors.acc],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(11),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x400A84FF),
                  blurRadius: 14,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: const Text(
              'Try Pro free for 7 days →',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onFree,
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 11),
            child: Text(
              'Continue with free plan',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: colors.ink3,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final Color dotColor;
  final String label;
  final String badge;
  final Color badgeColor;
  final KaalColors colors;
  const _FeatureRow({
    required this.dotColor,
    required this.label,
    required this.badge,
    required this.badgeColor,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: dotColor,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              color: colors.ink2,
            ),
          ),
        ),
        Text(
          badge,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 9,
            color: badgeColor,
          ),
        ),
      ],
    );
  }
}
