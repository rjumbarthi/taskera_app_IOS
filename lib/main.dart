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
import 'data/reminder.dart';
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
import 'services/google_service.dart';
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

  // Inject starter tasks, habits, goals, notes, calendar ONCE as permanent real
  // data. It is never auto-reseeded afterwards — switching language only changes
  // the UI, not your data.
  final currentLang   = prefs.getInt('kaal.lang') ?? 0;
  final alreadySeeded = prefs.getBool('kaal.dataSeeded') ?? false;
  final realDataReady = prefs.getBool('kaal.realData') ?? false;
  if (!alreadySeeded) {
    await seedDatabase(db, langIdx: currentLang);
    await prefs.setBool('kaal.dataSeeded', true);
    await prefs.setBool('kaal.realData', true);
  } else if (!realDataReady) {
    // One-time migration off the old auto-reseeding "demo data" model: refresh
    // once in the current language to clear stale/wrong-language rows, then keep
    // everything as permanent real data from here on.
    await reseedDatabase(db, langIdx: currentLang);
    await prefs.setBool('kaal.realData', true);
  }

  // ── Notifications ────────────────────────────────────────────────────────
  await NotificationService.instance.init();
  await NotificationService.instance.requestPermission();
  // Reschedule all notifications from current DB state on each launch.
  // This keeps alarms alive after device reboots.
  unawaited(_rescheduleNotifications(db, prefs));
  // Re-arm user-set reminders & alarms (stored in prefs) after reboot/relaunch.
  unawaited(_rescheduleReminders(prefs));

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

Future<void> _rescheduleReminders(SharedPreferences prefs) async {
  try {
    final raw = prefs.getStringList('kaal.reminders') ?? const [];
    final reminders = <Reminder>[];
    for (final s in raw) {
      try {
        reminders.add(Reminder.decode(s));
      } catch (_) {/* skip malformed */}
    }
    await NotificationService.instance.rescheduleReminders(reminders);
  } catch (_) {/* non-fatal */}
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
  final onboarded = AppLaunchPrefs.onboardingDone(prefs);
  final authed    = AppLaunchPrefs.skipAuth(prefs) ||
      Supabase.instance.client.auth.currentUser != null;

  // If the app was cold-started by tapping a notification, land directly on its
  // target screen (skip the splash) — but only once the user is past onboarding
  // and auth, so we never bypass those gates.
  final route = NotificationService.consumePendingRoute();
  if (route != null && onboarded && authed) return route;

  // Quote splash policy: show it on a genuine fresh start — first run / sign-in,
  // a new calendar day, or an idle gap of 8h+. Skip it (go straight to Focus,
  // feels like a resume) only when a returning signed-in user reopens the same
  // calendar day within 8 hours — i.e. Android killed us while backgrounded.
  if (onboarded && authed &&
      AppLaunchPrefs.wasActiveSameDayWithin(prefs, const Duration(hours: 8))) {
    return KaalRoutes.focus;
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
          // Safety net: when sign-in completes (e.g. the Google OAuth deep link
          // returns), make sure the user actually lands on Focus. Only redirect
          // from the auth screens — never yank the user out of onboarding or an
          // in-app flow (e.g. linking a calendar from Settings).
          final path = router.routerDelegate.currentConfiguration.uri.path;
          if (path == KaalRoutes.quote ||
              path == KaalRoutes.signin ||
              path == KaalRoutes.signup) {
            router.go(KaalRoutes.focus);
          }
        }
        if (state.event == AuthChangeEvent.signedOut) {
          // Drop the previous user's Google API tokens so the next account can't
          // reach their Gmail/Calendar.
          ref.read(googleServiceProvider).disconnect();
          router.go(KaalRoutes.signin);
        }
      });
    });

    // Note: seeded content is permanent real data — switching language only
    // re-localizes the UI, it does not wipe or re-seed your data.

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
          // The floating bottom-nav pill (≈50px content height, rendered in a
          // separate Stack layer above the Scaffold) isn't known to the Scaffold,
          // so floating snackbars sit under it. Lift every snackbar above the nav
          // by adding the nav height to the default bottom inset (10 → 64).
          snackBarTheme: const SnackBarThemeData(
            behavior: SnackBarBehavior.floating,
            insetPadding: EdgeInsets.fromLTRB(15, 5, 15, 64),
          ),
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
