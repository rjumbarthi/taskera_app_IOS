abstract final class KaalRoutes {
  // Tab roots (also used with context.go())
  static const focus   = '/focus';
  static const tasks   = '/tasks';
  static const habits  = '/habits';
  static const cal     = '/cal';
  static const notes   = '/notes';
  static const inbox   = '/inbox';

  // Focus sub-screens
  static const focusList   = '/focus/focuslist';
  static const pomodoro    = '/focus/pomodoro';
  static const brainDump   = '/focus/braindump';
  static const goals       = '/focus/goals';
  static const predictive  = '/focus/predictive';
  static const eodReflect  = '/focus/reflect';
  static const weeklyFocus = '/focus/weeklyfocus';
  // Tasks sub-screens
  static const tasksQuickAdd  = '/tasks/quickadd';
  static const tasksBoard     = '/tasks/board';
  static const tasksUpcoming  = '/tasks/upcoming';
  static const tasksLabels    = '/tasks/labels';
  static const tasksFilters   = '/tasks/filters';
  static const tasksInbox     = '/tasks/inbox';
  static const tasksSchedule  = '/tasks/schedule';
  static const tasksTimetrack = '/tasks/timetrack';
  static const tasksAnalytics = '/tasks/analytics';
  static const tasksPanelComp = '/tasks/panel-comp';
  static const tasksRecurring = '/tasks/recurring';
  static const tasksLists    = '/tasks/lists';

  // Habits sub-screens
  static const habitsAddHabit    = '/habits/addhabit';
  static const habitsDetail      = '/habits/habitdetail';
  static const habitsStats       = '/habits/habitstats';
  static const habitsAchievements = '/habits/achievements';
  static const habitsAddSlot     = '/habits/addslot';

  // Calendar sub-screens
  static const calGmail     = '/cal/gmailsync';
  static const calSync      = '/cal/calsync';
  static const calConflicts = '/cal/conflicts';
  static const calAddSlot   = '/cal/addslot';

  // Notes sub-screens
  static const notesEditor  = '/notes/noteeditor';

  // Onboarding (always public)
  static const quote    = '/quote';
  static const signin   = '/signin';
  static const signup   = '/signup';
  static const onboard  = '/onboard';
  static const agegate  = '/agegate';

  // Search tab
  static const search = '/search';

  // Settings tab + sub-screens
  static const settings     = '/settings';
  static const activityLogs = '/settings/activitylogs';
  static const studentMode  = '/settings/studentmode';
  static const notifCenter  = '/settings/notifcenter';
  static const widget       = '/settings/widget';

  // Profile tab + sub-screens
  static const profile      = '/profile';
  static const profileEdit  = '/profile/edit';
  static const referral     = '/profile/referral';
  static const weeklyReview = '/profile/weeklyreview';

  // Root-level modals (accessible from any tab via root navigator)
  static const paywall = '/paywall';
  static const legal   = '/legal';
}
