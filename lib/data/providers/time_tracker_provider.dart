import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TimeTrackerState {
  final bool running;
  final int elapsedSeconds;
  final String? taskTitle;
  final int? startedAtMs;

  const TimeTrackerState({
    this.running = false,
    this.elapsedSeconds = 0,
    this.taskTitle,
    this.startedAtMs,
  });

  TimeTrackerState copyWith({
    bool? running,
    int? elapsedSeconds,
    String? taskTitle,
    int? startedAtMs,
  }) => TimeTrackerState(
    running: running ?? this.running,
    elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
    taskTitle: taskTitle ?? this.taskTitle,
    startedAtMs: startedAtMs ?? this.startedAtMs,
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

  void startNew(String taskTitle) {
    _timer?.cancel();
    state = TimeTrackerState(
      running: true,
      elapsedSeconds: 0,
      taskTitle: taskTitle,
      startedAtMs: DateTime.now().millisecondsSinceEpoch,
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
