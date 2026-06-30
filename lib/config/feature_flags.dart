/// App-wide feature flags for staged rollout.
///
/// Flip a flag and rebuild to enable/disable a feature across every surface
/// that gates on it — no other code changes required.
library;

/// Gmail inbox sync.
///
/// The Gmail feature uses the **restricted** `gmail.readonly` OAuth scope, which
/// requires Google OAuth app verification *plus* an annual CASA security
/// assessment before it can ship in a production (non-Testing) app. That work is
/// deferred to a later release, so Gmail is surfaced as "Coming soon" for now.
///
/// The full implementation stays in place (`GoogleService`, inbox parsing,
/// `GmailSyncScreen`) — set this to `true` once verification + CASA clear to
/// re-enable every Gmail entry point at once.
///
/// Intentionally a non-`const` `final`: a `const false` would make the analyzer
/// report the now-unreachable Gmail branches as `dead_code`. This keeps it a
/// single-line switch without tripping lints.
final bool kGmailSyncEnabled = false;

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
