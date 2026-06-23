import 'focus_session_repository.dart';

/// Placeholder Firestore-backed implementation. NOT wired in yet — the app uses
/// [DriftFocusSessionRepository]. To switch later: add `firebase_core` +
/// `cloud_firestore`, configure a Firebase project, implement the methods below,
/// then return this from `focusSessionRepositoryProvider`.
///
/// Intended Firestore shape (mirrors [FocusSessionRecord]):
///   collection `focus_sessions` → doc { taskId, quadrant, startedAt,
///                                        durationSeconds, completed }
///   doc `tasks/{taskId}` → increment `totalFocusSeconds` by `durationSeconds`.
class FirestoreFocusSessionRepository implements FocusSessionRepository {
  @override
  Future<void> logSession(FocusSessionRecord record) async {
    throw UnimplementedError(
        'Firestore backend not configured. Using DriftFocusSessionRepository.');
  }

  @override
  Stream<List<FocusSessionRecord>> watchSessions(DateTime from, DateTime to) {
    throw UnimplementedError(
        'Firestore backend not configured. Using DriftFocusSessionRepository.');
  }
}
