import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database.dart';
import 'database_provider.dart';

/// Stream of all goals (in insertion order).
final goalsProvider = StreamProvider<List<Goal>>((ref) {
  return ref.watch(appDatabaseProvider).goalsDao.watchAll();
});

/// Stream of a single goal by id (null if not found).
final singleGoalProvider =
    StreamProvider.family<Goal?, int>((ref, id) {
  return ref.watch(appDatabaseProvider).goalsDao.watchGoal(id);
});

/// Stream of Task rows linked to a goal (live, auto-updates on task completion).
final goalLinkedTasksProvider =
    StreamProvider.family<List<Task>, int>((ref, goalId) {
  return ref.watch(appDatabaseProvider).watchLinkedTasks(goalId);
});

/// Stream of GoalTaskLink rows for a goal (used for count/badge display).
final goalTaskLinksProvider =
    StreamProvider.family<List<GoalTaskLink>, int>((ref, goalId) {
  return ref.watch(appDatabaseProvider).goalsDao.watchTaskLinks(goalId);
});

/// Stream of GoalHabitLink rows for a goal.
final goalHabitLinksProvider =
    StreamProvider.family<List<GoalHabitLink>, int>((ref, goalId) {
  return ref.watch(appDatabaseProvider).goalsDao.watchHabitLinks(goalId);
});
