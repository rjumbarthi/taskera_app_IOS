import 'dart:math' show max;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/providers/habits_provider.dart';
import '../../theme/taskera_colors.dart';
import '../../theme/taskera_theme.dart';
import '../../l10n/app_l10n.dart';
import '../../widgets/add_back_button.dart';

class HabitStatsScreen extends ConsumerStatefulWidget {
  const HabitStatsScreen({super.key});

  @override
  ConsumerState<HabitStatsScreen> createState() => _HabitStatsScreenState();
}

class _HabitStatsScreenState extends ConsumerState<HabitStatsScreen> {
  int _tabIdx = 0;
  late DateTime _periodStart;
  late DateTime _periodEnd;

  static const _tabs = ['Week', 'Month', 'Year'];
  static const _dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
  static const _months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];

  @override
  void initState() {
    super.initState();
    _resetPeriod();
  }

  void _resetPeriod() {
    final now   = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (_tabIdx == 0) {
      _periodStart = today.subtract(Duration(days: today.weekday - 1));
      _periodEnd   = _periodStart.add(const Duration(days: 7));
    } else if (_tabIdx == 1) {
      _periodStart = DateTime(today.year, today.month, 1);
      _periodEnd   = DateTime(today.year, today.month + 1, 1);
    } else {
      _periodStart = DateTime(today.year, 1, 1);
      _periodEnd   = DateTime(today.year + 1, 1, 1);
    }
  }

  void _switchTab(int idx) {
    setState(() { _tabIdx = idx; _resetPeriod(); });
  }

  void _prev() {
    setState(() {
      if (_tabIdx == 0) {
        _periodStart = _periodStart.subtract(const Duration(days: 7));
        _periodEnd   = _periodEnd.subtract(const Duration(days: 7));
      } else if (_tabIdx == 1) {
        final m = _periodStart.month == 1 ? 12 : _periodStart.month - 1;
        final y = _periodStart.month == 1 ? _periodStart.year - 1 : _periodStart.year;
        _periodStart = DateTime(y, m, 1);
        _periodEnd   = DateTime(_periodStart.year, _periodStart.month + 1, 1);
      } else {
        _periodStart = DateTime(_periodStart.year - 1, 1, 1);
        _periodEnd   = DateTime(_periodStart.year + 1, 1, 1);
      }
    });
  }

  void _next() {
    setState(() {
      if (_tabIdx == 0) {
        _periodStart = _periodStart.add(const Duration(days: 7));
        _periodEnd   = _periodEnd.add(const Duration(days: 7));
      } else if (_tabIdx == 1) {
        final m = _periodStart.month == 12 ? 1 : _periodStart.month + 1;
        final y = _periodStart.month == 12 ? _periodStart.year + 1 : _periodStart.year;
        _periodStart = DateTime(y, m, 1);
        _periodEnd   = DateTime(_periodStart.year, _periodStart.month + 1, 1);
      } else {
        _periodStart = DateTime(_periodStart.year + 1, 1, 1);
        _periodEnd   = DateTime(_periodStart.year + 2, 1, 1);
      }
    });
  }

  String _periodLabel() {
    if (_tabIdx == 0) {
      final e = _periodEnd.subtract(const Duration(days: 1));
      if (_periodStart.month == e.month) {
        return '${_months[_periodStart.month - 1]} ${_periodStart.day} – ${e.day}, ${_periodStart.year}';
      }
      return '${_months[_periodStart.month - 1]} ${_periodStart.day} – ${_months[e.month - 1]} ${e.day}, ${e.year}';
    } else if (_tabIdx == 1) {
      return '${_months[_periodStart.month - 1]} ${_periodStart.year}';
    } else {
      return '${_periodStart.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors  = TaskEraTheme.of(context).colors;
    final habits  = ref.watch(habitsProvider).valueOrNull ?? [];
    final logs    = ref.watch(allHabitLogsInRangeProvider((_periodStart, _periodEnd))).valueOrNull ?? [];
    final doneLogs = logs.where((l) => !l.isSkipped).toList();

    final daysInPeriod      = _periodEnd.difference(_periodStart).inDays.clamp(1, 9999);
    final possibleTotal     = habits.length * daysInPeriod;
    final completionPct     = possibleTotal > 0
        ? (doneLogs.length / possibleTotal * 100).round()
        : 0;

    // Per-habit completion bars
    final doneByHabit = <int, int>{};
    for (final l in doneLogs) {
      doneByHabit[l.habitId] = (doneByHabit[l.habitId] ?? 0) + 1;
    }
    final habitBars = habits.map((h) => (
      h.emoji,
      h.name,
      daysInPeriod > 0
          ? ((doneByHabit[h.id] ?? 0) / daysInPeriod).clamp(0.0, 1.0)
          : 0.0,
      Color(h.accentColorValue),
    )).toList();

    // Best days by weekday (1=Mon … 7=Sun)
    final dayCount = <int, int>{for (int i = 1; i <= 7; i++) i: 0};
    for (final l in doneLogs) {
      dayCount[l.logDate.weekday] = (dayCount[l.logDate.weekday] ?? 0) + 1;
    }
    final maxDayCount = dayCount.values.isEmpty ? 1 : dayCount.values.reduce(max);
    final dayBars = [
      for (int i = 1; i <= 7; i++)
        maxDayCount > 0 ? dayCount[i]! / maxDayCount : 0.0,
    ];

    // Stats
    final longestStreak = habits.isEmpty ? 0 : habits.map((h) {
      final m = RegExp(r'(\d+)d').firstMatch(h.streakLabel);
      return m != null ? int.parse(m.group(1)!) : 0;
    }).reduce(max);

    final totalCompletions = doneLogs.length;

    // Perfect days: dates where every habit was completed
    final doneCountByDate = <DateTime, int>{};
    for (final l in doneLogs) {
      final d = DateTime(l.logDate.year, l.logDate.month, l.logDate.day);
      doneCountByDate[d] = (doneCountByDate[d] ?? 0) + 1;
    }
    final perfectDays = habits.isEmpty ? 0
        : doneCountByDate.values.where((c) => c >= habits.length).length;

    // Spark chart: ~10 sample points over the period
    final sparkPts = <double>[];
    if (habits.isNotEmpty && daysInPeriod > 0) {
      const samples = 10;
      for (int i = 0; i < samples; i++) {
        final dayOffset = (i * (daysInPeriod - 1) / (samples - 1)).round();
        final d = _periodStart.add(Duration(days: dayOffset));
        final dateKey = DateTime(d.year, d.month, d.day);
        sparkPts.add(((doneCountByDate[dateKey] ?? 0) / habits.length).clamp(0.0, 1.0));
      }
    } else {
      sparkPts.addAll(List.filled(10, 0.0));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 12, 6),
          child: Row(
            children: [
              AddBackButton(onTap: () => context.pop()),
              const SizedBox(width: 8),
              Expanded(
                child: Text(AppL10n.of(context).habitStatistics,
                  style: TextStyle(fontFamily: 'Fraunces', fontVariations: [FontVariation('wght', 600)], fontSize: 19,
                    letterSpacing: -0.5, color: colors.ink, height: 1.1)),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
            children: [
              // Tab switcher
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(color: const Color(0x14FFFFFF), borderRadius: BorderRadius.circular(9)),
                child: Row(
                  children: [
                    for (int i = 0; i < _tabs.length; i++)
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _switchTab(i),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            decoration: BoxDecoration(
                              color: _tabIdx == i ? const Color(0x1A0A84FF) : Colors.transparent,
                              borderRadius: BorderRadius.circular(7),
                              border: _tabIdx == i ? Border.all(width: 0.5, color: const Color(0x330A84FF)) : null,
                            ),
                            child: Text(_tabs[i], textAlign: TextAlign.center,
                              style: TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w600,
                                color: _tabIdx == i ? colors.ink : colors.ink3, height: 1)),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              // Date range nav
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _RoundBtn(icon: Icons.chevron_left, colors: colors, onTap: _prev),
                  Text(_periodLabel(), style: TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w600, color: colors.ink)),
                  _RoundBtn(icon: Icons.chevron_right, colors: colors, onTap: _next),
                ],
              ),
              const SizedBox(height: 10),
              // Completion rate card
              Container(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
                decoration: BoxDecoration(
                  color: const Color(0x127FBA00),
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(width: 0.5, color: const Color(0x337FBA00)),
                ),
                child: Column(
                  children: [
                    Text(AppL10n.of(context).completionRate, style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: colors.ink3)),
                    const SizedBox(height: 4),
                    Text('$completionPct%',
                      style: TextStyle(fontFamily: 'Fraunces', fontSize: 42, fontWeight: FontWeight.w700, color: colors.successFg, height: 1)),
                    const SizedBox(height: 10),
                    SizedBox(height: 44, child: CustomPaint(painter: _SparkPainter(points: sparkPts))),
                    const SizedBox(height: 2),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_periodLabel().split('–').first.trim(),
                          style: TextStyle(fontFamily: 'Inter', fontSize: 9, color: colors.ink3)),
                        Text('Now',
                          style: TextStyle(fontFamily: 'Inter', fontSize: 9, color: colors.ink3)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // Stats grid
              Row(
                children: [
                  _StatTile(label: 'Longest Streak', value: longestStreak > 0 ? '$longestStreak days 🔥' : '—', valueColor: colors.ink, colors: colors),
                  const SizedBox(width: 6),
                  _StatTile(label: 'Habits Tracked', value: '${habits.length}', valueColor: colors.ink, colors: colors),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  _StatTile(label: 'Perfect Days', value: '$perfectDays', valueColor: TaskEraColors.acc2, colors: colors),
                  const SizedBox(width: 6),
                  _StatTile(label: 'Total Completions', value: '$totalCompletions', valueColor: colors.ink, colors: colors),
                ],
              ),
              const SizedBox(height: 8),
              // Per-habit completion bars
              if (habitBars.isNotEmpty)
                Container(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                  decoration: BoxDecoration(
                    color: colors.surf2,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(width: 0.5, color: colors.bdr0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(AppL10n.of(context).habitCompletion, style: TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w600, color: colors.ink)),
                      const SizedBox(height: 10),
                      for (final row in habitBars) ...[
                        _HabitBar(emoji: row.$1, name: row.$2, pct: row.$3, barColor: row.$4, colors: colors),
                        const SizedBox(height: 9),
                      ],
                    ],
                  ),
                ),
              if (habitBars.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colors.surf2,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(width: 0.5, color: colors.bdr0),
                  ),
                  child: Text(AppL10n.of(context).noHabitsFound, textAlign: TextAlign.center,
                    style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: colors.ink3)),
                ),
              const SizedBox(height: 8),
              // Best days bar chart
              Container(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                decoration: BoxDecoration(
                  color: colors.surf2,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(width: 0.5, color: colors.bdr0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(AppL10n.of(context).bestDays, style: TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w600, color: colors.ink)),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 54,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          for (int i = 0; i < dayBars.length; i++) ...[
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Expanded(
                                    child: Align(
                                      alignment: Alignment.bottomCenter,
                                      child: FractionallySizedBox(
                                        heightFactor: dayBars[i].clamp(0.0, 1.0),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: dayBars[i] > 0.75 ? const Color(0xFF9FCD44) : const Color(0x30FFFFFF),
                                            borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(_dayLabels[i], style: TextStyle(fontFamily: 'Inter', fontSize: 9, color: colors.ink3)),
                                ],
                              ),
                            ),
                            if (i < dayBars.length - 1) const SizedBox(width: 4),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RoundBtn extends StatelessWidget {
  final IconData icon;
  final TaskEraColors colors;
  final VoidCallback onTap;
  const _RoundBtn({required this.icon, required this.colors, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 22, height: 22,
        decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0x14FFFFFF), border: Border.all(width: 0.5, color: colors.bdr0)),
        child: Icon(icon, size: 14, color: colors.ink3),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label, value;
  final Color valueColor;
  final TaskEraColors colors;
  const _StatTile({required this.label, required this.value, required this.valueColor, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(
          color: colors.surf2,
          borderRadius: BorderRadius.circular(11),
          border: Border.all(width: 0.5, color: colors.bdr0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontFamily: 'Inter', fontSize: 9, color: colors.ink3)),
            const SizedBox(height: 3),
            Text(value, style: TextStyle(fontFamily: 'Fraunces', fontSize: 18, fontWeight: FontWeight.w700, color: valueColor, height: 1)),
          ],
        ),
      ),
    );
  }
}

class _HabitBar extends StatelessWidget {
  final String emoji, name;
  final double pct;
  final Color barColor;
  final TaskEraColors colors;
  const _HabitBar({required this.emoji, required this.name, required this.pct, required this.barColor, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 13, height: 1)),
            const SizedBox(width: 6),
            Expanded(child: Text(name, style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: colors.ink), overflow: TextOverflow.ellipsis)),
            Text('${(pct * 100).round()}%', style: TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w700, color: barColor)),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          height: 5,
          decoration: BoxDecoration(color: const Color(0x20FFFFFF), borderRadius: BorderRadius.circular(3)),
          child: FractionallySizedBox(
            widthFactor: pct, alignment: Alignment.centerLeft,
            child: Container(decoration: BoxDecoration(color: barColor, borderRadius: BorderRadius.circular(3))),
          ),
        ),
      ],
    );
  }
}

class _SparkPainter extends CustomPainter {
  final List<double> points;
  const _SparkPainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    final pts = points.isEmpty ? [0.0, 0.0] : points;
    final paint = Paint()
      ..color = const Color(0xFF9FCD44)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final path = Path();
    for (int i = 0; i < pts.length; i++) {
      final x = i / (pts.length - 1) * size.width;
      final y = (1 - pts[i].clamp(0.0, 1.0)) * size.height;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, paint);
    final fill = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(fill, Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter, end: Alignment.bottomCenter,
        colors: [const Color(0x599FCD44), const Color(0x009FCD44)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)));
  }

  @override
  bool shouldRepaint(_SparkPainter old) => old.points != points;
}
