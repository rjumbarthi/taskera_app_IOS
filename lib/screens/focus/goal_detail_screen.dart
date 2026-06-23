import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:drift/drift.dart' show Value;
import '../../data/database.dart' show Goal, Task, Habit, GoalsCompanion;
import '../../data/providers/goals_provider.dart';
import '../../data/providers/habits_provider.dart';
import '../../data/providers/tasks_provider.dart';
import '../../data/providers/database_provider.dart';
import '../../theme/kaal_colors.dart';
import '../../theme/kaal_theme.dart';
import '../../widgets/add_back_button.dart';
import '../../l10n/app_l10n.dart';

class GoalDetailScreen extends ConsumerWidget {
  final String goalId;
  const GoalDetailScreen({super.key, required this.goalId});

  int get _id => int.tryParse(goalId) ?? 0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors    = KaalTheme.of(context).colors;
    final goalAsync = ref.watch(singleGoalProvider(_id));

    return goalAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error:   (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: Colors.white))),
      data: (goal) {
        if (goal == null) {
          return Center(child: Text('Goal not found', style: TextStyle(color: colors.ink3)));
        }
        return _Body(goal: goal, colors: colors, goalId: goalId);
      },
    );
  }
}

// ── Body ──────────────────────────────────────────────────────────────────────

class _Body extends StatelessWidget {
  final Goal goal;
  final KaalColors colors;
  final String goalId;
  const _Body({required this.goal, required this.colors, required this.goalId});

  @override
  Widget build(BuildContext context) {
    final accentColor  = Color(goal.accentColorValue);
    final barColor     = Color(goal.barColorValue);
    final borderColor  = Color(goal.borderColorValue);
    final bgColor      = accentColor.withAlpha(0x12);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Sub-header
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 12, 6),
          child: Row(
            children: [
              AddBackButton(onTap: () => context.pop()),
              const SizedBox(width: 2),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      goal.title,
                      style: const TextStyle(
                        fontFamily: 'Fraunces',
                        fontVariations: [FontVariation('wght', 600)],
                        fontSize: 19,
                        letterSpacing: -0.5,
                        color: Color(0xFFF2F2F7),
                        height: 1.1,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      goal.subtitle,
                      style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: const Color(0xFF8E8E93), height: 1.3),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => context.push('/focus/editgoal/$goalId'),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: colors.surf2,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(width: 0.5, color: colors.bdr),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.edit_rounded, size: 13, color: colors.ink2),
                      const SizedBox(width: 5),
                      Text(AppL10n.of(context).edit, style: TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w600, color: colors.ink2)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 80),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Hero card
                Container(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(width: 0.5, color: borderColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 42, height: 42,
                            decoration: BoxDecoration(
                              color: accentColor.withAlpha(0x26),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            alignment: Alignment.center,
                            child: Text(goal.emoji, style: const TextStyle(fontSize: 20)),
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
                                    fontVariations: [FontVariation('wght', 700)],
                                    fontSize: 16,
                                    color: Color(0xFFF2F2F7),
                                    height: 1.25,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  goal.subtitle,
                                  style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: colors.ink3, height: 1.3),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 11),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(AppL10n.of(context).overallProgress, style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: colors.ink3)),
                          Text(
                            '${(goal.progressPct * 100).round()}%',
                            style: TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w700, color: accentColor),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Container(
                          height: 8,
                          color: colors.surf3,
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: goal.progressPct.clamp(0.0, 1.0),
                            child: ColoredBox(color: barColor),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // Why this matters
                _SectionCard(
                  label: 'WHY THIS MATTERS',
                  colors: colors,
                  child: Text(
                    goal.subtitle.isNotEmpty ? goal.subtitle : 'No description added yet.',
                    style: TextStyle(fontFamily: 'Inter', fontSize: 14, color: colors.ink2, height: 1.5),
                  ),
                ),
                const SizedBox(height: 10),

                // Milestones
                _MilestonesCard(goal: goal, colors: colors),
                const SizedBox(height: 10),

                // Linked tasks (live)
                _LinkedTasksCard(goalId: int.tryParse(goalId) ?? 0, colors: colors),
                const SizedBox(height: 10),

                // Supporting habits
                _SupportingHabitsCard(goalId: int.tryParse(goalId) ?? 0, colors: colors),
                const SizedBox(height: 10),

                // AI insight
                Container(
                  padding: const EdgeInsets.fromLTRB(12, 11, 12, 11),
                  decoration: BoxDecoration(
                    color: const Color(0x120A84FF),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(width: 0.5, color: const Color(0x400A84FF)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(width: 10, height: 10,
                              decoration: const BoxDecoration(color: KaalColors.acc, shape: BoxShape.circle)),
                          const SizedBox(width: 5),
                          const Text('Kaal AI', style: TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w700, color: KaalColors.acc2)),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text.rich(
                        TextSpan(
                          style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: colors.ink3, height: 1.55),
                          children: [
                            const TextSpan(text: 'At current pace you\'ll complete '),
                            TextSpan(
                              text: '~${(goal.progressPct * 100).round() + 2}% by next month',
                              style: TextStyle(color: colors.ink2, fontWeight: FontWeight.w600),
                            ),
                            const TextSpan(text: '. Link more Q2 tasks this week to stay on track.'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Shared section card ───────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final String label;
  final Widget child;
  final KaalColors colors;
  const _SectionCard({required this.label, required this.child, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(width: 0.5, color: colors.bdr),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(label, style: TextStyle(fontFamily: 'Inter', fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.5, color: colors.ink3)),
          const SizedBox(height: 6),
          child,
        ],
      ),
    );
  }
}

// ── Milestones card ───────────────────────────────────────────────────────────

class _MilestonesCard extends ConsumerStatefulWidget {
  final Goal goal;
  final KaalColors colors;
  const _MilestonesCard({required this.goal, required this.colors});

  @override
  ConsumerState<_MilestonesCard> createState() => _MilestonesCardState();
}

class _MilestonesCardState extends ConsumerState<_MilestonesCard> {
  Future<void> _addMilestone() async {
    final ctrl = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text(AppL10n.of(context).addMilestone,
            style: TextStyle(fontFamily: 'Inter', fontSize: 15, fontWeight: FontWeight.w600, color: widget.colors.ink)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          style: TextStyle(fontFamily: 'Inter', fontSize: 14, color: widget.colors.ink),
          decoration: InputDecoration(
            hintText: AppL10n.of(context).milestoneTitle,
            hintStyle: TextStyle(color: widget.colors.ink3),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: widget.colors.bdr2)),
            focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: KaalColors.acc)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppL10n.of(context).cancel, style: TextStyle(fontFamily: 'Inter', color: widget.colors.ink3)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, ctrl.text.trim()),
            child: Text(AppL10n.of(context).add, style: const TextStyle(fontFamily: 'Inter', color: KaalColors.acc2, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    ctrl.dispose();
    if (result == null || result.isEmpty || !mounted) return;
    final existing = widget.goal.milestones.split('\n').where((s) => s.isNotEmpty).toList();
    if (existing.length >= 5) return;
    existing.add(result);
    await ref.read(appDatabaseProvider).goalsDao.updateGoal(
      widget.goal.id,
      GoalsCompanion(milestones: Value(existing.join('\n'))),
    );
  }

  Future<void> _removeMilestone(int index) async {
    final existing = widget.goal.milestones.split('\n').where((s) => s.isNotEmpty).toList();
    existing.removeAt(index);
    await ref.read(appDatabaseProvider).goalsDao.updateGoal(
      widget.goal.id,
      GoalsCompanion(milestones: Value(existing.join('\n'))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final milestones = widget.goal.milestones.split('\n').where((s) => s.isNotEmpty).toList();
    return _SectionCard(
      label: 'MILESTONES',
      colors: widget.colors,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ...milestones.asMap().entries.map((e) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                Container(
                  width: 14, height: 14,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(width: 1.5, color: widget.colors.bdr2),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(child: Text(e.value,
                    style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: widget.colors.ink, height: 1.3))),
                GestureDetector(
                  onTap: () => _removeMilestone(e.key),
                  child: Icon(Icons.close_rounded, size: 14, color: widget.colors.ink3),
                ),
              ],
            ),
          )),
          if (milestones.isNotEmpty) Divider(height: 12, thickness: 0.5, color: widget.colors.bdr),
          if (milestones.length < 5)
            GestureDetector(
              onTap: _addMilestone,
              child: Text('+ ${AppL10n.of(context).addMilestone}',
                  style: const TextStyle(fontFamily: 'Inter', fontSize: 12, color: KaalColors.acc2)),
            ),
        ],
      ),
    );
  }
}

class _LinkedTasksCard extends ConsumerWidget {
  final int goalId;
  final KaalColors colors;
  const _LinkedTasksCard({required this.goalId, required this.colors});

  void _showLinkPicker(BuildContext context, WidgetRef ref) {
    final allTasks = <Task>[
      ...ref.read(quadrantTasksProvider(1)).value ?? [],
      ...ref.read(quadrantTasksProvider(2)).value ?? [],
      ...ref.read(quadrantTasksProvider(3)).value ?? [],
      ...ref.read(quadrantTasksProvider(4)).value ?? [],
    ];
    final linked = (ref.read(goalLinkedTasksProvider(goalId)).value ?? []).map((t) => t.id).toSet();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: const Color(0x8C000000),
      isScrollControlled: true,
      builder: (_) => _TaskPickerSheet(
        tasks: allTasks,
        linked: linked,
        goalId: goalId,
        colors: colors,
        db: ref.read(appDatabaseProvider),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final linkedTasks = ref.watch(goalLinkedTasksProvider(goalId)).value ?? [];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(width: 0.5, color: colors.bdr),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(AppL10n.of(context).linkedTasks.toUpperCase(), style: TextStyle(fontFamily: 'Inter', fontSize: 10,
                  fontWeight: FontWeight.w700, letterSpacing: 0.5, color: colors.ink3)),
              GestureDetector(
                onTap: () => _showLinkPicker(context, ref),
                child: Text('+ ${AppL10n.of(context).linkTask}', style: const TextStyle(fontFamily: 'Inter',
                    fontSize: 11, color: KaalColors.acc2)),
              ),
            ],
          ),
          if (linkedTasks.isEmpty) ...[
            const SizedBox(height: 8),
            Text(AppL10n.of(context).noLinkedTasksYet,
                style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: colors.ink3, height: 1.5)),
          ] else ...[
            const SizedBox(height: 8),
            for (final task in linkedTasks)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Container(
                      width: 14, height: 14,
                      decoration: BoxDecoration(
                        color: task.isDone ? KaalColors.q2 : Colors.transparent,
                        shape: BoxShape.circle,
                        border: task.isDone ? null : Border.all(width: 1.5, color: KaalColors.q2),
                      ),
                      alignment: Alignment.center,
                      child: task.isDone
                          ? const Icon(Icons.check_rounded, size: 9, color: Colors.white)
                          : null,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(task.title,
                          style: TextStyle(
                            fontFamily: 'Inter', fontSize: 13,
                            color: task.isDone ? colors.ink3 : colors.ink,
                            decoration: task.isDone ? TextDecoration.lineThrough : null,
                            decorationColor: colors.ink3, height: 1.3,
                          )),
                    ),
                    Text('Q${task.quadrant}',
                        style: TextStyle(fontFamily: 'Inter', fontSize: 10, color: colors.ink3)),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: () => ref.read(appDatabaseProvider).goalsDao.unlinkTask(goalId, task.id),
                      child: Icon(Icons.close_rounded, size: 14, color: colors.ink3),
                    ),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }
}

// ── Task picker sheet ─────────────────────────────────────────────────────────

class _TaskPickerSheet extends StatefulWidget {
  final List<Task> tasks;
  final Set<int> linked;
  final int goalId;
  final KaalColors colors;
  final dynamic db;
  const _TaskPickerSheet({required this.tasks, required this.linked,
      required this.goalId, required this.colors, required this.db});

  @override
  State<_TaskPickerSheet> createState() => _TaskPickerSheetState();
}

class _TaskPickerSheetState extends State<_TaskPickerSheet> {
  late final Set<int> _pending = Set.from(widget.linked);

  @override
  Widget build(BuildContext context) {
    final safeBot = MediaQuery.of(context).padding.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 16 + safeBot),
      decoration: const BoxDecoration(
        color: Color(0xFF1C1C1E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        border: Border(top: BorderSide(width: 0.5, color: Color(0x33FFFFFF))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 36, height: 4, margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(color: const Color(0x40FFFFFF), borderRadius: BorderRadius.circular(2))),
          Text(AppL10n.of(context).linkTasksToGoal, style: TextStyle(fontFamily: 'Inter', fontSize: 14,
              fontWeight: FontWeight.w600, color: widget.colors.ink, height: 1)),
          const SizedBox(height: 12),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 320),
            child: widget.tasks.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(AppL10n.of(context).noActiveTasksFound,
                        style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: widget.colors.ink3)),
                  )
                : ListView(
                    shrinkWrap: true,
                    children: widget.tasks.map((t) {
                      final isLinked = _pending.contains(t.id);
                      return GestureDetector(
                        onTap: () => setState(() {
                          if (isLinked) { _pending.remove(t.id); } else { _pending.add(t.id); }
                        }),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                          decoration: BoxDecoration(
                              border: Border(bottom: BorderSide(width: 0.5, color: const Color(0x1AFFFFFF)))),
                          child: Row(children: [
                            Container(
                              width: 16, height: 16,
                              decoration: BoxDecoration(
                                color: isLinked ? KaalColors.acc : Colors.transparent,
                                borderRadius: BorderRadius.circular(4),
                                border: isLinked ? null : Border.all(width: 1.5, color: const Color(0x40FFFFFF)),
                              ),
                              alignment: Alignment.center,
                              child: isLinked
                                  ? const Icon(Icons.check_rounded, size: 10, color: Colors.white)
                                  : null,
                            ),
                            const SizedBox(width: 10),
                            Expanded(child: Text(t.title,
                                style: TextStyle(fontFamily: 'Inter', fontSize: 13,
                                    color: widget.colors.ink, height: 1))),
                            Text('Q${t.quadrant}',
                                style: TextStyle(fontFamily: 'Inter', fontSize: 10, color: widget.colors.ink3)),
                          ]),
                        ),
                      );
                    }).toList(),
                  ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () async {
              final toAdd    = _pending.difference(widget.linked);
              final toRemove = widget.linked.difference(_pending);
              for (final id in toAdd)    { await widget.db.goalsDao.linkTask(widget.goalId, id); }
              for (final id in toRemove) { await widget.db.goalsDao.unlinkTask(widget.goalId, id); }
              if (context.mounted) Navigator.pop(context);
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 13),
              decoration: BoxDecoration(color: KaalColors.acc, borderRadius: BorderRadius.circular(11)),
              alignment: Alignment.center,
              child: Text(AppL10n.of(context).save, style: const TextStyle(fontFamily: 'Inter', fontSize: 14,
                  fontWeight: FontWeight.w700, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Supporting habits card ────────────────────────────────────────────────────

class _SupportingHabitsCard extends ConsumerWidget {
  final int goalId;
  final KaalColors colors;
  const _SupportingHabitsCard({required this.goalId, required this.colors});

  void _showHabitPicker(BuildContext context, WidgetRef ref) {
    final allHabits = ref.read(habitsProvider).value ?? [];
    final linked = (ref.read(goalHabitLinksProvider(goalId)).value ?? [])
        .map((l) => l.habitId)
        .toSet();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: const Color(0x8C000000),
      isScrollControlled: true,
      builder: (_) => _HabitPickerSheet(
        habits: allHabits,
        linked: linked,
        goalId: goalId,
        colors: colors,
        db: ref.read(appDatabaseProvider),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitLinks  = ref.watch(goalHabitLinksProvider(goalId)).value ?? [];
    final allHabits   = ref.watch(habitsProvider).value ?? [];
    final linkedIds   = habitLinks.map((l) => l.habitId).toSet();
    final linkedHabits = allHabits.where((h) => linkedIds.contains(h.id)).toList();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(width: 0.5, color: colors.bdr),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(AppL10n.of(context).supportingHabits.toUpperCase(), style: TextStyle(fontFamily: 'Inter', fontSize: 10,
                  fontWeight: FontWeight.w700, letterSpacing: 0.5, color: colors.ink3)),
              GestureDetector(
                onTap: () => _showHabitPicker(context, ref),
                child: Text('+ ${AppL10n.of(context).linkHabit}', style: const TextStyle(fontFamily: 'Inter',
                    fontSize: 11, color: KaalColors.acc2)),
              ),
            ],
          ),
          if (linkedHabits.isEmpty) ...[
            const SizedBox(height: 8),
            Text(AppL10n.of(context).noLinkedHabitsYet,
                style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: colors.ink3, height: 1.5)),
          ] else ...[
            const SizedBox(height: 8),
            for (final habit in linkedHabits)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Text(habit.emoji, style: const TextStyle(fontSize: 14)),
                    const SizedBox(width: 8),
                    Expanded(child: Text(habit.name,
                        style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: colors.ink, height: 1.3))),
                    Text(habit.frequencyLabel,
                        style: TextStyle(fontFamily: 'Inter', fontSize: 10, color: colors.ink3)),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: () => ref.read(appDatabaseProvider).goalsDao.unlinkHabit(goalId, habit.id),
                      child: Icon(Icons.close_rounded, size: 14, color: colors.ink3),
                    ),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }
}

// ── Habit picker sheet ────────────────────────────────────────────────────────

class _HabitPickerSheet extends StatefulWidget {
  final List<Habit> habits;
  final Set<int> linked;
  final int goalId;
  final KaalColors colors;
  final dynamic db;
  const _HabitPickerSheet({required this.habits, required this.linked,
      required this.goalId, required this.colors, required this.db});

  @override
  State<_HabitPickerSheet> createState() => _HabitPickerSheetState();
}

class _HabitPickerSheetState extends State<_HabitPickerSheet> {
  late final Set<int> _pending = Set.from(widget.linked);

  @override
  Widget build(BuildContext context) {
    final safeBot = MediaQuery.of(context).padding.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 16 + safeBot),
      decoration: const BoxDecoration(
        color: Color(0xFF1C1C1E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        border: Border(top: BorderSide(width: 0.5, color: Color(0x33FFFFFF))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 36, height: 4, margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(color: const Color(0x40FFFFFF), borderRadius: BorderRadius.circular(2))),
          Text(AppL10n.of(context).linkHabitsToGoal, style: TextStyle(fontFamily: 'Inter', fontSize: 14,
              fontWeight: FontWeight.w600, color: widget.colors.ink, height: 1)),
          const SizedBox(height: 12),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 320),
            child: widget.habits.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(AppL10n.of(context).noHabitsFound,
                        style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: widget.colors.ink3)),
                  )
                : ListView(
                    shrinkWrap: true,
                    children: widget.habits.map((h) {
                      final isLinked = _pending.contains(h.id);
                      return GestureDetector(
                        onTap: () => setState(() {
                          if (isLinked) { _pending.remove(h.id); } else { _pending.add(h.id); }
                        }),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                          decoration: const BoxDecoration(
                              border: Border(bottom: BorderSide(width: 0.5, color: Color(0x1AFFFFFF)))),
                          child: Row(children: [
                            Container(
                              width: 16, height: 16,
                              decoration: BoxDecoration(
                                color: isLinked ? KaalColors.acc : Colors.transparent,
                                borderRadius: BorderRadius.circular(4),
                                border: isLinked ? null : Border.all(width: 1.5, color: const Color(0x40FFFFFF)),
                              ),
                              alignment: Alignment.center,
                              child: isLinked
                                  ? const Icon(Icons.check_rounded, size: 10, color: Colors.white)
                                  : null,
                            ),
                            const SizedBox(width: 10),
                            Text(h.emoji, style: const TextStyle(fontSize: 14)),
                            const SizedBox(width: 8),
                            Expanded(child: Text(h.name,
                                style: TextStyle(fontFamily: 'Inter', fontSize: 13,
                                    color: widget.colors.ink, height: 1))),
                            Text(h.frequencyLabel,
                                style: TextStyle(fontFamily: 'Inter', fontSize: 10, color: widget.colors.ink3)),
                          ]),
                        ),
                      );
                    }).toList(),
                  ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () async {
              final toAdd    = _pending.difference(widget.linked);
              final toRemove = widget.linked.difference(_pending);
              for (final id in toAdd)    { await widget.db.goalsDao.linkHabit(widget.goalId, id); }
              for (final id in toRemove) { await widget.db.goalsDao.unlinkHabit(widget.goalId, id); }
              if (context.mounted) Navigator.pop(context);
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 13),
              decoration: BoxDecoration(color: KaalColors.acc, borderRadius: BorderRadius.circular(11)),
              alignment: Alignment.center,
              child: Text(AppL10n.of(context).save, style: const TextStyle(fontFamily: 'Inter', fontSize: 14,
                  fontWeight: FontWeight.w700, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}
