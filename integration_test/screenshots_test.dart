// Screenshot harness — drives the real app router to every KaalRoutes screen
// and writes a PNG per screen. Runs on the Windows embedder so glass/blur,
// wallpapers and variable fonts render for real.
//
//   flutter test integration_test/screenshots_test.dart -d windows \
//     --dart-define=SHOT_DIR=C:/Users/imrj0/Projects/kaal_app/screenshots
//
// Output: one <nn>_<name>.png per screen in SHOT_DIR (defaults to ./screenshots).
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:kaal_app/config/app_config.dart';
import 'package:kaal_app/data/database.dart';
import 'package:kaal_app/data/seed_data.dart';
import 'package:kaal_app/data/providers/database_provider.dart';
import 'package:kaal_app/settings/prefs_provider.dart';
import 'package:kaal_app/routing/app_router.dart';
import 'package:kaal_app/routing/routes.dart';
import 'package:kaal_app/main.dart' show KaalApp;

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  testWidgets('capture every screen', (tester) async {
    // ── Fixed mobile-proportioned surface: 390x844 @3x ──────────────────────
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    // ── Output dir ──────────────────────────────────────────────────────────
    const shotDirPath =
        String.fromEnvironment('SHOT_DIR', defaultValue: 'screenshots');
    final shotDir = Directory(shotDirPath);
    if (!shotDir.existsSync()) shotDir.createSync(recursive: true);
    debugPrint('[shots] writing PNGs to ${shotDir.absolute.path}');

    // ── Boot prefs: past onboarding + local-storage (skip auth) ─────────────
    SharedPreferences.setMockInitialValues({
      'kaal.onboardingDone': true,
      'kaal.skipAuth': true,
      'kaal.dataSeeded': true,
      'kaal.realData': true,
      'kaal.listsSeeded': true,
      // unlock all gated tabs so every screen is reachable
      'kaal.toggle.habits': true,
      'kaal.toggle.calendar': true,
      'kaal.toggle.notes': true,
      'kaal.toggle.inbox': true,
    });
    final prefs = await SharedPreferences.getInstance();

    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      anonKey: AppConfig.supabaseAnonKey,
      authOptions:
          const FlutterAuthClientOptions(authFlowType: AuthFlowType.pkce),
    );

    // ── DB: reuse the real on-disk DB; ensure it has content to screenshot ──
    final db = AppDatabase();
    if (await db.listsDao.isEmpty()) await db.listsDao.seedDefaults();
    final existing = await db.tasksDao.watchAll().first;
    if (existing.isEmpty) await seedDatabase(db, langIdx: 0);

    String firstId(List<dynamic> rows) =>
        rows.isEmpty ? '1' : (rows.first.id as int).toString();
    final taskId  = firstId(await db.tasksDao.watchAll().first);
    final habitId = firstId(await db.habitsDao.watchAll().first);
    final goalId  = firstId(await db.goalsDao.watchAll().first);
    final noteId  = firstId(await db.notesDao.watchAll().first);
    final eventId = firstId(await db.calendarDao.watchAll().first);

    // ── Mount the real app under a capture boundary ─────────────────────────
    final rootKey = GlobalKey();
    final router = buildAppRouter(KaalRoutes.focus, prefs);
    await tester.pumpWidget(
      RepaintBoundary(
        key: rootKey,
        child: ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            appDatabaseProvider.overrideWithValue(db),
          ],
          child: KaalApp(router: router),
        ),
      ),
    );
    await _settle(tester);

    Future<void> capture(String name) async {
      final boundary =
          rootKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();
      final f = File('${shotDir.path}/$name.png');
      await f.writeAsBytes(data!.buffer.asUint8List());
    }

    // ── The route table ─────────────────────────────────────────────────────
    final shots = <(String, String)>[
      // onboarding / public
      ('00_quote', KaalRoutes.quote),
      ('01_signin', KaalRoutes.signin),
      ('02_signup', KaalRoutes.signup),
      ('03_onboard', KaalRoutes.onboard),
      ('04_agegate', KaalRoutes.agegate),
      // tab roots
      ('10_focus', KaalRoutes.focus),
      ('20_tasks', KaalRoutes.tasks),
      ('30_habits', KaalRoutes.habits),
      ('40_calendar', KaalRoutes.cal),
      ('50_inbox', KaalRoutes.inbox),
      ('60_notes', KaalRoutes.notes),
      ('70_search', KaalRoutes.search),
      ('80_settings', KaalRoutes.settings),
      ('90_profile', KaalRoutes.profile),
      // focus subs
      ('11_focus_goals', KaalRoutes.goals),
      ('12_focus_goal_detail', '/focus/goals/$goalId'),
      ('13_focus_editgoal', '/focus/editgoal'),
      ('14_focus_editgoal_id', '/focus/editgoal/$goalId'),
      ('15_focus_pomodoro', KaalRoutes.pomodoro),
      ('16_focus_braindump', KaalRoutes.brainDump),
      ('17_focus_predictive', KaalRoutes.predictive),
      ('18_focus_reflect', KaalRoutes.eodReflect),
      ('19_focus_weeklyfocus', KaalRoutes.weeklyFocus),
      ('1a_focus_taskdetail', '/focus/taskdetail/$taskId'),
      ('1b_focus_list_today', KaalRoutes.focusList),
      ('1c_focus_list_active', '${KaalRoutes.focusList}?f=active'),
      ('1d_focus_list_done', '${KaalRoutes.focusList}?f=done'),
      ('1e_focus_list_overdue', '${KaalRoutes.focusList}?f=overdue'),
      // tasks subs
      ('21_tasks_taskdetail', '/tasks/taskdetail/$taskId'),
      ('22_tasks_edittask', '/tasks/edittask'),
      ('23_tasks_edittask_id', '/tasks/edittask/$taskId'),
      ('24_tasks_quickadd', KaalRoutes.tasksQuickAdd),
      ('25_tasks_capture', '/tasks/capture'),
      ('26_tasks_inbox', KaalRoutes.tasksInbox),
      ('27_tasks_board', KaalRoutes.tasksBoard),
      ('28_tasks_upcoming', KaalRoutes.tasksUpcoming),
      ('29_tasks_labels', KaalRoutes.tasksLabels),
      ('2a_tasks_filters', KaalRoutes.tasksFilters),
      ('2b_tasks_schedule', KaalRoutes.tasksSchedule),
      ('2c_tasks_recurring', KaalRoutes.tasksRecurring),
      ('2d_tasks_analytics', KaalRoutes.tasksAnalytics),
      ('2e_tasks_timetrack', KaalRoutes.tasksTimetrack),
      ('2f_tasks_pomodoro', KaalRoutes.tasksPomodoro),
      ('2g_tasks_quad_q1', '/tasks/quad/q1'),
      ('2h_tasks_quad_q2', '/tasks/quad/q2'),
      ('2i_tasks_quad_q3', '/tasks/quad/q3'),
      ('2j_tasks_quad_q4', '/tasks/quad/q4'),
      ('2k_tasks_panelcomp', KaalRoutes.tasksPanelComp),
      ('2l_tasks_lists', KaalRoutes.tasksLists),
      ('2m_tasks_logs', '/tasks/logs'),
      // habits subs
      ('31_habits_addhabit', KaalRoutes.habitsAddHabit),
      ('32_habits_addhabit_id', '/habits/addhabit/$habitId'),
      ('33_habits_detail', '/habits/habitdetail/$habitId'),
      ('34_habits_stats', KaalRoutes.habitsStats),
      ('35_habits_achievements', KaalRoutes.habitsAchievements),
      ('36_habits_addslot', KaalRoutes.habitsAddSlot),
      // calendar subs
      ('41_cal_conflicts', KaalRoutes.calConflicts),
      ('42_cal_addslot', KaalRoutes.calAddSlot),
      ('43_cal_addslot_id', '/cal/addslot/$eventId'),
      ('44_cal_calsync', KaalRoutes.calSync),
      ('45_cal_gmailsync', KaalRoutes.calGmail),
      // inbox subs
      ('51_inbox_integrations', '/inbox/integrations'),
      // notes subs
      ('61_notes_editor', KaalRoutes.notesEditor),
      ('62_notes_editor_id', '/notes/noteeditor/$noteId'),
      // settings subs
      ('81_settings_activitylogs', KaalRoutes.activityLogs),
      ('82_settings_studentmode', KaalRoutes.studentMode),
      ('83_settings_notifcenter', KaalRoutes.notifCenter),
      ('84_settings_widget', KaalRoutes.widget),
      // profile subs
      ('91_profile_edit', KaalRoutes.profileEdit),
      ('92_profile_referral', KaalRoutes.referral),
      ('93_profile_weeklyreview', KaalRoutes.weeklyReview),
      // root modals
      ('a0_paywall', KaalRoutes.paywall),
      ('a1_legal_terms', KaalRoutes.legal),
      ('a2_legal_privacy', '${KaalRoutes.legal}?tab=privacy'),
      ('a3_report', KaalRoutes.report),
    ];

    var ok = 0;
    final failed = <String>[];
    for (final (name, location) in shots) {
      try {
        router.go(location);
        await _settle(tester);
        await capture(name);
        ok++;
        debugPrint('[shots] ✓ $name  ($location)');
      } catch (e) {
        failed.add('$name <- $e');
        debugPrint('[shots] ✗ $name  ($location): $e');
      }
    }

    debugPrint('[shots] DONE: $ok/${shots.length} captured -> '
        '${shotDir.absolute.path}');
    if (failed.isNotEmpty) {
      debugPrint('[shots] FAILED (${failed.length}):\n  ${failed.join('\n  ')}');
    }
  });
}

// Settle the tree; fall back to fixed pumps for screens with perpetual
// animation (timers, spinners, auto-advancing splash) that never quiesce.
Future<void> _settle(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 350)); // let streams emit
  try {
    await tester.pumpAndSettle(
      const Duration(milliseconds: 80),
      EnginePhase.sendSemanticsUpdate,
      const Duration(seconds: 5),
    );
  } catch (_) {
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 120));
    }
  }
}
