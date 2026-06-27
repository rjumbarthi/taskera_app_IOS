import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

import '../data/database.dart';
import '../data/reminder.dart';
import '../routing/routes.dart';
import '../util/platform_layout.dart';

// ── Android channel IDs ───────────────────────────────────────────────────────
const _chTasks    = 'kaal_tasks';
const _chHabits   = 'kaal_habits';
const _chGoals    = 'kaal_goals';
const _chCalendar = 'kaal_calendar';
const _chInbox    = 'kaal_inbox';
const _chFocus    = 'kaal_focus';
const _chDtn      = 'kaal_dtn';
const _chReminders = 'kaal_reminders';
const _chAlarms    = 'kaal_alarms';

// ── DTN notification action ids ───────────────────────────────────────────────
const kDtnDone  = 'dtn_done';
const kDtnSkip  = 'dtn_skip';
const kDtnFocus = 'dtn_focus';
const kDtnNotifId = 7000;

// ── Reminder/Alarm notification action ids ────────────────────────────────────
const kReminderSnooze   = 'rem_snooze';
const kReminderDismiss  = 'rem_dismiss';
const kReminderSnoozeMin = 10;

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
      fullScreenIntent: isAlarm,
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
/// providers are ready. action is one of kDtnDone/kDtnSkip/kDtnFocus.
class DtnPendingAction {
  final String action;
  final int taskId;
  const DtnPendingAction(this.action, this.taskId);
}

/// SharedPreferences key holding DTN actions tapped while the app was in the
/// background — entries are `done:<id>` / `skip:<id>`. Drained on next resume.
const _kDtnQueueKey = 'kaal.dtn.pending';

/// Background-isolate entry point for action buttons tapped while the app is
/// backgrounded or terminated (all `showsUserInterface: false`). It runs in a
/// separate isolate with no access to the app's providers/DB.
///  • DTN Done/Skip → queued to SharedPreferences; applied on next resume.
///  • Reminder/Alarm Snooze → re-armed +10 min directly from this isolate, so it
///    works even when the app is fully killed (never needs to open the app).
@pragma('vm:entry-point')
Future<void> notificationBackgroundResponse(NotificationResponse r) async {
  final payload = r.payload;
  final action  = r.actionId;
  if (payload == null) return;

  if (payload.startsWith('dtn:')) {
    if (action != kDtnDone && action != kDtnSkip) return;
    final id = int.tryParse(payload.substring(4));
    if (id == null) return;
    final prefs = await SharedPreferences.getInstance();
    final queue = prefs.getStringList(_kDtnQueueKey) ?? <String>[];
    queue.add('${action == kDtnDone ? 'done' : 'skip'}:$id');
    await prefs.setStringList(_kDtnQueueKey, queue);
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
// 2000  habits daily 8am
// 2001  habits streak at risk 9pm
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

  /// Drain DTN Done/Skip actions that were tapped while the app was backgrounded
  /// (queued by [notificationBackgroundResponse]). Returns `done:<id>`/`skip:<id>`.
  static Future<List<String>> consumeDtnQueue(SharedPreferences prefs) async {
    final q = prefs.getStringList(_kDtnQueueKey) ?? const <String>[];
    if (q.isNotEmpty) await prefs.remove(_kDtnQueueKey);
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
      // payload = "dtn:<taskId>"
      final id = int.tryParse(payload.substring(4));
      if (id != null) {
        if (action == kDtnDone || action == kDtnSkip || action == kDtnFocus) {
          _pendingDtnAction = DtnPendingAction(action!, id);
        } else {
          // Body tap → open the task this card is about, not the dashboard.
          _pendingRoute = '/tasks/taskdetail/$id';
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
        _pendingRoute = KaalRoutes.cal; // body tap → open the calendar (reminders live there)
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
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _plugin.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
      onDidReceiveNotificationResponse: _routeResponse,
      // DTN Done/Skip tapped while backgrounded/terminated land here (separate
      // isolate) and are queued to prefs, so they apply without opening the app.
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

  /// Show/refresh the persistent DTN card for [task]. Appears on the lock
  /// screen (visibility public) with Done / Skip / Focus actions.
  Future<void> showDtnCard({
    required int taskId,
    required String title,
    required int quadrant,
    bool lockScreen = true,
  }) async {
    if (!_ready) return;
    await _plugin.show(
      kDtnNotifId,
      '▶ Do The Next  ·  Q$quadrant',
      title,
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
          actions: const [
            // Done/Skip apply in the background without opening the app; the card
            // is dismissed and the next task is shown when the app next runs.
            AndroidNotificationAction(kDtnDone, '✓ Done', showsUserInterface: false),
            AndroidNotificationAction(kDtnSkip, '⏭ Skip', showsUserInterface: false),
            // Focus needs the UI — it opens the task to start a focus session.
            AndroidNotificationAction(kDtnFocus, '▶ Focus', showsUserInterface: true),
          ],
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: false, presentBadge: false, presentSound: false),
      ),
      payload: 'dtn:$taskId',
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
      payload: KaalRoutes.tasks,
    );
  }

  /// 1 hour before task due date (one-shot per task)
  Future<void> scheduleTaskDueReminder(Task task) async {
    if (!_ready || task.dueDate == null) return;
    final remind = task.dueDate!.subtract(const Duration(hours: 1));
    if (!remind.isAfter(DateTime.now())) return;
    await _zonedOnce(
      1100 + (task.id % 100),
      task.title, 'Due in 1 hour',
      tz.TZDateTime.from(remind, tz.local),
      _chTasks, high: true,
      payload: '/tasks/taskdetail/${task.id}',
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
      payload: '${KaalRoutes.focusList}?f=overdue',
    );
  }

  // ── HABITS ────────────────────────────────────────────────────────────────

  /// Daily 8:00 — habit check-in nudge
  Future<void> scheduleHabitMorningReminder(int count) async {
    if (!_ready || count == 0) return;
    await _zonedRepeat(
      2000,
      '🔥 Track your habits',
      '$count ${count == 1 ? 'habit' : 'habits'} to log today — keep your streak alive',
      _nextDaily(8, 0),
      DateTimeComponents.time,
      _chHabits,
      payload: KaalRoutes.habits,
    );
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
      payload: KaalRoutes.habits,
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
      payload: KaalRoutes.weeklyReview,
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
      payload: '${KaalRoutes.goals}/${goal.id}',
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
      payload: '${KaalRoutes.goals}/${goal.id}',
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
      payload: KaalRoutes.cal,
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
      payload: KaalRoutes.cal,
    );
  }

  // ── INBOX ─────────────────────────────────────────────────────────────────

  /// Daily 8:30 — AI-classified action items digest
  Future<void> scheduleInboxDigest(int actionCount) async {
    if (!_ready || actionCount == 0) return;
    await _zonedRepeat(
      5000,
      '✦ $actionCount inbox ${actionCount == 1 ? 'action' : 'actions'} to review',
      'Kaal AI found items that need your decision',
      _nextDaily(8, 30),
      DateTimeComponents.time,
      _chInbox,
      payload: KaalRoutes.inbox,
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
      payload: KaalRoutes.pomodoro,
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
      payload: KaalRoutes.weeklyReview,
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
  }) async {
    if (!_ready) return;

    // Cancel stale alarms before rebuilding from current DB state.
    await _plugin.cancelAll();

    final now      = DateTime.now();
    final today    = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    // Tasks
    if (notifToggles['notifTasks'] ?? true) {
      final dueToday = tasks.where((t) =>
          !t.isDone && t.dueDate != null &&
          !t.dueDate!.isBefore(today) && t.dueDate!.isBefore(tomorrow)).length;
      final overdue = tasks.where((t) => !t.isDone && t.isOverdue).length;
      await scheduleMorningBriefing(dueToday);
      await scheduleOverdueDigest(overdue);
      for (final t in tasks.where((t) => !t.isDone)) {
        await scheduleTaskDueReminder(t);
      }
    }

    // Habits
    if (notifToggles['notifHabits'] ?? true) {
      await scheduleHabitMorningReminder(habits.length);
      await scheduleStreakAtRisk(habits.length);
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
