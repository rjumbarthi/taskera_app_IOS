import 'dart:async' show unawaited;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'l10n/app_l10n.dart';
import 'l10n/app_strings.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:window_manager/window_manager.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'config/app_config.dart';
import 'data/database.dart';
import 'data/db_connection.dart' show deleteDatabaseFile;
import 'data/seed_data.dart';
import 'data/providers/database_provider.dart';
import 'routing/app_router.dart';
import 'routing/routes.dart';
import 'settings/app_launch_prefs.dart';
import 'settings/kaal_settings.dart';
import 'settings/prefs_provider.dart';
import 'theme/kaal_theme.dart';
import 'util/platform_layout.dart';
import 'data/providers/auth_provider.dart';
import 'services/sync_service.dart';
import 'services/notification_service.dart';
import 'services/dtn_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (isDesktop) {
    // window_manager channel is not re-registered after hot restart on Windows
    // (only the Dart VM is restarted, not the native window). Safe to ignore.
    try {
      await windowManager.ensureInitialized();
      await windowManager.setMinimumSize(const Size(400, 700));
      await windowManager.setTitle('Kaal - Focus & Task Planner');
    } catch (_) {
      // hot restart — window_manager channel not re-registered on Windows
    }
  }

  // edge-to-edge / overlay-style only apply on mobile — on Windows this call
  // extends content into the Win32 title bar, which sets viewPadding.top to the
  // full title-bar height and leaves the Scaffold body with ~40 px.
  if (!isDesktop) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
    ));
  }

  // Suppress MissingPluginException noise on hot restart:
  //  • app_links  — supabase_flutter EventChannel not re-registered after Dart restart
  //  • window_manager — same; can also escape the try-catch via a secondary future
  //    and reach dart_vm_initializer.cc as an "Unhandled Exception"
  final prevOnError = FlutterError.onError;
  FlutterError.onError = (details) {
    if (details.exception is MissingPluginException) {
      final msg = details.exception.toString();
      if (msg.contains('app_links') || msg.contains('window_manager')) return;
    }
    prevOnError?.call(details);
  };
  // Belt-and-suspenders: also suppress via PlatformDispatcher for async errors
  // that bypass FlutterError.onError entirely.
  WidgetsBinding.instance.platformDispatcher.onError = (error, stack) {
    if (error is MissingPluginException &&
        error.toString().contains('window_manager')) {
      return true;
    }
    return false;
  };

  // ── Supabase (auth + cloud DB + edge functions) ──────────────────────────
  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    anonKey: AppConfig.supabaseAnonKey,
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
    ),
  );

  final prefs = await SharedPreferences.getInstance();
  await AppLaunchPrefs.recordInstallDate(prefs);
  _applyTabUnlocks(prefs);
  final db = await _openDatabase();

  // Seed default lists once on first launch
  if (!(prefs.getBool('kaal.listsSeeded') ?? false)) {
    if (await db.listsDao.isEmpty()) {
      await db.listsDao.seedDefaults();
    }
    await prefs.setBool('kaal.listsSeeded', true);
  }

  // Seed demo tasks, habits, goals, notes, calendar on first launch.
  // Re-seed automatically when the user switches language OR when kSeedVersion
  // is bumped (e.g. new translations added to seed_data.dart).
  final currentLang    = prefs.getInt('kaal.lang') ?? 0;
  final storedVersion  = prefs.getInt('kaal.seedVersion') ?? 0;
  final alreadySeeded  = prefs.getBool('kaal.dataSeeded') ?? false;
  final seededLang     = prefs.getInt('kaal.seededLang') ?? 0;
  if (!alreadySeeded) {
    await seedDatabase(db, langIdx: currentLang);
    await prefs.setBool('kaal.dataSeeded', true);
    await prefs.setInt('kaal.seededLang', currentLang);
    await prefs.setInt('kaal.seedVersion', kSeedVersion);
  } else if (seededLang != currentLang || storedVersion != kSeedVersion) {
    await reseedDatabase(db, langIdx: currentLang);
    await prefs.setInt('kaal.seededLang', currentLang);
    await prefs.setInt('kaal.seedVersion', kSeedVersion);
  }

  // ── Notifications ────────────────────────────────────────────────────────
  await NotificationService.instance.init();
  await NotificationService.instance.requestPermission();
  // Reschedule all notifications from current DB state on each launch.
  // This keeps alarms alive after device reboots.
  unawaited(_rescheduleNotifications(db, prefs));

  final initialLocation = _computeInitialLocation(prefs);
  final router = buildAppRouter(initialLocation, prefs);

  runApp(ProviderScope(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      appDatabaseProvider.overrideWithValue(db),
    ],
    child: KaalApp(router: router),
  ));
}

// In debug builds: probe the DB before returning it. If the open or any basic
// query throws (e.g. due to a botched migration from a dev-iteration DB), wipe
// the file and return a fresh AppDatabase. Remove this wrapper before release.
Future<AppDatabase> _openDatabase() async {
  if (!kDebugMode) return AppDatabase();
  try {
    final db = AppDatabase();
    // Force the connection open and run one query — surfaces migration errors.
    await db.customSelect('PRAGMA user_version').get();
    return db;
  } catch (e) {
    debugPrint('[Kaal] DB open failed ($e) — wiping dev database and recreating');
    await deleteDatabaseFile();
    return AppDatabase();
  }
}

// Auto-unlock timed tabs based on days since install.
// Only sets a key if the user has never touched it (getBool == null).
// Thresholds: habits=7d, calendar=10d, notes=14d, inbox=14d.
void _applyTabUnlocks(SharedPreferences prefs) {
  final days = AppLaunchPrefs.daysSinceInstall(prefs);
  const thresholds = {'habits': 7, 'calendar': 10, 'notes': 14, 'inbox': 14};
  for (final entry in thresholds.entries) {
    final key = 'kaal.toggle.${entry.key}';
    if (prefs.getBool(key) == null && days >= entry.value) {
      prefs.setBool(key, true);
    }
  }
}

Future<void> _rescheduleNotifications(AppDatabase db, SharedPreferences prefs) async {
  try {
    final tasks  = await db.tasksDao.watchAll().first;
    final habits = await db.habitsDao.watchAll().first;
    final goals  = await db.goalsDao.watchAll().first;
    final events = await db.calendarDao.watchAll().first;
    final toggles = {
      'notifTasks':    prefs.getBool('kaal.toggle.notifTasks')    ?? true,
      'notifHabits':   prefs.getBool('kaal.toggle.notifHabits')   ?? true,
      'notifGoals':    prefs.getBool('kaal.toggle.notifGoals')    ?? true,
      'notifCalendar': prefs.getBool('kaal.toggle.notifCalendar') ?? true,
      'notifInbox':    prefs.getBool('kaal.toggle.notifInbox')    ?? true,
      'notifFocus':    prefs.getBool('kaal.toggle.notifFocus')    ?? true,
    };
    await NotificationService.instance.rescheduleAll(
      tasks: tasks, habits: habits, goals: goals, events: events,
      notifToggles: toggles,
    );
  } catch (_) {
    // Non-fatal — notifications degrade gracefully if DB read fails at launch.
  }
}

String _computeInitialLocation(SharedPreferences prefs) {
  // If the app was cold-started by tapping a notification, land directly on its
  // target screen (skip the splash) — but only once the user is past onboarding
  // and auth, so we never bypass those gates.
  final route = NotificationService.consumePendingRoute();
  if (route != null &&
      AppLaunchPrefs.onboardingDone(prefs) &&
      (AppLaunchPrefs.skipAuth(prefs) ||
          Supabase.instance.client.auth.currentUser != null)) {
    return route;
  }
  // Otherwise start at the quote splash — it routes forward based on auth state.
  return KaalRoutes.quote;
}

// Matches AppStrings index order (0-18)
const _kLocales = [
  Locale('en'), Locale('ja'), Locale('de'), Locale('ko'),
  Locale('fr'), Locale('zh'), Locale('es'), Locale('pt'),
  Locale('it'), Locale('nl'), Locale('ar'),
  // Indian group (11-18)
  Locale('hi'), Locale('te'), Locale('ta'), Locale('kn'),
  Locale('ml'), Locale('mr'), Locale('gu'), Locale('bn'),
];

// Ordered to match settings screen accent picker
const _kAccents = [
  (Color(0xFF0A84FF), Color(0xFF409CFF), Color(0x1F0A84FF)), // blue
  (Color(0xFF7FBA00), Color(0xFF9FCD44), Color(0x1F7FBA00)), // green
  (Color(0xFFFF6B00), Color(0xFFFF8C42), Color(0x1FFF6B00)), // orange
  (Color(0xFFBF5AF2), Color(0xFFCF7BFF), Color(0x1FBF5AF2)), // purple
  (Color(0xFFFF2D55), Color(0xFFFF6578), Color(0x1FFF2D55)), // red
  (Color(0xFF00BCD4), Color(0xFF4DD0E1), Color(0x1F00BCD4)), // cyan
];

const _kFontFamilies  = ['Inter', 'Fraunces', 'Inter', 'Inter'];
const _kFontSizeScales = [0.85, 1.0, 1.15, 1.3];

class KaalApp extends ConsumerWidget {
  final GoRouter router;
  const KaalApp({super.key, required this.router});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AsyncValue<AuthState>>(authStateProvider, (_, next) {
      next.whenData((state) {
        if (state.event == AuthChangeEvent.signedIn) {
          ref.read(syncServiceProvider).syncAll();
        }
        if (state.event == AuthChangeEvent.signedOut) {
          router.go(KaalRoutes.signin);
        }
      });
    });

    // Re-seed all content in the new language whenever the user switches language.
    // Stream-based providers (tasks, habits, etc.) update automatically after reseed.
    ref.listen<int>(
      kaalSettingsProvider.select((s) => s.lang),
      (prev, next) {
        if (prev != null && prev != next) {
          final db    = ref.read(appDatabaseProvider);
          final prefs = ref.read(sharedPreferencesProvider);
          reseedDatabase(db, langIdx: next).then(
            (_) => prefs.setInt('kaal.seededLang', next),
          );
        }
      },
    );

    final s = ref.watch(kaalSettingsProvider);

    final themeMode = switch (s.theme) {
      0 => KaalThemeMode.dark,
      1 => KaalThemeMode.light,
      _ => KaalThemeMode.glass, // 2=Glass, 3=System (treat as glass)
    };
    final ac  = _kAccents[s.accent.clamp(0, _kAccents.length - 1)];
    final fam = _kFontFamilies[s.font.clamp(0, _kFontFamilies.length - 1)];
    final scale = _kFontSizeScales[s.fontSize.clamp(0, _kFontSizeScales.length - 1)];

    final themeData = KaalThemeData.fromMode(
      themeMode,
      accent: ac.$1, accent2: ac.$2, accentBg: ac.$3,
      fontFamily: fam,
      fontSizeScale: scale,
    );

    return KaalTheme(
      data: themeData,
      child: MaterialApp.router(
        title: 'Kaal - Focus & Task Planner',
        debugShowCheckedModeBanner: false,
        locale: _kLocales[s.lang.clamp(0, _kLocales.length - 1)],
        supportedLocales: _kLocales,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        scrollBehavior: const _KaalScrollBehavior(),
        routerConfig: router,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: const ColorScheme.dark(),
          scaffoldBackgroundColor: Colors.transparent,
          splashFactory: NoSplash.splashFactory,
          highlightColor: Colors.transparent,
        ),
        builder: (context, child) => AppL10n(
          strings: AppStrings(s.lang),
          child: Directionality(
            textDirection: s.lang == 10 ? TextDirection.rtl : TextDirection.ltr,
            child: MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.linear(scale),
              ),
              child: DtnController(router: router, child: child!),
            ),
          ),
        ),
      ),
    );
  }
}

// Removes overscroll glow and scrollbar indicators app-wide.
class _KaalScrollBehavior extends ScrollBehavior {
  const _KaalScrollBehavior();

  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) =>
      child;

  @override
  Widget buildScrollbar(
      BuildContext context, Widget child, ScrollableDetails details) =>
      child;
}
