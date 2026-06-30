// All configuration constants — fill these in after running through SETUP.md.
// NEVER commit real API keys to git. Add this file to .gitignore or use
// `flutter run --dart-define=SUPABASE_URL=...` to inject at build time.
class AppConfig {
  AppConfig._();

  // ── Supabase ─────────────────────────────────────────────────────────────
  // Dashboard → Project Settings → API
  static const supabaseUrl     = 'https://dutlcoxtxmnqektttffg.supabase.co';
  static const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImR1dGxjb3h0eG1ucWVrdHR0ZmZnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODAyMTk2MzcsImV4cCI6MjA5NTc5NTYzN30.zWEkDSfSH8IS8IuhTx7f3bzoRkwo9FnILvOk2aGmxoM';

  // ── PostHog product analytics ─────────────────────────────────────────────
  // app.posthog.com → Project Settings → Project API Key (starts with `phc_`).
  // This is a write-only client key — safe to ship, like the Supabase anon key.
  // Host: https://us.i.posthog.com (US cloud) or https://eu.i.posthog.com (EU).
  // Until a real key is set, analytics is a silent no-op.
  static const posthogApiKey = 'YOUR_POSTHOG_PROJECT_API_KEY';
  static const posthogHost   = 'https://us.i.posthog.com';

  // ── Payments ──────────────────────────────────────────────────────────────
  // Subscription product IDs — create these in Play Console + App Store Connect
  // (use the SAME id on both stores). UPI/cards appear inside Play's checkout in
  // India automatically — no separate UPI SDK is used for the in-app purchase.
  static const proMonthlyProductId = 'kaal_pro_monthly';
  static const proAnnualProductId  = 'kaal_pro_annual';

  // Razorpay payment LINK (razorpay.me/... or a generated Payment Link). Opened
  // in an external browser for a UPI checkout on your website — kept OUTSIDE the
  // in-app purchase flow to stay within Play/Apple policy. Empty = not set up.
  static const razorpayUpiLink = '';

  // ── Google OAuth ──────────────────────────────────────────────────────────
  // Cloud Console → APIs & Services → Credentials → OAuth 2.0 Client IDs
  // Create one client per platform type (Web, Android, iOS).
  static const googleClientIdWeb     = '657874499735-qmbr8p3uhi0kppu4q0vg4a99cs7c19n9.apps.googleusercontent.com';
  static const googleClientIdIos     = 'YOUR_IOS_CLIENT_ID.apps.googleusercontent.com';
  static const googleClientIdAndroid = '657874499735-3qf3r8malkpfduv72gmqjhncvfudhaq9.apps.googleusercontent.com';

  // ── Azure / Microsoft ─────────────────────────────────────────────────────
  // portal.azure.com → App Registrations → New Registration
  static const azureClientId       = 'YOUR_AZURE_APP_CLIENT_ID';
  static const azureTenantId       = 'common'; // or your specific tenant
  static const microsoftRedirectUri = 'kaalapp://microsoft-auth';

  // ── Deep-link scheme ──────────────────────────────────────────────────────
  // Must match the scheme registered in AndroidManifest.xml and Info.plist.
  // Also set as the redirect URL in Supabase Dashboard → Auth → URL Configuration.
  static const deepLinkScheme = 'io.supabase.kaalapp';

  // Notion — notion.so/my-integrations → New integration → OAuth 2.0
  static const notionClientId     = 'YOUR_NOTION_CLIENT_ID';
  static const notionClientSecret = 'YOUR_NOTION_CLIENT_SECRET';

  // Todoist — todoist.com/app_console → New app; redirect: kaalapp://todoist-auth
  static const todoistClientId     = 'YOUR_TODOIST_CLIENT_ID';
  static const todoistClientSecret = 'YOUR_TODOIST_CLIENT_SECRET';

  // Slack — api.slack.com/apps → Create app; redirect: kaalapp://slack-auth
  static const slackClientId     = 'YOUR_SLACK_CLIENT_ID';
  static const slackClientSecret = 'YOUR_SLACK_CLIENT_SECRET';

  // Jira — developer.atlassian.com → OAuth 2.0 (3LO); redirect: kaalapp://jira-auth
  static const jiraClientId = 'YOUR_ATLASSIAN_CLIENT_ID';

  // Asana — app.asana.com/-/developer_console → New app; redirect: kaalapp://asana-auth
  static const asanaClientId = 'YOUR_ASANA_CLIENT_ID';

  // Linear — linear.app/settings/api → New OAuth app; redirect: kaalapp://linear-auth
  static const linearClientId = 'YOUR_LINEAR_CLIENT_ID';

  // GitHub — github.com/settings/applications/new; redirect: kaalapp://github-auth
  static const githubClientId     = 'YOUR_GITHUB_CLIENT_ID';
  static const githubClientSecret = 'YOUR_GITHUB_CLIENT_SECRET';
}
