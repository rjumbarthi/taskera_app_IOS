import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database.dart';
import 'database_provider.dart';

/// Stream of all tasks (active + done) for search.
final allTasksProvider = StreamProvider<List<Task>>((ref) {
  return ref.watch(appDatabaseProvider).tasksDao.watchAll();
});

/// Stream of active (not done) tasks for a given quadrant (1–4).
final quadrantTasksProvider =
    StreamProvider.family<List<Task>, int>((ref, quadrant) {
  return ref.watch(appDatabaseProvider).tasksDao.watchByQuadrant(quadrant);
});

/// Stream of all completed tasks (most recent first).
final doneTasksProvider = StreamProvider<List<Task>>((ref) {
  return ref.watch(appDatabaseProvider).tasksDao.watchDone();
});

/// Stream of subtasks for a given task id.
final subtasksProvider =
    StreamProvider.family<List<Subtask>, int>((ref, taskId) {
  return ref.watch(appDatabaseProvider).tasksDao.watchSubtasks(taskId);
});

/// Stream of a single task by id (null if not found).
final singleTaskProvider =
    StreamProvider.family<Task?, int>((ref, id) {
  return ref.watch(appDatabaseProvider).tasksDao.watchTask(id);
});

/// Stream of unassigned (inbox) tasks — quadrant 0, not done.
final inboxTasksProvider = StreamProvider<List<Task>>((ref) {
  return ref.watch(appDatabaseProvider).tasksDao.watchInbox();
});
