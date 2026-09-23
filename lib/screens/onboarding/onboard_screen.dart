import 'dart:ui' show ImageFilter;

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/database.dart';
import '../../data/providers/database_provider.dart';
import '../../routing/routes.dart';
import '../../settings/app_launch_prefs.dart';
import '../../settings/taskera_settings.dart';
import '../../settings/prefs_provider.dart';
import '../../theme/taskera_colors.dart';
import '../../theme/taskera_theme.dart';
import '../../widgets/wallpaper_background.dart';

// Single-screen onboarding — every persona option (language, who, focus style,
// peak hours, first task) stacked on one scrollable page with a Skip. Age/Terms
// consent is folded into the primary action. The Pro upsell now lives on the
// PaywallScreen shown right after (mandatory for skip-auth / local-storage
// users, optional for signed-up users — decided there from the skipAuth flag).

class OnboardScreen extends ConsumerStatefulWidget {
  const OnboardScreen({super.key});

  @override
  ConsumerState<OnboardScreen> createState() => _OnboardScreenState();
}

class _OnboardScreenState extends ConsumerState<OnboardScreen> {
  int _langIdx = 0;
  int? _role;
  int? _focus;
  int? _peak;
  int? _quadrant;
  bool _indiaOpen = false;
  bool _saving = false;
  final _taskCtrl = TextEditingController();

  static const _worldLangs = [
    'English', '日本語', 'Deutsch', '한국어', 'Français',
    '中文', 'Español', 'Português', 'Italiano', 'Nederlands', 'العربية',
  ];
  static const _indiaLangs = [
    'हिन्दी', 'తెలుగు', 'தமிழ்', 'ಕನ್ನಡ',
    'മലയാളം', 'मराठी', 'ગુજરાતી', 'বাংলা',
  ];
  static const _indiaOffset = 11;

  static const _roleOpts = [
    ('💼', 'Professional / PM / Founder', 'Projects, meetings, deadlines'),
    ('📚', 'Student', 'Exams, assignments, study goals'),
    ('🚀', 'Freelancer / Solopreneur', 'Clients, income goals, time tracking'),
    ('⚡', 'ADHD / Overwhelmed', 'Focus, one task at a time, gentle nudges'),
    ('💪', 'Building discipline', 'Habits, routines, consistency'),
  ];
  static const _focusOpts = [
    ('🎯', 'Deep work blocks', '2–4h uninterrupted sessions'),
    ('🍅', 'Pomodoro (25/5 min)', 'Short bursts with breaks'),
    ('✅', 'Task-by-task', 'One at a time, no timers'),
    ('🌊', 'Flexible / Flow state', 'No structure, just track time'),
  ];
  static const _peakOpts = [
    ('🌅', 'Early bird · 5–9 AM', null),
    ('☀️', 'Morning · 9 AM–12 PM', null),
    ('🌤', 'Afternoon · 1–5 PM', null),
    ('🌙', 'Night owl · 6 PM–midnight', null),
  ];
  static const _quads = [
    (label: 'Q1 · Do Now',   sub: 'Urgent',    bg: Color(0x1AF25022), border: Color(0x40F25022), color: TaskEraColors.q1),
    (label: 'Q2 · Schedule', sub: 'Important',  bg: Color(0x1A7FBA00), border: Color(0x407FBA00), color: TaskEraColors.q2),
    (label: 'Q3 · Delegate', sub: 'Do Later',   bg: Color(0x1400A4EF), border: Color(0x3300A4EF), color: TaskEraColors.q3),
    (label: 'Q4 · Eliminate',sub: 'Remove',     bg: Color(0x14FFB900), border: Color(0x33FFB900), color: TaskEraColors.q4),
  ];

  @override
  void dispose() {
    _taskCtrl.dispose();
    super.dispose();
  }

  // Completes onboarding and hands off to the paywall (the relocated upsell).
  // [savePrefs] persists the persona answers + first task; Skip passes false.
  Future<void> _complete({required bool savePrefs}) async {
    if (_saving) return;
    setState(() => _saving = true);
    final prefs = ref.read(sharedPreferencesProvider);

    if (savePrefs) {
      if (_role != null)     await prefs.setInt('taskera.onboard.role',       _role!);
      if (_focus != null)    await prefs.setInt('taskera.onboard.focusStyle', _focus!);
      if (_peak != null)     await prefs.setInt('taskera.onboard.peakHours',  _peak!);
      if (_quadrant != null) await prefs.setInt('taskera.onboard.quadrant',   _quadrant!);
      final taskText = _taskCtrl.text.trim();
      if (taskText.isNotEmpty) {
        final quad = (_quadrant ?? 1) + 1; // picker 0–3 → Q1–Q4; default Q2
        await ref.read(appDatabaseProvider).tasksDao.insertTask(
              TasksCompanion(title: Value(taskText), quadrant: Value(quad)),
            );
      }
    }

    await AppLaunchPrefs.completeOnboarding(prefs);
    // Hand off to the relocated Pro upsell. The paywall reads the skipAuth flag
    // to decide mandatory (local-storage users) vs optional (signed-up users).
    if (mounted) context.go('${TaskEraRoutes.paywall}?from=onboard');
  }

  @override
  Widget build(BuildContext context) {
    final colors = TaskEraTheme.of(context).colors;
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
              Expanded(
                child: ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                    child: Container(
                      color: const Color(0x33000000),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(20, 22, 20, 16),
                        child: _content(colors),
                      ),
                    ),
                  ),
                ),
              ),
              // Pinned bottom action bar — Start (saves) + Skip (no save).
              _ActionBar(
                saving: _saving,
                onStart: () => _complete(savePrefs: true),
                onSkip: () => _complete(savePrefs: false),
                safeBottom: safeBottom,
                colors: colors,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _content(TaskEraColors colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Header ────────────────────────────────────────────────────────
        Text(
          'Welcome to TaskEra',
          style: TextStyle(
            fontFamily: 'Fraunces',
            fontVariations: const [FontVariation('wght', 700)],
            fontSize: 26,
            color: colors.ink,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Set yourself up in a few taps — or skip and dive straight in.',
          style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: colors.ink3, height: 1.5),
        ),
        const SizedBox(height: 22),

        // ── Language ──────────────────────────────────────────────────────
        _SectionHeader('Language', colors),
        const SizedBox(height: 10),
        _languageBlock(colors),
        const SizedBox(height: 22),

        // ── Who are you ───────────────────────────────────────────────────
        _SectionHeader('Who are you?', colors, sub: 'TaskEra adapts to your workflow'),
        const SizedBox(height: 10),
        for (var i = 0; i < _roleOpts.length; i++) ...[
          if (i > 0) const SizedBox(height: 6),
          _ObOpt(emoji: _roleOpts[i].$1, title: _roleOpts[i].$2, subtitle: _roleOpts[i].$3,
              selected: _role == i, onTap: () => setState(() => _role = i), colors: colors),
        ],
        const SizedBox(height: 22),

        // ── Focus style ───────────────────────────────────────────────────
        _SectionHeader('Your focus style', colors, sub: 'How do you work best?'),
        const SizedBox(height: 10),
        for (var i = 0; i < _focusOpts.length; i++) ...[
          if (i > 0) const SizedBox(height: 6),
          _ObOpt(emoji: _focusOpts[i].$1, title: _focusOpts[i].$2, subtitle: _focusOpts[i].$3,
              selected: _focus == i, onTap: () => setState(() => _focus = i), colors: colors),
        ],
        const SizedBox(height: 22),

        // ── Peak hours ────────────────────────────────────────────────────
        _SectionHeader('Your peak hours', colors, sub: 'When are you most productive?'),
        const SizedBox(height: 10),
        for (var i = 0; i < _peakOpts.length; i++) ...[
          if (i > 0) const SizedBox(height: 6),
          _ObOpt(emoji: _peakOpts[i].$1, title: _peakOpts[i].$2, subtitle: _peakOpts[i].$3,
              selected: _peak == i, onTap: () => setState(() => _peak = i), colors: colors),
        ],
        const SizedBox(height: 22),

        // ── First task ────────────────────────────────────────────────────
        _SectionHeader('Your first task', colors, sub: "What's one thing you want to get done?"),
        const SizedBox(height: 10),
        TextField(
          controller: _taskCtrl,
          style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: colors.ink),
          decoration: InputDecoration(
            hintText: 'e.g. Finish the project proposal',
            hintStyle: TextStyle(fontSize: 13, color: colors.ink3),
            filled: true,
            fillColor: colors.surf2,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(11),
                borderSide: BorderSide(width: 1.5, color: colors.bdr2)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(11),
                borderSide: BorderSide(width: 1.5, color: colors.bdr2)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(11),
                borderSide: const BorderSide(width: 1.5, color: TaskEraColors.acc)),
          ),
        ),
        const SizedBox(height: 8),
        Text('Which quadrant does this belong to?',
            style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: colors.ink3)),
        const SizedBox(height: 6),
        Row(children: [
          Expanded(child: _QuadBtn(quad: _quads[0], selected: _quadrant == 0, onTap: () => setState(() => _quadrant = 0))),
          const SizedBox(width: 6),
          Expanded(child: _QuadBtn(quad: _quads[1], selected: _quadrant == 1, onTap: () => setState(() => _quadrant = 1))),
        ]),
        const SizedBox(height: 6),
        Row(children: [
          Expanded(child: _QuadBtn(quad: _quads[2], selected: _quadrant == 2, onTap: () => setState(() => _quadrant = 2))),
          const SizedBox(width: 6),
          Expanded(child: _QuadBtn(quad: _quads[3], selected: _quadrant == 3, onTap: () => setState(() => _quadrant = 3))),
        ]),
        const SizedBox(height: 20),

        // ── Age / terms consent ───────────────────────────────────────────
        Text.rich(
          TextSpan(
            style: TextStyle(fontFamily: 'Inter', fontSize: 10, color: colors.ink3, height: 1.6),
            children: [
              const TextSpan(text: 'By continuing you confirm you are 13 or older and agree to our '),
              const TextSpan(text: 'Terms', style: TextStyle(color: TaskEraColors.acc2)),
              const TextSpan(text: ' and '),
              const TextSpan(text: 'Privacy Policy', style: TextStyle(color: TaskEraColors.acc2)),
              const TextSpan(text: '.'),
            ],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // ── Language chips (world + collapsible Indian group) ─────────────────────
  Widget _languageBlock(TaskEraColors colors) {
    final indiaSelected = _langIdx >= _indiaOffset;
    if (indiaSelected && !_indiaOpen) _indiaOpen = true;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(spacing: 6, runSpacing: 6, children: [
          for (int i = 0; i < _worldLangs.length; i++) _langChip(i, _worldLangs[i], colors),
        ]),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => setState(() => _indiaOpen = !_indiaOpen),
          child: Container(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
            decoration: BoxDecoration(
              color: indiaSelected ? TaskEraColors.accBg : colors.surf2,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(width: 0.5,
                  color: indiaSelected ? const Color(0x4D0A84FF) : colors.bdr0),
            ),
            child: Row(children: [
              Text('🇮🇳  Indian Languages', style: TextStyle(
                fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w500,
                color: indiaSelected ? TaskEraColors.acc2 : colors.ink2, height: 1)),
              const Spacer(),
              Icon(_indiaOpen ? Icons.expand_less : Icons.expand_more, size: 16,
                  color: indiaSelected ? TaskEraColors.acc2 : colors.ink3),
            ]),
          ),
        ),
        if (_indiaOpen) ...[
          const SizedBox(height: 8),
          Wrap(spacing: 6, runSpacing: 6, children: [
            for (int i = 0; i < _indiaLangs.length; i++)
              _langChip(_indiaOffset + i, _indiaLangs[i], colors),
          ]),
        ],
      ],
    );
  }

  Widget _langChip(int idx, String label, TaskEraColors colors) {
    final sel = _langIdx == idx;
    return GestureDetector(
      onTap: () {
        setState(() => _langIdx = idx);
        ref.read(taskeraSettingsProvider.notifier).setLang(idx);
      },
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 6, 10, 6),
        decoration: BoxDecoration(
          color: sel ? TaskEraColors.accBg : colors.surf2,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(width: 0.5, color: sel ? const Color(0x4D0A84FF) : colors.bdr0),
        ),
        child: Text(label, style: TextStyle(
          fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w500,
          color: sel ? TaskEraColors.acc2 : colors.ink2, height: 1)),
      ),
    );
  }
}

// ── Section header ──────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? sub;
  final TaskEraColors colors;
  const _SectionHeader(this.title, this.colors, {this.sub});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(
          fontFamily: 'Fraunces', fontVariations: const [FontVariation('wght', 700)],
          fontSize: 18, color: colors.ink, height: 1.2)),
        if (sub != null) ...[
          const SizedBox(height: 3),
          Text(sub!, style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: colors.ink3, height: 1.4)),
        ],
      ],
    );
  }
}

// ── Bottom action bar ───────────────────────────────────────────────────────

class _ActionBar extends StatelessWidget {
  final bool saving;
  final VoidCallback onStart;
  final VoidCallback onSkip;
  final double safeBottom;
  final TaskEraColors colors;
  const _ActionBar({
    required this.saving,
    required this.onStart,
    required this.onSkip,
    required this.safeBottom,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 12, 20, safeBottom + 14),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: saving ? null : onStart,
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: TaskEraColors.acc,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [BoxShadow(color: Color(0x4D0A84FF), blurRadius: 14, offset: Offset(0, 3))],
              ),
              child: saving
                  ? const SizedBox(width: 18, height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Start using TaskEra →', style: TextStyle(
                      fontFamily: 'Inter', fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: saving ? null : onSkip,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Text('Skip for now', style: TextStyle(
                fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w600, color: colors.ink3)),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Option card ─────────────────────────────────────────────────────────────

class _ObOpt extends StatelessWidget {
  final String emoji;
  final String title;
  final String? subtitle;
  final bool selected;
  final VoidCallback onTap;
  final TaskEraColors colors;
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
          color: selected ? TaskEraColors.accBg : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(width: 1, color: selected ? TaskEraColors.acc : colors.bdr),
        ),
        child: Row(children: [
          Text(emoji, style: const TextStyle(fontSize: 15)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(
                    fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w600, color: colors.ink)),
                if (subtitle != null) ...[
                  const SizedBox(height: 1),
                  Text(subtitle!, style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: colors.ink3)),
                ],
              ],
            ),
          ),
        ]),
      ),
    );
  }
}

// ── Quadrant button ─────────────────────────────────────────────────────────

class _QuadBtn extends StatelessWidget {
  final ({String label, String sub, Color bg, Color border, Color color}) quad;
  final bool selected;
  final VoidCallback onTap;
  const _QuadBtn({required this.quad, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? quad.bg.withValues(alpha: 0.25) : quad.bg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(width: 1.5, color: selected ? quad.color : quad.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(quad.label, textAlign: TextAlign.center, style: TextStyle(
                fontFamily: 'Inter', fontSize: 9, fontWeight: FontWeight.w700, color: quad.color)),
            const SizedBox(height: 2),
            Text(quad.sub, textAlign: TextAlign.center, style: const TextStyle(
                fontFamily: 'Inter', fontSize: 9, color: Color(0xFF7A7A86))),
          ],
        ),
      ),
    );
  }
}
