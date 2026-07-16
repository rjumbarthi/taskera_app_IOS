/// App-wide feature flags for staged rollout.
///
/// Flip a flag and rebuild to enable/disable a feature across every surface
/// that gates on it — no other code changes required.
library;

// Gmail & Google Calendar are now controlled by REMOTE flags in Supabase
// (`app_flags` table) — see `data/providers/feature_flags_provider.dart` and
// `FEATURE_FLAGS_SETUP.md`. This lets them be turned on/off without a new build
// (e.g. flip Gmail on the moment OAuth verification + CASA clear). Both default
// to OFF (fail-closed) so an un-verified scope is never exposed in production.

/// Seed starter/demo content on first launch (default lists like "Grocery
/// Shopping", plus sample tasks, habits, goals, notes, calendar events).
///
/// **Keep this `false` for production / Play Store builds** so every new user
/// starts with a completely empty app. Set it to `true` for development or
/// screenshots when you want the app pre-populated.
///
/// Note: this only affects *fresh* installs. A device that was already seeded
/// keeps its existing data; to test the empty state, reinstall or clear app data.
final bool kSeedDemoData = false;
