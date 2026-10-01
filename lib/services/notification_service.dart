import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

import '../data/database.dart';
import '../data/providers/pomodoro_provider.dart';
import '../data/reminder.dart';
import '../routing/routes.dart';
import '../util/platform_layout.dart';

// ── Android channel IDs ───────────────────────────────────────────────────────
const _chTasks    = 'taskera_tasks';
const _chHabits   = 'taskera_habits';
const _chGoals    = 'taskera_goals';
const _chCalendar = 'taskera_calendar';
const _chInbox    = 'taskera_inbox';
const _chFocus    = 'taskera_focus';
const _chDtn      = 'taskera_dtn';
const _chReminders = 'taskera_reminders';
const _chAlarms    = 'taskera_alarms';

// ── DTN notification action ids ───────────────────────────────────────────────
// Start/Pause directly drive the persisted Pomodoro session (pomodoro_provider
// .dart) so they work from a paired Apple Watch / Wear OS even while the app
// is backgrounded or killed — there's no "Skip"/"Focus" button anymore, just
// the timer controls plus Done.
const kDtnDone  = 'dtn_done';
const kDtnStart = 'dtn_start';
const kDtnPause = 'dtn_pause';
const kDtnNotifId = 7000;

// ── Reminder/Alarm notification action ids ────────────────────────────────────
const kReminderSnooze   = 'rem_snooze';
const kReminderDismiss  = 'rem_dismiss';
const kReminderSnoozeMin = 10;

// ── Task-due / Habit-checkin notification action ids ──────────────────────────
// Lets a task or habit be completed directly from the notification — including
// from a paired Apple Watch / Wear OS, which mirror these actions automatically
// (no separate watch app needed; see iOS categories below for why both
// platforms need a registered action, not just Android).
const kTaskDone     = 'task_done';
const kHabitCheckIn = 'habit_checkin';
const kHabitSkip    = 'habit_skip';

// ── iOS/macOS notification categories ─────────────────────────────────────────
// Darwin only shows action buttons (and therefore only mirrors them to a
// paired Apple Watch) when the notification's categoryIdentifier matches one
// registered here at init. Android actions need no such registration.
// DTN needs two categories, not one — Darwin categories are immutable sets of
// actions, so "show Start OR Pause depending on state" means picking between
// two pre-registered categories per notification, not relabeling one.
const _catDtnIdle    = 'dtn_idle_category';
const _catDtnRunning = 'dtn_running_category';
const _catReminder   = 'reminder_category';
const _catHabit      = 'habit_category';
const _catTaskDue    = 'taskdue_category';

// Title/details shared by the instance scheduler and the background snooze
// handler (which runs in a separate isolate and can't call instance methods).
String _reminderTitle(String label, bool isAlarm) =>
    isAlarm ? '⏰ ${label.isEmpty ? "Alarm" : label}' : '🔔 ${label.isEmpty ? "Reminder" : label}';

AndroidNotificationDetails _reminderAndroidDetails(bool isAlarm) =>
    AndroidNotificationDetails(
      isAlarm ? _chAlarms : _chReminders,
      isAlarm ? 'Alarms' : 'Reminders',
      icon: 'ic_stat_focus',
      importance: isAlarm ? Importance.max : Importance.high,
      priority:   isAlarm ? Priority.max   : Priority.high,
      // No full-screen intent: USE_FULL_SCREEN_INTENT is not allowed for this app
      // category on Google Play. Alarms stay heads-up + alarm sound/category.
      category: isAlarm
          ? AndroidNotificationCategory.alarm
          : AndroidNotificationCategory.reminder,
      audioAttributesUsage:
          isAlarm ? AudioAttributesUsage.alarm : AudioAttributesUsage.notification,
      actions: const [
        AndroidNotificationAction(kReminderSnooze, 'Snooze 10m', showsUserInterface: false),
        AndroidNotificationAction(kReminderDismiss, 'Dismiss',
            showsUserInterface: false, cancelNotification: true),
      ],
    );

// Notification id blocks for reminders (9000–9499) and their snoozes (9500–9999)
// — separate so snoozing a *repeating* reminder doesn't overwrite its schedule.
int _reminderNotifIdOf(int id) => 9000 + (id % 500);
int _snoozeNotifIdOf(int id)   => 9500 + (id % 500);

/// A pending action from a DTN notification button, consumed by the app once
/// providers are ready. action is one of kDtnDone/kDtnStart/kDtnPause.
/// durationSec is only meaningful for Start (carried from the payload so the
/// foreground handler doesn't need its own task lookup).
class DtnPendingAction {
  final String action;
  final int taskId;
  final int durationSec;
  const DtnPendingAction(this.action, this.taskId, this.durationSec);
}

/// SharedPreferences key holding DTN Done taps that happened while the app was
/// backgrounded — entries are `done:<id>`. Drained on next resume. Start/Pause
/// don't need this queue: they write straight to the Pomodoro keys below,
/// which is all they need to take effect, even with the app fully killed.
const _kDtnQueueKey = 'taskera.dtn.pending';

/// A pending action from a habit check-in notification, consumed once
/// providers are ready. action is kHabitCheckIn or kHabitSkip.
class HabitPendingAction {
  final String action;
  final int habitId;
  const HabitPendingAction(this.action, this.habitId);
}

/// SharedPreferences key for habit actions tapped while backgrounded —
/// entries are `checkin:<id>` / `skip:<id>`. Drained on next resume.
const _kHabitQueueKey = 'taskera.habit.pending';

/// SharedPreferences key for task-due "Mark done" taps while backgrounded —
/// entries are the bare task id. Drained on next resume.
const _kTaskQueueKey = 'taskera.taskdue.pending';

/// Background-isolate entry point for action buttons tapped while the app is
/// backgrounded or terminated (all `showsUserInterface: false`). It runs in a
/// separate isolate with no access to the app's providers/DB.
///  • DTN Done → queued to SharedPreferences; applied on next resume.
///  • DTN Start/Pause → applied directly to the Pomodoro keys, no queue needed.
///  • Reminder/Alarm Snooze → re-armed +10 min directly from this isolate, so it
///    works even when the app is fully killed (never needs to open the app).
@pragma('vm:entry-point')
Future<void> notificationBackgroundResponse(NotificationResponse r) async {
  final payload = r.payload;
  final action  = r.actionId;
  if (payload == null) return;

  if (payload.startsWith('dtn:')) {
    Map<String, dynamic>? data;
    try {
      data = jsonDecode(payload.substring(4)) as Map<String, dynamic>;
    } catch (_) {
      return;
    }
    final id = data['id'] as int?;
    if (id == null) return;
    final title       = (data['title'] as String?) ?? '';
    final quadrant    = (data['quadrant'] as int?) ?? 1;
    final durationSec = (data['durationSec'] as int?) ?? 1500;

    if (action == kDtnDone) {
      final prefs = await SharedPreferences.getInstance();
      final queue = prefs.getStringList(_kDtnQueueKey) ?? <String>[];
      queue.add('done:$id');
      await prefs.setStringList(_kDtnQueueKey, queue);
      // A done task's own Pomodoro session (if any) is stale — clear it so a
      // finished task doesn't leave a ghost timer running.
      if ((prefs.getInt(kPomodoroKeyTaskId) ?? -1) == id) {
        await prefs.setInt(kPomodoroKeyTaskId, -1);
        await prefs.setBool(kPomodoroKeyRunning, false);
        await prefs.remove(kPomodoroKeyRunningSince);
        await prefs.setInt(kPomodoroKeyElapsedAtPause, 0);
      }
      // Dismiss the ongoing card right now so the tap has an immediate visible
      // effect — it's only applied to the DB silently on the next app open.
      try {
        final plugin = FlutterLocalNotificationsPlugin();
        await plugin.initialize(const InitializationSettings(
          android: AndroidInitializationSettings('ic_stat_focus'),
          iOS: DarwinInitializationSettings(
              requestAlertPermission: false, requestBadgePermission: false, requestSoundPermission: false),
        ));
        await plugin.cancel(kDtnNotifId);
      } catch (_) {/* best-effort — the app resync cancels/refreshes it anyway */}
      return;
    }

    if (action == kDtnStart || action == kDtnPause) {
      // Start/Pause need no DB and no queue — they write straight to the
      // Pomodoro keys, which is a complete, correct state change on its own.
      // This is what makes Pause work from a paired watch even with the app
      // fully killed: there's no app-resume round trip to wait for.
      final prefs = await SharedPreferences.getInstance();
      final nowMs = DateTime.now().millisecondsSinceEpoch;
      bool nowRunning;
      if (action == kDtnStart) {
        final sameSession = prefs.getInt(kPomodoroKeyTaskId) == id &&
            !(prefs.getBool(kPomodoroKeyRunning) ?? false) &&
            (prefs.getInt(kPomodoroKeyElapsedAtPause) ?? 0) > 0 &&
            (prefs.getInt(kPomodoroKeyDurationSec) ?? -1) == durationSec;
        if (!sameSession) await prefs.setInt(kPomodoroKeyElapsedAtPause, 0);
        await prefs.setInt(kPomodoroKeyTaskId, id);
        await prefs.setInt(kPomodoroKeyDurationSec, durationSec);
        await prefs.setBool(kPomodoroKeyRunning, true);
        await prefs.setInt(kPomodoroKeyRunningSince, nowMs);
        nowRunning = true;
      } else {
        final runningSince   = prefs.getInt(kPomodoroKeyRunningSince);
        final elapsedAtPause = prefs.getInt(kPomodoroKeyElapsedAtPause) ?? 0;
        final extra = runningSince != null ? ((nowMs - runningSince) ~/ 1000) : 0;
        await prefs.setInt(
            kPomodoroKeyElapsedAtPause, elapsedAtPause + (extra < 0 ? 0 : extra));
        await prefs.setBool(kPomodoroKeyRunning, false);
        await prefs.remove(kPomodoroKeyRunningSince);
        nowRunning = false;
      }
      // Re-show the same card with the flipped Start/Pause action, entirely
      // from this isolate — the payload already carries title/quadrant, so no
      // DB lookup or app resume is needed for the button to update correctly.
      try {
        final plugin = FlutterLocalNotificationsPlugin();
        await plugin.initialize(const InitializationSettings(
          android: AndroidInitializationSettings('ic_stat_focus'),
          iOS: DarwinInitializationSettings(
              requestAlertPermission: false, requestBadgePermission: false, requestSoundPermission: false),
        ));
        await plugin.show(
          kDtnNotifId,
          nowRunning ? '⏱ Focusing  ·  Q$quadrant' : '▶ Do The Next  ·  Q$quadrant',
          title,
          NotificationService._dtnDetails(running: nowRunning, lockScreen: true),
          payload: payload,
        );
      } catch (_) {/* best-effort */}
      return;
    }
    return;
  }

  if (payload.startsWith('taskdue:')) {
    if (action != kTaskDone) return;
    final id = int.tryParse(payload.substring(8));
    if (id == null) return;
    final prefs = await SharedPreferences.getInstance();
    final queue = prefs.getStringList(_kTaskQueueKey) ?? <String>[];
    queue.add('$id');
    await prefs.setStringList(_kTaskQueueKey, queue);
    try {
      final plugin = FlutterLocalNotificationsPlugin();
      await plugin.initialize(const InitializationSettings(
        android: AndroidInitializationSettings('ic_stat_focus'),
        iOS: DarwinInitializationSettings(
            requestAlertPermission: false, requestBadgePermission: false, requestSoundPermission: false),
      ));
      await plugin.cancel(1100 + (id % 100));
    } catch (_) {/* best-effort */}
    return;
  }

  if (payload.startsWith('habit:')) {
    if (action != kHabitCheckIn && action != kHabitSkip) return;
    final id = int.tryParse(payload.substring(6));
    if (id == null) return;
    final prefs = await SharedPreferences.getInstance();
    final queue = prefs.getStringList(_kHabitQueueKey) ?? <String>[];
    queue.add('${action == kHabitCheckIn ? 'checkin' : 'skip'}:$id');
    await prefs.setStringList(_kHabitQueueKey, queue);
    try {
      final plugin = FlutterLocalNotificationsPlugin();
      await plugin.initialize(const InitializationSettings(
        android: AndroidInitializationSettings('ic_stat_focus'),
        iOS: DarwinInitializationSettings(
            requestAlertPermission: false, requestBadgePermission: false, requestSoundPermission: false),
      ));
      await plugin.cancel(2100 + (id % 100));
    } catch (_) {/* best-effort */}
    return;
  }

  if (payload.startsWith('rem:') && action == kReminderSnooze) {
    try {
      final data = jsonDecode(payload.substring(4)) as Map<String, dynamic>;
      final id      = data['id'] as int;
      final label   = (data['label'] as String?) ?? '';
      final isAlarm = (data['isAlarm'] as bool?) ?? false;
      tz_data.initializeTimeZones();
      final plugin = FlutterLocalNotificationsPlugin();
      await plugin.initialize(const InitializationSettings(
        android: AndroidInitializationSettings('ic_stat_focus'),
        iOS: DarwinInitializationSettings(
            requestAlertPermission: false, requestBadgePermission: false, requestSoundPermission: false),
      ));
      final when = tz.TZDateTime.now(tz.local).add(const Duration(minutes: kReminderSnoozeMin));
      await plugin.zonedSchedule(
        _snoozeNotifIdOf(id),
        _reminderTitle(label, isAlarm),
        isAlarm ? 'Alarm (snoozed)' : 'Reminder (snoozed)',
        when,
        NotificationDetails(
          android: _reminderAndroidDetails(isAlarm),
          iOS: const DarwinNotificationDetails(
              presentAlert: true, presentBadge: true, presentSound: true),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload,
      );
    } catch (_) {/* best-effort */}
  }
}

// ── Notification ID allocation ────────────────────────────────────────────────
// 1000  tasks morning briefing
// 1050  tasks overdue digest
// 1100–1199  per-task due reminders  (1100 + taskId % 100)
// 2001  habits streak at risk 9pm
// 2100–2199  per-habit check-in 8am  (2100 + habitId % 100)
// 3000  goals weekly Friday check-in
// 3001  weekly review Sunday reminder
// 3100–3199  goal deadline 7-day  (3100 + goalId % 100)
// 3200–3299  goal deadline 1-day  (3200 + goalId % 100)
// 4000–4099  calendar 15-min      (4000 + eventId % 100)
// 5000  inbox daily digest 8:30am
// 6000  pomodoro complete (immediate show)

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _ready = false;
  bool get isReady => _ready;

  // ── Pending deep-link from notification tap ────────────────────────────────
  // flutter_local_notifications calls the tap handler outside widget tree;
  // store the payload and let the router consume it on next build.
  static String? _pendingRoute;
  static String? consumePendingRoute() {
    final r = _pendingRoute;
    _pendingRoute = null;
    return r;
  }

  // DTN notification button taps land here (foreground or app-launch) and are
  // consumed by the DtnController once the widget tree + DB are ready.
  static DtnPendingAction? _pendingDtnAction;
  static DtnPendingAction? consumePendingDtnAction() {
    final a = _pendingDtnAction;
    _pendingDtnAction = null;
    return a;
  }

  /// Drain DTN Done actions that were tapped while the app was backgrounded
  /// (queued by [notificationBackgroundResponse]). Returns `done:<id>`.
  static Future<List<String>> consumeDtnQueue(SharedPreferences prefs) async {
    final q = prefs.getStringList(_kDtnQueueKey) ?? const <String>[];
    if (q.isNotEmpty) await prefs.remove(_kDtnQueueKey);
    return q;
  }

  // Habit check-in/skip notification button taps (foreground or app-launch).
  static HabitPendingAction? _pendingHabitAction;
  static HabitPendingAction? consumePendingHabitAction() {
    final a = _pendingHabitAction;
    _pendingHabitAction = null;
    return a;
  }

  /// Drain habit check-in/skip actions tapped while backgrounded. Returns
  /// `checkin:<id>`/`skip:<id>`.
  static Future<List<String>> consumeHabitQueue(SharedPreferences prefs) async {
    final q = prefs.getStringList(_kHabitQueueKey) ?? const <String>[];
    if (q.isNotEmpty) await prefs.remove(_kHabitQueueKey);
    return q;
  }

  // Task-due "Mark done" notification button taps (foreground or app-launch).
  static int? _pendingTaskDoneId;
  static int? consumePendingTaskDone() {
    final id = _pendingTaskDoneId;
    _pendingTaskDoneId = null;
    return id;
  }

  /// Drain task-due "Mark done" taps that happened while backgrounded.
  static Future<List<String>> consumeTaskDueQueue(SharedPreferences prefs) async {
    final q = prefs.getStringList(_kTaskQueueKey) ?? const <String>[];
    if (q.isNotEmpty) await prefs.remove(_kTaskQueueKey);
    return q;
  }

  /// Set by the live app (DtnController) so a notification tap navigates/applies
  /// immediately while the app is alive (foreground OR resumed from background),
  /// instead of waiting on the resume lifecycle — which races with this callback
  /// and would otherwise drop the deep link, opening a "fresh" session.
  static VoidCallback? onTapHandled;

  static void _routeResponse(NotificationResponse r) {
    final payload = r.payload;
    final action  = r.actionId;
    if (payload != null && payload.startsWith('dtn:')) {
      // payload = "dtn:<jsonEncoded {id,title,quadrant,durationSec}>"
      Map<String, dynamic>? data;
      try {
        data = jsonDecode(payload.substring(4)) as Map<String, dynamic>;
      } catch (_) {/* malformed — treat as no payload below */}
      final id = data?['id'] as int?;
      if (id != null) {
        if (action == kDtnDone || action == kDtnStart || action == kDtnPause) {
          final durationSec = (data?['durationSec'] as int?) ?? 1500;
          _pendingDtnAction = DtnPendingAction(action!, id, durationSec);
        } else {
          // Body tap → open the task this card is about, not the dashboard.
          _pendingRoute = '/tasks/taskdetail/$id';
        }
      }
      onTapHandled?.call();
      return;
    }
    if (payload != null && payload.startsWith('taskdue:')) {
      final id = int.tryParse(payload.substring(8));
      if (id != null) {
        if (action == kTaskDone) {
          _pendingTaskDoneId = id;
        } else {
          // Body tap → open the task itself.
          _pendingRoute = '/tasks/taskdetail/$id';
        }
      }
      onTapHandled?.call();
      return;
    }
    if (payload != null && payload.startsWith('habit:')) {
      final id = int.tryParse(payload.substring(6));
      if (id != null) {
        if (action == kHabitCheckIn || action == kHabitSkip) {
          _pendingHabitAction = HabitPendingAction(action!, id);
        } else {
          // Body tap → open the habits list.
          _pendingRoute = TaskEraRoutes.habits;
        }
      }
      onTapHandled?.call();
      return;
    }
    if (payload != null && payload.startsWith('rem:')) {
      final data = jsonDecode(payload.substring(4)) as Map<String, dynamic>;
      if (action == kReminderSnooze) {
        instance._snoozeReminder(data['id'] as int,
            (data['label'] as String?) ?? '', (data['isAlarm'] as bool?) ?? false);
      } else if (action != kReminderDismiss) {
        _pendingRoute = TaskEraRoutes.cal; // body tap → open the calendar (reminders live there)
        onTapHandled?.call();
      }
      return;
    }
    _pendingRoute = payload;
    onTapHandled?.call();
  }

  // ── Init ──────────────────────────────────────────────────────────────────

  Future<void> init() async {
    // flutter_local_notifications v18 supports Android, iOS, macOS, Linux only.
    // Windows desktop is not supported — skip silently.
    if (kIsWeb || isDesktop) return;

    tz_data.initializeTimeZones();

    // White Focus-compass silhouette (notification small icons are monochrome).
    // NB: pass the bare resource name — the plugin does NOT resolve a
    // "@drawable/" prefix and would silently fall back to the launcher icon.
    const androidSettings = AndroidInitializationSettings('ic_stat_focus');
    final iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
      // Registers the action buttons for each notification "kind" on iOS —
      // without this, iOS notifications show no buttons at all (Android
      // actions need no such registration), and nothing would mirror to a
      // paired Apple Watch either, since Watch mirrors the phone's actual
      // notification content/actions as-is.
      notificationCategories: [
        DarwinNotificationCategory(_catDtnIdle, actions: [
          DarwinNotificationAction.plain(kDtnStart, '▶ Start'),
          DarwinNotificationAction.plain(kDtnDone, '✓ Done'),
        ]),
        DarwinNotificationCategory(_catDtnRunning, actions: [
          DarwinNotificationAction.plain(kDtnPause, '⏸ Pause'),
          DarwinNotificationAction.plain(kDtnDone, '✓ Done'),
        ]),
        DarwinNotificationCategory(_catReminder, actions: [
          DarwinNotificationAction.plain(kReminderSnooze, 'Snooze 10m'),
          DarwinNotificationAction.plain(kReminderDismiss, 'Dismiss',
              options: {DarwinNotificationActionOption.destructive}),
        ]),
        DarwinNotificationCategory(_catHabit, actions: [
          DarwinNotificationAction.plain(kHabitCheckIn, '✓ Check in'),
          DarwinNotificationAction.plain(kHabitSkip, '⏭ Skip'),
        ]),
        DarwinNotificationCategory(_catTaskDue, actions: [
          DarwinNotificationAction.plain(kTaskDone, '✓ Mark done'),
        ]),
      ],
    );

    await _plugin.initialize(
      InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
      onDidReceiveNotificationResponse: _routeResponse,
      // Action taps while backgrounded/terminated land here (separate isolate)
      // — DTN Done/habit/task-due actions queue to prefs for next resume; DTN
      // Start/Pause apply directly, so they work without opening the app.
      onDidReceiveBackgroundNotificationResponse: notificationBackgroundResponse,
    );

    if (!kIsWeb && Platform.isAndroid) {
      final android = _plugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      for (final ch in _androidChannels) {
        await android?.createNotificationChannel(ch);
      }
    }

    // Cold start from a tapped notification: onDidReceiveNotificationResponse
    // does NOT fire when the app was terminated, so read the launch payload here
    // and stash the route/action for the app to consume on first build.
    final launch = await _plugin.getNotificationAppLaunchDetails();
    if ((launch?.didNotificationLaunchApp ?? false) &&
        launch?.notificationResponse != null) {
      _routeResponse(launch!.notificationResponse!);
    }

    _ready = true;
  }

  static const _androidChannels = [
    AndroidNotificationChannel(_chTasks,    'Tasks',
        description: 'Task due dates and overdue alerts', importance: Importance.high),
    AndroidNotificationChannel(_chHabits,   'Habits',
        description: 'Daily habit reminders and streak alerts', importance: Importance.defaultImportance),
    AndroidNotificationChannel(_chGoals,    'Goals',
        description: 'Goal check-ins and deadline reminders', importance: Importance.defaultImportance),
    AndroidNotificationChannel(_chCalendar, 'Calendar',
        description: 'Event reminders', importance: Importance.high),
    AndroidNotificationChannel(_chInbox,    'Inbox',
        description: 'AI-classified inbox digest', importance: Importance.defaultImportance),
    AndroidNotificationChannel(_chFocus,    'Focus',
        description: 'Pomodoro and focus session alerts', importance: Importance.high),
    AndroidNotificationChannel(_chDtn,      'Do The Next',
        description: 'Ongoing card for your current top task',
        importance: Importance.low, playSound: false, enableVibration: false),
    AndroidNotificationChannel(_chReminders, 'Reminders',
        description: 'One-time reminders you set', importance: Importance.high),
    AndroidNotificationChannel(_chAlarms,    'Alarms',
        description: 'Full-screen alarms with an alarm sound',
        importance: Importance.max, playSound: true,
        audioAttributesUsage: AudioAttributesUsage.alarm),
  ];

  // ── Reminders & Alarms (standalone, user-set) ──────────────────────────────

  // Payload carries enough to reschedule a snooze from the background isolate.
  static String _reminderPayload(Reminder r) =>
      'rem:${jsonEncode({'id': r.id, 'label': r.label, 'isAlarm': r.isAlarm})}';

  Future<void> scheduleReminder(Reminder r) async {
    if (!_ready || r.isPast) return;
    final repeat = switch (r.repeat) {
      ReminderRepeat.none   => null,
      ReminderRepeat.daily  => DateTimeComponents.time,
      ReminderRepeat.weekly => DateTimeComponents.dayOfWeekAndTime,
    };
    await _plugin.zonedSchedule(
      _reminderNotifIdOf(r.id),
      _reminderTitle(r.label, r.isAlarm),
      r.isAlarm ? 'Alarm' : 'Reminder',
      tz.TZDateTime.from(r.when, tz.local),
      NotificationDetails(
        android: _reminderAndroidDetails(r.isAlarm),
        iOS: const DarwinNotificationDetails(
            presentAlert: true, presentBadge: true, presentSound: true),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: repeat,
      payload: _reminderPayload(r),
    );
  }

  // Re-fire this reminder 10 minutes from now under a separate id (so a repeating
  // reminder's schedule is left intact). Used by the foreground Snooze action.
  Future<void> _snoozeReminder(int id, String label, bool isAlarm) async {
    if (!_ready) return;
    final when = tz.TZDateTime.now(tz.local).add(const Duration(minutes: kReminderSnoozeMin));
    await _plugin.zonedSchedule(
      _snoozeNotifIdOf(id),
      _reminderTitle(label, isAlarm),
      isAlarm ? 'Alarm (snoozed)' : 'Reminder (snoozed)',
      when,
      NotificationDetails(
        android: _reminderAndroidDetails(isAlarm),
        iOS: const DarwinNotificationDetails(
            presentAlert: true, presentBadge: true, presentSound: true),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'rem:${jsonEncode({'id': id, 'label': label, 'isAlarm': isAlarm})}',
    );
  }

  Future<void> cancelReminder(int id) async {
    if (!_ready) return;
    await _plugin.cancel(_reminderNotifIdOf(id));
    await _plugin.cancel(_snoozeNotifIdOf(id));
  }

  /// Re-arm all future reminders/alarms from the saved list (called on launch).
  Future<void> rescheduleReminders(List<Reminder> reminders) async {
    if (!_ready) return;
    for (final r in reminders) {
      await _plugin.cancel(_reminderNotifIdOf(r.id));
      if (!r.isPast) await scheduleReminder(r);
    }
  }

  // ── DTN "Do The Next" — ongoing, music-player-style card ───────────────────

  /// Shared by the live [showDtnCard] call and the background isolate's
  /// Start/Pause re-show (notification_service.dart top-level handler), so
  /// both build the exact same actions/category for a given running state.
  static NotificationDetails _dtnDetails({
    required bool running,
    required bool lockScreen,
  }) =>
      NotificationDetails(
        android: AndroidNotificationDetails(
          _chDtn, 'Do The Next',
          icon: 'ic_stat_focus',
          importance: Importance.low,
          priority: Priority.low,
          ongoing: true,
          autoCancel: false,
          onlyAlertOnce: true,
          showWhen: false,
          category: AndroidNotificationCategory.recommendation,
          visibility: lockScreen
              ? NotificationVisibility.public
              : NotificationVisibility.secret,
          // Both run in the background isolate without opening the app, so
          // pausing/starting from a locked phone or a paired watch never pops
          // the app open — same expectation as a media player's controls.
          actions: [
            running
                ? const AndroidNotificationAction(kDtnPause, '⏸ Pause', showsUserInterface: false)
                : const AndroidNotificationAction(kDtnStart, '▶ Start', showsUserInterface: false),
            const AndroidNotificationAction(kDtnDone, '✓ Done', showsUserInterface: false),
          ],
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: false, presentBadge: false, presentSound: false,
          categoryIdentifier: running ? _catDtnRunning : _catDtnIdle,
        ),
      );

  /// Show/refresh the persistent DTN card for [taskId]. Appears on the lock
  /// screen (visibility public) with Start/Pause (whichever applies) + Done.
  Future<void> showDtnCard({
    required int taskId,
    required String title,
    required int quadrant,
    required int durationSec,
    bool running = false,
    bool lockScreen = true,
  }) async {
    if (!_ready) return;
    await _plugin.show(
      kDtnNotifId,
      running ? '⏱ Focusing  ·  Q$quadrant' : '▶ Do The Next  ·  Q$quadrant',
      title,
      _dtnDetails(running: running, lockScreen: lockScreen),
      payload:
          'dtn:${jsonEncode({'id': taskId, 'title': title, 'quadrant': quadrant, 'durationSec': durationSec})}',
    );
  }

  Future<void> cancelDtn() async {
    if (!_ready) return;
    await _plugin.cancel(kDtnNotifId);
  }

  Future<void> requestPermission() async {
    if (!_ready) return;
    if (!kIsWeb && Platform.isIOS) {
      await _plugin
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    }
    if (!kIsWeb && Platform.isAndroid) {
      final android = _plugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      await android?.requestNotificationsPermission();
      // Exact alarms use USE_EXACT_ALARM (API 33+) / SCHEDULE_EXACT_ALARM
      // (API 31-32) — both auto-granted, so no runtime exact-alarm prompt needed.
    }
  }

  // ── Detail builders ───────────────────────────────────────────────────────

  NotificationDetails _details(String channelId, {bool high = false}) =>
      NotificationDetails(
        android: AndroidNotificationDetails(
          channelId, channelId,
          importance: high ? Importance.high : Importance.defaultImportance,
          priority:   high ? Priority.high   : Priority.defaultPriority,
          icon: 'ic_stat_focus',
        ),
        iOS: const DarwinNotificationDetails(
            presentAlert: true, presentBadge: true, presentSound: true),
      );

  // ── Time helpers ──────────────────────────────────────────────────────────

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  /// Next occurrence of HH:mm in local timezone (tomorrow if already past today).
  tz.TZDateTime _nextDaily(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var t = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (!t.isAfter(now)) t = t.add(const Duration(days: 1));
    return t;
  }

  /// Next occurrence of HH:mm on a given weekday (1=Mon … 7=Sun).
  tz.TZDateTime _nextWeekday(int weekday, int hour, int minute) {
    var t = _nextDaily(hour, minute);
    while (t.weekday != weekday) {
      t = t.add(const Duration(days: 1));
    }
    return t;
  }

  // ── TASKS ─────────────────────────────────────────────────────────────────

  /// Daily 8:00 — "X tasks due today"
  Future<void> scheduleMorningBriefing(int dueCount) async {
    if (!_ready || dueCount == 0) return;
    await _zonedRepeat(
      1000,
      'Tasks due today',
      '$dueCount ${dueCount == 1 ? 'task needs' : 'tasks need'} your attention',
      _nextDaily(8, 0),
      DateTimeComponents.time,
      _chTasks, high: true,
      payload: TaskEraRoutes.tasks,
    );
  }

  /// 1 hour before task due date (one-shot per task). [withAction] attaches a
  /// "Mark done" button (off by default — opt-in via Settings ▸ Notifications
  /// ▸ Quick Actions); either way the body tap still opens the task.
  Future<void> scheduleTaskDueReminder(Task task, {bool withAction = false}) async {
    if (!_ready || task.dueDate == null) return;
    final remind = task.dueDate!.subtract(const Duration(hours: 1));
    if (!remind.isAfter(DateTime.now())) return;
    await _plugin.zonedSchedule(
      1100 + (task.id % 100),
      task.title, 'Due in 1 hour',
      tz.TZDateTime.from(remind, tz.local),
      NotificationDetails(
        android: AndroidNotificationDetails(
          _chTasks, 'Tasks',
          icon: 'ic_stat_focus',
          importance: Importance.high, priority: Priority.high,
          actions: withAction
              ? const [AndroidNotificationAction(kTaskDone, '✓ Mark done', showsUserInterface: false)]
              : const [],
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true, presentBadge: true, presentSound: true,
          categoryIdentifier: withAction ? _catTaskDue : null,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'taskdue:${task.id}',
    );
  }

  /// Daily 9:00 — overdue digest
  Future<void> scheduleOverdueDigest(int overdueCount) async {
    if (!_ready || overdueCount == 0) return;
    await _zonedRepeat(
      1050,
      '⚡ $overdueCount overdue ${overdueCount == 1 ? 'task' : 'tasks'}',
      'Tackle these first before new work piles up',
      _nextDaily(9, 0),
      DateTimeComponents.time,
      _chTasks, high: true,
      payload: '${TaskEraRoutes.focusList}?f=overdue',
    );
  }

  // ── HABITS ────────────────────────────────────────────────────────────────

  /// Daily 8:00 — one notification per not-yet-checked-in habit. [withActions]
  /// attaches Check-in/Skip buttons (off by default — opt-in via Settings ▸
  /// Notifications ▸ Quick Actions); either way the body tap opens Habits.
  /// Content is fixed at schedule time like every other daily notification
  /// here — if a habit gets checked in later today some other way, its 8am
  /// card (already scheduled) still fires; rescheduleAll re-running after any
  /// habit change is what keeps this reasonably fresh, same tradeoff the old
  /// combined-count reminder already had.
  Future<void> scheduleHabitCheckIns(List<Habit> uncheckedHabits, {bool withActions = false}) async {
    if (!_ready) return;
    for (final h in uncheckedHabits) {
      await _plugin.zonedSchedule(
        2100 + (h.id % 100),
        '🔥 ${h.name}',
        'Check in to keep your streak alive',
        _nextDaily(8, 0),
        NotificationDetails(
          android: AndroidNotificationDetails(
            _chHabits, 'Habits',
            icon: 'ic_stat_focus',
            importance: Importance.defaultImportance,
            actions: withActions
                ? const [
                    AndroidNotificationAction(kHabitCheckIn, '✓ Check in', showsUserInterface: false),
                    AndroidNotificationAction(kHabitSkip, '⏭ Skip', showsUserInterface: false),
                  ]
                : const [],
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true, presentBadge: true, presentSound: true,
            categoryIdentifier: withActions ? _catHabit : null,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: 'habit:${h.id}',
      );
    }
  }

  /// Daily 21:00 — streak at risk if habits still unlogged
  Future<void> scheduleStreakAtRisk(int unloggedCount) async {
    if (!_ready || unloggedCount == 0) return;
    await _zonedRepeat(
      2001,
      '⚠️ Streak at risk',
      '$unloggedCount ${unloggedCount == 1 ? 'habit' : 'habits'} still unlogged — 3 hours left',
      _nextDaily(21, 0),
      DateTimeComponents.time,
      _chHabits, high: true,
      payload: TaskEraRoutes.habits,
    );
  }

  // ── GOALS ─────────────────────────────────────────────────────────────────

  /// Every Friday 18:00 — weekly goal check-in
  Future<void> scheduleWeeklyGoalCheckIn() async {
    if (!_ready) return;
    await _zonedRepeat(
      3000,
      '🎯 Weekly goal check-in',
      'Review your progress and set priorities for next week',
      _nextWeekday(DateTime.friday, 18, 0),
      DateTimeComponents.dayOfWeekAndTime,
      _chGoals,
      payload: TaskEraRoutes.weeklyReview,
    );
  }

  /// 7 days before goal deadline
  Future<void> scheduleGoalDeadlineWarn7d(Goal goal) async {
    if (!_ready || goal.deadline == null) return;
    final t = goal.deadline!.subtract(const Duration(days: 7));
    if (!t.isAfter(DateTime.now())) return;
    await _zonedOnce(
      3100 + (goal.id % 100),
      '${goal.emoji} Goal deadline in 7 days', goal.title,
      tz.TZDateTime.from(t, tz.local),
      _chGoals,
      payload: '${TaskEraRoutes.goals}/${goal.id}',
    );
  }

  /// 1 day before goal deadline
  Future<void> scheduleGoalDeadlineWarn1d(Goal goal) async {
    if (!_ready || goal.deadline == null) return;
    final t = goal.deadline!.subtract(const Duration(days: 1));
    if (!t.isAfter(DateTime.now())) return;
    await _zonedOnce(
      3200 + (goal.id % 100),
      '${goal.emoji} Goal deadline tomorrow!', goal.title,
      tz.TZDateTime.from(t, tz.local),
      _chGoals, high: true,
      payload: '${TaskEraRoutes.goals}/${goal.id}',
    );
  }

  // ── CALENDAR ──────────────────────────────────────────────────────────────

  /// 15 minutes before each calendar event (the "pre" reminder)
  Future<void> scheduleCalendarReminder(CalendarEvent event) async {
    if (!_ready || event.eventDate == null) return;
    final t = event.eventDate!.subtract(const Duration(minutes: 15));
    if (!t.isAfter(DateTime.now())) return;
    await _zonedOnce(
      4000 + (event.id % 100),
      '📅 ${event.title}', 'Starting in 15 minutes',
      tz.TZDateTime.from(t, tz.local),
      _chCalendar, high: true,
      payload: TaskEraRoutes.cal,
    );
  }

  /// At the event's start time (the "actual" notification) — scheduled when an
  /// invite is accepted, alongside the 15-min pre-reminder.
  Future<void> scheduleEventStart(CalendarEvent event) async {
    if (!_ready || event.eventDate == null) return;
    final t = event.eventDate!;
    if (!t.isAfter(DateTime.now())) return;
    await _zonedOnce(
      4100 + (event.id % 100),
      '📅 ${event.title}', 'Starting now',
      tz.TZDateTime.from(t, tz.local),
      _chCalendar, high: true,
      payload: TaskEraRoutes.cal,
    );
  }

  // ── INBOX ─────────────────────────────────────────────────────────────────

  /// Daily 8:30 — AI-classified action items digest
  Future<void> scheduleInboxDigest(int actionCount) async {
    if (!_ready || actionCount == 0) return;
    await _zonedRepeat(
      5000,
      '✦ $actionCount inbox ${actionCount == 1 ? 'action' : 'actions'} to review',
      'TaskEra AI found items that need your decision',
      _nextDaily(8, 30),
      DateTimeComponents.time,
      _chInbox,
      payload: TaskEraRoutes.inbox,
    );
  }

  // ── FOCUS ─────────────────────────────────────────────────────────────────

  /// Immediate — called by PomodoroScreen when timer fires
  Future<void> showPomodoroComplete({required bool isBreak}) async {
    if (!_ready) return;
    await _plugin.show(
      6000,
      isBreak ? '▶ Break over — back to focus' : '🍅 Pomodoro complete!',
      isBreak
          ? 'Your break is done. Start the next session.'
          : 'Take a 5-minute break, then keep going.',
      _details(_chFocus, high: true),
      payload: TaskEraRoutes.pomodoro,
    );
  }

  /// Every Sunday 20:00 — weekly review reminder
  Future<void> scheduleWeeklyReviewReminder() async {
    if (!_ready) return;
    await _zonedRepeat(
      3001,
      '📋 Weekly review time',
      'Reflect on this week and plan the next',
      _nextWeekday(DateTime.sunday, 20, 0),
      DateTimeComponents.dayOfWeekAndTime,
      _chFocus,
      payload: TaskEraRoutes.weeklyReview,
    );
  }

  // ── Cancel helpers ────────────────────────────────────────────────────────

  Future<void> cancelTaskReminder(int taskId)  => _plugin.cancel(1100 + (taskId % 100));
  Future<void> cancelGoalReminders(int goalId) async {
    await _plugin.cancel(3100 + (goalId % 100));
    await _plugin.cancel(3200 + (goalId % 100));
  }
  Future<void> cancelEventReminder(int eventId) async {
    await _plugin.cancel(4000 + (eventId % 100)); // 15-min pre
    await _plugin.cancel(4100 + (eventId % 100)); // at-start
  }
  Future<void> cancelAll() => _plugin.cancelAll();

  // ── Bulk reschedule — call on app start and after settings changes ─────────

  Future<void> rescheduleAll({
    required List<Task>          tasks,
    required List<Habit>         habits,
    required List<Goal>          goals,
    required List<CalendarEvent> events,
    int inboxActionCount = 0,
    Map<String, bool> notifToggles = const {},
    // The task currently shown on the "Do The Next" card, if any. Its own due
    // reminder is skipped — DTN already gives it a Done action, and firing both
    // would mean two separate "mark done" prompts for the same task.
    int? dtnTaskId,
  }) async {
    if (!_ready) return;

    // Cancel stale alarms before rebuilding from current DB state.
    await _plugin.cancelAll();

    final now      = DateTime.now();
    final today    = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final withActions = notifToggles['notifQuickActions'] ?? false;

    // Tasks
    if (notifToggles['notifTasks'] ?? true) {
      final dueToday = tasks.where((t) =>
          !t.isDone && t.dueDate != null &&
          !t.dueDate!.isBefore(today) && t.dueDate!.isBefore(tomorrow)).length;
      final overdue = tasks.where((t) => !t.isDone && t.isOverdue).length;
      await scheduleMorningBriefing(dueToday);
      await scheduleOverdueDigest(overdue);
      for (final t in tasks.where((t) => !t.isDone && t.id != dtnTaskId)) {
        await scheduleTaskDueReminder(t, withAction: withActions);
      }
    }

    // Habits
    if (notifToggles['notifHabits'] ?? true) {
      final unchecked = habits.where((h) =>
          h.lastCheckedDate == null || !_isSameDay(h.lastCheckedDate!, now)).toList();
      await scheduleHabitCheckIns(unchecked, withActions: withActions);
      await scheduleStreakAtRisk(unchecked.length);
    }

    // Goals
    if (notifToggles['notifGoals'] ?? true) {
      await scheduleWeeklyGoalCheckIn();
      for (final g in goals) {
        await scheduleGoalDeadlineWarn7d(g);
        await scheduleGoalDeadlineWarn1d(g);
      }
    }

    // Calendar
    if (notifToggles['notifCalendar'] ?? true) {
      for (final e in events) {
        await scheduleCalendarReminder(e);
      }
    }

    // Inbox
    if (notifToggles['notifInbox'] ?? true) {
      await scheduleInboxDigest(inboxActionCount);
    }

    // Focus (weekly review Sunday reminder)
    if (notifToggles['notifFocus'] ?? true) {
      await scheduleWeeklyReviewReminder();
    }
  }

  // ── Internal schedule wrappers ────────────────────────────────────────────

  Future<void> _zonedOnce(
    int id, String title, String body, tz.TZDateTime when,
    String channelId, {
    bool high = false,
    String? payload,
  }) =>
      _plugin.zonedSchedule(
        id, title, body, when,
        _details(channelId, high: high),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload,
      );

  Future<void> _zonedRepeat(
    int id, String title, String body, tz.TZDateTime when,
    DateTimeComponents repeat,
    String channelId, {
    bool high = false,
    String? payload,
  }) =>
      _plugin.zonedSchedule(
        id, title, body, when,
        _details(channelId, high: high),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: repeat,
        payload: payload,
      );
}

final notificationServiceProvider =
    Provider<NotificationService>((_) => NotificationService.instance);
