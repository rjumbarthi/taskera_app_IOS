import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/database.dart' show Goal, Task, Habit;
import '../../data/providers/goals_provider.dart';
import '../../data/providers/habits_provider.dart';
import '../../data/providers/tasks_provider.dart';
import '../../data/providers/database_provider.dart';
import '../../theme/kaal_colors.dart';
import '../../theme/kaal_theme.dart';
import '../../widgets/add_back_button.dart';
import '../../widgets/goal_meta_label.dart';
import '../../widgets/goal_link_pickers.dart';
import '../../l10n/app_l10n.dart';

// ── Data ──────────────────────────────────────────────────────────────────────

enum _LinkType { task, habit }

class _LinkedItem {
  final String title;
  final bool done;
  final String? badge;
  final Color? badgeColor;
  final Color color; // dot + (when not done) text color
  const _LinkedItem({
    required this.title,
    required this.color,
    this.done = false,
    this.badge,
    this.badgeColor,
  });
}

class _Goal {
  final String emoji;
  final String title;
  final String sub;
  final double pct;
  final Color pctColor;
  final _LinkType linkType;
  const _Goal({
    required this.emoji,
    required this.title,
    required this.sub,
    required this.pct,
    required this.pctColor,
    required this.linkType,
  });
}

// ── DB → display model mapping ─────────────────────────────────────────────

_Goal _rowToGoal(Goal r) => _Goal(
      emoji: r.emoji,
      title: r.title,
      sub: r.subtitle,
      pct: r.progressPct,
      pctColor: Color(r.accentColorValue),
      linkType: r.linkType == 'habit' ? _LinkType.habit : _LinkType.task,
    );

// ── Screen ────────────────────────────────────────────────────────────────────

class GoalsScreen extends ConsumerWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = KaalTheme.of(context).colors;
    final goals = ref.watch(goalsProvider).value ?? [];

    // Header subtitle from real goals: count + the most-referenced quadrant
    // (extracted from each goal's linked label / subtitle text).
    String goalsSubtitle;
    if (goals.isEmpty) {
      goalsSubtitle = 'No goals yet';
    } else {
      final qTally = <int, int>{};
      final re = RegExp(r'Q([1-4])');
      for (final g in goals) {
        final m = re.firstMatch(g.linkedLabel) ?? re.firstMatch(g.subtitle);
        if (m != null) {
          final q = int.parse(m.group(1)!);
          qTally[q] = (qTally[q] ?? 0) + 1;
        }
      }
      final base = '${goals.length} active';
      if (qTally.isNotEmpty) {
        final domQ = qTally.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
        goalsSubtitle = '$base · mapped to Q$domQ';
      } else {
        goalsSubtitle = '$base goal${goals.length == 1 ? '' : 's'}';
      }
    }

    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SubHeader(subtitle: goalsSubtitle),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Quote banner
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                      decoration: BoxDecoration(
                        color: const Color(0x0F7FBA00), // rgba(127,186,0,.06)
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(width: 0.5, color: const Color(0x337FBA00)),
                      ),
                      child: Text(
                        '"Goals without Q2 tasks are just wishes. Map every goal to at least one scheduled action."',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          color: colors.successFg,
                          height: 1.6,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Goal cards
                    ...goals.map((row) {
                      final g = _rowToGoal(row);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: GestureDetector(
                          onTap: () => context.push('/focus/goals/${row.id}'),
                          child: _GoalCard(goal: g, goalId: row.id, colors: colors),
                        ),
                      );
                    }),

                    // Add goal row
                    GestureDetector(
                      onTap: () => context.push('/focus/editgoal'),
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                      padding: const EdgeInsets.all(13),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          width: 0.5,
                          color: colors.bdr2,
                          style: BorderStyle.none, // dashed not supported natively
                        ),
                      ),
                      child: _DashedBorderBox(
                        color: colors.bdr2,
                        radius: 14,
                        child: Padding(
                          padding: const EdgeInsets.all(13),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add, size: 14, color: colors.ink3),
                              const SizedBox(width: 8),
                              Text(
                                'Add a new goal (max 5)',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 14,
                                  color: colors.ink3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        // FAB
        Positioned(
          right: 16,
          bottom: 16 + MediaQuery.paddingOf(context).bottom,
          child: GestureDetector(
            onTap: () => context.push('/focus/editgoal'),
            child: Container(
              width: 48, height: 48,
              decoration: const BoxDecoration(
                color: KaalColors.acc,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.add, color: Colors.white, size: 22),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Sub-header ────────────────────────────────────────────────────────────────

class _SubHeader extends StatelessWidget {
  final String subtitle;
  const _SubHeader({required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final colors = KaalTheme.of(context).colors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 6),
      child: Row(
        children: [
          AddBackButton(onTap: () => context.pop()),
          const SizedBox(width: 2),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Goals',
                style: TextStyle(
                  fontFamily: 'Fraunces',
                  fontVariations: [FontVariation('wght', 600)],
                  fontSize: 19,
                  letterSpacing: -0.5,
                  color: colors.ink,
                  height: 1.1,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  color: colors.ink3,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Goal card ─────────────────────────────────────────────────────────────────

class _GoalCard extends ConsumerWidget {
  final _Goal goal;
  final int goalId;
  final KaalColors colors;
  const _GoalCard({required this.goal, required this.goalId, required this.colors});

  // Cap rows per type so a card with both tasks and habits shows both.
  static const _maxPerType = 4;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accent = goal.pctColor;

    // Live linked items, derived from the real links.
    final tasks      = ref.watch(goalLinkedTasksProvider(goalId)).value ?? const <Task>[];
    final habitLinks = ref.watch(goalHabitLinksProvider(goalId)).value ?? const [];
    final allHabits  = ref.watch(habitsProvider).value ?? const <Habit>[];
    final linkedHabitIds = habitLinks.map((e) => e.habitId).toSet();
    final habits = allHabits.where((h) => linkedHabitIds.contains(h.id)).toList();

    final taskItems = [
      for (final t in tasks)
        _LinkedItem(title: t.title, done: t.isDone, color: accent),
    ];
    final habitItems = [
      for (final h in habits)
        _LinkedItem(
          title: '${h.emoji} ${h.name}',
          color: accent,
          badge: h.streakLabel,
          badgeColor: Color(h.streakColorValue),
        ),
    ];
    // Tasks first, then habits — capped per type.
    final items = [...taskItems.take(_maxPerType), ...habitItems.take(_maxPerType)];
    final hidden = (taskItems.length - taskItems.take(_maxPerType).length) +
        (habitItems.length - habitItems.take(_maxPerType).length);

    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: accent.withAlpha(0x12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(width: 1.0, color: accent.withAlpha(0x4D)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header row
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: accent.withAlpha(0x1F),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Text(goal.emoji, style: const TextStyle(fontSize: 18)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      goal.title,
                      style: const TextStyle(
                        fontFamily: 'Fraunces',
                        fontVariations: [FontVariation('wght', 600)],
                        fontSize: 14,
                        color: Color(0xFFF2F2F7),
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      goal.sub,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: colors.ink3,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${(goal.pct * 100).round()}%',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: goal.pctColor,
                ),
              ),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: () => context.push('/focus/editgoal/$goalId'),
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Icon(Icons.edit_rounded, size: 13, color: colors.ink3),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: Container(
              height: 5,
              color: colors.surf3,
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: goal.pct,
                child: ColoredBox(color: accent),
              ),
            ),
          ),

          const SizedBox(height: 9),

          // Linked label (live — derived from actual task/habit links)
          GoalMetaLabel(
            goalId: goalId,
            isHabit: goal.linkType == _LinkType.habit,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              fontWeight: FontWeight.w400,
              color: colors.ink3,
            ),
          ),

          // Linked task/habit rows (live)
          if (items.isNotEmpty) ...[
            const SizedBox(height: 6),
            Column(
              children: [
                for (final item in items)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: _LinkedRow(item: item, colors: colors),
                  ),
                if (hidden > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      '+$hidden more',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11,
                        color: colors.ink3,
                      ),
                    ),
                  ),
              ],
            ),
          ],

          const SizedBox(height: 9),

          // Action buttons — link tasks / habits to this goal
          Row(
            children: [
              Expanded(
                child: _LinkBtn(
                  label: '+ ${AppL10n.of(context).linkTask}',
                  bg: KaalColors.accBg,
                  fg: KaalColors.acc2,
                  onTap: () => _linkTasks(context, ref),
                ),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: _LinkBtn(
                  label: '+ ${AppL10n.of(context).linkHabit}',
                  bg: const Color(0x1ABF5AF2),
                  fg: const Color(0xFFBF5AF2),
                  onTap: () => _linkHabits(context, ref),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _linkTasks(BuildContext context, WidgetRef ref) {
    final allTasks = <Task>[
      ...ref.read(quadrantTasksProvider(1)).value ?? [],
      ...ref.read(quadrantTasksProvider(2)).value ?? [],
      ...ref.read(quadrantTasksProvider(3)).value ?? [],
      ...ref.read(quadrantTasksProvider(4)).value ?? [],
    ];
    final linked = (ref.read(goalLinkedTasksProvider(goalId)).value ?? [])
        .map((t) => t.id)
        .toSet();
    showTaskLinkPicker(
      context: context,
      tasks: allTasks,
      initial: linked,
      colors: colors,
      onSave: (selected) async {
        final db = ref.read(appDatabaseProvider);
        for (final id in selected.difference(linked)) { await db.goalsDao.linkTask(goalId, id); }
        for (final id in linked.difference(selected)) { await db.goalsDao.unlinkTask(goalId, id); }
      },
    );
  }

  void _linkHabits(BuildContext context, WidgetRef ref) {
    final allHabits = ref.read(habitsProvider).value ?? const <Habit>[];
    final linked = (ref.read(goalHabitLinksProvider(goalId)).value ?? [])
        .map((l) => l.habitId)
        .toSet();
    showHabitLinkPicker(
      context: context,
      habits: allHabits,
      initial: linked,
      colors: colors,
      onSave: (selected) async {
        final db = ref.read(appDatabaseProvider);
        for (final id in selected.difference(linked)) { await db.goalsDao.linkHabit(goalId, id); }
        for (final id in linked.difference(selected)) { await db.goalsDao.unlinkHabit(goalId, id); }
      },
    );
  }
}

// ── Link action button ────────────────────────────────────────────────────────

class _LinkBtn extends StatelessWidget {
  final String label;
  final Color bg;
  final Color fg;
  final VoidCallback onTap;
  const _LinkBtn({required this.label, required this.bg, required this.fg, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 7),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: fg,
          ),
        ),
      ),
    );
  }
}

// ── Linked task/habit row ─────────────────────────────────────────────────────

class _LinkedRow extends StatelessWidget {
  final _LinkedItem item;
  final KaalColors colors;
  const _LinkedRow({required this.item, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          // Status dot
          item.done
              ? Container(
                  width: 11, height: 11,
                  decoration: BoxDecoration(color: item.color, shape: BoxShape.circle),
                  alignment: Alignment.center,
                  child: const Icon(Icons.check_rounded, size: 7, color: Colors.white),
                )
              : Container(
                  width: 11, height: 11,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(width: 1.5, color: item.color),
                  ),
                ),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              item.title,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                color: item.done ? colors.ink3 : item.color,
                decoration: item.done ? TextDecoration.lineThrough : null,
                decorationColor: colors.ink3,
                height: 1.3,
              ),
            ),
          ),
          if (item.badge != null) ...[
            const SizedBox(width: 6),
            Text(
              item.badge!,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                color: item.badgeColor,
                height: 1.3,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Dashed border box ─────────────────────────────────────────────────────────

class _DashedBorderBox extends StatelessWidget {
  final Widget child;
  final Color color;
  final double radius;
  const _DashedBorderBox({required this.child, required this.color, required this.radius});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedBorderPainter(color: color, radius: radius),
      child: child,
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double radius;
  _DashedBorderPainter({required this.color, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;
    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          Radius.circular(radius)));
    const dashLen = 5.0;
    const gapLen  = 4.0;
    final metrics = path.computeMetrics();
    for (final m in metrics) {
      double dist = 0;
      while (dist < m.length) {
        canvas.drawPath(m.extractPath(dist, dist + dashLen), paint);
        dist += dashLen + gapLen;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter old) =>
      old.color != color || old.radius != radius;
}
