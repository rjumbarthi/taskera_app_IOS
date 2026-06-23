import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database.dart';
import '../providers/database_provider.dart';

/// Persisted focus-session shape:
/// `{ taskId, quadrant, startedAt, durationSeconds, completed }`.
class FocusSessionRecord {
  final int taskId;
  final int quadrant;
  final DateTime startedAt;
  final int durationSeconds;
  final bool completed;

  const FocusSessionRecord({
    required this.taskId,
    required this.quadrant,
    required this.startedAt,
    required this.durationSeconds,
    required this.completed,
  });
}

/// Backend-agnostic store for focus sessions. A Firestore implementation can be
/// swapped into [focusSessionRepositoryProvider] later — see
/// `firestore_focus_session_repository.dart`.
abstract class FocusSessionRepository {
  /// Write a session record and accumulate its time onto the task
  /// (`Tasks.totalFocusSeconds`).
  Future<void> logSession(FocusSessionRecord record);

  /// Sessions started within `[from, to)`.
  Stream<List<FocusSessionRecord>> watchSessions(DateTime from, DateTime to);
}

/// Drift (local SQLite) implementation — the one used today.
class DriftFocusSessionRepository implements FocusSessionRepository {
  final AppDatabase _db;
  DriftFocusSessionRepository(this._db);

  @override
  Future<void> logSession(FocusSessionRecord r) async {
    await _db.focusDao.insertSession(FocusSessionsCompanion(
      taskId:          Value(r.taskId),
      quadrant:        Value(r.quadrant),
      startedAt:       Value(r.startedAt),
      durationSeconds: Value(r.durationSeconds),
      completed:       Value(r.completed),
    ));
    await _db.tasksDao.addFocusSeconds(r.taskId, r.durationSeconds);
  }

  @override
  Stream<List<FocusSessionRecord>> watchSessions(DateTime from, DateTime to) =>
      _db.focusDao.watchSessionsInRange(from, to).map((rows) => rows
          .map((s) => FocusSessionRecord(
                taskId:          s.taskId,
                quadrant:        s.quadrant,
                startedAt:       s.startedAt,
                durationSeconds: s.durationSeconds,
                completed:       s.completed,
              ))
          .toList());
}

final focusSessionRepositoryProvider = Provider<FocusSessionRepository>(
  (ref) => DriftFocusSessionRepository(ref.watch(appDatabaseProvider)),
);

/// This week's sessions (Monday 00:00 → next Monday) for the weekly review.
final weeklyFocusSessionsProvider =
    StreamProvider<List<FocusSessionRecord>>((ref) {
  final now       = DateTime.now();
  final today     = DateTime(now.year, now.month, now.day);
  final monday    = today.subtract(Duration(days: today.weekday - 1));
  final nextMonday = monday.add(const Duration(days: 7));
  return ref.watch(focusSessionRepositoryProvider).watchSessions(monday, nextMonday);
});
