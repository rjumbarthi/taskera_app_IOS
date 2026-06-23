import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/providers/time_tracker_provider.dart';
import '../../theme/kaal_colors.dart';
import '../../theme/kaal_theme.dart';
import '../../widgets/add_back_button.dart';

// ── Data ──────────────────────────────────────────────────────────────────────

class _LogEntry {
  final String title, timeRange, status, duration;
  final Color quadColor;
  const _LogEntry(this.title, this.timeRange, this.status, this.duration, this.quadColor);
}

const _log = [
  _LogEntry('Morning journaling',   '10:00–10:22 AM', 'Done',    '22m',    KaalColors.q2),
  _LogEntry('Fix gym app bug #482', '11:15–1:05 PM',  'Done',    '1h 50m', KaalColors.q1),
  _LogEntry('Study for exam — Chapter 4', '2:14 PM', 'Running', '23m',    KaalColors.q2),
];

class _EstRow {
  final String title, est, actual;
  const _EstRow(this.title, this.est, this.actual);
}

const _estRows = [
  _EstRow('Morning journaling',   'Est 5m',  'Act 22m'),
  _EstRow('Fix production bug',   'Est 1h',  'Act 60m'),
];

const _weekBars = [
  [0.20, 0.30, 0.0],
  [0.15, 0.25, 0.0],
  [0.30, 0.20, 0.0],
  [0.25, 0.35, 0.0],
  [0.20, 0.15, 0.0],
  [0.10, 0.10, 0.0],
  [0.05, 0.20, 0.10],
];

const _weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

// ── Body (reusable — embedded in merged Timer screen) ─────────────────────────

class TimeTrackBody extends ConsumerStatefulWidget {
  const TimeTrackBody({super.key});

  @override
  ConsumerState<TimeTrackBody> createState() => _TimeTrackBodyState();
}

class _TimeTrackBodyState extends ConsumerState<TimeTrackBody> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final tracker = ref.read(timeTrackerProvider);
      if (tracker.taskTitle == null) {
        ref.read(timeTrackerProvider.notifier).startNew('Study for exam — Chapter 4');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors   = KaalTheme.of(context).colors;
    final tracker  = ref.watch(timeTrackerProvider);
    final notifier = ref.read(timeTrackerProvider.notifier);

    final startLabel = tracker.startedAtMs != null
        ? _fmtTime(DateTime.fromMillisecondsSinceEpoch(tracker.startedAtMs!))
        : '--:-- --';

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ACTIVE NOW card
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
                Text('Q2 · Started $startLabel', style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: colors.ink3)),
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
          for (final entry in _log) ...[
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
                    painter: _StackedBarPainter(bars: _weekBars),
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
                    _LegendDot(color: KaalColors.acc, label: 'Today (live)'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // EST. VS ACTUAL
          Text('EST. VS ACTUAL', style: TextStyle(fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.5, color: colors.ink3)),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(11),
              border: Border.all(width: 0.5, color: colors.bdr),
            ),
            child: Column(
              children: [
                for (final row in _estRows) ...[
                  _EstVsActualRow(row: row, colors: colors),
                  const SizedBox(height: 6),
                ],
                Divider(height: 1, thickness: 0.5, color: colors.bdr),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text('✦ ', style: TextStyle(color: KaalColors.acc2)),
                    Expanded(
                      child: Text(
                        'You underestimate technical tasks by ~50% on average',
                        style: const TextStyle(fontFamily: 'Inter', fontSize: 11, color: KaalColors.acc2, height: 1.4),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
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
                onTap: () {},
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
