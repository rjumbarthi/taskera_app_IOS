import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database.dart';
import 'database_provider.dart';

/// Stream of all habits (in insertion order).
final habitsProvider = StreamProvider<List<Habit>>((ref) {
  return ref.watch(appDatabaseProvider).habitsDao.watchAllWithWeeklyFill();
});

/// Stream of a single habit by id.
final singleHabitProvider =
    StreamProvider.family<Habit?, int>((ref, habitId) {
  return ref.watch(appDatabaseProvider).habitsDao.watchHabit(habitId);
});

/// Stream of sub-habits for a given habit id.
final subHabitsProvider =
    StreamProvider.family<List<SubHabit>, int>((ref, habitId) {
  return ref.watch(appDatabaseProvider).habitsDao.watchSubHabits(habitId);
});

/// All done (non-skipped) logs across every habit for a given week [start, end).
final habitWeekLogsProvider =
    StreamProvider.family<List<HabitLog>, (DateTime, DateTime)>((ref, args) {
  final (start, end) = args;
  return ref.watch(appDatabaseProvider).habitsDao.watchWeekLogs(start, end);
});

/// Stream of completion logs for a habit in a given (habitId, year, month).
final habitMonthLogsProvider =
    StreamProvider.family<List<HabitLog>, (int, int, int)>((ref, args) {
  final (habitId, year, month) = args;
  return ref
      .watch(appDatabaseProvider)
      .habitsDao
      .watchMonthLogs(habitId, year, month);
});

/// All log entries for a single habit (oldest first).
final habitAllLogsProvider =
    StreamProvider.family<List<HabitLog>, int>((ref, habitId) {
  return ref.watch(appDatabaseProvider).habitsDao.watchHabitAllLogs(habitId);
});

/// All log entries across all habits in a date range [from, to).
final allHabitLogsInRangeProvider =
    StreamProvider.family<List<HabitLog>, (DateTime, DateTime)>((ref, args) {
  final (from, to) = args;
  return ref.watch(appDatabaseProvider).habitsDao.watchAllLogsInRange(from, to);
});
