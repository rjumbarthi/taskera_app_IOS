import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/database.dart' show Task;
import '../data/providers/database_provider.dart';
import '../data/providers/dtn_provider.dart';
import '../routing/routes.dart';
import '../settings/kaal_settings.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _consumePending();
      _sync();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _consumePending();
      _sync();
    }
  }

  // Apply a pending notification-button action and any deep-link route.
  Future<void> _consumePending() async {
    final action = NotificationService.consumePendingDtnAction();
    if (action != null) {
      final db = ref.read(appDatabaseProvider);
      switch (action.action) {
        case kDtnDone:
          await db.tasksDao.toggleDone(action.taskId, true);
          break;
        case kDtnSkip:
          ref.read(dtnSkipProvider.notifier)
              .update((s) => {...s, action.taskId});
          break;
        case kDtnFocus:
          widget.router.go(KaalRoutes.focus);
          break;
      }
    }
    final route = NotificationService.consumePendingRoute();
    if (route != null) widget.router.go(route);
  }

  // Show or cancel the ongoing card to match current state.
  Future<void> _sync() async {
    if (!mounted) return;
    final enabled = ref.read(kaalSettingsProvider).sw('dtnNotif');
    final task    = ref.read(dtnTaskProvider);
    final svc     = ref.read(notificationServiceProvider);
    if (enabled && task != null) {
      await svc.showDtnCard(
        taskId: task.id,
        title: task.title,
        quadrant: task.quadrant,
        lockScreen: ref.read(kaalSettingsProvider).sw('dtnLockScreen'),
      );
      await DtnWidgetBridge.update(title: task.title, meta: 'Q${task.quadrant}');
    } else {
      await svc.cancelDtn();
      await DtnWidgetBridge.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Refresh the card whenever the top task changes or the setting flips.
    ref.listen<Task?>(dtnTaskProvider, (_, _) => _sync());
    ref.listen<bool>(
      kaalSettingsProvider.select((s) => s.sw('dtnNotif')),
      (_, _) => _sync(),
    );
    return widget.child;
  }
}
