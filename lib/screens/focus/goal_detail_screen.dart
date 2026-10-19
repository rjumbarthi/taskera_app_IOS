import 'package:flutter/material.dart';
import '../../widgets/ai_insight_card.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:drift/drift.dart' show Value;
import '../../data/database.dart' show Goal, Task, GoalsCompanion;
import '../../data/providers/goals_provider.dart';
import '../../data/providers/habits_provider.dart';
import '../../data/providers/tasks_provider.dart';
import '../../data/providers/database_provider.dart';
import '../../theme/taskera_colors.dart';
import '../../theme/taskera_theme.dart';
import '../../widgets/add_back_button.dart';
import '../../widgets/goal_link_pickers.dart';
import '../../l10n/app_l10n.dart';

class GoalDetailScreen extends ConsumerWidget {
  final String goalId;
  const GoalDetailScreen({super.key, required this.goalId});

  int get _id => int.tryParse(goalId) ?? 0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors    = TaskEraTheme.of(context).colors;
    final goalAsync = ref.watch(singleGoalProvider(_id));

    return goalAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error:   (e, _) => Center(child: Text('Error: $e', style: TextStyle(color: Colors.white))),
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
  final TaskEraColors colors;
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
              AddBackButton(strokeColor: accentColor, onTap: () => context.pop()),
              const SizedBox(width: 8),
              Expanded(
                child: RichText(
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  text: TextSpan(
                    style: TextStyle(
                      fontFamily: TaskEraTheme.of(context).type.numberFontFamily,
                      fontVariations: [FontVariation('wght', 600)],
                      fontSize: 19,
                      letterSpacing: -0.5,
                      height: 1.3,
                    ),
                    children: [
                      TextSpan(text: '${AppL10n.of(context).goals} · ', style: TextStyle(color: accentColor)),
                      TextSpan(text: goal.title, style: TextStyle(color: colors.ink)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
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
                      Text(AppL10n.of(context).edit, style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 12, fontWeight: FontWeight.w600, color: colors.ink2)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 16),
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
                            child: Text(goal.emoji, style: TextStyle(fontSize: 20)),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  goal.title,
                                  style: TextStyle(
                                    fontFamily: TaskEraTheme.of(context).type.numberFontFamily,
                                    fontVariations: [FontVariation('wght', 700)],
                                    fontSize: 16,
                                    color: Color(0xFFF2F2F7),
                                    height: 1.25,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  goal.subtitle,
                                  style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 12, color: colors.ink3, height: 1.3),
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
                          Text(AppL10n.of(context).overallProgress, style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 12, color: colors.ink3)),
                          Text(
                            '${(goal.progressPct * 100).round()}%',
                            style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 16, fontWeight: FontWeight.w700, color: accentColor),
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

                // Why this matters — tap to add/edit
                _WhyMattersCard(goal: goal, colors: colors),
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

                // Real on-demand TaskEra AI — reasons over this goal.
                AiInsightCard(
                  input: 'Goal: ${goal.title}\n'
                      'Why it matters: ${goal.subtitle}\n'
                      'Progress: ${(goal.progressPct * 100).round()}%'
                      '${goal.notes != null && goal.notes!.trim().isNotEmpty ? '\nNotes: ${goal.notes!.trim()}' : ''}'
                      '${goal.milestones.trim().isNotEmpty ? '\nMilestones: ${goal.milestones.trim().replaceAll('\n', '; ')}' : ''}',
                  hint: 'How do I hit this goal faster?',
                  margin: EdgeInsets.zero,
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
  final TaskEraColors colors;
  // Right-aligned action next to the label — e.g. "+ Add milestone", to match
  // the Linked Tasks / Supporting Habits cards' "+ Link task" placement.
  final Widget? trailing;
  const _SectionCard({required this.label, required this.child, required this.colors, this.trailing});

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
          trailing == null
              ? Text(label, style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.5, color: colors.ink3))
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(label, style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.5, color: colors.ink3)),
                    trailing!,
                  ],
                ),
          const SizedBox(height: 6),
          child,
        ],
      ),
    );
  }
}

// ── Why this matters card ─────────────────────────────────────────────────────

class _WhyMattersCard extends ConsumerStatefulWidget {
  final Goal goal;
  final TaskEraColors colors;
  const _WhyMattersCard({required this.goal, required this.colors});

  @override
  ConsumerState<_WhyMattersCard> createState() => _WhyMattersCardState();
}

class _WhyMattersCardState extends ConsumerState<_WhyMattersCard> {
  Future<void> _edit() async {
    final ctrl = TextEditingController(text: widget.goal.subtitle);
    final result = await showDialog<String>(
      context: context,
      // Use the dialog's OWN context to pop (not the outer screen context) —
      // the earlier milestone-dialog bug popped the whole screen instead of
      // just the dialog because it reused the outer context here.
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text('Why this matters',
            style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          maxLines: 4,
          style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 14, color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Why does this goal matter to you?',
            hintStyle: TextStyle(color: Color(0xB3FFFFFF)),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0x4DFFFFFF))),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: TaskEraColors.acc)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text(AppL10n.of(context).cancel, style: const TextStyle(color: Color(0xB3FFFFFF))),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, ctrl.text.trim()),
            child: Text(AppL10n.of(context).save, style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily,
                color: widget.colors.plainText ? Colors.white : TaskEraColors.acc2, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    ctrl.dispose();
    if (result == null || !mounted || result == widget.goal.subtitle) return;
    await ref.read(appDatabaseProvider).goalsDao.updateGoal(
      widget.goal.id,
      GoalsCompanion(subtitle: Value(result)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _edit,
      child: _SectionCard(
        label: 'WHY THIS MATTERS',
        colors: widget.colors,
        child: Text(
          widget.goal.subtitle.isNotEmpty ? widget.goal.subtitle : 'Tap to add why this goal matters to you.',
          style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 14, color: widget.colors.ink2, height: 1.5),
        ),
      ),
    );
  }
}

// ── Milestones card ───────────────────────────────────────────────────────────

class _MilestonesCard extends ConsumerStatefulWidget {
  final Goal goal;
  final TaskEraColors colors;
  const _MilestonesCard({required this.goal, required this.colors});

  @override
  ConsumerState<_MilestonesCard> createState() => _MilestonesCardState();
}

class _MilestonesCardState extends ConsumerState<_MilestonesCard> {
  Future<void> _addMilestone() async {
    final ctrl = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      // showDialog pushes onto the ROOT navigator by default. The action
      // buttons below used to call Navigator.pop(context) with the OUTER
      // (screen) context instead of this dialog's own — Navigator.pop then
      // resolved to the nearest ancestor navigator relative to THAT context,
      // which is this screen's nested shell-branch navigator, not the root.
      // So "Add"/"Cancel" popped the whole Goal Detail screen off its tab
      // (landing back on Focus) instead of just closing the dialog.
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        // Fixed-dark surface regardless of app theme — its text must be fixed
        // light too. widget.colors.ink/.ink3 flip to near-black on light theme,
        // which made the typed text invisible against this background (you
        // could type, you just couldn't see it — looked like input was dead).
        title: Text(AppL10n.of(context).addMilestone,
            style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 14, color: Colors.white),
          decoration: InputDecoration(
            hintText: AppL10n.of(context).milestoneTitle,
            hintStyle: const TextStyle(color: Color(0xB3FFFFFF)),
            enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0x4DFFFFFF))),
            focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: TaskEraColors.acc)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text(AppL10n.of(context).cancel, style: const TextStyle(color: Color(0xB3FFFFFF))),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, ctrl.text.trim()),
            child: Text(AppL10n.of(context).add, style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily,
                color: widget.colors.plainText ? Colors.white : TaskEraColors.acc2, fontWeight: FontWeight.w700)),
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
      // Rightmost, matching "+ Link task" / "+ Link habit" placement.
      trailing: milestones.length < 5
          ? GestureDetector(
              onTap: _addMilestone,
              child: Text('+ ${AppL10n.of(context).addMilestone}',
                  style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 11, color: widget.colors.textOrPlain(TaskEraColors.acc2))),
            )
          : null,
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
                    style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 13, color: widget.colors.ink, height: 1.3))),
                GestureDetector(
                  onTap: () => _removeMilestone(e.key),
                  child: Icon(Icons.close_rounded, size: 14, color: widget.colors.ink3),
                ),
              ],
            ),
          )),
          if (milestones.isEmpty)
            Text('No milestones yet.',
                style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 13, color: widget.colors.ink3, height: 1.5)),
        ],
      ),
    );
  }
}

class _LinkedTasksCard extends ConsumerWidget {
  final int goalId;
  final TaskEraColors colors;
  const _LinkedTasksCard({required this.goalId, required this.colors});

  void _showLinkPicker(BuildContext context, WidgetRef ref) {
    final allTasks = <Task>[
      ...ref.read(quadrantTasksProvider(1)).value ?? [],
      ...ref.read(quadrantTasksProvider(2)).value ?? [],
      ...ref.read(quadrantTasksProvider(3)).value ?? [],
      ...ref.read(quadrantTasksProvider(4)).value ?? [],
    ];
    final linked = (ref.read(goalLinkedTasksProvider(goalId)).value ?? []).map((t) => t.id).toSet();

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
              Text(AppL10n.of(context).linkedTasks.toUpperCase(), style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 10,
                  fontWeight: FontWeight.w700, letterSpacing: 0.5, color: colors.ink3)),
              GestureDetector(
                onTap: () => _showLinkPicker(context, ref),
                child: Text('+ ${AppL10n.of(context).linkTask}', style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily,
                    fontSize: 11, color: colors.textOrPlain(TaskEraColors.acc2))),
              ),
            ],
          ),
          if (linkedTasks.isEmpty) ...[
            const SizedBox(height: 8),
            Text(AppL10n.of(context).noLinkedTasksYet,
                style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 13, color: colors.ink3, height: 1.5)),
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
                        color: task.isDone ? TaskEraColors.q2 : Colors.transparent,
                        shape: BoxShape.circle,
                        border: task.isDone ? null : Border.all(width: 1.5, color: TaskEraColors.q2),
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
                            fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 13,
                            color: task.isDone ? colors.ink3 : colors.ink,
                            decoration: task.isDone ? TextDecoration.lineThrough : null,
                            decorationColor: colors.ink3, height: 1.3,
                          )),
                    ),
                    Text('Q${task.quadrant}',
                        style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 10, color: colors.ink3)),
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

// ── Supporting habits card ────────────────────────────────────────────────────

class _SupportingHabitsCard extends ConsumerWidget {
  final int goalId;
  final TaskEraColors colors;
  const _SupportingHabitsCard({required this.goalId, required this.colors});

  void _showHabitPicker(BuildContext context, WidgetRef ref) {
    final allHabits = ref.read(habitsProvider).value ?? [];
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
              Text(AppL10n.of(context).supportingHabits.toUpperCase(), style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 10,
                  fontWeight: FontWeight.w700, letterSpacing: 0.5, color: colors.ink3)),
              GestureDetector(
                onTap: () => _showHabitPicker(context, ref),
                child: Text('+ ${AppL10n.of(context).linkHabit}', style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily,
                    fontSize: 11, color: colors.textOrPlain(TaskEraColors.acc2))),
              ),
            ],
          ),
          if (linkedHabits.isEmpty) ...[
            const SizedBox(height: 8),
            Text(AppL10n.of(context).noLinkedHabitsYet,
                style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 13, color: colors.ink3, height: 1.5)),
          ] else ...[
            const SizedBox(height: 8),
            for (final habit in linkedHabits)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Text(habit.emoji, style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 8),
                    Expanded(child: Text(habit.name,
                        style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 13, color: colors.ink, height: 1.3))),
                    Text(habit.frequencyLabel,
                        style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 10, color: colors.ink3)),
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
