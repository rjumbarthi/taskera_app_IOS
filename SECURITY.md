# Kaal — Security Hardening

Status of the security pass across Android / iOS / Windows / Web.

## ✅ Fixed in the app (this pass)

| Area | What changed | Files |
|---|---|---|
| **Secure token storage** | All 11 OAuth/AI token stores now use a shared hardened `FlutterSecureStorage`: Android **EncryptedSharedPreferences** (AES-256 via Keystore) + iOS keychain `first_unlock_this_device` (no iCloud sync). | `lib/services/secure_store.dart` + all `lib/services/*_service.dart` |
| **Sign-in / OTP throttling** | 45s cooldown on "Send / Resend OTP" (blocks email/SMS bombing + rate-limit hammering); link disables + counts down. | `lib/screens/onboarding/otp_cooldown.dart`, `signin_screen.dart`, `signup_screen.dart` |
| **Password strength** | Client-side rule enforced before signup: ≥8 chars **and** letters+numbers. | `signup_screen.dart` |
| **Input length caps** | Hard caps on titles (200), DB cells (2000), search (100), note body / capture / feedback (10000) — stops giant-paste DoS and sync-payload bloat. | `lib/util/input_limits.dart` + note editor, block editor, db editors, search, quick capture |
| **Android backup lockdown** | `allowBackup=false`, `fullBackupContent=false`, and Android-12+ `dataExtractionRules` excluding all data — blocks `adb backup` extraction of the local DB + session. | `AndroidManifest.xml`, `res/xml/data_extraction_rules.xml` |
| **OAuth return errors** | Web OAuth failures now surface in-app instead of failing silently (earlier pass). | `signin_screen.dart` |

## ✅ Verified already-safe (no change needed)

- **SQL injection:** none. Drift parameterizes everything; the only raw SQL is static `PRAGMA` literals. Search is in-memory Dart, not SQL.
- **Cleartext traffic:** disabled by default on Android target SDK; iOS ATS not weakened (no `NSAllowsArbitraryLoads`).
- **Token logging:** no tokens/passwords/emails are logged anywhere; the one debug log is `kDebugMode`-gated.
- **PKCE:** Supabase auth + Microsoft/Jira/Asana/Linear OAuth all use PKCE; Google is brokered through Supabase (no secret in app).
- **Exported components:** only LAUNCHER + appwidget are exported (required); notification receivers are `exported=false`.

## ⚠️ MUST DO — not fixable in app code

### 1. Row-Level Security (RLS) — highest priority
Without RLS policies, **any user's anon key can read/write everyone's data.** This is the #1 real risk for a Supabase app. In the Supabase dashboard → each synced table (`tasks`, `habits`, `goals`, `notes`, `calendar_events`, …) → **Enable RLS** and add policies like:
```sql
alter table public.tasks enable row level security;
create policy "own rows" on public.tasks
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
```
Repeat for every table that has a `user_id`.

### 2. OAuth client secrets must move to a backend (Critical)
`app_config.dart` holds `clientSecret` fields for **Notion, Todoist, Slack, GitHub**. A client secret in a shipped app **can be extracted from the APK/IPA** — the token exchange for these providers currently runs in the app (`*_service.dart`). Fix:
- Move each provider's token exchange to a **Supabase Edge Function** (server-side), like Google already does.
- Remove the secrets from `app_config.dart`.
- If any real secret was ever committed/shipped, **rotate it** in that provider's console.
(These are currently `YOUR_..._SECRET` placeholders, so nothing is leaked *yet* — fix before you fill them in.)

### 3. Supabase Auth settings (dashboard)
- **Rate limits / CAPTCHA** for password + OTP (the in-app cooldown is only a speed bump).
- **Leaked-password protection** (HaveIBeenPwned) → on.
- **Minimum password length** → ≥8 (match the client).
- **OTP expiry** → short (e.g. 10 min).

### 4. OAuth `state` (CSRF) — when you wire these integrations up
Notion and Microsoft send an OAuth `state` but don't yet validate it on callback (`notion_service.dart`, `microsoft_service.dart`). Store the generated `state` and compare on callback (Todoist/Slack/GitHub/Jira/Asana/Linear already do). Only relevant once those integrations are actually configured.

## Not implemented (lower priority / optional)
- Account-enumeration hardening (distinct "email exists" messages) — partly a Supabase Auth setting.
- Certificate pinning, jailbreak/root detection, `FLAG_SECURE` screenshot blocking — advanced, add if your threat model needs them.
