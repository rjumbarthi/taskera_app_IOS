import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_l10n.dart';
import '../../settings/taskera_settings.dart';
import '../../theme/taskera_colors.dart';
import '../../theme/taskera_theme.dart';
import '../../widgets/add_back_button.dart';
import '../../widgets/taskera_top_bar.dart';
import '../../widgets/wallpaper_background.dart';

class WidgetPreviewScreen extends ConsumerWidget {
  const WidgetPreviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors    = TaskEraTheme.of(context).colors;
    final safeBot   = MediaQuery.of(context).padding.bottom;
    final wallpaper = ref.watch(taskeraSettingsProvider).wallpaper;

    return Stack(children: [
      Positioned.fill(child: WallpaperBackground(wallpaper: wallpaper)),
      Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          TaskEraTopBar(
            title: AppL10n.of(context).widgetPreview,
            leading: AddBackButton(onTap: () => Navigator.of(context).pop()),
            actions: [
              Container(
                padding: const EdgeInsets.fromLTRB(8, 2, 8, 2),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF5856D6), TaskEraColors.acc],
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: const Text('PRO',
                    style: TextStyle(fontFamily: 'Inter', fontSize: 9,
                        fontWeight: FontWeight.w700, color: Colors.white, height: 1)),
              ),
            ],
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(12, 0, 12, safeBot + 24),
              children: [
                _ProGateBanner(colors: colors),
                const SizedBox(height: 8),
                _PreviewNote(colors: colors),
                const SizedBox(height: 8),
                _SectionLabel('Active Focus · Home + Lock', colors),
                const SizedBox(height: 6),
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _ActiveFocusHomeWidget(),
                  const SizedBox(width: 8),
                  _ActiveFocusLockWidget(),
                ]),
                const SizedBox(height: 8),
                _SectionLabel('Top Task · Small', colors),
                const SizedBox(height: 6),
                _TopTaskSmall(),
                const SizedBox(height: 8),
                _SectionLabel('Habit Streak · Small', colors),
                const SizedBox(height: 6),
                _HabitStreakSmall(),
                const SizedBox(height: 8),
                _SectionLabel('Focus Timer · Small', colors),
                const SizedBox(height: 6),
                _FocusTimerSmall(),
                const SizedBox(height: 8),
                _SectionLabel('Today Tasks · Medium', colors),
                const SizedBox(height: 6),
                _TodayTasksMedium(),
                const SizedBox(height: 8),
                _SectionLabel('Goals Progress · Medium', colors),
                const SizedBox(height: 6),
                _GoalsProgressMedium(),
                const SizedBox(height: 8),
                _SectionLabel('Quad Summary · Medium', colors),
                const SizedBox(height: 6),
                _QuadSummaryMedium(),
                const SizedBox(height: 8),
                _SectionLabel('Daily Quote · Medium', colors),
                const SizedBox(height: 6),
                _DailyQuoteMedium(),
                const SizedBox(height: 8),
                _SectionLabel('Active Focus · Large', colors),
                const SizedBox(height: 6),
                _ActiveFocusLarge(),
                const SizedBox(height: 8),
                _SectionLabel('Today Command · Large', colors),
                const SizedBox(height: 6),
                _TodayCommandLarge(),
                const SizedBox(height: 8),
                _SectionLabel('Today Card · Large', colors),
                const SizedBox(height: 6),
                _TodayCardLarge(),
                const SizedBox(height: 8),
                _SectionLabel('Today Card · Lock Screen', colors),
                const SizedBox(height: 6),
                _TodayCardLock(),
                const SizedBox(height: 8),
                _SectionLabel('Do This Now · Large', colors),
                const SizedBox(height: 6),
                _DoThisNowLarge(),
                const SizedBox(height: 8),
                _SectionLabel('Do This Now · Lock Screen', colors),
                const SizedBox(height: 6),
                _DoThisNowLock(),
                const SizedBox(height: 8),
                _SectionLabel('Next Event · Small', colors),
                const SizedBox(height: 6),
                _NextEventSmall(),
                const SizedBox(height: 8),
                _SectionLabel("Today's Schedule · Medium", colors),
                const SizedBox(height: 6),
                _TodaysScheduleMedium(),
                const SizedBox(height: 8),
                _SectionLabel('Habit Check · Small', colors),
                const SizedBox(height: 6),
                _HabitCheckSmall(),
                const SizedBox(height: 8),
                _SectionLabel('Habits Today · Medium', colors),
                const SizedBox(height: 6),
                _HabitsTodayMedium(),
                const SizedBox(height: 8),
                _SectionLabel('Last Note · Small', colors),
                const SizedBox(height: 6),
                _LastNoteSmall(),
                const SizedBox(height: 8),
                _SectionLabel('Recent Notes · Medium', colors),
                const SizedBox(height: 6),
                _RecentNotesMedium(),
                const SizedBox(height: 8),
                _SectionLabel('Inbox · Small', colors),
                const SizedBox(height: 6),
                _InboxSmall(),
                const SizedBox(height: 8),
                _SectionLabel('Inbox · Medium', colors),
                const SizedBox(height: 6),
                _InboxMedium(),
                const SizedBox(height: 8),
                _SectionLabel('Lock Screen · Inline', colors),
                const SizedBox(height: 6),
                _LockScreenInline(),
              ],
            ),
          ),
        ]),
      ),
    ]);
  }
}

// ── Section label ─────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  final TaskEraColors colors;
  const _SectionLabel(this.text, this.colors);

  @override
  Widget build(BuildContext context) {
    return Text(text.toUpperCase(),
        style: TextStyle(fontFamily: 'Inter', fontSize: 11,
            fontWeight: FontWeight.w700, letterSpacing: 0.5,
            color: colors.ink3, height: 1));
  }
}

// ── Pro gate banner ───────────────────────────────────────────────────────────

class _ProGateBanner extends StatelessWidget {
  final TaskEraColors colors;
  const _ProGateBanner({required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0x1F5856D6), Color(0x140A84FF)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(width: 0.5, color: const Color(0x4D5856D6)),
      ),
      child: Row(children: [
        const Text('📱', style: TextStyle(fontSize: 18)),
        const SizedBox(width: 9),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(AppL10n.of(context).homeWidgetsPro,
                style: TextStyle(fontFamily: 'Inter', fontSize: 12,
                    fontWeight: FontWeight.w700, color: TaskEraColors.acc2, height: 1.2)),
            Text(AppL10n.of(context).upgradeForWidgets,
                style: TextStyle(fontFamily: 'Inter', fontSize: 10,
                    color: colors.ink3, height: 1.3)),
          ]),
        ),
        const SizedBox(width: 9),
        Container(
          padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF5856D6), TaskEraColors.acc],
              begin: Alignment.topLeft, end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(7),
          ),
          child: Text(AppL10n.of(context).upgrade,
              style: TextStyle(fontFamily: 'Inter', fontSize: 10,
                  fontWeight: FontWeight.w700, color: Colors.white, height: 1)),
        ),
      ]),
    );
  }
}

class _PreviewNote extends StatelessWidget {
  final TaskEraColors colors;
  const _PreviewNote({required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 7, 10, 7),
      decoration: BoxDecoration(
        color: colors.surf2,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text('Preview only. Add TaskEra widgets to iOS home screen after upgrading.',
          style: TextStyle(fontFamily: 'Inter', fontSize: 12,
              color: colors.ink3, height: 1.4)),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Widget mockups (dark-themed — represent the actual OS widgets)
// ══════════════════════════════════════════════════════════════════════════════

// ── Active Focus · Home ───────────────────────────────────────────────────────

class _ActiveFocusHomeWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 170, height: 130,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF071426), Color(0xFF101923)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(width: 0.5, color: const Color(0x590A84FF)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.access_time_rounded, color: Color(0xFF0A84FF), size: 13),
          const SizedBox(width: 5),
          const Text('TASKERA LIVE',
              style: TextStyle(fontFamily: 'Inter', fontSize: 9,
                  fontWeight: FontWeight.w700, color: Color(0xFF409CFF), height: 1)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.fromLTRB(5, 1, 5, 1),
            decoration: BoxDecoration(
              color: const Color(0x21127000),
              borderRadius: BorderRadius.circular(5),
            ),
            child: const Text('HABIT',
                style: TextStyle(fontFamily: 'Inter', fontSize: 9,
                    fontWeight: FontWeight.w700, color: Color(0xFF9FCD44), height: 1)),
          ),
        ]),
        const SizedBox(height: 7),
        const Text('Gym workout',
            style: TextStyle(fontFamily: 'Inter', fontSize: 13,
                fontWeight: FontWeight.w700, color: Colors.white, height: 1.25)),
        const SizedBox(height: 2),
        const Text('Habit · In progress',
            style: TextStyle(fontFamily: 'Inter', fontSize: 10,
                color: Color(0x85FFFFFF), height: 1.25)),
        const Spacer(),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: const LinearProgressIndicator(
            value: 0.32,
            minHeight: 4,
            backgroundColor: Color(0x1FFFFFFF),
            valueColor: AlwaysStoppedAnimation(Color(0xFF0A84FF)),
          ),
        ),
        const SizedBox(height: 4),
        const Text('35:00',
            style: TextStyle(fontFamily: 'Fraunces', fontSize: 13,
                fontVariations: [FontVariation('wght', 700)],
                color: Colors.white, height: 1)),
      ]),
    );
  }
}

class _ActiveFocusLockWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.fromLTRB(11, 9, 11, 9),
        decoration: BoxDecoration(
          color: const Color(0x14FFFFFF),
          borderRadius: BorderRadius.circular(13),
          border: Border.all(width: 0.5, color: const Color(0x24FFFFFF)),
        ),
        child: Row(children: [
          Container(
            width: 24, height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(width: 2, color: const Color(0x590A84FF)),
            ),
            child: const Center(
              child: SizedBox(width: 7, height: 7,
                  child: DecoratedBox(
                    decoration: BoxDecoration(color: Color(0xFF0A84FF), shape: BoxShape.circle),
                  )),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Gym workout',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontFamily: 'Inter', fontSize: 12,
                      fontWeight: FontWeight.w700, color: Colors.white, height: 1.2)),
              const Text('35:00 · In progress',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontFamily: 'Inter', fontSize: 10,
                      color: Color(0x80FFFFFF), height: 1.3)),
            ]),
          ),
        ]),
      ),
    );
  }
}

// ── Small widgets ─────────────────────────────────────────────────────────────

class _TopTaskSmall extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 130, height: 130,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0A0A0C), Color(0xFF1E1E22)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(width: 0.5, color: const Color(0x40FFFFFF)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: 8, height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(width: 1.5, color: TaskEraColors.acc),
            ),
            child: Center(child: Container(width: 3, height: 3,
                decoration: const BoxDecoration(
                  color: Color(0xFF3D8BFF), shape: BoxShape.circle))),
          ),
          const SizedBox(width: 5),
          const Text('TaskEra',
              style: TextStyle(fontFamily: 'Inter', fontSize: 12,
                  fontWeight: FontWeight.w600, color: Colors.white, height: 1)),
        ]),
        const SizedBox(height: 4),
        const Text('Top task today',
            style: TextStyle(fontFamily: 'Inter', fontSize: 11,
                color: Color(0x80FFFFFF), height: 1.3)),
        const SizedBox(height: 4),
        const Expanded(
          child: Text('Assignment submission',
              style: TextStyle(fontFamily: 'Inter', fontSize: 13,
                  fontWeight: FontWeight.w500, color: Colors.white, height: 1.3)),
        ),
        Row(children: [
          Container(width: 5, height: 5,
              decoration: const BoxDecoration(color: TaskEraColors.q1, shape: BoxShape.circle)),
          const SizedBox(width: 4),
          const Text('Q1 · Score 9.2',
              style: TextStyle(fontFamily: 'Inter', fontSize: 10,
                  color: Color(0x73FFFFFF), height: 1)),
        ]),
      ]),
    );
  }
}

class _HabitStreakSmall extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 130, height: 130,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF120A1F), Color(0xFF1A0D2E)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(width: 0.5, color: const Color(0x4DBF5AF2)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: 8, height: 8,
              decoration: const BoxDecoration(color: Color(0xFFBF5AF2), shape: BoxShape.circle)),
          const SizedBox(width: 4),
          const Text('Habits',
              style: TextStyle(fontFamily: 'Inter', fontSize: 10,
                  fontWeight: FontWeight.w600, color: Color(0xFFBF5AF2), height: 1)),
        ]),
        const SizedBox(height: 6),
        const Text('14🔥',
            style: TextStyle(fontFamily: 'Fraunces', fontSize: 24,
                fontVariations: [FontVariation('wght', 700)],
                color: Colors.white, height: 1)),
        const Text('streak · 3/4 today',
            style: TextStyle(fontFamily: 'Inter', fontSize: 9,
                color: Color(0x73FFFFFF), height: 1.3)),
        const Spacer(),
        Row(children: [
          Expanded(child: Container(height: 4,
              decoration: BoxDecoration(color: const Color(0xFFBF5AF2),
                  borderRadius: BorderRadius.circular(2)))),
          const SizedBox(width: 2),
          Expanded(child: Container(height: 4,
              decoration: BoxDecoration(color: const Color(0xFFBF5AF2),
                  borderRadius: BorderRadius.circular(2)))),
          const SizedBox(width: 2),
          Expanded(child: Container(height: 4,
              decoration: BoxDecoration(color: const Color(0xFFBF5AF2),
                  borderRadius: BorderRadius.circular(2)))),
          const SizedBox(width: 2),
          Expanded(child: Container(height: 4,
              decoration: BoxDecoration(color: const Color(0x26FFFFFF),
                  borderRadius: BorderRadius.circular(2)))),
        ]),
      ]),
    );
  }
}

class _FocusTimerSmall extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 130, height: 130,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0A1628), Color(0xFF0D1E3A)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(width: 0.5, color: const Color(0x4D0A84FF)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 60, height: 60,
            child: CustomPaint(
              painter: _CircularTimerPainter(progress: 0.75),
              child: const Center(
                child: Text('23:41',
                    style: TextStyle(fontFamily: 'Fraunces', fontSize: 12,
                        fontVariations: [FontVariation('wght', 700)],
                        color: Colors.white, height: 1)),
              ),
            ),
          ),
          const SizedBox(height: 4),
          const Text('Chapter 4 study',
              textAlign: TextAlign.center,
              style: TextStyle(fontFamily: 'Inter', fontSize: 10,
                  color: Color(0x80FFFFFF), height: 1.3)),
        ],
      ),
    );
  }
}

class _CircularTimerPainter extends CustomPainter {
  final double progress;
  const _CircularTimerPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2, cy = size.height / 2, r = size.width / 2 - 3;
    final bg = Paint()
      ..color = const Color(0x330A84FF)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;
    final fg = Paint()
      ..color = const Color(0xFF0A84FF)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(Offset(cx, cy), r, bg);
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r),
      -3.14159 / 2,
      2 * 3.14159 * progress,
      false,
      fg,
    );
  }

  @override
  bool shouldRepaint(_CircularTimerPainter old) => old.progress != progress;
}

// ── Medium widgets ────────────────────────────────────────────────────────────

class _TodayTasksMedium extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0A0A0C), Color(0xFF1E1E22)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(width: 0.5, color: const Color(0x40FFFFFF)),
      ),
      child: Column(children: [
        Row(children: [
          const Text('Today · 6 tasks',
              style: TextStyle(fontFamily: 'Inter', fontSize: 12,
                  fontWeight: FontWeight.w600, color: Colors.white, height: 1)),
          const Spacer(),
          const Text('Tue 29',
              style: TextStyle(fontFamily: 'Inter', fontSize: 12,
                  color: Color(0x4DFFFFFF), height: 1)),
        ]),
        const SizedBox(height: 8),
        _TaskLine(dot: TaskEraColors.q1, text: 'Assignment submission', badge: 'P1',
            badgeBg: const Color(0x24FF453A), badgeFg: const Color(0xFFFF8080)),
        const SizedBox(height: 4),
        _TaskLine(dot: TaskEraColors.q2, text: 'Study for exam — Chapter 4', badge: 'P2',
            badgeBg: const Color(0x24FF9500), badgeFg: const Color(0xFFFF9500)),
        const SizedBox(height: 4),
        Opacity(
          opacity: 0.6,
          child: _TaskLine(dot: TaskEraColors.q2, text: 'Morning journaling', badge: 'P3',
              badgeBg: Colors.transparent, badgeFg: const Color(0x59FFFFFF)),
        ),
      ]),
    );
  }
}

class _TaskLine extends StatelessWidget {
  final Color dot;
  final String text;
  final String badge;
  final Color badgeBg;
  final Color badgeFg;
  const _TaskLine({required this.dot, required this.text, required this.badge,
      required this.badgeBg, required this.badgeFg});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(width: 10, height: 10,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(width: 1.5, color: dot),
        ),
      ),
      const SizedBox(width: 6),
      Expanded(
        child: Text(text,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontFamily: 'Inter', fontSize: 12,
                color: Colors.white, height: 1.2)),
      ),
      const SizedBox(width: 4),
      Container(
        padding: const EdgeInsets.fromLTRB(4, 1, 4, 1),
        decoration: BoxDecoration(color: badgeBg, borderRadius: BorderRadius.circular(3)),
        child: Text(badge,
            style: TextStyle(fontFamily: 'Inter', fontSize: 9,
                color: badgeFg, height: 1)),
      ),
    ]);
  }
}

class _GoalsProgressMedium extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0D1A0D), Color(0xFF0A1E14)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(width: 0.5, color: const Color(0x407FBA00)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: 8, height: 8,
              decoration: const BoxDecoration(color: TaskEraColors.q2, shape: BoxShape.circle)),
          const SizedBox(width: 5),
          const Text('Goals · April',
              style: TextStyle(fontFamily: 'Inter', fontSize: 12,
                  fontWeight: FontWeight.w600, color: Color(0xFF9FCD44), height: 1)),
        ]),
        const SizedBox(height: 10),
        _GoalBar(label: 'Launch MVP', percent: 0.60,
            pctColor: const Color(0xFF9FCD44), barColor: TaskEraColors.q2),
        const SizedBox(height: 7),
        _GoalBar(label: 'Exercise habit', percent: 0.43,
            pctColor: const Color(0xFFBF5AF2), barColor: const Color(0xFFBF5AF2)),
        const SizedBox(height: 7),
        _GoalBar(label: 'Read 12 books', percent: 0.25,
            pctColor: const Color(0xFF409CFF), barColor: const Color(0xFF409CFF)),
      ]),
    );
  }
}

class _GoalBar extends StatelessWidget {
  final String label;
  final double percent;
  final Color pctColor;
  final Color barColor;
  const _GoalBar({required this.label, required this.percent,
      required this.pctColor, required this.barColor});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Row(children: [
        Expanded(child: Text(label,
            style: const TextStyle(fontFamily: 'Inter', fontSize: 12,
                color: Colors.white, height: 1.2))),
        Text('${(percent * 100).round()}%',
            style: TextStyle(fontFamily: 'Inter', fontSize: 9,
                fontWeight: FontWeight.w700, color: pctColor, height: 1)),
      ]),
      const SizedBox(height: 3),
      ClipRRect(
        borderRadius: BorderRadius.circular(2),
        child: LinearProgressIndicator(
          value: percent,
          minHeight: 4,
          backgroundColor: const Color(0x1AFFFFFF),
          valueColor: AlwaysStoppedAnimation(barColor),
        ),
      ),
    ]);
  }
}

class _QuadSummaryMedium extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0A0A0C), Color(0xFF1E1E22)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(width: 0.5, color: const Color(0x40FFFFFF)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Text("Today's quads",
              style: TextStyle(fontFamily: 'Inter', fontSize: 12,
                  fontWeight: FontWeight.w600, color: Colors.white, height: 1)),
          const Spacer(),
          const Text('Tue 29',
              style: TextStyle(fontFamily: 'Inter', fontSize: 10,
                  color: Color(0x4DFFFFFF), height: 1)),
        ]),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(child: _QuadMiniCell(label: 'Q1 Do Now', count: '2',
              bg: const Color(0x26F25022), border: const Color(0x4DF25022),
              labelColor: TaskEraColors.q1)),
          const SizedBox(width: 4),
          Expanded(child: _QuadMiniCell(label: 'Q2 Schedule', count: '6',
              bg: const Color(0x1F7FBA00), border: const Color(0x407FBA00),
              labelColor: TaskEraColors.q2)),
        ]),
        const SizedBox(height: 4),
        Row(children: [
          Expanded(child: _QuadMiniCell(label: 'Q3 Delegate', count: '4',
              bg: const Color(0x1A00A4EF), border: const Color(0x3300A4EF),
              labelColor: TaskEraColors.q3)),
          const SizedBox(width: 4),
          Expanded(child: _QuadMiniCell(label: 'Q4 Eliminate', count: '2',
              bg: const Color(0x1AFFB900), border: const Color(0x33FFB900),
              labelColor: TaskEraColors.q4)),
        ]),
      ]),
    );
  }
}

class _QuadMiniCell extends StatelessWidget {
  final String label;
  final String count;
  final Color bg;
  final Color border;
  final Color labelColor;
  const _QuadMiniCell({required this.label, required this.count,
      required this.bg, required this.border, required this.labelColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(width: 0.5, color: border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label.toUpperCase(),
            style: TextStyle(fontFamily: 'Inter', fontSize: 8,
                fontWeight: FontWeight.w700, color: labelColor,
                letterSpacing: 0.3, height: 1)),
        Text(count,
            style: const TextStyle(fontFamily: 'Fraunces', fontSize: 18,
                fontVariations: [FontVariation('wght', 600)],
                color: Colors.white, height: 1.1)),
      ]),
    );
  }
}

class _DailyQuoteMedium extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0D0D1A), Color(0xFF1A0D2E)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(width: 0.5, color: const Color(0x33BF5AF2)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('"',
            style: TextStyle(fontFamily: 'Inter', fontSize: 20,
                color: Color(0x99BF5AF2), height: 1)),
        const SizedBox(height: 6),
        const Text(
          'What is important is seldom urgent and what is urgent is seldom important.',
          style: TextStyle(fontFamily: 'Inter', fontSize: 12,
              fontStyle: FontStyle.italic,
              color: Color(0xCCFFFFFF), height: 1.55),
        ),
        const SizedBox(height: 8),
        const Text('— Dwight D. Eisenhower',
            style: TextStyle(fontFamily: 'Inter', fontSize: 10,
                color: Color(0x4DFFFFFF), height: 1)),
      ]),
    );
  }
}

// ── Large widgets ─────────────────────────────────────────────────────────────

class _ActiveFocusLarge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 245,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF061120), Color(0xFF101923)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(width: 0.5, color: const Color(0x520A84FF)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.access_time_rounded, color: Color(0xFF0A84FF), size: 17),
          const SizedBox(width: 7),
          const Text('TASKERA LIVE',
              style: TextStyle(fontFamily: 'Inter', fontSize: 10,
                  fontWeight: FontWeight.w800, letterSpacing: 0.6,
                  color: Color(0xFF409CFF), height: 1)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.fromLTRB(7, 3, 7, 3),
            decoration: BoxDecoration(
              color: const Color(0x24127000),
              borderRadius: BorderRadius.circular(7),
            ),
            child: const Text('HABIT',
                style: TextStyle(fontFamily: 'Inter', fontSize: 10,
                    fontWeight: FontWeight.w700, color: Color(0xFF9FCD44), height: 1)),
          ),
        ]),
        const SizedBox(height: 12),
        Expanded(
          child: Row(children: [
            SizedBox(
              width: 112, height: 112,
              child: CustomPaint(
                painter: _CircularTimerPainter(progress: 0.32),
                child: const Center(
                  child: Text('35:00',
                      style: TextStyle(fontFamily: 'Fraunces', fontSize: 20,
                          fontVariations: [FontVariation('wght', 700)],
                          color: Colors.white, height: 1)),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Gym workout',
                    style: TextStyle(fontFamily: 'Inter', fontSize: 22,
                        fontWeight: FontWeight.w700, color: Colors.white, height: 1.16)),
                const SizedBox(height: 6),
                const Text('Habit · In progress',
                    style: TextStyle(fontFamily: 'Inter', fontSize: 12,
                        color: Color(0x8CFFFFFF), height: 1.35)),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: Container(height: 5,
                      decoration: BoxDecoration(color: const Color(0xFF0A84FF),
                          borderRadius: BorderRadius.circular(3)))),
                  const SizedBox(width: 6),
                  Expanded(child: Container(height: 5,
                      decoration: BoxDecoration(color: const Color(0xFF0A84FF),
                          borderRadius: BorderRadius.circular(3)))),
                  const SizedBox(width: 6),
                  Expanded(child: Container(height: 5,
                      decoration: BoxDecoration(color: const Color(0x24FFFFFF),
                          borderRadius: BorderRadius.circular(3)))),
                  const SizedBox(width: 6),
                  Expanded(child: Container(height: 5,
                      decoration: BoxDecoration(color: const Color(0x24FFFFFF),
                          borderRadius: BorderRadius.circular(3)))),
                ]),
              ]),
            ),
          ]),
        ),
        const SizedBox(height: 8),
        const Text('Shows the running habit/task outside the app.',
            style: TextStyle(fontFamily: 'Inter', fontSize: 10,
                color: Color(0x73FFFFFF), height: 1.3)),
      ]),
    );
  }
}

class _TodayCommandLarge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 245,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0A0A0C), Color(0xFF18181D)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(width: 0.5, color: const Color(0x40FFFFFF)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Expanded(
            child: Text('Today · 11 tasks',
                style: TextStyle(fontFamily: 'Inter', fontSize: 13,
                    fontWeight: FontWeight.w800, color: Colors.white, height: 1)),
          ),
          const Text('25% done',
              style: TextStyle(fontFamily: 'Inter', fontSize: 10,
                  fontWeight: FontWeight.w700, color: Color(0xFF9FCD44), height: 1)),
        ]),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: const LinearProgressIndicator(
            value: 0.25, minHeight: 5,
            backgroundColor: Color(0x1AFFFFFF),
            valueColor: AlwaysStoppedAnimation(Color(0xFF9FCD44)),
          ),
        ),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: _CommandQuadCell(
            label: 'Q1 DO NOW', count: '2', sub: '1 overdue',
            bg: const Color(0x29F25022), border: const Color(0x59F25022),
            color: TaskEraColors.q1,
          )),
          const SizedBox(width: 7),
          Expanded(child: _CommandQuadCell(
            label: 'Q2 FOCUS', count: '6', sub: '3 scheduled',
            bg: const Color(0x247FBA00), border: const Color(0x4D7FBA00),
            color: const Color(0xFF9FCD44),
          )),
        ]),
        const SizedBox(height: 12),
        _LargeLine(dot: TaskEraColors.q1, text: 'Submit assignment before deadline'),
        const SizedBox(height: 6),
        Opacity(opacity: 0.72,
            child: _LargeLine(dot: TaskEraColors.q2, text: 'Study for exam - Chapter 4')),
      ]),
    );
  }
}

class _CommandQuadCell extends StatelessWidget {
  final String label, count, sub;
  final Color bg, border, color;
  const _CommandQuadCell({required this.label, required this.count, required this.sub,
      required this.bg, required this.border, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(width: 0.5, color: border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
            style: TextStyle(fontFamily: 'Inter', fontSize: 9,
                fontWeight: FontWeight.w800, color: color, height: 1)),
        Text(count,
            style: const TextStyle(fontFamily: 'Fraunces', fontSize: 28,
                fontVariations: [FontVariation('wght', 700)],
                color: Colors.white, height: 1.1)),
        Text(sub,
            style: const TextStyle(fontFamily: 'Inter', fontSize: 10,
                color: Color(0x80FFFFFF), height: 1)),
      ]),
    );
  }
}

class _LargeLine extends StatelessWidget {
  final Color dot;
  final String text;
  const _LargeLine({required this.dot, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(width: 9, height: 9,
        decoration: BoxDecoration(shape: BoxShape.circle,
            border: Border.all(width: 1.5, color: dot)),
      ),
      const SizedBox(width: 7),
      Expanded(child: Text(text,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontFamily: 'Inter', fontSize: 12,
              color: Colors.white, height: 1.2))),
    ]);
  }
}

class _TodayCardLarge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 245,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0A0A0C), Color(0xFF18181D)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(width: 0.5, color: const Color(0x40FFFFFF)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Text('Today',
              style: TextStyle(fontFamily: 'Inter', fontSize: 13,
                  fontWeight: FontWeight.w800, color: Colors.white,
                  letterSpacing: -0.2, height: 1)),
          const Spacer(),
          const Text('Wed 13',
              style: TextStyle(fontFamily: 'Inter', fontSize: 10,
                  color: Color(0x4DFFFFFF), height: 1)),
        ]),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: const LinearProgressIndicator(
            value: 0.25, minHeight: 4,
            backgroundColor: Color(0x14FFFFFF),
            valueColor: AlwaysStoppedAnimation(Color(0xFF9FCD44)),
          ),
        ),
        const SizedBox(height: 6),
        Row(children: [
          const Text('3 of 11 done',
              style: TextStyle(fontFamily: 'Inter', fontSize: 10,
                  color: Color(0x66FFFFFF), height: 1)),
          const Spacer(),
          const Text('25%',
              style: TextStyle(fontFamily: 'Inter', fontSize: 10,
                  fontWeight: FontWeight.w700, color: Color(0xFF9FCD44), height: 1)),
        ]),
        const SizedBox(height: 10),
        _TodayCardLine(dot: TaskEraColors.q1, text: 'Submit assignment before deadline',
            badge: 'Q1', badgeBg: const Color(0x24FF453A), badgeFg: const Color(0xFFFF8080)),
        const SizedBox(height: 6),
        Opacity(opacity: 0.75, child: _TodayCardLine(dot: TaskEraColors.q2,
            text: 'Study for exam — Chapter 4',
            badge: 'Q2', badgeBg: const Color(0x247FBA00), badgeFg: const Color(0xFF9FCD44))),
        const SizedBox(height: 6),
        Opacity(opacity: 0.45, child: _TodayCardLine(
            dot: const Color(0x33FFFFFF),
            text: 'Reply to Priya re: launch',
            badge: 'Q3', badgeBg: Colors.transparent, badgeFg: const Color(0x4DFFFFFF))),
        const Spacer(),
        const Text('+8 more · TaskEra',
            style: TextStyle(fontFamily: 'Inter', fontSize: 10,
                color: Color(0x33FFFFFF), height: 1)),
      ]),
    );
  }
}

class _TodayCardLine extends StatelessWidget {
  final Color dot;
  final String text, badge;
  final Color badgeBg, badgeFg;
  const _TodayCardLine({required this.dot, required this.text,
      required this.badge, required this.badgeBg, required this.badgeFg});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(width: 9, height: 9,
          decoration: BoxDecoration(shape: BoxShape.circle,
              border: Border.all(width: 1.5, color: dot))),
      const SizedBox(width: 7),
      Expanded(child: Text(text, overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontFamily: 'Inter', fontSize: 12,
              color: Colors.white, height: 1.2))),
      const SizedBox(width: 4),
      Container(
        padding: const EdgeInsets.fromLTRB(5, 1, 5, 1),
        decoration: BoxDecoration(color: badgeBg, borderRadius: BorderRadius.circular(3)),
        child: Text(badge, style: TextStyle(fontFamily: 'Inter', fontSize: 9,
            color: badgeFg, height: 1)),
      ),
    ]);
  }
}

class _TodayCardLock extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(13, 10, 13, 10),
      decoration: BoxDecoration(
        color: const Color(0x12FFFFFF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(width: 0.5, color: const Color(0x1FFFFFFF)),
      ),
      child: Row(children: [
        Container(
          width: 26, height: 26,
          decoration: BoxDecoration(
            color: const Color(0x267FBA00),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(width: 0.5, color: const Color(0x4D7FBA00)),
          ),
          child: const Icon(Icons.check_box_rounded, color: Color(0xFF9FCD44), size: 14),
        ),
        const SizedBox(width: 9),
        const Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Today · 3 of 11 done',
                style: TextStyle(fontFamily: 'Inter', fontSize: 12,
                    fontWeight: FontWeight.w700, color: Colors.white, height: 1.2)),
            Text('Next: Submit assignment · Q1 · TaskEra',
                style: TextStyle(fontFamily: 'Inter', fontSize: 10,
                    color: Color(0x73FFFFFF), height: 1.3)),
          ]),
        ),
        const Text('25%',
            style: TextStyle(fontFamily: 'Inter', fontSize: 10,
                fontWeight: FontWeight.w700, color: Color(0xFF9FCD44), height: 1)),
      ]),
    );
  }
}

class _DoThisNowLarge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 245,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF120808), Color(0xFF1E1008)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(width: 0.5, color: const Color(0x4DF25022)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.play_arrow_rounded, color: TaskEraColors.q1, size: 13),
          const SizedBox(width: 6),
          const Text('DO THIS NOW',
              style: TextStyle(fontFamily: 'Inter', fontSize: 10,
                  fontWeight: FontWeight.w800, letterSpacing: 0.6,
                  color: TaskEraColors.q1, height: 1)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.fromLTRB(7, 2, 7, 2),
            decoration: BoxDecoration(
              color: const Color(0x24F25022),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text('Q1 · URGENT',
                style: TextStyle(fontFamily: 'Inter', fontSize: 9,
                    fontWeight: FontWeight.w700, color: TaskEraColors.q1, height: 1)),
          ),
        ]),
        const Spacer(),
        const Text('Submit assignment before deadline',
            style: TextStyle(fontFamily: 'Inter', fontSize: 21,
                fontWeight: FontWeight.w700, color: Colors.white, height: 1.2)),
        const SizedBox(height: 8),
        Row(children: [
          Container(width: 7, height: 7,
              decoration: const BoxDecoration(
                  color: Color(0xFFFF453A), shape: BoxShape.circle)),
          const SizedBox(width: 6),
          const Text('Overdue · AI Score 9.2',
              style: TextStyle(fontFamily: 'Inter', fontSize: 12,
                  color: Color(0x8CFFFFFF), height: 1)),
        ]),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: const LinearProgressIndicator(
            value: 0, minHeight: 4,
            backgroundColor: Color(0x1AFFFFFF),
            valueColor: AlwaysStoppedAnimation(TaskEraColors.q1),
          ),
        ),
        const SizedBox(height: 8),
        Row(children: [
          const Text('Tap to start · Skip →',
              style: TextStyle(fontFamily: 'Inter', fontSize: 10,
                  color: Color(0x59FFFFFF), height: 1)),
          const Spacer(),
          const Text('TaskEra',
              style: TextStyle(fontFamily: 'Inter', fontSize: 10,
                  fontWeight: FontWeight.w700, color: Color(0x4DFFFFFF), height: 1)),
        ]),
      ]),
    );
  }
}

class _DoThisNowLock extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(13, 10, 13, 10),
      decoration: BoxDecoration(
        color: const Color(0x14F25022),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(width: 0.5, color: const Color(0x40F25022)),
      ),
      child: Row(children: [
        Container(
          width: 26, height: 26,
          decoration: const BoxDecoration(
            color: Color(0x2EF25022), shape: BoxShape.circle,
            border: Border.fromBorderSide(BorderSide(
                color: Color(0x66F25022), width: 0.5)),
          ),
          child: const Icon(Icons.play_arrow_rounded, color: TaskEraColors.q1, size: 12),
        ),
        const SizedBox(width: 9),
        const Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Submit assignment before deadline',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontFamily: 'Inter', fontSize: 12,
                    fontWeight: FontWeight.w700, color: Colors.white, height: 1.2)),
            Text('Q1 · Urgent · Score 9.2 · TaskEra',
                style: TextStyle(fontFamily: 'Inter', fontSize: 10,
                    color: Color(0x73FFFFFF), height: 1.3)),
          ]),
        ),
      ]),
    );
  }
}

class _NextEventSmall extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 130, height: 130,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0A1628), Color(0xFF0D1E3A)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(width: 0.5, color: const Color(0x4D00A4EF)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: 7, height: 7,
              decoration: const BoxDecoration(color: TaskEraColors.q3, shape: BoxShape.circle)),
          const SizedBox(width: 4),
          const Text('Calendar',
              style: TextStyle(fontFamily: 'Inter', fontSize: 10,
                  fontWeight: FontWeight.w600, color: TaskEraColors.q3, height: 1)),
        ]),
        const Spacer(),
        const Text('Next · 11:00 AM',
            style: TextStyle(fontFamily: 'Inter', fontSize: 9,
                color: Color(0x73FFFFFF), height: 1.3)),
        const SizedBox(height: 3),
        const Text('Q2 planning review',
            style: TextStyle(fontFamily: 'Inter', fontSize: 12,
                fontWeight: FontWeight.w600, color: Colors.white, height: 1.3)),
        const SizedBox(height: 4),
        const Text('30 min · 6 people',
            style: TextStyle(fontFamily: 'Inter', fontSize: 9,
                color: Color(0x59FFFFFF), height: 1)),
      ]),
    );
  }
}

class _TodaysScheduleMedium extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0A1628), Color(0xFF0D1E3A)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(width: 0.5, color: const Color(0x4000A4EF)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Expanded(child: Text('Today · 3 events',
              style: TextStyle(fontFamily: 'Inter', fontSize: 12,
                  fontWeight: FontWeight.w600, color: Colors.white, height: 1))),
          const Text('Tue 29',
              style: TextStyle(fontFamily: 'Inter', fontSize: 10,
                  color: Color(0x4DFFFFFF), height: 1)),
        ]),
        const SizedBox(height: 8),
        _ScheduleLine(time: '9 AM', label: 'Team standup',
            bg: const Color(0x2600A4EF), border: const Color(0x4D00A4EF),
            labelColor: TaskEraColors.q3),
        const SizedBox(height: 5),
        _ScheduleLine(time: '11 AM', label: 'Q2 planning review · Invite',
            bg: const Color(0x1A7FBA00), border: const Color(0x407FBA00),
            labelColor: const Color(0xFF9FCD44)),
        const SizedBox(height: 5),
        _ScheduleLine(time: '2 PM', label: 'Design sync',
            bg: const Color(0x0FFFFFFF), border: Colors.transparent,
            labelColor: const Color(0x99FFFFFF)),
      ]),
    );
  }
}

class _ScheduleLine extends StatelessWidget {
  final String time, label;
  final Color bg, border, labelColor;
  const _ScheduleLine({required this.time, required this.label,
      required this.bg, required this.border, required this.labelColor});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      SizedBox(
        width: 36,
        child: Text(time,
            style: const TextStyle(fontFamily: 'Inter', fontSize: 9,
                color: Color(0x66FFFFFF), height: 1)),
      ),
      Expanded(
        child: Container(
          padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(6),
            border: border == Colors.transparent ? null
                : Border.all(width: 0.5, color: border),
          ),
          child: Text(label, overflow: TextOverflow.ellipsis,
              style: TextStyle(fontFamily: 'Inter', fontSize: 10,
                  fontWeight: FontWeight.w600, color: labelColor, height: 1.2)),
        ),
      ),
    ]);
  }
}

class _HabitCheckSmall extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 130, height: 130,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF120A1F), Color(0xFF1A0D2E)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(width: 0.5, color: const Color(0x4DBF5AF2)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: 7, height: 7,
              decoration: const BoxDecoration(color: Color(0xFFBF5AF2), shape: BoxShape.circle)),
          const SizedBox(width: 4),
          const Text('Habits',
              style: TextStyle(fontFamily: 'Inter', fontSize: 10,
                  fontWeight: FontWeight.w600, color: Color(0xFFBF5AF2), height: 1)),
        ]),
        const SizedBox(height: 4),
        const Text('Today · 1 of 4 done',
            style: TextStyle(fontFamily: 'Inter', fontSize: 9,
                color: Color(0x73FFFFFF), height: 1)),
        const Spacer(),
        _HabitCheckLine(done: true, label: 'Morning journal'),
        const SizedBox(height: 4),
        _HabitCheckLine(done: false, label: 'Gym workout'),
        const SizedBox(height: 4),
        _HabitCheckLine(done: false, label: 'Read 30 min'),
      ]),
    );
  }
}

class _HabitCheckLine extends StatelessWidget {
  final bool done;
  final String label;
  const _HabitCheckLine({required this.done, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(
        width: 10, height: 10,
        decoration: BoxDecoration(
          color: done ? const Color(0xFFBF5AF2) : Colors.transparent,
          shape: BoxShape.circle,
          border: done ? null : Border.all(width: 1.5, color: const Color(0x33FFFFFF)),
        ),
        child: done ? const Icon(Icons.check, color: Colors.white, size: 7) : null,
      ),
      const SizedBox(width: 5),
      Text(label,
          style: TextStyle(fontFamily: 'Inter', fontSize: 9,
              color: done ? const Color(0xB3FFFFFF) : const Color(0x59FFFFFF),
              height: 1)),
    ]);
  }
}

class _HabitsTodayMedium extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF120A1F), Color(0xFF1A0D2E)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(width: 0.5, color: const Color(0x33BF5AF2)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Expanded(child: Text('Habits · 1 of 4',
              style: TextStyle(fontFamily: 'Inter', fontSize: 12,
                  fontWeight: FontWeight.w600, color: Colors.white, height: 1))),
          const Text('14🔥',
              style: TextStyle(fontFamily: 'Inter', fontSize: 10,
                  fontWeight: FontWeight.w700, color: Color(0xFFBF5AF2), height: 1)),
        ]),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: const LinearProgressIndicator(
            value: 0.25, minHeight: 3,
            backgroundColor: Color(0x1AFFFFFF),
            valueColor: AlwaysStoppedAnimation(Color(0xFFBF5AF2)),
          ),
        ),
        const SizedBox(height: 8),
        _HabitMediumLine(done: true, label: 'Morning journaling'),
        const SizedBox(height: 5),
        _HabitMediumLine(done: false, label: 'Gym workout'),
        const SizedBox(height: 5),
        _HabitMediumLine(done: false, label: 'Read 30 min'),
        const SizedBox(height: 5),
        _HabitMediumLine(done: false, label: 'Cold shower'),
      ]),
    );
  }
}

class _HabitMediumLine extends StatelessWidget {
  final bool done;
  final String label;
  const _HabitMediumLine({required this.done, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(
        width: 11, height: 11,
        decoration: BoxDecoration(
          color: done ? const Color(0xFFBF5AF2) : Colors.transparent,
          shape: BoxShape.circle,
          border: done ? null : Border.all(width: 1.5, color: const Color(0x33FFFFFF)),
        ),
        child: done ? const Icon(Icons.check, color: Colors.white, size: 8) : null,
      ),
      const SizedBox(width: 7),
      Text(label,
          style: TextStyle(fontFamily: 'Inter', fontSize: 12,
              color: done ? Colors.white : const Color(0x73FFFFFF), height: 1.2)),
    ]);
  }
}

class _LastNoteSmall extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 130, height: 130,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A1400), Color(0xFF2A1F00)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(width: 0.5, color: const Color(0x40FFB900)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: 7, height: 7,
              decoration: const BoxDecoration(color: TaskEraColors.q4, shape: BoxShape.circle)),
          const SizedBox(width: 4),
          const Text('Notes',
              style: TextStyle(fontFamily: 'Inter', fontSize: 10,
                  fontWeight: FontWeight.w600, color: TaskEraColors.q4, height: 1)),
        ]),
        const SizedBox(height: 8),
        const Expanded(
          child: Text('MVP launch plan v2',
              style: TextStyle(fontFamily: 'Inter', fontSize: 13,
                  fontWeight: FontWeight.w600, color: Colors.white, height: 1.3)),
        ),
        const Text('Updated today',
            style: TextStyle(fontFamily: 'Inter', fontSize: 9,
                color: Color(0x59FFFFFF), height: 1)),
      ]),
    );
  }
}

class _RecentNotesMedium extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A1400), Color(0xFF2A1F00)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(width: 0.5, color: const Color(0x33FFB900)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Expanded(child: Text('Notes · 3 recent',
              style: TextStyle(fontFamily: 'Inter', fontSize: 12,
                  fontWeight: FontWeight.w600, color: Colors.white, height: 1))),
          const Text('TaskEra',
              style: TextStyle(fontFamily: 'Inter', fontSize: 10,
                  color: Color(0x99FFB900), height: 1)),
        ]),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.fromLTRB(9, 6, 9, 6),
          decoration: BoxDecoration(
            color: const Color(0x14FFB900),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(width: 0.5, color: const Color(0x26FFB900)),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('MVP launch plan v2',
                style: TextStyle(fontFamily: 'Inter', fontSize: 12,
                    fontWeight: FontWeight.w500, color: Colors.white, height: 1.2)),
            const Text('Updated today',
                style: TextStyle(fontFamily: 'Inter', fontSize: 9,
                    color: Color(0x40FFFFFF), height: 1.3)),
          ]),
        ),
        const SizedBox(height: 5),
        _NoteRow(title: 'Q2 goals review', time: 'Yesterday'),
        const SizedBox(height: 5),
        _NoteRow(title: 'Investor meeting notes', time: '2d ago'),
      ]),
    );
  }
}

class _NoteRow extends StatelessWidget {
  final String title, time;
  const _NoteRow({required this.title, required this.time});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(9, 6, 9, 6),
      decoration: BoxDecoration(
        color: const Color(0x0AFFFFFF),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title,
            style: const TextStyle(fontFamily: 'Inter', fontSize: 12,
                color: Color(0xB3FFFFFF), height: 1.2)),
        Text(time,
            style: const TextStyle(fontFamily: 'Inter', fontSize: 9,
                color: Color(0x40FFFFFF), height: 1.3)),
      ]),
    );
  }
}

class _InboxSmall extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 130, height: 130,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0D0F1A), Color(0xFF141626)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(width: 0.5, color: const Color(0x400A84FF)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: 7, height: 7,
              decoration: const BoxDecoration(color: TaskEraColors.acc, shape: BoxShape.circle)),
          const SizedBox(width: 4),
          const Text('Inbox',
              style: TextStyle(fontFamily: 'Inter', fontSize: 10,
                  fontWeight: FontWeight.w600, color: TaskEraColors.acc, height: 1)),
        ]),
        const SizedBox(height: 6),
        const Text('3',
            style: TextStyle(fontFamily: 'Fraunces', fontSize: 28,
                fontVariations: [FontVariation('wght', 700)],
                color: Colors.white, height: 1)),
        const Text('items need action',
            style: TextStyle(fontFamily: 'Inter', fontSize: 9,
                color: Color(0x73FFFFFF), height: 1.3)),
        const Spacer(),
        const Text('Review →',
            style: TextStyle(fontFamily: 'Inter', fontSize: 10,
                fontWeight: FontWeight.w600, color: TaskEraColors.acc, height: 1)),
      ]),
    );
  }
}

class _InboxMedium extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0D0F1A), Color(0xFF141626)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(width: 0.5, color: const Color(0x330A84FF)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Expanded(child: Text('Inbox · 3 items',
              style: TextStyle(fontFamily: 'Inter', fontSize: 12,
                  fontWeight: FontWeight.w600, color: Colors.white, height: 1))),
          Container(
            padding: const EdgeInsets.fromLTRB(6, 2, 6, 2),
            decoration: BoxDecoration(
              color: const Color(0x330A84FF),
              borderRadius: BorderRadius.circular(5),
            ),
            child: const Text('New',
                style: TextStyle(fontFamily: 'Inter', fontSize: 9,
                    fontWeight: FontWeight.w700, color: TaskEraColors.acc, height: 1)),
          ),
        ]),
        const SizedBox(height: 8),
        _InboxItem(dot: TaskEraColors.q1, title: 'Assignment deadline email', sub: 'Add as Q1 task?'),
        const SizedBox(height: 5),
        Opacity(opacity: 0.8,
            child: _InboxItem(dot: TaskEraColors.q2, title: 'Team standup moved', sub: 'Reschedule?')),
        const SizedBox(height: 5),
        Opacity(opacity: 0.8,
            child: _InboxItem(dot: const Color(0xFFBF5AF2),
                title: 'Client feedback received', sub: 'Create task?')),
      ]),
    );
  }
}

class _InboxItem extends StatelessWidget {
  final Color dot;
  final String title, sub;
  const _InboxItem({required this.dot, required this.title, required this.sub});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(width: 7, height: 7,
          decoration: BoxDecoration(color: dot, shape: BoxShape.circle)),
      const SizedBox(width: 7),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style: const TextStyle(fontFamily: 'Inter', fontSize: 12,
                  color: Colors.white, height: 1.2)),
          Text(sub,
              style: const TextStyle(fontFamily: 'Inter', fontSize: 10,
                  color: Color(0x66FFFFFF), height: 1.3)),
        ]),
      ),
    ]);
  }
}

class _LockScreenInline extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 9, 12, 9),
      decoration: BoxDecoration(
        color: const Color(0x14FFFFFF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(width: 0.5, color: const Color(0x1AFFFFFF)),
      ),
      child: Row(children: [
        Row(children: [
          Container(width: 6, height: 6,
              decoration: const BoxDecoration(color: TaskEraColors.q1, shape: BoxShape.circle)),
          const SizedBox(width: 3),
          Container(width: 6, height: 6,
              decoration: const BoxDecoration(color: TaskEraColors.q2, shape: BoxShape.circle)),
          const SizedBox(width: 3),
          Container(width: 6, height: 6,
              decoration: const BoxDecoration(color: TaskEraColors.q3, shape: BoxShape.circle)),
          const SizedBox(width: 3),
          Container(width: 6, height: 6,
              decoration: const BoxDecoration(
                  color: Color(0x33FFFFFF), shape: BoxShape.circle)),
        ]),
        const SizedBox(width: 8),
        const Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('2 Q1 · 4 Q2 active',
                style: TextStyle(fontFamily: 'Inter', fontSize: 12,
                    fontWeight: FontWeight.w500, color: Colors.white, height: 1.2)),
            Text('TaskEra · 14🔥 streak',
                style: TextStyle(fontFamily: 'Inter', fontSize: 10,
                    color: Color(0x73FFFFFF), height: 1.3)),
          ]),
        ),
      ]),
    );
  }
}
