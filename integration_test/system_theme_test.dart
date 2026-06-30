// Proves theme=3 ("System") follows the OS brightness: glass when the OS is
// dark, light when the OS is light — and live-switches when the OS flips.
// If System were still dead (always glass), the two captured frames would be
// byte-identical; the test asserts they differ.
//
//   flutter test integration_test/system_theme_test.dart -d windows \
//     --dart-define=SHOT_DIR=C:/Users/imrj0/Projects/kaal_app/screenshots
import 'dart:io';
import 'dart:typed_data';
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
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('System theme follows OS brightness', (tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(
        () => tester.platformDispatcher.clearPlatformBrightnessTestValue());

    const shotDirPath =
        String.fromEnvironment('SHOT_DIR', defaultValue: 'screenshots');
    final shotDir = Directory(shotDirPath)..createSync(recursive: true);

    SharedPreferences.setMockInitialValues({
      'kaal.onboardingDone': true,
      'kaal.skipAuth': true,
      'kaal.dataSeeded': true,
      'kaal.realData': true,
      'kaal.listsSeeded': true,
      'kaal.theme': 3, // ← System
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

    final rootKey = GlobalKey();
    final router = buildAppRouter(KaalRoutes.settings, prefs);

    Future<Uint8List> capture(String name) async {
      final b =
          rootKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final img = await b.toImage(pixelRatio: 3.0);
      final data = await img.toByteData(format: ui.ImageByteFormat.png);
      img.dispose();
      final bytes = data!.buffer.asUint8List();
      await File('${shotDir.path}/$name.png').writeAsBytes(bytes);
      return bytes;
    }

    Future<void> settle() => tester.pumpAndSettle(
        const Duration(milliseconds: 100),
        EnginePhase.sendSemanticsUpdate,
        const Duration(seconds: 6));

    // OS dark → expect the glass (dark) theme.
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
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
    await settle();
    final darkBytes = await capture('ZZ_system_os-dark');

    // Flip OS to light — the observer should rebuild into the light theme.
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.light;
    await settle();
    final lightBytes = await capture('ZZ_system_os-light');

    final identical = darkBytes.length == lightBytes.length &&
        _bytesEqual(darkBytes, lightBytes);
    debugPrint('[systheme] os-dark=${darkBytes.length}B '
        'os-light=${lightBytes.length}B identical=$identical');
    // If System were dead, both renders would be the same glass frame.
    expect(identical, isFalse,
        reason: 'System theme produced identical frames for OS dark vs light '
            '— it is not following the OS.');
  });
}

bool _bytesEqual(Uint8List a, Uint8List b) {
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
