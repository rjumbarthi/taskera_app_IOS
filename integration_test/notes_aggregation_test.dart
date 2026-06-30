// Proves the Notes tab aggregates notes that live on tasks, habits and goals.
// Seeds a note onto the first task/habit/goal, renders the Notes screen, and
// asserts the "From your tasks, habits & goals" section appears.
//
//   flutter test integration_test/notes_aggregation_test.dart -d windows \
//     --dart-define=SHOT_DIR=C:/Users/imrj0/Projects/kaal_app/screenshots
import 'dart:io';
import 'dart:ui' as ui;

import 'package:drift/drift.dart' show Value;
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
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Notes tab shows notes from tasks/habits/goals', (tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    const shotDirPath =
        String.fromEnvironment('SHOT_DIR', defaultValue: 'screenshots');
    final shotDir = Directory(shotDirPath)..createSync(recursive: true);

    SharedPreferences.setMockInitialValues({
      'kaal.onboardingDone': true,
      'kaal.skipAuth': true,
      'kaal.dataSeeded': true,
      'kaal.realData': true,
      'kaal.listsSeeded': true,
    });
    final prefs = await SharedPreferences.getInstance();
    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      anonKey: AppConfig.supabaseAnonKey,
      authOptions:
          const FlutterAuthClientOptions(authFlowType: AuthFlowType.pkce),
    );
    final db = AppDatabase();
    if (await db.listsDao.isEmpty()) await db.listsDao.seedDefaults();
    if ((await db.tasksDao.watchAll().first).isEmpty) {
      await seedDatabase(db, langIdx: 0);
    }

    // Write a note onto the first task, habit and goal.
    final task  = (await db.tasksDao.watchAll().first).first;
    final habit = (await db.habitsDao.watchAll().first).first;
    final goal  = (await db.goalsDao.watchAll().first).first;
    await (db.update(db.tasks)..where((t) => t.id.equals(task.id)))
        .write(const TasksCompanion(notes: Value('Ship the v1 build to TestFlight before Friday.')));
    await (db.update(db.habits)..where((h) => h.id.equals(habit.id)))
        .write(const HabitsCompanion(notes: Value('Stretch first — protect the knee.')));
    await (db.update(db.goals)..where((g) => g.id.equals(goal.id)))
        .write(const GoalsCompanion(notes: Value('Break this into 3 measurable milestones.')));

    final rootKey = GlobalKey();
    final router = buildAppRouter(KaalRoutes.notes, prefs);
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
    await tester.pumpAndSettle(const Duration(milliseconds: 100),
        EnginePhase.sendSemanticsUpdate, const Duration(seconds: 6));

    final boundary =
        rootKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    final img = await boundary.toImage(pixelRatio: 3.0);
    final data = await img.toByteData(format: ui.ImageByteFormat.png);
    img.dispose();
    await File('${shotDir.path}/ZZ_notes_aggregated.png')
        .writeAsBytes(data!.buffer.asUint8List());

    expect(find.textContaining('FROM YOUR TASKS'), findsOneWidget,
        reason: 'The aggregated section header should be visible.');
    expect(find.text('📋 Task'), findsWidgets);
    expect(find.text('🔁 Habit'), findsWidgets);
    expect(find.text('🎯 Goal'), findsWidgets);
  });
}
