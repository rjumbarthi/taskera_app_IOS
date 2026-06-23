import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/providers/tasks_provider.dart';
import '../../data/providers/time_tracker_provider.dart';
import '../../theme/kaal_colors.dart';
import '../../theme/kaal_theme.dart';
import '../../l10n/app_l10n.dart';
import '../../widgets/add_back_button.dart';

// ── Screen ────────────────────────────────────────────────────────────────────

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors  = KaalTheme.of(context).colors;
    final done    = ref.watch(doneTasksProvider).valueOrNull ?? [];
    final tracker = ref.watch(timeTrackerProvider);

    // Stat calculations
    final completedCount = done.length;
    final overdueCount   = done.where((t) => t.isOverdue).length;
    final onTimeFrac     = completedCount > 0 ? 1.0 - (overdueCount / completedCount) : 0.0;
    final onTimePct      = (onTimeFrac * 100).round();
    final timeLogged     = tracker.elapsedSeconds;

    // Daily completions — last 7 days
    final now = DateTime.now();
    final dailyCounts = List.generate(7, (i) {
      final day = now.subtract(Duration(days: 6 - i));
      return done.where((t) {
        if (t.doneAt == null) return false;
        final d = t.doneAt!;
        return d.year == day.year && d.month == day.month && d.day == day.day;
      }).length;
    });

    // Per-quadrant done counts
    final qCounts  = [1, 2, 3, 4].map((q) => done.where((t) => t.quadrant == q).length).toList();
    final maxQuad  = qCounts.reduce((a, b) => a > b ? a : b);
    final quadFrac = qCounts.map((c) => maxQuad > 0 ? c / maxQuad : 0.0).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Sub-bar
          Row(
            children: [
              AddBackButton(onTap: () => context.pop()),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(AppL10n.of(context).taskAnalytics, style: TextStyle(fontFamily: 'Fraunces', fontVariations: [FontVariation('wght', 600)], fontSize: 19, letterSpacing: -0.5, color: colors.ink, height: 1.1)),
                    Text(AppL10n.of(context).last7Days, style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: colors.ink3, height: 1.2)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Stat cells
          Row(
            children: [
              _StatCell(value: '$completedCount', label: 'Completed',    colors: colors),
              const SizedBox(width: 8),
              _StatCell(value: '$onTimePct%',     label: 'On-time rate', colors: colors),
              const SizedBox(width: 8),
              _StatCell(value: _fmtTime(timeLogged), label: 'Time logged', colors: colors),
            ],
          ),
          const SizedBox(height: 16),

          // Daily completions chart
          _SectionLabel(label: 'DAILY COMPLETIONS', colors: colors),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(11),
              border: Border.all(width: 0.5, color: colors.bdr),
            ),
            child: Column(
              children: [
                SizedBox(
                  height: 80,
                  child: CustomPaint(
                    painter: _BarChartPainter(
                      values: dailyCounts,
                      color: KaalColors.acc,
                      bgColor: Colors.white.withAlpha(0x15),
                    ),
                    size: Size.infinite,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: ['M', 'T', 'W', 'T', 'F', 'S', 'S'].map(
                    (d) => SizedBox(width: 28, child: Center(child: Text(d, style: TextStyle(fontFamily: 'Inter', fontSize: 9, color: colors.ink3)))),
                  ).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // By quadrant
          _SectionLabel(label: 'BY QUADRANT', colors: colors),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(11),
              border: Border.all(width: 0.5, color: colors.bdr),
            ),
            child: Column(
              children: [
                _QuadBar(label: 'Q1 · Do Now',    value: quadFrac[0], count: qCounts[0], color: KaalColors.q1, colors: colors),
                const SizedBox(height: 8),
                _QuadBar(label: 'Q2 · Schedule',  value: quadFrac[1], count: qCounts[1], color: KaalColors.q2, colors: colors),
                const SizedBox(height: 8),
                _QuadBar(label: 'Q3 · Delegate',  value: quadFrac[2], count: qCounts[2], color: KaalColors.q3, colors: colors),
                const SizedBox(height: 8),
                _QuadBar(label: 'Q4 · Eliminate', value: quadFrac[3], count: qCounts[3], color: KaalColors.q4, colors: colors),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // On-time vs Overdue
          _SectionLabel(label: 'ON-TIME VS OVERDUE', colors: colors),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.fromLTRB(12, 16, 12, 16),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(11),
              border: Border.all(width: 0.5, color: colors.bdr),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 100, height: 100,
                  child: CustomPaint(
                    painter: _DonutPainter(
                      fraction: onTimeFrac,
                      fgColor: colors.successFg,
                      bgColor: const Color(0xFFFF6B6B),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _LegendRow(color: const Color(0xFF9FCD44), label: 'On-time', value: '$onTimePct%', colors: colors),
                      const SizedBox(height: 8),
                      _LegendRow(color: const Color(0xFFFF6B6B), label: 'Overdue', value: '${100 - onTimePct}%', colors: colors),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // AI Insight
          Container(
            padding: const EdgeInsets.fromLTRB(12, 11, 12, 11),
            decoration: BoxDecoration(
              color: const Color(0x120A84FF),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(width: 0.5, color: const Color(0x400A84FF)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('KAAL AI · INSIGHT', style: TextStyle(fontFamily: 'Inter', fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 0.4, color: KaalColors.acc2)),
                const SizedBox(height: 5),
                Text(
                  'You complete 40% more tasks on Fridays. Q2 tasks have the best completion rate. Consider scheduling deep work on Friday mornings.',
                  style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: KaalColors.acc2, height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

String _fmtTime(int seconds) {
  final h = seconds ~/ 3600;
  final m = (seconds % 3600) ~/ 60;
  if (h > 0) return '${h}h ${m}m';
  if (m > 0) return '${m}m';
  return '0m';
}

// ── Reusable widgets ──────────────────────────────────────────────────────────

class _StatCell extends StatelessWidget {
  final String value, label;
  final KaalColors colors;
  const _StatCell({required this.value, required this.label, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(width: 0.5, color: colors.bdr),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: TextStyle(fontFamily: 'Fraunces', fontSize: 22, fontWeight: FontWeight.w700, color: colors.ink, height: 1.1)),
            Text(label, style: TextStyle(fontFamily: 'Inter', fontSize: 9, color: colors.ink3)),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  final KaalColors colors;
  const _SectionLabel({required this.label, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Text(label, style: TextStyle(fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.5, color: colors.ink3));
  }
}

class _QuadBar extends StatelessWidget {
  final String label;
  final double value;
  final int count;
  final Color color;
  final KaalColors colors;
  const _QuadBar({required this.label, required this.value, required this.count, required this.color, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 90,
          child: Text(label, style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: colors.ink2), overflow: TextOverflow.ellipsis),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: SizedBox(
              height: 5,
              child: Row(
                children: [
                  Expanded(flex: (value * 100).round(), child: Container(color: color)),
                  Expanded(flex: (100 - (value * 100).round()).clamp(0, 100), child: Container(color: colors.surf3)),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text('$count done', style: TextStyle(fontFamily: 'Inter', fontSize: 9, color: colors.ink3)),
      ],
    );
  }
}

class _LegendRow extends StatelessWidget {
  final Color color;
  final String label, value;
  final KaalColors colors;
  const _LegendRow({required this.color, required this.label, required this.value, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 8),
        Expanded(child: Text(label, style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: colors.ink))),
        Text(value, style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w700, color: color)),
      ],
    );
  }
}

// ── CustomPainters ────────────────────────────────────────────────────────────

class _BarChartPainter extends CustomPainter {
  final List<int> values;
  final Color color, bgColor;
  const _BarChartPainter({required this.values, required this.color, required this.bgColor});

  @override
  void paint(Canvas canvas, Size size) {
    final max = values.reduce((a, b) => a > b ? a : b).toDouble();
    final barW = size.width / (values.length * 2 - 1);
    final gap = barW;

    for (int i = 0; i < values.length; i++) {
      final x = i * (barW + gap);
      final barH = (values[i] / max) * size.height;
      final bgRect = RRect.fromRectAndRadius(Rect.fromLTWH(x, 0, barW, size.height), const Radius.circular(3));
      final barRect = RRect.fromRectAndRadius(Rect.fromLTWH(x, size.height - barH, barW, barH), const Radius.circular(3));
      canvas.drawRRect(bgRect, Paint()..color = bgColor);
      canvas.drawRRect(barRect, Paint()..color = color);
    }
  }

  @override
  bool shouldRepaint(_BarChartPainter old) => false;
}

class _DonutPainter extends CustomPainter {
  final double fraction;
  final Color fgColor, bgColor;
  const _DonutPainter({required this.fraction, required this.fgColor, required this.bgColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;
    final strokeW = 14.0;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeW
      ..strokeCap = StrokeCap.round;

    // Background arc
    paint.color = bgColor;
    canvas.drawCircle(center, radius, paint);

    // Foreground arc
    paint.color = fgColor;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -1.5708, // start at top (-π/2)
      fraction * 6.2832,
      false,
      paint,
    );

    // Center text
    final tp = TextPainter(
      text: TextSpan(
        text: '${(fraction * 100).round()}%',
        style: const TextStyle(fontFamily: 'Fraunces', fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(_DonutPainter old) => false;
}
