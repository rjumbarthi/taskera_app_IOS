import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/providers/tasks_provider.dart';
import '../../data/providers/time_tracker_provider.dart';
import '../../data/repositories/focus_session_repository.dart';
import '../../theme/kaal_colors.dart';
import '../../theme/kaal_theme.dart';
import '../../widgets/add_back_button.dart';

// ── Data ──────────────────────────────────────────────────────────────────────

class _LogEntry {
  final String title, timeRange, status, duration;
  final Color quadColor;
  const _LogEntry(this.title, this.timeRange, this.status, this.duration, this.quadColor);
}

class _EstRow {
  final String title, est, actual;
  const _EstRow(this.title, this.est, this.actual);
}

const _weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

Color _quadColor(int q) => switch (q) {
      1 => KaalColors.q1,
      2 => KaalColors.q2,
      3 => KaalColors.q3,
      _ => KaalColors.q4,
    };

// ── Body (reusable — embedded in merged Timer screen) ─────────────────────────

class TimeTrackBody extends ConsumerWidget {
  const TimeTrackBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => const SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(12, 8, 12, 16),
        child: TimeTrackContent(),
      );
}

/// The time-log content WITHOUT its own scroll view, so it can be embedded at
/// the bottom of the Timer screen as well as used standalone in TimeTrackScreen.
class TimeTrackContent extends ConsumerWidget {
  const TimeTrackContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors   = KaalTheme.of(context).colors;
    final tracker  = ref.watch(timeTrackerProvider);
    final notifier = ref.read(timeTrackerProvider.notifier);

    final startLabel = tracker.startedAtMs != null
        ? _fmtTime(DateTime.fromMillisecondsSinceEpoch(tracker.startedAtMs!))
        : '--:-- --';

    // ── Live data from focus-session history + tasks ──────────────────────────
    final tasks = ref.watch(allTasksProvider).value ?? [];
    final taskById = {for (final t in tasks) t.id: t};
    final sessions = ref.watch(weeklyFocusSessionsProvider).value ?? [];

    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final monday = todayStart.subtract(Duration(days: todayStart.weekday - 1));

    // TODAY'S LOG — completed/stopped sessions started today, newest first.
    final todayLog = <_LogEntry>[];
    final todaySorted = sessions.where((s) => !s.startedAt.isBefore(todayStart)).toList()
      ..sort((a, b) => b.startedAt.compareTo(a.startedAt));
    for (final s in todaySorted) {
      final end = s.startedAt.add(Duration(seconds: s.durationSeconds));
      todayLog.add(_LogEntry(
        taskById[s.taskId]?.title ?? 'Task #${s.taskId}',
        '${_fmtTime(s.startedAt)}–${_fmtTime(end)}',
        s.completed ? 'Done' : 'Logged',
        _fmtDuration(s.durationSeconds),
        _quadColor(s.quadrant),
      ));
    }

    // THIS WEEK — seconds per weekday split into [Q1, Q2, other], normalized.
    final week = List.generate(7, (_) => <double>[0, 0, 0]);
    for (final s in sessions) {
      final di = DateTime(s.startedAt.year, s.startedAt.month, s.startedAt.day)
          .difference(monday)
          .inDays;
      if (di < 0 || di > 6) continue;
      final b = s.quadrant == 1 ? 0 : (s.quadrant == 2 ? 1 : 2);
      week[di][b] += s.durationSeconds.toDouble();
    }
    final maxTotal =
        week.map((d) => d[0] + d[1] + d[2]).fold<double>(0, (m, v) => v > m ? v : m);
    final weekBars = [
      for (final d in week)
        maxTotal > 0 ? [d[0] / maxTotal, d[1] / maxTotal, d[2] / maxTotal] : <double>[0, 0, 0],
    ];

    // EST. VS ACTUAL — tasks with both an estimate and tracked time.
    final estRows = <_EstRow>[];
    var ratioSum = 0.0;
    var ratioN = 0;
    for (final t in tasks) {
      final est = t.timeAllocatedMin ?? 0;
      final actMin = (t.totalFocusSeconds / 60).round();
      if (est > 0 && actMin > 0) {
        estRows.add(_EstRow(t.title, 'Est ${_fmtMin(est)}', 'Act ${_fmtMin(actMin)}'));
        ratioSum += actMin / est;
        ratioN++;
      }
    }
    final estShown = estRows.take(5).toList();
    String? estInsight;
    if (ratioN > 0) {
      final avg = ratioSum / ratioN;
      if (avg >= 1.15) {
        estInsight = 'You underestimate tasks by ~${((avg - 1) * 100).round()}% on average';
      } else if (avg <= 0.85) {
        estInsight = 'You overestimate tasks by ~${((1 - avg) * 100).round()}% on average';
      } else {
        estInsight = 'Your time estimates are close to actual';
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
          // ACTIVE NOW card — reflects the task you started from Focus/DTN, or
          // an idle state when nothing is being tracked.
          if (tracker.taskTitle == null)
            _IdleTimerCard(colors: colors)
          else
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0x120A84FF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(width: 0.5, color: const Color(0x400A84FF)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tracker.running ? 'ACTIVE NOW' : 'PAUSED', style: const TextStyle(fontFamily: 'Inter', fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 0.4, color: KaalColors.acc2)),
                const SizedBox(height: 6),
                Text(tracker.taskTitle ?? '—', style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w600, color: colors.ink)),
                Text('Started $startLabel', style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: colors.ink3)),
                const SizedBox(height: 14),
                Center(
                  child: Text(
                    tracker.displayTime,
                    style: TextStyle(fontFamily: 'Fraunces', fontSize: 42, fontWeight: FontWeight.w700, color: colors.ink, letterSpacing: -1, height: 1),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: tracker.running ? notifier.pause : notifier.resume,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(9),
                            border: Border.all(width: 0.5, color: colors.bdr2),
                          ),
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(tracker.running ? Icons.pause : Icons.play_arrow, size: 14, color: colors.ink),
                              const SizedBox(width: 5),
                              Text(tracker.running ? 'Pause' : 'Resume', style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w600, color: colors.ink)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: GestureDetector(
                        onTap: notifier.stop,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(9),
                            border: Border.all(width: 0.5, color: const Color(0xFFFF6B6B).withAlpha(0x60)),
                          ),
                          alignment: Alignment.center,
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.stop, size: 14, color: Color(0xFFFF6B6B)),
                              SizedBox(width: 5),
                              Text('Stop', style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFFFF6B6B))),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // TODAY'S LOG
          Text("TODAY'S LOG", style: TextStyle(fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.5, color: colors.ink3)),
          const SizedBox(height: 6),
          if (todayLog.isEmpty)
            _Placeholder('No sessions logged today yet.', colors)
          else
            for (final entry in todayLog) ...[
              _LogRow(entry: entry, colors: colors),
              const SizedBox(height: 4),
            ],
          const SizedBox(height: 16),

          // THIS WEEK chart
          Text('THIS WEEK', style: TextStyle(fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.5, color: colors.ink3)),
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
                    painter: _StackedBarPainter(bars: weekBars),
                    size: Size.infinite,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: _weekDays.map(
                    (d) => SizedBox(width: 28, child: Center(child: Text(d, style: TextStyle(fontFamily: 'Inter', fontSize: 9, color: colors.ink3)))),
                  ).toList(),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _LegendDot(color: KaalColors.q1, label: 'Q1'),
                    const SizedBox(width: 12),
                    _LegendDot(color: KaalColors.q2, label: 'Q2'),
                    const SizedBox(width: 12),
                    _LegendDot(color: KaalColors.acc, label: 'Other'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // EST. VS ACTUAL
          Text('EST. VS ACTUAL', style: TextStyle(fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.5, color: colors.ink3)),
          const SizedBox(height: 6),
          if (estShown.isEmpty)
            _Placeholder('Track time on tasks that have a duration estimate to compare here.', colors)
          else
            Container(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(11),
                border: Border.all(width: 0.5, color: colors.bdr),
              ),
              child: Column(
                children: [
                  for (final row in estShown) ...[
                    _EstVsActualRow(row: row, colors: colors),
                    const SizedBox(height: 6),
                  ],
                  if (estInsight != null) ...[
                    Divider(height: 1, thickness: 0.5, color: colors.bdr),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Text('✦ ', style: TextStyle(color: KaalColors.acc2)),
                        Expanded(
                          child: Text(
                            estInsight,
                            style: const TextStyle(fontFamily: 'Inter', fontSize: 11, color: KaalColors.acc2, height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
      ],
    );
  }
}

// ── Screen (standalone — keeps /tasks/timetrack route working) ─────────────────

class TimeTrackScreen extends ConsumerWidget {
  const TimeTrackScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors  = KaalTheme.of(context).colors;
    final tracker = ref.watch(timeTrackerProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
          child: Row(
            children: [
              AddBackButton(onTap: () => context.pop()),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Time tracking', style: TextStyle(fontFamily: 'Fraunces', fontVariations: [FontVariation('wght', 600)], fontSize: 19, letterSpacing: -0.5, color: colors.ink, height: 1.1)),
                    Text('Today: ${_fmtDuration(tracker.elapsedSeconds)} tracked', style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: colors.ink3, height: 1.2)),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Grouping by task coming soon'))),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(10, 4, 10, 4),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(7),
                    border: Border.all(width: 0.5, color: colors.bdr),
                  ),
                  child: Text('By task', style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: colors.ink3)),
                ),
              ),
            ],
          ),
        ),
        const Expanded(child: TimeTrackBody()),
      ],
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

String _fmtTime(DateTime dt) {
  final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
  final m = dt.minute.toString().padLeft(2, '0');
  final ampm = dt.hour < 12 ? 'AM' : 'PM';
  return '$h:$m $ampm';
}

String _fmtDuration(int seconds) {
  final h = seconds ~/ 3600;
  final m = (seconds % 3600) ~/ 60;
  if (h > 0) return '${h}h ${m}m';
  return '${m}m';
}

String _fmtMin(int minutes) {
  if (minutes >= 60) {
    final h = minutes ~/ 60;
    final r = minutes % 60;
    return r > 0 ? '${h}h ${r}m' : '${h}h';
  }
  return '${minutes}m';
}

class _Placeholder extends StatelessWidget {
  final String text;
  final KaalColors colors;
  const _Placeholder(this.text, this.colors);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(width: 0.5, color: colors.bdr),
      ),
      child: Text(text,
          style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: colors.ink3, height: 1.4)),
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _LogRow extends StatelessWidget {
  final _LogEntry entry;
  final KaalColors colors;
  const _LogRow({required this.entry, required this.colors});

  @override
  Widget build(BuildContext context) {
    final running = entry.status == 'Running';
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 9, 12, 9),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(width: 0.5, color: colors.bdr),
      ),
      child: Row(
        children: [
          Container(width: 4, height: 4, decoration: BoxDecoration(shape: BoxShape.circle, color: entry.quadColor)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.title, style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w500, color: entry.quadColor)),
                Text(entry.timeRange, style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: colors.ink3)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(entry.duration, style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w600, color: running ? KaalColors.acc : colors.ink)),
              if (running)
                const Text('Running', style: TextStyle(fontFamily: 'Inter', fontSize: 9, color: KaalColors.acc2)),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    final colors = KaalTheme.of(context).colors;
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontFamily: 'Inter', fontSize: 9, color: colors.ink3)),
      ],
    );
  }
}

class _EstVsActualRow extends StatelessWidget {
  final _EstRow row;
  final KaalColors colors;
  const _EstVsActualRow({required this.row, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(row.title, style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: colors.ink))),
        Text(row.est, style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: colors.ink3)),
        const SizedBox(width: 8),
        Text('·', style: TextStyle(color: colors.ink3)),
        const SizedBox(width: 8),
        Text(row.actual, style: const TextStyle(fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFFFF6B6B))),
      ],
    );
  }
}

// ── Stacked bar chart ─────────────────────────────────────────────────────────

class _StackedBarPainter extends CustomPainter {
  final List<List<double>> bars;
  const _StackedBarPainter({required this.bars});

  @override
  void paint(Canvas canvas, Size size) {
    const colors = [KaalColors.q1, KaalColors.q2, KaalColors.acc];
    final barW = size.width / (bars.length * 2 - 1);
    final gap  = barW;

    for (int i = 0; i < bars.length; i++) {
      final x = i * (barW + gap);
      double yBottom = size.height;
      for (int j = 0; j < bars[i].length; j++) {
        final h = bars[i][j] * size.height;
        if (h <= 0) continue;
        final rect = RRect.fromRectAndRadius(
          Rect.fromLTWH(x, yBottom - h, barW, h),
          const Radius.circular(2),
        );
        canvas.drawRRect(rect, Paint()..color = colors[j]);
        yBottom -= h;
      }
    }
  }

  @override
  bool shouldRepaint(_StackedBarPainter old) => false;
}

// ── Idle state — shown in the Time Log when nothing is being tracked ──────────

class _IdleTimerCard extends StatelessWidget {
  final KaalColors colors;
  const _IdleTimerCard({required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surf2,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(width: 0.5, color: colors.bdr),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('NO ACTIVE TIMER',
              style: TextStyle(fontFamily: 'Inter', fontSize: 9, fontWeight: FontWeight.w700,
                  letterSpacing: 0.4, color: colors.ink3)),
          const SizedBox(height: 6),
          Text('Start a task from Focus or its detail screen to track time here.',
              style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: colors.ink2, height: 1.4)),
        ],
      ),
    );
  }
}
