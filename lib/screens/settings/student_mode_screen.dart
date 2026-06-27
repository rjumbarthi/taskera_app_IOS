import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../data/providers/lists_provider.dart';
import '../../data/providers/tasks_provider.dart';
import '../../data/repositories/focus_session_repository.dart';
import '../../settings/kaal_settings.dart';
import '../../theme/kaal_colors.dart';
import '../../theme/kaal_theme.dart';
import '../../widgets/add_back_button.dart';
import '../../widgets/kaal_top_bar.dart';
import '../../widgets/wallpaper_background.dart';

class StudentModeScreen extends ConsumerWidget {
  const StudentModeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors    = KaalTheme.of(context).colors;
    final safeBot   = MediaQuery.of(context).padding.bottom;
    final wallpaper = ref.watch(kaalSettingsProvider).wallpaper;

    return Stack(children: [
      Positioned.fill(child: WallpaperBackground(wallpaper: wallpaper)),
      Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          KaalTopBar(
            title: 'Student Mode',
            subtitle: 'UPSC · JEE · MBA · Board exams',
            leading: AddBackButton(onTap: () => Navigator.of(context).pop()),
            actions: [
              Container(width: 8, height: 8,
                  decoration: const BoxDecoration(
                      color: KaalColors.q2, shape: BoxShape.circle)),
            ],
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(12, 8, 12, safeBot + 24),
          children: [
            _SectionLabel('Exam countdowns', colors),
            const SizedBox(height: 6),
            _ExamCountdowns(colors: colors),
            const SizedBox(height: 9),
            _StudyPlanCard(colors: colors),
            const SizedBox(height: 9),
            _SectionLabel('Subject task groups', colors),
            const SizedBox(height: 6),
            _SubjectGroups(colors: colors),
            const SizedBox(height: 9),
            _WeekStatsCard(colors: colors),
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
  final KaalColors colors;
  const _SectionLabel(this.text, this.colors);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 2, 0, 0),
      child: Text(text.toUpperCase(),
          style: TextStyle(fontFamily: 'Inter', fontSize: 9,
              fontWeight: FontWeight.w700, letterSpacing: 0.5,
              color: colors.ink3, height: 1)),
    );
  }
}

// ── Exam countdowns ───────────────────────────────────────────────────────────

class _ExamCountdowns extends StatelessWidget {
  final KaalColors colors;
  const _ExamCountdowns({required this.colors});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 130,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _AddExamCard(colors: colors),
        ],
      ),
    );
  }
}

class _AddExamCard extends StatelessWidget {
  final KaalColors colors;
  const _AddExamCard({required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      decoration: BoxDecoration(
        color: colors.surf2,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(width: 1.5, color: colors.bdr2,
            style: BorderStyle.none),
      ),
      child: CustomPaint(
        painter: _DashedBorderPainter(color: colors.bdr2),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text('+',
              style: TextStyle(fontFamily: 'Inter', fontSize: 20,
                  color: colors.ink3, height: 1)),
          const SizedBox(height: 4),
          Text('Add exam',
              style: TextStyle(fontFamily: 'Inter', fontSize: 11,
                  color: colors.ink3, height: 1.2)),
        ]),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  const _DashedBorderPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
          Rect.fromLTWH(0.75, 0.75, size.width - 1.5, size.height - 1.5),
          const Radius.circular(13)));
    _drawDashed(canvas, path, paint);
  }

  void _drawDashed(Canvas canvas, Path path, Paint paint) {
    const dashLen = 5.0, gapLen = 4.0;
    final metrics = path.computeMetrics();
    for (final m in metrics) {
      double dist = 0;
      while (dist < m.length) {
        final end = (dist + dashLen).clamp(0, m.length);
        canvas.drawPath(m.extractPath(dist, end.toDouble()), paint);
        dist += dashLen + gapLen;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter old) => old.color != color;
}

// ── Study plan card ───────────────────────────────────────────────────────────

class _StudyPlanCard extends StatelessWidget {
  final KaalColors colors;
  const _StudyPlanCard({required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(13, 12, 13, 12),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(width: 0.5, color: colors.bdr2),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text("Today's study plan",
            style: TextStyle(fontFamily: 'Inter', fontSize: 13,
                fontWeight: FontWeight.w700, color: colors.ink, height: 1)),
        const SizedBox(height: 9),
        Text('No study plan yet — add subjects and schedule tasks to build one.',
            style: TextStyle(fontFamily: 'Inter', fontSize: 12,
                color: colors.ink3, height: 1.4)),
      ]),
    );
  }
}

// ── Subject groups ────────────────────────────────────────────────────────────

class _SubjectGroups extends ConsumerWidget {
  final KaalColors colors;
  const _SubjectGroups({required this.colors});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lists = ref.watch(listsProvider).value ?? const <CustomList>[];
    return Column(children: [
      if (lists.isEmpty)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(11),
            border: Border.all(width: 0.5, color: colors.bdr),
          ),
          child: Text('Create a list to track a subject.',
              style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: colors.ink3, height: 1.4)),
        )
      else
        for (final l in lists) ...[
          _SubjectRowLive(list: l, colors: colors),
          const SizedBox(height: 6),
        ],
      const SizedBox(height: 6),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(12, 9, 12, 9),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(11),
          border: Border.all(width: 1.5, color: colors.bdr2,
              style: BorderStyle.none),
        ),
        child: CustomPaint(
          painter: _DashedBorderPainter(color: colors.bdr2),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 9),
            child: Text('+ Add subject',
                style: TextStyle(fontFamily: 'Inter', fontSize: 12,
                    fontWeight: FontWeight.w600, color: colors.ink3, height: 1)),
          ),
        ),
      ),
    ]);
  }
}

/// One subject row backed by a real [CustomList]; counts come from its items.
class _SubjectRowLive extends ConsumerWidget {
  final CustomList list;
  final KaalColors colors;
  const _SubjectRowLive({required this.list, required this.colors});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(listItemsProvider(list.id)).value ?? const <CustomListItem>[];
    final total = items.length;
    final left = items.where((i) => !i.isDone).length;
    final sub = total == 0
        ? 'No items yet'
        : '$total item${total == 1 ? '' : 's'}${left > 0 ? ' · $left left' : ' · all done'}';
    return _SubjectRow(
      emoji: list.emoji,
      label: list.title,
      sub: sub,
      quadLabel: '',
      quadColor: colors.ink3,
      iconBg: colors.surf2,
      border: colors.bdr,
      colors: colors,
    );
  }
}

class _SubjectRow extends StatelessWidget {
  final String emoji;
  final String label;
  final String sub;
  final String quadLabel;
  final Color quadColor;
  final Color iconBg;
  final Color border;
  final KaalColors colors;
  const _SubjectRow({required this.emoji, required this.label, required this.sub,
      required this.quadLabel, required this.quadColor, required this.iconBg,
      required this.border, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 9, 12, 9),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(width: 0.5, color: border),
      ),
      child: Row(children: [
        Container(
          width: 28, height: 28,
          decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(8)),
          alignment: Alignment.center,
          child: Text(emoji, style: const TextStyle(fontSize: 13)),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label,
                style: TextStyle(fontFamily: 'Inter', fontSize: 13,
                    fontWeight: FontWeight.w600, color: colors.ink, height: 1.2)),
            Text(sub,
                style: TextStyle(fontFamily: 'Inter', fontSize: 10,
                    color: colors.ink3, height: 1.3)),
          ]),
        ),
        Text(quadLabel,
            style: TextStyle(fontFamily: 'Inter', fontSize: 12,
                fontWeight: FontWeight.w600, color: quadColor, height: 1)),
        const SizedBox(width: 6),
        Text('›',
            style: TextStyle(fontSize: 18, color: colors.ink3, height: 1)),
      ]),
    );
  }
}

// ── Week stats card ───────────────────────────────────────────────────────────

class _WeekStatsCard extends ConsumerWidget {
  final KaalColors colors;
  const _WeekStatsCard({required this.colors});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final monday = today.subtract(Duration(days: today.weekday - 1));

    // Studied this week — total focus time.
    final sessions = ref.watch(weeklyFocusSessionsProvider).value ?? [];
    final secs = sessions.fold<int>(0, (a, s) => a + s.durationSeconds);
    final mins = secs ~/ 60;
    final hrs = mins ~/ 60;
    final studied = hrs > 0 ? (mins % 60 > 0 ? '${hrs}h ${mins % 60}m' : '${hrs}h') : '${mins}m';

    // Tasks done this week + productive-day streak.
    final done = ref.watch(doneTasksProvider).value ?? [];
    final doneThisWeek =
        done.where((t) => t.doneAt != null && !t.doneAt!.isBefore(monday)).length;
    final doneDays = done
        .where((t) => t.doneAt != null)
        .map((t) => DateTime(t.doneAt!.year, t.doneAt!.month, t.doneAt!.day))
        .toSet();
    var streak = 0;
    var anchor = doneDays.contains(today) ? today : today.subtract(const Duration(days: 1));
    while (doneDays.contains(anchor)) {
      streak++;
      anchor = anchor.subtract(const Duration(days: 1));
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(13, 10, 13, 12),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(width: 0.5, color: colors.bdr),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('This week',
            style: TextStyle(fontFamily: 'Inter', fontSize: 12,
                fontWeight: FontWeight.w700, color: colors.ink, height: 1)),
        const SizedBox(height: 8),
        Row(children: [
          _WeekCell(value: studied, label: 'Studied',
              bg: colors.surf2, valueColor: colors.ink),
          const SizedBox(width: 6),
          _WeekCell(value: '$doneThisWeek', label: 'Done',
              bg: colors.surf2, valueColor: KaalColors.q2),
          const SizedBox(width: 6),
          _WeekCell(value: '$streak🔥', label: 'Day streak',
              bg: const Color(0x14FFB900), valueColor: KaalColors.q4),
        ]),
      ]),
    );
  }
}

class _WeekCell extends StatelessWidget {
  final String value;
  final String label;
  final Color bg;
  final Color valueColor;
  const _WeekCell({required this.value, required this.label,
      required this.bg, required this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(9)),
        child: Column(children: [
          Text(value,
              style: TextStyle(fontFamily: 'Fraunces', fontSize: 18,
                  fontVariations: const [FontVariation('wght', 700)],
                  color: valueColor, height: 1)),
          const SizedBox(height: 1),
          Text(label,
              style: TextStyle(fontFamily: 'Inter', fontSize: 9,
                  color: Colors.white54, height: 1.3)),
        ]),
      ),
    );
  }
}
