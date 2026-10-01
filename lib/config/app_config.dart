// All configuration constants — fill these in after running through SETUP.md.
// NEVER commit real API keys to git. Add this file to .gitignore or use
// `flutter run --dart-define=SUPABASE_URL=...` to inject at build time.
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class AppConfig {
  AppConfig._();

  // ── Supabase ─────────────────────────────────────────────────────────────
  // TaskEra shares Kaal's Supabase project (free-tier cap of 2 projects per
  // org, hit on 2026-09-23 — a separate project wasn't available) but is
  // fully isolated under its own `taskera` Postgres schema, own RLS
  // policies, and its own auth.users trigger — decided + set up 2026-10-01.
  // auth.users IS shared across both apps (one Supabase Auth per project):
  // the same email signing into Kaal and TaskEra is the same account, but
  // each app's data (tasks/habits/goals/etc.) lives only in its own schema.
  // See supabase/migrations/taskera_schema.sql for the full setup.
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
  // Subscription product IDs. Intended to be the SAME id on both stores, but
  // the iOS App Store Connect subscriptions were created as
  // com.port443.taskera.pro.monthly/.annual instead of taskera_pro_monthly/annual —
  // and Apple product IDs can never be edited once created — so iOS gets its
  // own constants here while Android keeps the original plain ids. UPI/cards
  // appear inside Play's checkout in India automatically — no separate UPI
  // SDK is used for the in-app purchase.
  static const _proMonthlyProductIdAndroid = 'taskera_pro_monthly';
  static const _proAnnualProductIdAndroid  = 'taskera_pro_annual';
  static const proMonthlyProductIdIOS = 'com.port443.taskera.pro.monthly';
  static const proAnnualProductIdIOS  = 'com.port443.taskera.pro.annual';

  static String get proMonthlyProductId =>
      (!kIsWeb && Platform.isIOS) ? proMonthlyProductIdIOS : _proMonthlyProductIdAndroid;
  static String get proAnnualProductId =>
      (!kIsWeb && Platform.isIOS) ? proAnnualProductIdIOS : _proAnnualProductIdAndroid;

  // Razorpay payment LINK (razorpay.me/... or a generated Payment Link). Opened
  // in an external browser for a UPI checkout on your website — kept OUTSIDE the
  // in-app purchase flow to stay within Play/Apple policy. Empty = not set up.
  static const razorpayUpiLink = 'https://razorpay.me/@TaskEra_App';

  // ── Google OAuth ──────────────────────────────────────────────────────────
  // These were Kaal's own client IDs, registered to com.port443.kaal — won't
  // work for TaskEra's own bundle id. Register new ones for
  // com.port443.taskera before shipping.
  // Cloud Console → APIs & Services → Credentials → OAuth 2.0 Client IDs
  // Create one client per platform type (Web, Android, iOS).
  static const googleClientIdWeb     = 'YOUR_WEB_CLIENT_ID.apps.googleusercontent.com';
  static const googleClientIdIos     = 'YOUR_IOS_CLIENT_ID.apps.googleusercontent.com';
  static const googleClientIdAndroid = 'YOUR_ANDROID_CLIENT_ID.apps.googleusercontent.com';

  // ── Azure / Microsoft ─────────────────────────────────────────────────────
  // portal.azure.com → App Registrations → New Registration
  static const azureClientId       = 'YOUR_AZURE_APP_CLIENT_ID';
  static const azureTenantId       = 'common'; // or your specific tenant
  static const microsoftRedirectUri = 'taskeraapp://microsoft-auth';

  // ── Deep-link scheme ──────────────────────────────────────────────────────
  // Must match the scheme registered in AndroidManifest.xml and Info.plist.
  // Also set as the redirect URL in Supabase Dashboard → Auth → URL Configuration.
  static const deepLinkScheme = 'io.supabase.taskeraapp';

  // Notion — notion.so/my-integrations → New integration → OAuth 2.0
  static const notionClientId     = 'YOUR_NOTION_CLIENT_ID';
  static const notionClientSecret = 'YOUR_NOTION_CLIENT_SECRET';

  // Todoist — todoist.com/app_console → New app; redirect: taskeraapp://todoist-auth
  static const todoistClientId     = 'YOUR_TODOIST_CLIENT_ID';
  static const todoistClientSecret = 'YOUR_TODOIST_CLIENT_SECRET';

  // Slack — api.slack.com/apps → Create app; redirect: taskeraapp://slack-auth
  static const slackClientId     = 'YOUR_SLACK_CLIENT_ID';
  static const slackClientSecret = 'YOUR_SLACK_CLIENT_SECRET';

  // Jira — developer.atlassian.com → OAuth 2.0 (3LO); redirect: taskeraapp://jira-auth
  static const jiraClientId = 'YOUR_ATLASSIAN_CLIENT_ID';

  // Asana — app.asana.com/-/developer_console → New app; redirect: taskeraapp://asana-auth
  static const asanaClientId = 'YOUR_ASANA_CLIENT_ID';

  // Linear — linear.app/settings/api → New OAuth app; redirect: taskeraapp://linear-auth
  static const linearClientId = 'YOUR_LINEAR_CLIENT_ID';

  // GitHub — github.com/settings/applications/new; redirect: taskeraapp://github-auth
  static const githubClientId     = 'YOUR_GITHUB_CLIENT_ID';
  static const githubClientSecret = 'YOUR_GITHUB_CLIENT_SECRET';
}
