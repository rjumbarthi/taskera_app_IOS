import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/providers/goals_provider.dart';
import '../data/providers/habits_provider.dart';
import '../l10n/app_l10n.dart';

/// Live goal metadata line shown under a goal's title/progress bar.
///
/// Derives its text from the goal's actual links (not a stored string):
/// - task-linked goals  → "Linked tasks · N"
/// - habit-linked goals → "Linked habits · X/Y streaks this week"
///   (X = linked habits with an active 🔥 streak, Y = total linked habits)
class GoalMetaLabel extends ConsumerWidget {
  final int goalId;
  final bool isHabit;
  final TextStyle style;

  const GoalMetaLabel({
    super.key,
    required this.goalId,
    required this.isHabit,
    required this.style,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppL10n.of(context);

    final String text;
    if (isHabit) {
      final links  = ref.watch(goalHabitLinksProvider(goalId)).value ?? const [];
      final habits = ref.watch(habitsProvider).value ?? const [];
      final linkedIds = links.map((e) => e.habitId).toSet();
      final linked = habits.where((h) => linkedIds.contains(h.id)).toList();
      final withStreak = linked.where((h) => h.streakLabel.contains('🔥')).length;
      text = l.linkedHabitsStreaks(withStreak, linked.length);
    } else {
      final tasks = ref.watch(goalLinkedTasksProvider(goalId)).value ?? const [];
      text = l.linkedTasksCount(tasks.length);
    }

    return Text(text, style: style);
  }
}

/// Live goal counts: "N tasks · M habits" — derived from the real links.
class GoalCountsLabel extends ConsumerWidget {
  final int goalId;
  final TextStyle style;

  const GoalCountsLabel({super.key, required this.goalId, required this.style});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppL10n.of(context);
    final taskCount  = (ref.watch(goalLinkedTasksProvider(goalId)).value ?? const []).length;
    final habitCount = (ref.watch(goalHabitLinksProvider(goalId)).value ?? const []).length;
    return Text('$taskCount ${l.tasks} · $habitCount ${l.habits}', style: style);
  }
}
