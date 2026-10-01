import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../settings/prefs_provider.dart';

// SharedPreferences keys. Also written directly — bypassing this provider —
// by the notification background isolate in notification_service.dart, which
// runs in a separate isolate with no Riverpod access. Keep both in sync.
const kPomodoroKeyTaskId         = 'taskera.pomodoro.taskId';
const kPomodoroKeyDurationSec    = 'taskera.pomodoro.durationSec';
const kPomodoroKeyRunning        = 'taskera.pomodoro.running';
const kPomodoroKeyElapsedAtPause = 'taskera.pomodoro.elapsedAtPause';
const kPomodoroKeyRunningSince   = 'taskera.pomodoro.runningSinceMs';

/// A Pomodoro session's truth, persisted to SharedPreferences so it survives
/// the app being backgrounded or killed — required for a notification/watch
/// Pause action to mean anything when the app isn't open. Elapsed time is
/// always computed from wall-clock timestamps, never a live ticking Timer, so
/// it's correct the instant the app (re)opens regardless of how long it was
/// away.
class PomodoroState {
  final int taskId; // -1 = no active session
  final int durationSec;
  final bool running;
  final int elapsedSecAtPause;
  final int? runningSinceEpochMs;

  const PomodoroState({
    this.taskId = -1,
    this.durationSec = 25 * 60,
    this.running = false,
    this.elapsedSecAtPause = 0,
    this.runningSinceEpochMs,
  });

  int elapsedSecAt(DateTime now) {
    if (!running || runningSinceEpochMs == null) return elapsedSecAtPause;
    final extra = (now.millisecondsSinceEpoch - runningSinceEpochMs!) ~/ 1000;
    return elapsedSecAtPause + (extra < 0 ? 0 : extra);
  }

  int secondsLeftAt(DateTime now) =>
      (durationSec - elapsedSecAt(now)).clamp(0, durationSec);

  PomodoroState copyWith({
    int? taskId,
    int? durationSec,
    bool? running,
    int? elapsedSecAtPause,
    int? runningSinceEpochMs,
    bool clearRunningSince = false,
  }) =>
      PomodoroState(
        taskId: taskId ?? this.taskId,
        durationSec: durationSec ?? this.durationSec,
        running: running ?? this.running,
        elapsedSecAtPause: elapsedSecAtPause ?? this.elapsedSecAtPause,
        runningSinceEpochMs: clearRunningSince
            ? null
            : (runningSinceEpochMs ?? this.runningSinceEpochMs),
      );
}

class PomodoroNotifier extends Notifier<PomodoroState> {
  @override
  PomodoroState build() {
    final p = ref.read(sharedPreferencesProvider);
    return PomodoroState(
      taskId: p.getInt(kPomodoroKeyTaskId) ?? -1,
      durationSec: p.getInt(kPomodoroKeyDurationSec) ?? 25 * 60,
      running: p.getBool(kPomodoroKeyRunning) ?? false,
      elapsedSecAtPause: p.getInt(kPomodoroKeyElapsedAtPause) ?? 0,
      runningSinceEpochMs: p.getInt(kPomodoroKeyRunningSince),
    );
  }

  void _persist() {
    final p = ref.read(sharedPreferencesProvider);
    p.setInt(kPomodoroKeyTaskId, state.taskId);
    p.setInt(kPomodoroKeyDurationSec, state.durationSec);
    p.setBool(kPomodoroKeyRunning, state.running);
    p.setInt(kPomodoroKeyElapsedAtPause, state.elapsedSecAtPause);
    if (state.runningSinceEpochMs != null) {
      p.setInt(kPomodoroKeyRunningSince, state.runningSinceEpochMs!);
    } else {
      p.remove(kPomodoroKeyRunningSince);
    }
  }

  /// Reload from SharedPreferences — call on app resume in case the
  /// background notification isolate changed it directly.
  void refreshFromDisk() => state = build();

  /// Start a fresh session for [taskId]/[durationSec], or resume it in place
  /// if it's already the active (paused) task/duration.
  void start(int taskId, int durationSec) {
    if (state.taskId == taskId &&
        state.durationSec == durationSec &&
        !state.running &&
        state.elapsedSecAtPause > 0) {
      state = state.copyWith(
          running: true,
          runningSinceEpochMs: DateTime.now().millisecondsSinceEpoch);
    } else {
      state = PomodoroState(
        taskId: taskId,
        durationSec: durationSec,
        running: true,
        runningSinceEpochMs: DateTime.now().millisecondsSinceEpoch,
      );
    }
    _persist();
  }

  void pause() {
    if (!state.running) return;
    final now = DateTime.now();
    state = state.copyWith(
      running: false,
      elapsedSecAtPause: state.elapsedSecAt(now),
      clearRunningSince: true,
    );
    _persist();
  }

  void reset() {
    state = const PomodoroState();
    _persist();
  }

  /// No-op state replacement purely to notify listeners — called by the
  /// screen's own 1s UI timer so the countdown repaints while running. The
  /// provider itself holds no live Timer (only the open screen does); the
  /// persisted wall-clock math is what stays correct in the background.
  void touch() {
    if (state.running) state = state.copyWith();
  }
}

final pomodoroProvider =
    NotifierProvider<PomodoroNotifier, PomodoroState>(PomodoroNotifier.new);
