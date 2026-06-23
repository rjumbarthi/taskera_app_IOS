import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

import '../data/database.dart';
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

// ── DTN notification action ids ───────────────────────────────────────────────
const kDtnDone  = 'dtn_done';
const kDtnSkip  = 'dtn_skip';
const kDtnFocus = 'dtn_focus';
const kDtnNotifId = 7000;

/// A pending action from a DTN notification button, consumed by the app once
/// providers are ready. action is one of kDtnDone/kDtnSkip/kDtnFocus.
class DtnPendingAction {
  final String action;
  final int taskId;
  const DtnPendingAction(this.action, this.taskId);
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
          // Body tap → open the focus dashboard.
          _pendingRoute = KaalRoutes.focus;
        }
      }
      return;
    }
    _pendingRoute = payload;
  }

  // ── Init ──────────────────────────────────────────────────────────────────

  Future<void> init() async {
    // flutter_local_notifications v18 supports Android, iOS, macOS, Linux only.
    // Windows desktop is not supported — skip silently.
    if (kIsWeb || isDesktop) return;

    tz_data.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
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
  ];

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
            AndroidNotificationAction(kDtnDone,  '✓ Done',  showsUserInterface: true),
            AndroidNotificationAction(kDtnSkip,  '⏭ Skip',  showsUserInterface: true),
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
      payload: KaalRoutes.tasks,
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
      payload: KaalRoutes.goals,
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
      payload: KaalRoutes.goals,
    );
  }

  // ── CALENDAR ──────────────────────────────────────────────────────────────

  /// 15 minutes before each calendar event
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
  Future<void> cancelEventReminder(int eventId) => _plugin.cancel(4000 + (eventId % 100));
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
