import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/database.dart';
import '../../data/providers/database_provider.dart';
import '../../data/providers/habits_provider.dart';
import '../../l10n/app_l10n.dart';
import '../../util/kaal_dialogs.dart';
import '../../theme/kaal_colors.dart';
import '../../theme/kaal_theme.dart';
import '../../widgets/add_back_button.dart';

class HabitDetailScreen extends ConsumerStatefulWidget {
  final String habitId;
  const HabitDetailScreen({super.key, required this.habitId});

  @override
  ConsumerState<HabitDetailScreen> createState() => _HabitDetailScreenState();
}

class _HabitDetailScreenState extends ConsumerState<HabitDetailScreen> {
  late int _year;
  late int _month;

  // Inline "add routine step" state for the sub-habit list.
  bool _addingStep = false;
  final _stepCtrl = TextEditingController();

  static const _monthNames = [
    'January','February','March','April','May','June',
    'July','August','September','October','November','December',
  ];
  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _year  = now.year;
    _month = now.month;
  }

  @override
  void dispose() {
    _stepCtrl.dispose();
    super.dispose();
  }

  Future<void> _addStep(int habitId, int nextOrder) async {
    final title = _stepCtrl.text.trim();
    if (title.isEmpty) {
      setState(() => _addingStep = false);
      return;
    }
    await ref.read(appDatabaseProvider).habitsDao.insertSubHabit(
          SubHabitsCompanion(
            habitId:   Value(habitId),
            title:     Value(title),
            sortOrder: Value(nextOrder),
          ),
        );
    _stepCtrl.clear();
    setState(() => _addingStep = false);
  }

  void _prevMonth() => setState(() {
    if (_month == 1) { _month = 12; _year--; } else { _month--; }
  });

  void _nextMonth() => setState(() {
    if (_month == 12) { _month = 1; _year++; } else { _month++; }
  });

  // Builds the grid cells for the calendar.
  List<Widget> _buildCalCells({
    required int year,
    required int month,
    required Set<int> doneDays,
    required Set<int> skipDays,
    required DateTime? createdAt,
    required KaalColors colors,
    required Color accent,
  }) {
    final today       = DateTime.now();
    final todayDate   = DateTime(today.year, today.month, today.day);
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final offset      = DateTime(year, month, 1).weekday - 1; // 0=Mon
    // The first day a habit can be marked is its creation day. When the date is
    // unknown (still loading) fall back to today so no spurious miss marks show
    // for days before the habit existed.
    final created     = createdAt != null
        ? DateTime(createdAt.year, createdAt.month, createdAt.day)
        : todayDate;

    final cells = <Widget>[];

    for (int i = 0; i < offset; i++) {
      cells.add(const SizedBox());
    }

    for (int day = 1; day <= daysInMonth; day++) {
      final cellDate = DateTime(year, month, day);
      final isDone    = doneDays.contains(day);
      final isSkipped = skipDays.contains(day);
      final isToday   = cellDate == todayDate;
      final isPast    = cellDate.isBefore(todayDate);
      // Days strictly before the creation day predate the habit — show a
      // neutral dim number, never a check or miss marker. Check/miss/today marks
      // begin ON the creation day.
      final beforeCreated = cellDate.isBefore(created);

      Widget cell;
      if (isDone) {
        // Explicit completion always wins — even on the creation date.
        cell = Center(child: Icon(Icons.check_rounded, size: 18, color: accent));
      } else if (isSkipped) {
        cell = Center(child: Icon(Icons.remove_rounded, size: 18, color: const Color(0xFFFFB900)));
      } else if (beforeCreated) {
        // Before the habit existed → dim date number, no miss marker.
        cell = Center(
          child: Text('$day',
            style: TextStyle(fontFamily: 'Inter', fontSize: 8,
              color: colors.ink3.withAlpha(0x28), height: 1)),
        );
      } else if (isToday) {
        cell = Container(
          margin: const EdgeInsets.all(1),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            border: Border.all(width: 0.5, color: KaalColors.acc.withAlpha(0x80)),
          ),
          child: Center(
            child: Text('$day',
              style: const TextStyle(fontFamily: 'Inter', fontSize: 8,
                color: KaalColors.acc, height: 1)),
          ),
        );
      } else if (isPast) {
        // After creation, before today, not logged → missed.
        cell = Center(child: Icon(Icons.close_rounded, size: 18, color: colors.ink3));
      } else {
        // Future date — dim number.
        cell = Center(
          child: Text('$day',
            style: TextStyle(fontFamily: 'Inter', fontSize: 8,
              color: colors.ink3.withAlpha(0x55), height: 1)),
        );
      }
      cells.add(cell);
    }

    // Pad to complete the last row.
    final rem = cells.length % 7;
    if (rem != 0) {
      for (int i = 0; i < 7 - rem; i++) {
        cells.add(const SizedBox());
      }
    }
    return cells;
  }

  @override
  Widget build(BuildContext context) {
    final colors  = KaalTheme.of(context).colors;
    final id      = int.tryParse(widget.habitId) ?? 0;
    final habit   = ref.watch(singleHabitProvider(id)).valueOrNull;
    final subs    = ref.watch(subHabitsProvider(id)).valueOrNull ?? [];
    final monthLogs = ref.watch(habitMonthLogsProvider((id, _year, _month))).valueOrNull ?? [];
    final allLogs   = ref.watch(habitAllLogsProvider(id)).valueOrNull ?? [];
    final doneDays  = monthLogs.where((l) => !l.isSkipped).map((l) => l.logDate.day).toSet();
    final skipDays  = monthLogs.where((l) =>  l.isSkipped).map((l) => l.logDate.day).toSet();

    final name    = habit?.name          ?? '—';
    final emoji   = habit?.emoji         ?? '⭐';
    final meta    = habit?.frequencyLabel ?? '';
    final streak  = habit?.streakLabel   ?? '—';
    final accent  = habit != null ? Color(habit.accentColorValue) : const Color(0xFF9FCD44);
    final filled  = habit?.weeklyFilledCount ?? 0;

    // ── 8-week completion chart ────────────────────────────────────────────
    final now    = DateTime.now();
    final today  = DateTime(now.year, now.month, now.day);
    final doneLogs = allLogs.where((l) => !l.isSkipped).toList();

    final weekBars   = <double>[];
    final weekLabels = <String>[];
    for (int w = 7; w >= 0; w--) {
      final wEnd   = today.subtract(Duration(days: w * 7));
      final wStart = wEnd.subtract(const Duration(days: 6));
      final cnt = doneLogs.where((l) {
        final d = DateTime(l.logDate.year, l.logDate.month, l.logDate.day);
        return !d.isBefore(wStart) && !d.isAfter(wEnd);
      }).length;
      weekBars.add(cnt / 7);
      final thu = wEnd.add(Duration(days: 4 - wEnd.weekday));
      final wNum = (thu.difference(DateTime(thu.year, 1, 1)).inDays ~/ 7) + 1;
      weekLabels.add('W$wNum');
    }
    final weekAvgPct = weekBars.isEmpty ? '—'
        : '${(weekBars.reduce((a, b) => a + b) / weekBars.length * 100).round()}%';

    // ── 30-day trend (13 sample points with 3-day rolling window) ─────────
    final last30Start = today.subtract(const Duration(days: 29));
    final trendPts = List<double>.generate(13, (i) {
      final center = last30Start.add(Duration(days: (i * 29 / 12).round()));
      int cnt = 0, tot = 0;
      for (int di = -3; di <= 3; di++) {
        final d = center.add(Duration(days: di));
        if (d.isBefore(last30Start) || d.isAfter(today)) continue;
        tot++;
        if (doneLogs.any((l) {
          final ld = DateTime(l.logDate.year, l.logDate.month, l.logDate.day);
          return ld == d;
        })) {
          cnt++;
        }
      }
      return tot == 0 ? 0.0 : cnt / tot;
    });

    // ── All-time stats ─────────────────────────────────────────────────────
    final totalDone   = allLogs.where((l) => !l.isSkipped).length;
    final totalSkip   = allLogs.where((l) =>  l.isSkipped).length;
    final createdAt   = habit?.createdAt;
    final createdDay  = createdAt != null
        ? DateTime(createdAt.year, createdAt.month, createdAt.day)
        : today;
    final daysSince   = today.difference(createdDay).inDays.clamp(0, 99999);
    final weeksSince  = daysSince / 7;
    final totalMissed = (daysSince - totalDone - totalSkip).clamp(0, daysSince);
    final avgPerWeek  = weeksSince > 0
        ? (totalDone / weeksSince).toStringAsFixed(1)
        : '—';
    final activeSince = createdAt != null
        ? () {
            const ms = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
            return "${ms[createdAt.month - 1]} '${createdAt.year.toString().substring(2)}";
          }()
        : '—';

    final calCells = _buildCalCells(
      year: _year, month: _month,
      doneDays: doneDays,
      skipDays: skipDays,
      createdAt: habit?.createdAt,
      colors: colors, accent: accent,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Sub-bar
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 12, 6),
          child: Row(
            children: [
              AddBackButton(onTap: () => context.pop()),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(name, style: TextStyle(fontFamily: 'Fraunces', fontVariations: [FontVariation('wght', 600)], fontSize: 19, letterSpacing: -0.5, color: colors.ink, height: 1.1)),
                    Text('$meta · $streak', style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: colors.ink3, height: 1.2)),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => context.push('/habits/addhabit/${widget.habitId}'),
                child: Container(
                  width: 32, height: 32,
                  alignment: Alignment.center,
                  child: Icon(Icons.edit_outlined, size: 16, color: colors.ink3),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 72),
            children: [
              // Hero card — accent tint
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: accent.withAlpha(0x12),
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(width: 0.5, color: accent.withAlpha(0x33)),
                ),
                child: Column(
                  children: [
                    Text(emoji, style: const TextStyle(fontSize: 36, height: 1)),
                    const SizedBox(height: 6),
                    Text(name, style: TextStyle(fontFamily: 'Fraunces', fontSize: 18, fontWeight: FontWeight.w600, color: colors.ink, height: 1.1)),
                    const SizedBox(height: 3),
                    Text(meta, style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: colors.ink3)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _HeroStat(value: streak, label: 'Current Streak', valueColor: accent,
                          bgColor: accent.withAlpha(0x1F), borderColor: accent.withAlpha(0x40)),
                        const SizedBox(width: 8),
                        _HeroStat(value: '$filled/7', label: 'This week', valueColor: colors.ink),
                        const SizedBox(width: 8),
                        _HeroStat(value: filled > 0 ? '${(filled / 7 * 100).round()}%' : '—', label: 'Completion', valueColor: KaalColors.acc2),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...subs.map((s) => _SubHabitRow(
                          title: s.title,
                          isDone: s.isDone,
                          accent: accent,
                          colors: colors,
                          onTap: () => ref
                              .read(appDatabaseProvider)
                              .habitsDao
                              .toggleSubHabitDone(s.id, !s.isDone),
                          onDelete: () async {
                            final ok = await kaalConfirmDelete(context,
                                message: 'Delete step "${s.title}"?');
                            if (ok) {
                              await ref
                                  .read(appDatabaseProvider)
                                  .habitsDao
                                  .deleteSubHabit(s.id);
                            }
                          },
                        )),
                    _AddStepRow(
                      colors: colors,
                      accent: accent,
                      controller: _stepCtrl,
                      adding: _addingStep,
                      onStart: () => setState(() => _addingStep = true),
                      onCancel: () => setState(() {
                        _addingStep = false;
                        _stepCtrl.clear();
                      }),
                      onSubmit: () => _addStep(id, subs.length),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // Calendar heatmap
              _Card(
                colors: colors,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${_monthNames[_month - 1]} $_year',
                          style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w600, color: colors.ink)),
                        Row(
                          children: [
                            _NavBtn(icon: Icons.chevron_left, colors: colors, onTap: _prevMonth),
                            const SizedBox(width: 4),
                            _NavBtn(icon: Icons.chevron_right, colors: colors, onTap: _nextMonth),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: ['M','T','W','T','F','S','S'].map((d) => Expanded(
                        child: Text(d, textAlign: TextAlign.center,
                          style: TextStyle(fontFamily: 'Inter', fontSize: 9, fontWeight: FontWeight.w600, color: colors.ink3)),
                      )).toList(),
                    ),
                    const SizedBox(height: 3),
                    GridView.count(
                      crossAxisCount: 7, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 2, crossAxisSpacing: 2, childAspectRatio: 1.1,
                      children: calCells,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        _LegendIcon(icon: Icons.check_rounded, iconColor: accent, label: 'Done', colors: colors),
                        const SizedBox(width: 10),
                        _LegendIcon(icon: Icons.close_rounded, iconColor: colors.ink3, label: 'Missed', colors: colors),
                        const SizedBox(width: 10),
                        _LegendIcon(icon: Icons.circle_outlined, iconColor: colors.ink3.withAlpha(0x60), label: 'Future', colors: colors),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // Last 8 weeks bar chart
              _Card(
                colors: colors,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(AppL10n.of(context).last8Weeks, style: TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w600, color: colors.ink)),
                        Text(weekAvgPct, style: TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w700, color: colors.successFg)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 56,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          for (int i = 0; i < weekBars.length; i++) ...[
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Expanded(
                                    child: Align(
                                      alignment: Alignment.bottomCenter,
                                      child: FractionallySizedBox(
                                        heightFactor: weekBars[i].clamp(0.0, 1.0),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: weekBars[i] > 0.7 ? const Color(0xFF9FCD44) : const Color(0x40FFFFFF),
                                            borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(weekLabels[i], style: TextStyle(fontFamily: 'Inter', fontSize: 8, color: colors.ink3)),
                                ],
                              ),
                            ),
                            if (i < weekBars.length - 1) const SizedBox(width: 3),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // 30-day trend
              _Card(
                colors: colors,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('30-day trend', style: TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w600, color: colors.ink)),
                    const SizedBox(height: 8),
                    SizedBox(height: 52, child: CustomPaint(painter: _TrendPainter(points: trendPts))),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('30 days ago', style: TextStyle(fontFamily: 'Inter', fontSize: 9, color: colors.ink3)),
                        Text(AppL10n.of(context).today, style: TextStyle(fontFamily: 'Inter', fontSize: 9, color: colors.ink3)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // Reminder card
              _Card(
                colors: colors,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(AppL10n.of(context).reminder, style: TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w600, color: colors.ink)),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('6:30 AM', style: TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w500, color: colors.ink)),
                            Text(AppL10n.of(context).everyWeekday, style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: colors.ink3)),
                          ],
                        ),
                        const _ToggleWidget(initial: true),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // All-time stats 2x2
              _Card(
                colors: colors,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(AppL10n.of(context).allTimeStats, style: TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w600, color: colors.ink)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _StatCell2(label: 'Total completions', value: '$totalDone', valueColor: colors.ink),
                        const SizedBox(width: 8),
                        _StatCell2(label: 'Total missed', value: '$totalMissed', valueColor: const Color(0xFFFF6B6B)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _StatCell2(label: 'Avg per week', value: avgPerWeek, valueColor: colors.ink),
                        const SizedBox(width: 8),
                        _StatCell2(label: 'Active since', value: activeSince, valueColor: colors.ink),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () async {
                  final confirmed = await kaalConfirmDelete(context);
                  if (confirmed && context.mounted) {
                    await ref.read(appDatabaseProvider).habitsDao.deleteHabit(id);
                    if (context.mounted) context.pop();
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(13),
                  decoration: BoxDecoration(
                    color: const Color(0x12FF453A),
                    borderRadius: BorderRadius.circular(11),
                    border: Border.all(width: 0.5, color: const Color(0x33FF453A)),
                  ),
                  alignment: Alignment.center,
                  child: Text('${AppL10n.of(context).delete} Habit', style: const TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFFFF453A), height: 1)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Local widgets ─────────────────────────────────────────────────────────────

class _Card extends StatelessWidget {
  final Widget child;
  final KaalColors colors;
  const _Card({required this.child, required this.colors});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
    decoration: BoxDecoration(
      color: const Color(0x0DFFFFFF),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(width: 0.5, color: const Color(0x1AFFFFFF)),
    ),
    child: child,
  );
}

class _HeroStat extends StatelessWidget {
  final String value, label;
  final Color valueColor;
  final Color bgColor;
  final Color borderColor;
  const _HeroStat({required this.value, required this.label, required this.valueColor,
    this.bgColor = Colors.transparent, this.borderColor = const Color(0x1AFFFFFF)});

  @override
  Widget build(BuildContext context) {
    final colors = KaalTheme.of(context).colors;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.fromLTRB(8, 10, 8, 10),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(width: 0.5, color: borderColor),
        ),
        child: Column(
          children: [
            Text(value, style: TextStyle(fontFamily: 'Fraunces', fontSize: 17, fontWeight: FontWeight.w700, color: valueColor, height: 1)),
            const SizedBox(height: 3),
            Text(label, textAlign: TextAlign.center,
              style: TextStyle(fontFamily: 'Inter', fontSize: 9, color: colors.labelMuted, height: 1.2)),
          ],
        ),
      ),
    );
  }
}

class _NavBtn extends StatelessWidget {
  final IconData icon;
  final KaalColors colors;
  final VoidCallback onTap;
  const _NavBtn({required this.icon, required this.colors, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 26, height: 26,
        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(width: 0.5, color: colors.bdr)),
        child: Icon(icon, size: 16, color: colors.ink2),
      ),
    );
  }
}


class _LegendIcon extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final KaalColors colors;
  const _LegendIcon({required this.icon, required this.iconColor, required this.label, required this.colors});

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, size: 11, color: iconColor),
      const SizedBox(width: 3),
      Text(label, style: TextStyle(fontFamily: 'Inter', fontSize: 9, color: colors.ink3)),
    ],
  );
}

class _StatCell2 extends StatelessWidget {
  final String label, value;
  final Color valueColor;
  const _StatCell2({required this.label, required this.value, required this.valueColor});

  @override
  Widget build(BuildContext context) {
    final colors = KaalTheme.of(context).colors;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 9, 10, 9),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(9),
          border: Border.all(width: 0.5, color: const Color(0x1AFFFFFF)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontFamily: 'Inter', fontSize: 9, color: colors.labelMuted)),
            const SizedBox(height: 3),
            Text(value, style: TextStyle(fontFamily: 'Fraunces', fontSize: 18, fontWeight: FontWeight.w700, color: valueColor, height: 1)),
          ],
        ),
      ),
    );
  }
}

class _ToggleWidget extends StatefulWidget {
  final bool initial;
  const _ToggleWidget({required this.initial});

  @override
  State<_ToggleWidget> createState() => _ToggleWidgetState();
}

class _ToggleWidgetState extends State<_ToggleWidget> {
  late bool _on;
  @override
  void initState() { super.initState(); _on = widget.initial; }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _on = !_on),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 36, height: 21,
        decoration: BoxDecoration(
          color: _on ? KaalColors.acc : const Color(0x33FFFFFF),
          borderRadius: BorderRadius.circular(11),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          alignment: _on ? Alignment.centerRight : Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2.5),
            child: Container(width: 16, height: 16, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
          ),
        ),
      ),
    );
  }
}

class _TrendPainter extends CustomPainter {
  final List<double> points;
  const _TrendPainter({required this.points});

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
      final y = (1 - pts[i]) * size.height;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, paint);

    // Fill
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
  bool shouldRepaint(_TrendPainter old) => old.points != points;
}

// ── Sub-habit (routine step) row — tap to check in, long-press to delete ───────
class _SubHabitRow extends StatelessWidget {
  final String title;
  final bool isDone;
  final Color accent;
  final KaalColors colors;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  const _SubHabitRow({
    required this.title, required this.isDone, required this.accent,
    required this.colors, required this.onTap, required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      onLongPress: onDelete,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Container(
              width: 16, height: 16,
              decoration: BoxDecoration(
                color: isDone ? accent.withAlpha(0x33) : Colors.transparent,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(width: 0.5, color: isDone ? accent.withAlpha(0x80) : colors.bdr2),
              ),
              child: isDone ? Icon(Icons.check_rounded, size: 11, color: accent) : null,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(title, style: TextStyle(
                fontFamily: 'Inter', fontSize: 12,
                color: isDone ? colors.ink3 : colors.ink,
                decoration: isDone ? TextDecoration.lineThrough : null,
                decorationColor: colors.ink3,
              )),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Inline "add routine step" affordance ──────────────────────────────────────
class _AddStepRow extends StatelessWidget {
  final KaalColors colors;
  final Color accent;
  final TextEditingController controller;
  final bool adding;
  final VoidCallback onStart;
  final VoidCallback onCancel;
  final VoidCallback onSubmit;
  const _AddStepRow({
    required this.colors, required this.accent, required this.controller,
    required this.adding, required this.onStart, required this.onCancel, required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    if (!adding) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onStart,
        child: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Row(
            children: [
              Icon(Icons.add_rounded, size: 15, color: accent),
              const SizedBox(width: 6),
              Text('Add step', style: TextStyle(
                fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w500, color: accent)),
            ],
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              autofocus: true,
              style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: colors.ink),
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => onSubmit(),
              decoration: InputDecoration(
                isDense: true,
                hintText: 'New step…',
                hintStyle: TextStyle(fontFamily: 'Inter', fontSize: 12, color: colors.ink3),
                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(7), borderSide: BorderSide(width: 0.5, color: colors.bdr)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(7), borderSide: BorderSide(width: 0.5, color: accent)),
              ),
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(onTap: onSubmit, child: Icon(Icons.check_rounded, size: 18, color: accent)),
          const SizedBox(width: 8),
          GestureDetector(onTap: onCancel, child: Icon(Icons.close_rounded, size: 18, color: colors.ink3)),
        ],
      ),
    );
  }
}
