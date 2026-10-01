import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/database.dart' show Task;
import '../data/providers/database_provider.dart';
import '../data/providers/dtn_provider.dart';
import '../data/providers/pomodoro_provider.dart';
import '../settings/app_launch_prefs.dart';
import '../settings/taskera_settings.dart';
import '../settings/prefs_provider.dart';
import 'dtn_widget_bridge.dart';
import 'notification_service.dart';

/// Keeps the ongoing "Do The Next" notification in sync with the current DTN
/// task + the `dtnNotif` setting, and applies button taps (Done / Skip / Focus)
/// once the app is in the foreground.
class DtnController extends ConsumerStatefulWidget {
  final GoRouter router;
  final Widget child;
  const DtnController({super.key, required this.router, required this.child});

  @override
  ConsumerState<DtnController> createState() => _DtnControllerState();
}

class _DtnControllerState extends ConsumerState<DtnController>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Apply a notification tap the moment its callback fires (app alive), not
    // only on the next resume lifecycle — the two race and the resume often
    // wins before the payload is set, dropping the deep link.
    NotificationService.onTapHandled = () {
      if (mounted) _consumePending();
    };
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _consumePending();
      _sync();
    });
  }

  @override
  void dispose() {
    if (NotificationService.onTapHandled != null) {
      NotificationService.onTapHandled = null;
    }
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _consumePending();
      _sync();
    } else if (state == AppLifecycleState.paused) {
      // Remember we were just foregrounded, so a quick reopen after Android
      // kills us in the background skips the quote splash (feels like a resume).
      AppLaunchPrefs.recordActive(ref.read(sharedPreferencesProvider));
    }
  }

  // Apply a pending notification-button action and any deep-link route.
  Future<void> _consumePending() async {
    // Pick up any Start/Pause the background isolate applied directly to disk
    // while the app was closed — the live provider's in-memory state would
    // otherwise be stale until this runs.
    ref.read(pomodoroProvider.notifier).refreshFromDisk();

    // Foreground action (app was open when the button was tapped).
    final action = NotificationService.consumePendingDtnAction();
    if (action != null) {
      final db = ref.read(appDatabaseProvider);
      switch (action.action) {
        case kDtnDone:
          await db.tasksDao.toggleDone(action.taskId, true);
          if (ref.read(pomodoroProvider).taskId == action.taskId) {
            ref.read(pomodoroProvider.notifier).reset();
          }
          break;
        case kDtnStart:
          ref.read(pomodoroProvider.notifier)
              .start(action.taskId, action.durationSec);
          break;
        case kDtnPause:
          ref.read(pomodoroProvider.notifier).pause();
          break;
      }
    }

    // Background-queued Done taps — applied without the app having opened.
    final queued = await NotificationService.consumeDtnQueue(
        ref.read(sharedPreferencesProvider));
    if (queued.isNotEmpty) {
      final db = ref.read(appDatabaseProvider);
      for (final e in queued) {
        final sep = e.indexOf(':');
        if (sep < 0) continue;
        final id = int.tryParse(e.substring(sep + 1));
        if (id == null) continue;
        if (e.startsWith('done:')) {
          await db.tasksDao.toggleDone(id, true);
          if (ref.read(pomodoroProvider).taskId == id) {
            ref.read(pomodoroProvider.notifier).reset();
          }
        }
      }
    }

    final route = NotificationService.consumePendingRoute();
    if (route != null) widget.router.go(route);
  }

  // Show or cancel the ongoing card to match current state.
  Future<void> _sync() async {
    if (!mounted) return;
    final enabled = ref.read(taskeraSettingsProvider).sw('dtnNotif');
    final task    = ref.read(dtnTaskProvider);
    final svc     = ref.read(notificationServiceProvider);
    if (enabled && task != null) {
      final pomo = ref.read(pomodoroProvider);
      final durationSec = (task.timeAllocatedMin ?? 25) * 60;
      await svc.showDtnCard(
        taskId: task.id,
        title: task.title,
        quadrant: task.quadrant,
        durationSec: durationSec,
        running: pomo.taskId == task.id && pomo.running,
        lockScreen: ref.read(taskeraSettingsProvider).sw('dtnLockScreen'),
      );
      await DtnWidgetBridge.update(title: task.title, meta: 'Q${task.quadrant}');
    } else {
      await svc.cancelDtn();
      await DtnWidgetBridge.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Refresh the card whenever the top task changes, the setting flips, or
    // the Pomodoro session's running state changes (so the Start/Pause button
    // on the card stays in sync with what the Timer screen is doing).
    ref.listen<Task?>(dtnTaskProvider, (_, _) => _sync());
    ref.listen<bool>(
      taskeraSettingsProvider.select((s) => s.sw('dtnNotif')),
      (_, _) => _sync(),
    );
    // select, not a bare listen — pomodoroProvider.touch() emits a new state
    // every second while running (to drive the Timer screen's countdown); the
    // DTN card only needs to refresh when (taskId, running) actually changes,
    // not every second, or this would re-post the notification every second.
    ref.listen<(int, bool)>(
      pomodoroProvider.select((s) => (s.taskId, s.running)),
      (_, _) => _sync(),
    );
    return widget.child;
  }
}
