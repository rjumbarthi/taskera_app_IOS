import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/focus_session_repository.dart';

class TimeTrackerState {
  final bool running;
  final int elapsedSeconds;
  final String? taskTitle;
  final int? startedAtMs;
  final int? taskId;   // when set, stop() writes the time back to this task
  final int quadrant;  // for the logged focus-session record

  const TimeTrackerState({
    this.running = false,
    this.elapsedSeconds = 0,
    this.taskTitle,
    this.startedAtMs,
    this.taskId,
    this.quadrant = 0,
  });

  TimeTrackerState copyWith({
    bool? running,
    int? elapsedSeconds,
    String? taskTitle,
    int? startedAtMs,
    int? taskId,
    int? quadrant,
  }) => TimeTrackerState(
    running: running ?? this.running,
    elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
    taskTitle: taskTitle ?? this.taskTitle,
    startedAtMs: startedAtMs ?? this.startedAtMs,
    taskId: taskId ?? this.taskId,
    quadrant: quadrant ?? this.quadrant,
  );

  String get displayTime {
    final h = elapsedSeconds ~/ 3600;
    final m = (elapsedSeconds % 3600) ~/ 60;
    final s = elapsedSeconds % 60;
    if (h > 0) {
      return '$h:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }
    return '0:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
}

class TimeTrackerNotifier extends Notifier<TimeTrackerState> {
  Timer? _timer;

  @override
  TimeTrackerState build() => const TimeTrackerState();

  /// Start a fresh session. Pass [taskId] (and [quadrant]) so the elapsed time
  /// is written back to that task when the session stops.
  void startNew(String taskTitle, {int? taskId, int quadrant = 0}) {
    _timer?.cancel();
    state = TimeTrackerState(
      running: true,
      elapsedSeconds: 0,
      taskTitle: taskTitle,
      startedAtMs: DateTime.now().millisecondsSinceEpoch,
      taskId: taskId,
      quadrant: quadrant,
    );
    _startTicking();
  }

  void pause() {
    _timer?.cancel();
    _timer = null;
    state = state.copyWith(running: false);
  }

  void resume() {
    if (!state.running) {
      state = state.copyWith(running: true);
      _startTicking();
    }
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    final s = state;
    // Persist the time against the task (and as a focus-session record).
    if (s.taskId != null && s.startedAtMs != null && s.elapsedSeconds > 0) {
      ref.read(focusSessionRepositoryProvider).logSession(FocusSessionRecord(
            taskId: s.taskId!,
            quadrant: s.quadrant == 0 ? 1 : s.quadrant,
            startedAt: DateTime.fromMillisecondsSinceEpoch(s.startedAtMs!),
            durationSeconds: s.elapsedSeconds,
            completed: false,
          ));
    }
    state = const TimeTrackerState();
  }

  void _startTicking() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      state = state.copyWith(elapsedSeconds: state.elapsedSeconds + 1);
    });
  }
}

final timeTrackerProvider =
    NotifierProvider<TimeTrackerNotifier, TimeTrackerState>(TimeTrackerNotifier.new);
