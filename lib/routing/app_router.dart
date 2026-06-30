import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/providers/ai_access_provider.dart';
import '../data/providers/auth_provider.dart';
import '../data/database.dart' show Habit;
import '../services/ad_service.dart';
import '../data/providers/calendar_provider.dart';
import '../data/providers/habits_provider.dart';
import '../data/providers/notes_provider.dart';
import '../data/providers/tasks_provider.dart';
import '../l10n/app_l10n.dart';
import '../settings/app_launch_prefs.dart';
import '../screens/focus/focus_screen.dart';
import '../screens/calendar/calendar_screen.dart';
import '../screens/habits/habits_screen.dart';
import '../screens/inbox/inbox_screen.dart';
import '../screens/notes/notes_screen.dart';
import '../screens/tasks/tasks_screen.dart';
import '../screens/tasks/task_detail_screen.dart';
import '../screens/tasks/edit_task_screen.dart';
import '../screens/tasks/quick_add_screen.dart';
import '../screens/tasks/inbox_panel_screen.dart';
import '../screens/tasks/board_screen.dart';
import '../screens/tasks/upcoming_screen.dart';
import '../screens/tasks/labels_screen.dart';
import '../screens/tasks/filters_screen.dart';
import '../screens/tasks/day_schedule_screen.dart';
import '../screens/tasks/smart_recurrence_screen.dart';
import '../screens/tasks/analytics_screen.dart';
import '../screens/tasks/time_track_screen.dart';
import '../screens/tasks/quad_screen.dart';
import '../screens/tasks/completed_panel_screen.dart';
import '../screens/tasks/lists_screen.dart';
import '../screens/focus/focus_list_screen.dart';
import '../screens/focus/brain_dump_screen.dart';
import '../screens/focus/edit_goal_screen.dart';
import '../screens/focus/goal_detail_screen.dart';
import '../screens/focus/goals_screen.dart';
import '../screens/focus/pomodoro_screen.dart';
import '../screens/focus/eod_reflect_screen.dart';
import '../screens/focus/predictive_ai_screen.dart';
import '../screens/focus/weekly_review_screen.dart';
import '../screens/habits/add_habit_screen.dart';
import '../screens/habits/habit_detail_screen.dart';
import '../screens/habits/habit_stats_screen.dart';
import '../screens/habits/achievements_screen.dart';
import '../screens/habits/add_slot_screen.dart';
import '../screens/calendar/gmail_sync_screen.dart';
import '../screens/calendar/cal_sync_screen.dart';
import '../screens/calendar/conflicts_screen.dart';
import '../screens/notes/note_editor_screen.dart';
import '../screens/onboarding/onboard_screen.dart';
import '../screens/onboarding/quote_splash_screen.dart';
import '../screens/onboarding/signin_screen.dart';
import '../screens/onboarding/signup_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/inbox/inbox_integrations_screen.dart';
import '../screens/legal_screen.dart';
import '../screens/settings/report_feedback_screen.dart';
import '../screens/paywall_screen.dart';
import '../screens/profile/edit_profile_screen.dart';
import '../screens/profile/referral_screen.dart';
import '../screens/search_screen.dart';
import '../screens/settings/notification_center_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/settings/student_mode_screen.dart';
import '../screens/settings/logs_screen.dart';
import '../screens/settings/widget_preview_screen.dart';
import '../theme/kaal_colors.dart';
import '../theme/kaal_theme.dart';
import '../widgets/app_shell.dart';
import '../widgets/kaal_avatar.dart';
import '../widgets/kaal_bottom_nav.dart';
import '../widgets/top_ico_button.dart';
import 'current_tab.dart';
import 'page_transitions.dart';
import 'routes.dart';

// Top-bar SVG icon strings — stroke="white" recolored via colorFilter
const _kSearchSvg = '<svg width="22" height="22" viewBox="0 0 22 22" fill="none" '
    'stroke="white" stroke-width="1.6" stroke-linecap="round">'
    '<circle cx="10" cy="10" r="7"/>'
    '<path d="M21 21l-4.35-4.35"/></svg>';

const _kAnalyticsSvg = '<svg width="22" height="22" viewBox="0 0 22 22" fill="none" '
    'stroke="white" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round">'
    '<rect x="2" y="12" width="4" height="8"/>'
    '<rect x="9" y="7" width="4" height="13"/>'
    '<rect x="16" y="2" width="4" height="18"/></svg>';

const _kShareSvg = '<svg width="22" height="22" viewBox="0 0 22 22" fill="none" '
    'stroke="white" stroke-width="1.6" stroke-linecap="round">'
    '<path d="M4 12v8a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2v-8"/>'
    '<polyline points="16 6 12 2 8 6"/>'
    '<line x1="12" y1="2" x2="12" y2="15"/></svg>';

const _kHabitStatsSvg = '<svg width="22" height="22" viewBox="0 0 22 22" fill="none" '
    'stroke="white" stroke-width="1.6" stroke-linecap="round">'
    '<line x1="18" y1="20" x2="18" y2="10"/>'
    '<line x1="12" y1="20" x2="12" y2="4"/>'
    '<line x1="6" y1="20" x2="6" y2="14"/></svg>';

const _k7DaysSvg = '<svg width="22" height="22" viewBox="0 0 22 22" fill="none" '
    'stroke="white" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round">'
    '<rect x="3" y="4" width="16" height="16" rx="2"/>'
    '<path d="M15 2v4M7 2v4M3 10h16"/></svg>';

const _kSettingsSvg = '<svg width="22" height="22" viewBox="0 0 24 24" fill="none" '
    'stroke="white" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round">'
    '<path d="M12 15a3 3 0 1 0 0-6 3 3 0 0 0 0 6z"/>'
    '<path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 0 1-2.83 2.83l-.06-.06'
    'a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-4 0v-.09'
    'A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 0 1-2.83-2.83'
    'l.06-.06A1.65 1.65 0 0 0 4.68 15a1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1 0-4h.09'
    'A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 0 1 2.83-2.83'
    'l.06.06A1.65 1.65 0 0 0 9 4.68a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 4 0v.09'
    'a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 0 1 2.83 2.83'
    'l-.06.06A1.65 1.65 0 0 0 19.4 9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 0 4h-.09'
    'a1.65 1.65 0 0 0-1.51 1z"/></svg>';

// Per-branch navigator keys — each branch gets its own stack.
final _rootKey      = GlobalKey<NavigatorState>(debugLabel: 'root');
final _focusKey     = GlobalKey<NavigatorState>(debugLabel: 'focus');
final _tasksKey     = GlobalKey<NavigatorState>(debugLabel: 'tasks');
final _habitsKey    = GlobalKey<NavigatorState>(debugLabel: 'habits');
final _calKey       = GlobalKey<NavigatorState>(debugLabel: 'cal');
final _inboxKey     = GlobalKey<NavigatorState>(debugLabel: 'inbox');
final _notesKey     = GlobalKey<NavigatorState>(debugLabel: 'notes');
final _searchKey    = GlobalKey<NavigatorState>(debugLabel: 'search');
final _settingsKey  = GlobalKey<NavigatorState>(debugLabel: 'settings');
final _profileKey   = GlobalKey<NavigatorState>(debugLabel: 'profile');

// Build the router with the computed initial location (see main.dart).
// The redirect guard re-checks auth on every navigation so that the browser URL
// (which go_router respects on web) cannot bypass the onboarding/auth gates.
GoRouter buildAppRouter(String initialLocation, SharedPreferences prefs) => GoRouter(
  navigatorKey: _rootKey,
  initialLocation: initialLocation,
  redirect: (context, state) {
    final path = state.uri.path;
    // These routes are always reachable — no auth required.
    const publicPaths = {
      KaalRoutes.quote,
      KaalRoutes.signin,
      KaalRoutes.signup,
      KaalRoutes.onboard,
    };
    if (publicPaths.contains(path)) return null;

    // Must complete onboarding before accessing any other screen.
    if (!AppLaunchPrefs.onboardingDone(prefs)) return KaalRoutes.quote;

    // Must be signed in or have explicitly skipped auth.
    final isSignedIn = Supabase.instance.client.auth.currentUser != null;
    if (!AppLaunchPrefs.skipAuth(prefs) && !isSignedIn) return KaalRoutes.signin;

    return null;
  },
  routes: [
    // ── Standalone routes — onboarding (fade transition, full-replace flow) ──
    GoRoute(path: KaalRoutes.quote,       pageBuilder: (c, s) => fadePage(child: const QuoteSplashScreen(),   state: s)),
    GoRoute(path: KaalRoutes.signin,      pageBuilder: (c, s) => fadePage(child: const SigninScreen(),        state: s)),
    GoRoute(path: KaalRoutes.signup,      pageBuilder: (c, s) => slideRightPage(child: const SignupScreen(),  state: s)),
    GoRoute(path: KaalRoutes.onboard,     pageBuilder: (c, s) => fadePage(child: const OnboardScreen(),      state: s)),

    // ── Authenticated shell — bottom nav always visible ──────────────────
    ShellRoute(
      builder: (context, state, child) =>
          _NavShell(path: state.uri.path, child: child),
      routes: [
    // Root-level modals — accessible from any tab via root navigator
    GoRoute(path: KaalRoutes.paywall, pageBuilder: (c, s) => slideUpPage(child: PaywallScreen(from: s.uri.queryParameters['from']), state: s)),
    GoRoute(path: KaalRoutes.legal,   pageBuilder: (c, s) => slideRightPage(child: LegalScreen(tab: switch (s.uri.queryParameters['tab']) {
      'privacy'   => LegalTab.privacy,
      'copyright' => LegalTab.copyright,
      'support'   => LegalTab.support,
      'deletion'  => LegalTab.deletion,
      'datainfo'  => LegalTab.dataInfo,
      _           => LegalTab.terms,
    }), state: s)),
    GoRoute(path: KaalRoutes.report,  pageBuilder: (c, s) => slideRightPage(child: const ReportFeedbackScreen(), state: s)),
      ], // _NavShell.routes
    ),   // ShellRoute(_NavShell)

    // ── Tab shell — top-level so pathless shells don't nest (avoids duplicate pageKey) ──
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) => _RouterShell(shell: shell),
      branches: [
        // ── Focus (branch 0) ──────────────────────────────────────────────
        StatefulShellBranch(
          navigatorKey: _focusKey,
          routes: [
            GoRoute(
              path: KaalRoutes.focus,
              pageBuilder: (context, state) =>
                  NoTransitionPage<void>(key: state.pageKey, child: const FocusDashboardScreen()),
              routes: [
                GoRoute(path: 'goals',       pageBuilder: (context, s) => slideRightPage(child: const GoalsScreen(),                       state: s)),
                GoRoute(path: 'goals/:id',   pageBuilder: (context, s) => slideRightPage(child: GoalDetailScreen(goalId: s.pathParameters['id'] ?? ''), state: s)),
                GoRoute(path: 'editgoal',    pageBuilder: (context, s) => slideRightPage(child: const EditGoalScreen(goalId: ''),             state: s)),
                GoRoute(path: 'editgoal/:id',pageBuilder: (context, s) => slideRightPage(child: EditGoalScreen(goalId: s.pathParameters['id'] ?? ''), state: s)),
                GoRoute(path: 'pomodoro',    pageBuilder: (context, s) => slideRightPage(child: const PomodoroScreen(),                    state: s)),
                GoRoute(path: 'braindump',   pageBuilder: (context, s) => slideRightPage(child: const BrainDumpScreen(),                  state: s)),
                GoRoute(path: 'predictive',  pageBuilder: (context, s) => slideRightPage(child: const PredictiveAiScreen(),                state: s)),
                GoRoute(path: 'reflect',     pageBuilder: (context, s) => slideRightPage(child: const EodReflectScreen(),    state: s)),
                GoRoute(path: 'taskdetail/:id', pageBuilder: (context, s) => slideRightPage(child: TaskDetailScreen(taskId: s.pathParameters['id'] ?? ''), state: s)),
                GoRoute(
                  path: 'focuslist',
                  pageBuilder: (context, s) {
                    final f = switch (s.uri.queryParameters['f']) {
                      'active'  => FocusFilter.active,
                      'done'    => FocusFilter.done,
                      'overdue' => FocusFilter.overdue,
                      _         => FocusFilter.today,
                    };
                    return slideRightPage(child: FocusListScreen(initialFilter: f), state: s);
                  },
                ),
              ],
            ),
          ],
        ),

        // ── Tasks (branch 1) ──────────────────────────────────────────────
        StatefulShellBranch(
          navigatorKey: _tasksKey,
          routes: [
            GoRoute(
              path: KaalRoutes.tasks,
              pageBuilder: (context, state) =>
                  NoTransitionPage<void>(key: state.pageKey, child: const TasksScreen()),
              routes: [
                GoRoute(path: 'taskdetail/:id', pageBuilder: (context, s) => slideRightPage(child: TaskDetailScreen(taskId: s.pathParameters['id'] ?? ''), state: s)),
                GoRoute(path: 'edittask',        pageBuilder: (context, s) => slideRightPage(child: EditTaskScreen(initialQuad: int.tryParse(s.uri.queryParameters['quad'] ?? '')), state: s)),
                GoRoute(path: 'edittask/:id',    pageBuilder: (context, s) => slideRightPage(child: EditTaskScreen(taskId: s.pathParameters['id']),    state: s)),
                GoRoute(path: 'quickadd',        pageBuilder: (context, s) => slideRightPage(child: const QuickAddScreen(),                                              state: s)),
                GoRoute(path: 'inbox',           pageBuilder: (context, s) => slideRightPage(child: const InboxPanelScreen(),                                             state: s)),
                GoRoute(path: 'board',           pageBuilder: (context, s) => slideRightPage(child: const BoardScreen(),                                                  state: s)),
                GoRoute(path: 'upcoming',        pageBuilder: (context, s) => slideRightPage(child: const UpcomingScreen(),                                               state: s)),
                GoRoute(path: 'labels',          pageBuilder: (context, s) => slideRightPage(child: const LabelsScreen(),                                                 state: s)),
                GoRoute(path: 'filters',         pageBuilder: (context, s) => slideRightPage(child: const FiltersScreen(),                                                state: s)),
                GoRoute(path: 'schedule',        pageBuilder: (context, s) => slideRightPage(child: const DayScheduleScreen(),                                            state: s)),
                GoRoute(path: 'recurring',       pageBuilder: (context, s) => slideRightPage(child: const SmartRecurrenceScreen(),                                        state: s)),
                GoRoute(path: 'analytics',       pageBuilder: (context, s) => slideRightPage(child: const AnalyticsScreen(),                                              state: s)),
                GoRoute(path: 'timetrack',       pageBuilder: (context, s) => slideRightPage(child: const TimeTrackScreen(),                                              state: s)),
                GoRoute(path: 'pomodoro',        pageBuilder: (context, s) => slideRightPage(child: const PomodoroScreen(),                                               state: s)),
                GoRoute(path: 'quad/:q',         pageBuilder: (context, s) => slideRightPage(child: QuadScreen(quad: s.pathParameters['q'] ?? 'q1'),                     state: s)),
                GoRoute(path: 'panel-comp',      pageBuilder: (context, s) => slideRightPage(child: const CompletedPanelScreen(),                                         state: s)),
                GoRoute(path: 'lists',           pageBuilder: (context, s) => slideRightPage(child: const ListsScreen(),                                                   state: s)),
                GoRoute(path: 'lists/:id',       pageBuilder: (context, s) => slideRightPage(child: ListsScreen(initialListId: int.tryParse(s.pathParameters['id'] ?? '')), state: s)),
                GoRoute(path: 'logs',            pageBuilder: (context, s) => slideRightPage(child: const LogsScreen(standalone: false),                                   state: s)),
              ],
            ),
          ],
        ),

        // ── Habits (branch 2) ─────────────────────────────────────────────
        StatefulShellBranch(
          navigatorKey: _habitsKey,
          routes: [
            GoRoute(
              path: KaalRoutes.habits,
              pageBuilder: (context, state) =>
                  NoTransitionPage<void>(key: state.pageKey, child: const HabitsScreen()),
              routes: [
                GoRoute(path: 'addhabit',        pageBuilder: (context, s) => slideRightPage(child: const AddHabitScreen(),                                                    state: s)),
                GoRoute(path: 'addhabit/:id',    pageBuilder: (context, s) => slideRightPage(child: AddHabitScreen(habitId: s.pathParameters['id']),                          state: s)),
                GoRoute(path: 'habitdetail/:id', pageBuilder: (context, s) => slideRightPage(child: HabitDetailScreen(habitId: s.pathParameters['id'] ?? ''),                  state: s)),
                GoRoute(path: 'habitstats',      pageBuilder: (context, s) => slideRightPage(child: const HabitStatsScreen(),                                                   state: s)),
                GoRoute(path: 'achievements',    pageBuilder: (context, s) => slideRightPage(child: const AchievementsScreen(),                                                 state: s)),
                GoRoute(path: 'addslot',         pageBuilder: (context, s) => slideRightPage(child: const AddSlotScreen(),                                                      state: s)),
              ],
            ),
          ],
        ),

        // ── Calendar (branch 3) ───────────────────────────────────────────
        StatefulShellBranch(
          navigatorKey: _calKey,
          routes: [
            GoRoute(
              path: KaalRoutes.cal,
              pageBuilder: (context, state) =>
                  NoTransitionPage<void>(key: state.pageKey, child: const CalendarScreen()),
              routes: [
                GoRoute(path: 'conflicts',        pageBuilder: (context, s) => slideRightPage(child: const ConflictsScreen(), state: s)),
                GoRoute(path: 'addslot',         pageBuilder: (context, s) => slideRightPage(child: const AddSlotScreen(), state: s)),
                GoRoute(path: 'addslot/:eventId', pageBuilder: (context, s) => slideRightPage(child: AddSlotScreen(eventId: s.pathParameters['eventId']), state: s)),
                GoRoute(path: 'calsync',         pageBuilder: (context, s) => slideRightPage(child: const CalSyncScreen(),   state: s)),
                GoRoute(path: 'gmailsync',       pageBuilder: (context, s) => slideRightPage(child: const GmailSyncScreen(), state: s)),
              ],
            ),
          ],
        ),

        // ── Inbox (branch 4) ──────────────────────────────────────────────
        StatefulShellBranch(
          navigatorKey: _inboxKey,
          routes: [
            GoRoute(
              path: KaalRoutes.inbox,
              pageBuilder: (context, state) =>
                  NoTransitionPage<void>(key: state.pageKey, child: const InboxScreen()),
              routes: [
                GoRoute(path: 'integrations', pageBuilder: (context, s) => slideRightPage(child: const InboxIntegrationsScreen(), state: s)),
              ],
            ),
          ],
        ),

        // ── Notes (branch 5) ──────────────────────────────────────────────
        StatefulShellBranch(
          navigatorKey: _notesKey,
          routes: [
            GoRoute(
              path: KaalRoutes.notes,
              pageBuilder: (context, state) =>
                  NoTransitionPage<void>(key: state.pageKey, child: const NotesScreen()),
              routes: [
                GoRoute(path: 'noteeditor',     pageBuilder: (context, s) => slideRightPage(child: const NoteEditorScreen(),                         state: s)),
                GoRoute(path: 'noteeditor/:id', pageBuilder: (context, s) => slideRightPage(child: NoteEditorScreen(noteId: s.pathParameters['id']), state: s)),
              ],
            ),
          ],
        ),

        // ── Search (branch 6) ─────────────────────────────────────────────
        StatefulShellBranch(
          navigatorKey: _searchKey,
          routes: [
            GoRoute(
              path: KaalRoutes.search,
              pageBuilder: (context, state) =>
                  NoTransitionPage<void>(key: state.pageKey, child: const SearchScreen()),
            ),
          ],
        ),

        // ── Settings (branch 7) ───────────────────────────────────────────
        StatefulShellBranch(
          navigatorKey: _settingsKey,
          routes: [
            GoRoute(
              path: KaalRoutes.settings,
              pageBuilder: (context, state) =>
                  NoTransitionPage<void>(key: state.pageKey, child: const SettingsScreen()),
              routes: [
                GoRoute(path: 'activitylogs', pageBuilder: (c, s) => slideRightPage(child: LogsScreen(standalone: false),            state: s)),
                GoRoute(path: 'studentmode',  pageBuilder: (c, s) => slideRightPage(child: const StudentModeScreen(),                state: s)),
                GoRoute(path: 'notifcenter',  pageBuilder: (c, s) => slideRightPage(child: const NotificationCenterScreen(),         state: s)),
                GoRoute(path: 'widget',       pageBuilder: (c, s) => slideRightPage(child: const WidgetPreviewScreen(),              state: s)),
              ],
            ),
          ],
        ),

        // ── Profile (branch 8) ────────────────────────────────────────────
        StatefulShellBranch(
          navigatorKey: _profileKey,
          routes: [
            GoRoute(
              path: KaalRoutes.profile,
              pageBuilder: (context, state) =>
                  NoTransitionPage<void>(key: state.pageKey, child: const ProfileScreen()),
              routes: [
                GoRoute(path: 'edit',         pageBuilder: (c, s) => slideRightPage(child: const EditProfileScreen(),   state: s)),
                GoRoute(path: 'referral',     pageBuilder: (c, s) => slideRightPage(child: const ReferralScreen(),      state: s)),
                GoRoute(path: 'weeklyreview', pageBuilder: (c, s) => slideRightPage(child: const WeeklyReviewScreen(),  state: s)),
              ],
            ),
          ],
        ),
      ],
    ),
  ],
);

// ── Global nav shell — renders KaalBottomNav over every authenticated screen ─

class _NavShell extends StatelessWidget {
  final String path;
  final Widget child;
  const _NavShell({required this.path, required this.child});

  static KaalTab _tabFromPath(String path) {
    if (path.startsWith('/focus'))    return KaalTab.focus;
    if (path.startsWith('/tasks'))    return KaalTab.tasks;
    if (path.startsWith('/habits'))   return KaalTab.habits;
    if (path.startsWith('/cal'))      return KaalTab.calendar;
    if (path.startsWith('/inbox'))    return KaalTab.inbox;
    if (path.startsWith('/notes'))    return KaalTab.notes;
    if (path.startsWith('/search'))   return KaalTab.search;
    if (path.startsWith('/settings')) return KaalTab.settings;
    if (path.startsWith('/profile'))  return KaalTab.profile;
    return KaalTab.focus;
  }

  static String _routeForTab(KaalTab tab) => switch (tab) {
    KaalTab.focus    => KaalRoutes.focus,
    KaalTab.tasks    => KaalRoutes.tasks,
    KaalTab.habits   => KaalRoutes.habits,
    KaalTab.calendar => KaalRoutes.cal,
    KaalTab.inbox  => KaalRoutes.inbox,
    KaalTab.notes    => KaalRoutes.notes,
    KaalTab.search   => KaalRoutes.search,
    KaalTab.settings => KaalRoutes.settings,
    KaalTab.profile  => KaalRoutes.profile,
  };

  // Nav bar fixed content height: 6px top-pad + 44px minHeight = 50px above the
  // system safe area. We inject this into MediaQuery.padding.bottom so every
  // descendant screen's SafeArea / scroll padding / Positioned offsets clear the
  // floating nav bar automatically without knowing about it explicitly.
  static const _kNavContentHeight = 50.0;

  @override
  Widget build(BuildContext context) {
    // Full-screen modals with no tab context — show without the bottom nav.
    // (Paywall included so the post-onboarding mandatory gate can't be escaped
    // by tapping a tab.)
    if (path == KaalRoutes.legal ||
        path == KaalRoutes.report ||
        path == KaalRoutes.paywall) {
      return child;
    }

    final tab = _tabFromPath(path);
    final mq  = MediaQuery.of(context);
    return MediaQuery(
      data: mq.copyWith(
        padding: mq.padding.copyWith(
          bottom: mq.padding.bottom + _kNavContentHeight,
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(child: child),
          Align(
            alignment: Alignment.bottomCenter,
            child: KaalBottomNav(
              currentTab: tab,
              onTabChanged: (t) {
                // Free users see an occasional interstitial (capped in AdService).
                if (!ProviderScope.containerOf(context, listen: false).read(isProProvider)) {
                  AdService.instance.maybeShowInterstitial();
                }
                context.go(_routeForTab(t));
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Tab shell widget ──────────────────────────────────────────────────────────

class _RouterShell extends ConsumerWidget {
  final StatefulNavigationShell shell;
  const _RouterShell({required this.shell});

  KaalTab get _tab => KaalTab.values[shell.currentIndex];

  String _title(BuildContext context) {
    final str = AppL10n.of(context);
    return switch (_tab) {
      KaalTab.focus    => str.focus,
      KaalTab.tasks    => str.tasks,
      KaalTab.habits   => str.habits,
      KaalTab.calendar => str.calendar,
      KaalTab.inbox  => str.inbox,
      KaalTab.notes    => str.notes,
      KaalTab.search   => str.search,
      KaalTab.settings => str.settings,
      KaalTab.profile  => str.profile,
    };
  }

  static String _focusDateLabel() {
    final now = DateTime.now();
    const days   = ['Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday'];
    const months = ['January','February','March','April','May','June',
                    'July','August','September','October','November','December'];
    return '${days[now.weekday - 1]}, ${now.day} ${months[now.month - 1]}';
  }

  static int _maxStreakDays(List<Habit> habits) {
    int best = 0;
    for (final h in habits) {
      final m = RegExp(r'(\d+)').firstMatch(h.streakLabel);
      if (m != null) {
        final n = int.tryParse(m.group(1)!) ?? 0;
        if (n > best) best = n;
      }
    }
    return best;
  }

  String? _subtitle({
    required int streakDays,
    required int activeCount,
    required int overdueCount,
    required int habitCount,
    required int eventCount,
    required int inviteCount,
    required int noteCount,
  }) => switch (_tab) {
        KaalTab.focus    => '${_focusDateLabel()} · 🔥 ${streakDays}d streak',
        KaalTab.tasks    => '$activeCount ${activeCount == 1 ? 'task' : 'tasks'} active${overdueCount > 0 ? ' · $overdueCount overdue' : ''}',
        KaalTab.habits   => '$habitCount active · 🔥 ${streakDays}d streak',
        KaalTab.calendar => '$eventCount ${eventCount == 1 ? 'event' : 'events'}${inviteCount > 0 ? ' · $inviteCount ${inviteCount == 1 ? 'invite' : 'invites'}' : ''}',
        KaalTab.notes    => '$noteCount ${noteCount == 1 ? 'note' : 'notes'}',
        KaalTab.inbox  => 'Email · SMS · Parsed',
        _                => null,
      };

  List<Widget> _actions(BuildContext context) {
    final ink3 = KaalTheme.of(context).colors.ink3;
    final cf   = ColorFilter.mode(ink3, BlendMode.srcIn);
    switch (_tab) {
      case KaalTab.focus:
        return [
          const _SyncPill(),
          TopIcoButton(icon: SvgPicture.string(_kSearchSvg,   width: 22, height: 22, colorFilter: cf), onTap: () => context.go(KaalRoutes.search)),
          TopIcoButton(icon: SvgPicture.string(_kSettingsSvg, width: 22, height: 22, colorFilter: cf), onTap: () => context.go(KaalRoutes.settings)),
          TopIcoButton(icon: const KaalAvatar(size: 24), onTap: () => context.go(KaalRoutes.profile)),
        ];
      case KaalTab.tasks:
        return [
          GestureDetector(
            onTap: () => context.push(KaalRoutes.tasksUpcoming),
            child: SizedBox(
              width: 38,
              height: 38,
              child: Center(
                child: SvgPicture.string(_k7DaysSvg, width: 22, height: 22, colorFilter: cf),
              ),
            ),
          ),
          TopIcoButton(icon: SvgPicture.string(_kAnalyticsSvg, width: 22, height: 22, colorFilter: cf), onTap: () => context.push(KaalRoutes.tasksAnalytics)),
          TopIcoButton(icon: SvgPicture.string(_kSearchSvg,    width: 22, height: 22, colorFilter: cf), onTap: () => context.go(KaalRoutes.search)),
          TopIcoButton(icon: SvgPicture.string(_kSettingsSvg,  width: 22, height: 22, colorFilter: cf), onTap: () => context.go(KaalRoutes.settings)),
          TopIcoButton(icon: const KaalAvatar(size: 24), onTap: () => context.go(KaalRoutes.profile)),
        ];
      case KaalTab.habits:
        return [
          TopIcoButton(icon: SvgPicture.string(_kHabitStatsSvg, width: 22, height: 22, colorFilter: cf), onTap: () => context.push('/habits/habitstats')),
          TopIcoButton(icon: SvgPicture.string(_kSearchSvg,      width: 22, height: 22, colorFilter: cf), onTap: () => context.go(KaalRoutes.search)),
          TopIcoButton(icon: SvgPicture.string(_kSettingsSvg,    width: 22, height: 22, colorFilter: cf), onTap: () => context.go(KaalRoutes.settings)),
          TopIcoButton(icon: const KaalAvatar(size: 24), onTap: () => context.go(KaalRoutes.profile)),
        ];
      case KaalTab.calendar:
        return [
          const _ConflictsPill(),
          TopIcoButton(icon: SvgPicture.string(_kSearchSvg,   width: 22, height: 22, colorFilter: cf), onTap: () => context.go(KaalRoutes.search)),
          TopIcoButton(icon: SvgPicture.string(_kSettingsSvg, width: 22, height: 22, colorFilter: cf), onTap: () => context.go(KaalRoutes.settings)),
          TopIcoButton(icon: const KaalAvatar(size: 24), onTap: () => context.go(KaalRoutes.profile)),
        ];
      case KaalTab.notes:
        return [
          TopIcoButton(icon: SvgPicture.string(_kShareSvg,    width: 22, height: 22, colorFilter: cf), onTap: () {}),
          TopIcoButton(icon: SvgPicture.string(_kSearchSvg,   width: 22, height: 22, colorFilter: cf), onTap: () => context.go(KaalRoutes.search)),
          TopIcoButton(icon: SvgPicture.string(_kSettingsSvg, width: 22, height: 22, colorFilter: cf), onTap: () => context.go(KaalRoutes.settings)),
          TopIcoButton(icon: const KaalAvatar(size: 24), onTap: () => context.go(KaalRoutes.profile)),
        ];
      case KaalTab.inbox:
        return [
          TopIcoButton(icon: SvgPicture.string(_kSearchSvg,   width: 22, height: 22, colorFilter: cf), onTap: () => context.go(KaalRoutes.search)),
          TopIcoButton(icon: SvgPicture.string(_kSettingsSvg, width: 22, height: 22, colorFilter: cf), onTap: () => context.go(KaalRoutes.settings)),
          TopIcoButton(icon: const KaalAvatar(size: 24), onTap: () => context.go(KaalRoutes.profile)),
        ];
      case KaalTab.search:
        return [
          TopIcoButton(icon: SvgPicture.string(_kSettingsSvg, width: 22, height: 22, colorFilter: cf), onTap: () => context.go(KaalRoutes.settings)),
          TopIcoButton(icon: const KaalAvatar(size: 24), onTap: () => context.go(KaalRoutes.profile)),
        ];
      case KaalTab.settings:
        return [
          TopIcoButton(icon: SvgPicture.string(_kSearchSvg,   width: 22, height: 22, colorFilter: cf), onTap: () => context.go(KaalRoutes.search)),
          TopIcoButton(icon: SvgPicture.string(_kSettingsSvg, width: 22, height: 22,
              colorFilter: const ColorFilter.mode(KaalColors.acc, BlendMode.srcIn)), onTap: () {}),
          TopIcoButton(icon: const KaalAvatar(size: 24), onTap: () => context.go(KaalRoutes.profile)),
        ];
      case KaalTab.profile:
        return [
          TopIcoButton(icon: SvgPicture.string(_kSearchSvg,   width: 22, height: 22, colorFilter: cf), onTap: () => context.go(KaalRoutes.search)),
          TopIcoButton(icon: SvgPicture.string(_kSettingsSvg, width: 22, height: 22, colorFilter: cf), onTap: () => context.go(KaalRoutes.settings)),
          TopIcoButton(icon: const KaalAvatar(size: 24), onTap: null),
        ];
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habits       = ref.watch(habitsProvider).valueOrNull ?? const [];
    final streak       = _maxStreakDays(habits);
    final allTasks     = ref.watch(allTasksProvider).valueOrNull ?? const [];
    final active       = allTasks.where((t) => !t.isDone).toList();
    final activeCount  = active.length;
    final overdueCount = active.where((t) => t.isOverdue).length;
    final events       = ref.watch(calendarEventsProvider).valueOrNull ?? const [];
    final today        = DateTime.now();
    final todayEvents  = events.where((e) {
      final d = e.eventDate;
      return d != null && d.year == today.year && d.month == today.month && d.day == today.day;
    }).toList();
    final inviteCount  = todayEvents.where((e) => e.isInvite).length;
    final notes        = ref.watch(notesProvider).valueOrNull ?? const [];
    final tab = _tab;

    AppShell appShell() => AppShell(
          title: _title(context),
          subtitle: _subtitle(
            streakDays:    streak,
            activeCount:   activeCount,
            overdueCount:  overdueCount,
            habitCount:    habits.length,
            eventCount:    todayEvents.length,
            inviteCount:   inviteCount,
            noteCount:     notes.length,
          ),
          actions: _actions(context),
          body: shell,
        );

    final mq  = MediaQuery.of(context);
    return MediaQuery(
      data: mq.copyWith(
        padding: mq.padding.copyWith(
          bottom: mq.padding.bottom + _NavShell._kNavContentHeight,
        ),
      ),
      child: CurrentTab(
        tab: tab,
        child: Stack(
          children: [
            Positioned.fill(child: appShell()),
            Align(
              alignment: Alignment.bottomCenter,
              child: KaalBottomNav(
                currentTab: tab,
                onTabChanged: (t) {
                  if (!ProviderScope.containerOf(context, listen: false).read(isProProvider)) {
                    AdService.instance.maybeShowInterstitial();
                  }
                  context.go(_NavShell._routeForTab(t));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Top-bar action widgets ────────────────────────────────────────────────────

// Synced pill — green when signed in and syncing, grey when local-only.
class _SyncPill extends ConsumerWidget {
  const _SyncPill();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final signedIn = ref.watch(isSignedInProvider);
    final color  = signedIn ? KaalColors.success : const Color(0xFF8E8E93);
    final bgColor = signedIn ? const Color(0x1F7FBA00) : const Color(0x1A8E8E93);
    final bdColor = signedIn ? const Color(0x407FBA00) : const Color(0x338E8E93);
    final label   = signedIn ? 'Synced' : 'Local';

    return Container(
      padding: const EdgeInsets.fromLTRB(6, 2, 6, 2),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(width: 0.5, color: bdColor),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 5, height: 5,
            child: DecoratedBox(
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
          ),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Inter', fontSize: 11,
              fontWeight: FontWeight.w600, color: color, height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

// Conflicts pill: amber ⚡ tag for calendar top bar
class _ConflictsPill extends StatelessWidget {
  const _ConflictsPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(7, 2, 7, 2),
      decoration: BoxDecoration(
        color: const Color(0x1AFFB900),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(width: 0.5, color: const Color(0x40FFB900)),
      ),
      child: const Text(
        '⚡ 2 conflicts',
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 9,
          color: Color(0xFFFFB900),
          height: 1,
        ),
      ),
    );
  }
}


