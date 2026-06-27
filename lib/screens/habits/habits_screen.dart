import 'dart:math' show min, max;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../data/database.dart' show Habit, SubHabit;
import '../../data/providers/database_provider.dart';
import '../../data/providers/habits_provider.dart';
import '../../services/activity_log_service.dart';
import '../../l10n/app_l10n.dart';
import '../../routing/routes.dart';
import '../../theme/kaal_colors.dart';
import '../../theme/kaal_theme.dart';
import '../../util/platform_layout.dart';

// ── Data ──────────────────────────────────────────────────────────────────────

class _Sub {
  const _Sub(this.title, {this.done = false});
  final String title;
  final bool done;
}

class _Habit {
  const _Habit({
    required this.id,
    required this.emoji,
    required this.name,
    required this.meta,
    required this.streak,
    required this.streakColor,
    required this.accentColor,
    required this.filled,
    required this.checkedToday,
    this.subs = const [],
    this.subLabel = 'Sub-habits',
  });
  final int id;
  final String emoji;
  final String name;
  final String meta;
  final String streak;
  final Color streakColor;
  final Color accentColor;
  final int filled; // out of 7
  final bool checkedToday;
  final List<_Sub> subs;
  final String subLabel;
}

// ── DB → display model mapping ─────────────────────────────────────────────

bool _isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

_Habit _rowToHabit(Habit r, List<SubHabit> subs) => _Habit(
      id: r.id,
      emoji: r.emoji,
      name: r.name,
      meta: r.frequencyLabel,
      streak: r.streakLabel,
      streakColor: Color(r.streakColorValue),
      accentColor: Color(r.accentColorValue),
      filled: r.weeklyFilledCount,
      checkedToday: r.lastCheckedDate != null && _isSameDay(r.lastCheckedDate!, DateTime.now()),
      subLabel: r.subLabel ?? 'Sub-habits',
      subs: subs.map((s) => _Sub(s.title, done: s.isDone)).toList(),
    );

// ── Screen ────────────────────────────────────────────────────────────────────

class HabitsScreen extends ConsumerStatefulWidget {
  const HabitsScreen({super.key});

  @override
  ConsumerState<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends ConsumerState<HabitsScreen> {
  final List<bool> _expanded = [];

  bool _isExpanded(int i) => i < _expanded.length ? _expanded[i] : false;

  void _toggleExpanded(int i) {
    setState(() {
      while (_expanded.length <= i) {
        _expanded.add(false);
      }
      _expanded[i] = !_expanded[i];
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = KaalTheme.of(context).colors;
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _WeekStrip(colors: colors),
            _StatsGrid(colors: colors),
            _StreakBanner(),
            Expanded(
              child: ListView(
                // AppShell reserves the bottom-nav footprint; only a small gap here.
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
                children: [
                  ...() {
                    final rows = ref.watch(habitsProvider).value ?? [];
                    return [
                      for (int i = 0; i < rows.length; i++) ...[
                        Builder(builder: (ctx) {
                          final r = rows[i];
                          final subs = ref.watch(subHabitsProvider(r.id)).value ?? [];
                          return _HabitCard(
                            habit: _rowToHabit(r, subs),
                            index: i,
                            isExpanded: _isExpanded(i),
                            onExpand: () => _toggleExpanded(i),
                            onCheck: () {
                              final wasChecked = r.lastCheckedDate != null &&
                                  _isSameDay(r.lastCheckedDate!, DateTime.now());
                              ref.read(appDatabaseProvider).habitsDao.toggleCheckedToday(
                                r.id, !wasChecked,
                                wasChecked ? max(0, r.weeklyFilledCount - 1)
                                           : min(r.weeklyFilledCount + 1, 7),
                              );
                              ref.logActivity(
                                wasChecked
                                    ? 'Habit "${r.name}" unchecked for today'
                                    : 'Habit "${r.name}" checked for today',
                                type: 'habit');
                            },
                            onLongPress: () => _showHabitMenu(ctx, ref, r, colors),
                            onSecondaryTap: isDesktop
                                ? () => _showHabitMenu(ctx, ref, r, colors)
                                : null,
                            colors: colors,
                          );
                        }),
                        const SizedBox(height: 5),
                      ],
                    ];
                  }(),
                  _AddHabitRow(colors: colors, onTap: () => context.push(KaalRoutes.habitsAddHabit)),
                ],
              ),
            ),
          ],
        ),
        Positioned(
          right: 16,
          bottom: 16 + MediaQuery.paddingOf(context).bottom,
          child: GestureDetector(
            onTap: () => context.push(KaalRoutes.habitsAddHabit),
            child: Container(
              width: 42,
              height: 42,
              decoration: const BoxDecoration(
                color: KaalColors.acc,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Color(0x8C000000), blurRadius: 12, offset: Offset(0, 4))],
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 24),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Week strip ────────────────────────────────────────────────────────────────

class _WeekStrip extends ConsumerWidget {
  final KaalColors colors;
  const _WeekStrip({required this.colors});

  static const _labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  static const _checkSvg =
      '<svg width="8" height="8" viewBox="0 0 22 22" fill="none" '
      'stroke="currentColor" stroke-width="2.5" stroke-linecap="round">'
      '<path d="M5 12l4 4 8-8"/></svg>';

  static const _plusSvg =
      '<svg width="8" height="8" viewBox="0 0 22 22" fill="none" '
      'stroke="white" stroke-width="2.5" stroke-linecap="round">'
      '<path d="M12 5v14M5 12h14"/></svg>';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now   = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    // Monday of the current week (weekday: 1=Mon … 7=Sun)
    final weekStart = today.subtract(Duration(days: today.weekday - 1));
    final weekEnd   = weekStart.add(const Duration(days: 7));

    final logs = ref.watch(habitWeekLogsProvider((weekStart, weekEnd))).valueOrNull ?? [];
    // Normalise each log date to midnight so Set lookup works correctly.
    final doneDates = {
      for (final l in logs)
        DateTime(l.logDate.year, l.logDate.month, l.logDate.day),
    };

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
      child: Row(
        children: [
          for (int i = 0; i < 7; i++) ...[
            _DayCell(
              label:      _labels[i],
              isDone:     doneDates.contains(weekStart.add(Duration(days: i))),
              isToday:    weekStart.add(Duration(days: i)) == today,
              isFuture:   weekStart.add(Duration(days: i)).isAfter(today),
              colors:     colors,
              checkSvg:   _checkSvg,
              plusSvg:    _plusSvg,
            ),
          ],
        ],
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  final String label;
  final bool isDone;
  final bool isToday;
  final bool isFuture;
  final KaalColors colors;
  final String checkSvg;
  final String plusSvg;
  const _DayCell({
    required this.label, required this.isDone, required this.isToday,
    required this.isFuture, required this.colors,
    required this.checkSvg, required this.plusSvg,
  });

  @override
  Widget build(BuildContext context) {
    final circleColor = isFuture
        ? Colors.transparent
        : const Color(0x337FBA00);
    final borderColor = isFuture
        ? colors.bdr
        : const Color(0x667FBA00);
    final iconFilter = ColorFilter.mode(
      isFuture ? colors.ink3 : colors.successFg,
      BlendMode.srcIn,
    );

    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Inter', fontSize: 9,
              color: isToday ? KaalColors.acc : colors.ink3, height: 1,
            ),
          ),
          const SizedBox(height: 2),
          Center(
            child: Container(
              width: 18, height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: circleColor,
                border: Border.all(width: 0.5, color: borderColor),
              ),
              child: Center(
                child: isFuture
                    ? SvgPicture.string(plusSvg, width: 8, height: 8,
                        colorFilter: iconFilter)
                    : SvgPicture.string(checkSvg, width: 8, height: 8,
                        colorFilter: ColorFilter.mode(colors.successFg, BlendMode.srcIn)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Stats 4-grid ──────────────────────────────────────────────────────────────

class _StatsGrid extends ConsumerWidget {
  final KaalColors colors;
  const _StatsGrid({required this.colors});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habits = ref.watch(habitsProvider).valueOrNull ?? [];
    final now = DateTime.now();
    final activeCount = habits.length;
    final doneToday = habits.where((h) =>
        h.lastCheckedDate != null && _isSameDay(h.lastCheckedDate!, now)).length;
    final maxStreak = habits.isEmpty ? 0 : habits.map((h) => h.weeklyFilledCount).reduce(max);
    final weekPct = habits.isEmpty ? 0 :
        (habits.map((h) => h.weeklyFilledCount).reduce((a, b) => a + b) /
         (habits.length * 7) * 100).round();

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
      child: Row(
        children: [
          _StatCell(value: '$maxStreak🔥', label: AppL10n.of(context).streak,   valueColor: colors.successFg,      colors: colors),
          const SizedBox(width: 5),
          _StatCell(value: '$doneToday/$activeCount', label: AppL10n.of(context).today, valueColor: KaalColors.acc2, colors: colors),
          const SizedBox(width: 5),
          _StatCell(value: '$weekPct%',  label: AppL10n.of(context).thisWeek, valueColor: const Color(0xFFBF5AF2), colors: colors),
          const SizedBox(width: 5),
          _StatCell(value: '$activeCount', label: AppL10n.of(context).active,  valueColor: KaalColors.q4,           colors: colors),
        ],
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  final String value;
  final String label;
  final Color valueColor;
  final KaalColors colors;
  const _StatCell({required this.value, required this.label, required this.valueColor, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.fromLTRB(6, 8, 6, 8),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(width: 0.5, color: colors.bdr2),
        ),
        child: Column(
          children: [
            Text(
              value,
              textAlign: TextAlign.center,
              style: TextStyle(fontFamily: 'Fraunces', fontSize: 15, fontWeight: FontWeight.w700, color: valueColor, height: 1),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(fontFamily: 'Inter', fontSize: 9, color: colors.ink3, height: 1),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Streak banner ─────────────────────────────────────────────────────────────

class _StreakBanner extends ConsumerWidget {
  const _StreakBanner();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = KaalTheme.of(context).colors;
    final habits = ref.watch(habitsProvider).valueOrNull ?? [];
    final maxFill = habits.isEmpty ? 0 : habits.map((h) => h.weeklyFilledCount).reduce(max);
    if (habits.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 6),
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 9, 12, 9),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0x24FFB900), Color(0x14FF9500)],
          ),
          borderRadius: BorderRadius.circular(11),
          border: Border.all(width: 0.5, color: const Color(0x4DFFB900)),
        ),
        child: Row(
          children: [
            const Text('🔥', style: TextStyle(fontSize: 15, height: 1)),
            const SizedBox(width: 7),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$maxFill-day streak!',
                    style: const TextStyle(fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFFFFB900), height: 1),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    AppL10n.of(context).keepGoingLabel,
                    style: TextStyle(fontFamily: 'Inter', fontSize: 9, color: colors.ink3, height: 1.3),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 7),
            Container(
              padding: const EdgeInsets.fromLTRB(8, 5, 8, 5),
              decoration: BoxDecoration(
                color: const Color(0x33FFB900),
                borderRadius: BorderRadius.circular(7),
              ),
              child: Text(
                '🔔 ${AppL10n.of(context).remindLabel}',
                style: const TextStyle(fontFamily: 'Inter', fontSize: 9, fontWeight: FontWeight.w700, color: Color(0xFFFFB900), height: 1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Habit card ────────────────────────────────────────────────────────────────

class _HabitCard extends StatelessWidget {
  final _Habit habit;
  final int index;
  final bool isExpanded;
  final VoidCallback onExpand;
  final VoidCallback onCheck;
  final VoidCallback? onLongPress;
  final VoidCallback? onSecondaryTap;
  final KaalColors colors;

  const _HabitCard({
    required this.habit,
    required this.index,
    required this.isExpanded,
    required this.onExpand,
    required this.onCheck,
    this.onLongPress,
    this.onSecondaryTap,
    required this.colors,
  });

  static const _checkSvg =
      '<svg width="18" height="18" viewBox="0 0 22 22" fill="none" '
      'stroke="white" stroke-width="2.5" stroke-linecap="round">'
      '<path d="M5 12l4 4 8-8"/></svg>';

  static const _subCheckSvg =
      '<svg width="9" height="9" viewBox="0 0 22 22" fill="none" '
      'stroke="#9fcd44" stroke-width="2.5" stroke-linecap="round">'
      '<path d="M5 12l4 4 8-8"/></svg>';

  @override
  Widget build(BuildContext context) {
    final ac = habit.accentColor;
    return GestureDetector(
      onTap: () => context.push('/habits/habitdetail/${habit.id}'),
      onLongPress: onLongPress,
      onSecondaryTap: onSecondaryTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(width: 0.5, color: ac.withAlpha(0x33)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              habit.name,
              style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w600, color: colors.ink, height: 1),
            ),
            const SizedBox(height: 7),
            // Icon + meta row
            Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(color: ac.withAlpha(0x1A), borderRadius: BorderRadius.circular(8)),
                  child: Center(child: Text(habit.emoji, style: const TextStyle(fontSize: 16, height: 1))),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    habit.meta,
                    style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: colors.ink3, height: 1),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  habit.streak,
                  style: TextStyle(fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w700, color: habit.streakColor, height: 1),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(6, 2, 2, 2),
                  child: Text('⋯', style: TextStyle(fontSize: 15, color: colors.ink3, height: 1)),
                ),
                GestureDetector(
                  onTap: onExpand,
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(4, 2, 4, 2),
                    child: AnimatedRotation(
                      turns: isExpanded ? 0.25 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: Text('›', style: TextStyle(fontSize: 13, color: colors.ink3, height: 1)),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                // Dead-zone buffer: taps in the padding around the checkmark are
                // absorbed (never open habit details); only the icon toggles.
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {},
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: GestureDetector(
                      onTap: onCheck,
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: habit.checkedToday ? ac : ac.withAlpha(0x1A),
                          shape: BoxShape.circle,
                          border: Border.all(width: 0.5, color: ac.withAlpha(0x99)),
                        ),
                        child: Center(
                          child: SvgPicture.string(
                            _checkSvg,
                            width: 18,
                            height: 18,
                            colorFilter: ColorFilter.mode(
                              habit.checkedToday ? Colors.white : ac.withAlpha(0x80),
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Progress bar: 7 segments
            Row(
              children: [
                for (int i = 0; i < 7; i++) ...[
                  Expanded(
                    child: Container(
                      height: 5,
                      decoration: BoxDecoration(
                        color: i < habit.filled ? ac.withAlpha(0xE5) : ac.withAlpha(0x1F),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  if (i < 6) const SizedBox(width: 2),
                ],
              ],
            ),
            // Expandable sub-habits
            if (isExpanded) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.only(top: 8),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(width: 0.5, color: colors.bdr)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      habit.subLabel.toUpperCase(),
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: colors.ink3,
                        letterSpacing: 0.4,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 3),
                    for (final sub in habit.subs)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: Row(
                          children: [
                            Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                color: sub.done ? const Color(0x337FBA00) : Colors.transparent,
                                border: Border.all(
                                  width: 0.5,
                                  color: sub.done ? const Color(0x807FBA00) : colors.bdr2,
                                ),
                              ),
                              child: sub.done
                                  ? Center(child: SvgPicture.string(_subCheckSvg, width: 9, height: 9))
                                  : null,
                            ),
                            const SizedBox(width: 7),
                            Expanded(
                              child: Opacity(
                                opacity: sub.done ? 0.5 : 1.0,
                                child: Text(
                                  sub.title,
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 13,
                                    color: colors.ink2,
                                    height: 1,
                                    decoration: sub.done ? TextDecoration.lineThrough : null,
                                    decorationColor: colors.ink2,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Long-press context menu ───────────────────────────────────────────────────

Future<void> _showHabitMenu(BuildContext ctx, WidgetRef ref, Habit habit, KaalColors colors) {
  return showModalBottomSheet(
    isScrollControlled: true,
    context: ctx,
    backgroundColor: Colors.transparent,
    barrierColor: const Color(0x8C000000),
    builder: (sheetCtx) => SafeArea(
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 16),
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C1E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(width: 0.5, color: colors.bdr),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
              child: Text(
                '${habit.emoji}  ${habit.name}',
                style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w600,
                    color: Color(habit.accentColorValue), height: 1.3),
                maxLines: 2, overflow: TextOverflow.ellipsis,
              ),
            ),
            Container(height: 0.5, color: colors.bdr),
            _HabitMenuItem(
              icon: Icons.skip_next_outlined,
              label: AppL10n.of(ctx).skipToday,
              color: colors.ink,
              colors: colors,
              onTap: () {
                Navigator.of(sheetCtx).pop();
                ref.read(appDatabaseProvider).habitsDao.skipToday(habit.id);
                ref.logActivity('Habit "${habit.name}" skipped today', type: 'habit');
              },
            ),
            _HabitMenuItem(
              icon: Icons.calendar_today_outlined,
              label: AppL10n.of(ctx).reschedule,
              color: colors.ink,
              colors: colors,
              onTap: () => Navigator.of(sheetCtx).pop(),
            ),
            _HabitMenuItem(
              icon: Icons.edit_outlined,
              label: AppL10n.of(ctx).editHabit,
              color: colors.ink,
              colors: colors,
              onTap: () {
                Navigator.of(sheetCtx).pop();
                ctx.push('/habits/addhabit/${habit.id}');
              },
            ),
            _HabitMenuItem(
              icon: Icons.shield_outlined,
              label: AppL10n.of(ctx).streakProtect,
              color: const Color(0xFFFFB900),
              colors: colors,
              onTap: () {
                Navigator.of(sheetCtx).pop();
                _showStreakProtectDialog(ctx, colors);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    ),
  );
}

void _showStreakProtectDialog(BuildContext ctx, KaalColors colors) {
  showDialog(
    context: ctx,
    builder: (dialogCtx) => Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C1E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(width: 0.5, color: const Color(0x4DFFB900)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🔥', style: TextStyle(fontSize: 36, height: 1)),
            const SizedBox(height: 12),
            Text(
              AppL10n.of(ctx).streakProtect,
              style: TextStyle(fontFamily: 'Inter', fontSize: 17, fontWeight: FontWeight.w700,
                  color: const Color(0xFFFFB900)),
            ),
            const SizedBox(height: 8),
            Text(
              AppL10n.of(ctx).streakProtectBody,
              textAlign: TextAlign.center,
              style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: colors.ink2, height: 1.5),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () => Navigator.of(dialogCtx).pop(),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFB900),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Text(
                  AppL10n.of(ctx).enableStreakProtect,
                  style: const TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w700, color: Colors.black),
                ),
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => Navigator.of(dialogCtx).pop(),
              child: Text(
                AppL10n.of(ctx).notNow,
                style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: colors.ink3),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _HabitMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final KaalColors colors;
  final VoidCallback onTap;
  const _HabitMenuItem({required this.icon, required this.label, required this.color, required this.colors, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 12),
            Text(label, style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: color, height: 1)),
          ],
        ),
      ),
    );
  }
}

// ── Add new habit row ─────────────────────────────────────────────────────────

class _AddHabitRow extends StatelessWidget {
  final KaalColors colors;
  final VoidCallback onTap;
  const _AddHabitRow({required this.colors, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CustomPaint(
        painter: _DashedBorderPainter(color: colors.bdr2, radius: 12),
        child: Container(
          padding: const EdgeInsets.all(11),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add, size: 18, color: colors.ink3),
              const SizedBox(width: 7),
              Text(
                AppL10n.of(context).addHabit,
                style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: colors.ink3, height: 1),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double radius;
  const _DashedBorderPainter({required this.color, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0.25, 0.25, size.width - 0.5, size.height - 0.5),
        Radius.circular(radius),
      ));

    for (final m in path.computeMetrics()) {
      double d = 0;
      bool draw = true;
      while (d < m.length) {
        final len = draw ? 5.0 : 4.0;
        if (draw) canvas.drawPath(m.extractPath(d, d + len), paint);
        d += len;
        draw = !draw;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter old) => old.color != color || old.radius != radius;
}
