# TaskEra — Go-live checklist

Everything the **code** needs is done. These are the steps that require your accounts /
CLI (I can't run them for you). Payment specifics are in `payments_setup.md`.

---

## 1. Deploy the backend (Supabase CLI)
```bash
supabase link --project-ref dutlcoxtxmnqektttffg

# Edge functions
supabase functions deploy ai-proxy
supabase functions deploy razorpay-webhook --no-verify-jwt
supabase functions deploy validate-purchase

# Secrets
supabase secrets set ANTHROPIC_API_KEY=sk-ant-...
supabase secrets set OPENAI_API_KEY=sk-...
supabase secrets set RAZORPAY_WEBHOOK_SECRET=whsec_...
supabase secrets set APPLE_SHARED_SECRET=...
supabase secrets set GOOGLE_PLAY_SERVICE_ACCOUNT='{ ...service-account JSON... }'
supabase secrets set ANDROID_PACKAGE=com.port443.taskera
```
**Migrations** — run in the SQL editor in order (idempotent): `001_initial_schema.sql`,
`002_sync_labels_realtime.sql`, `003_notes_columns.sql`, `004_pro_entitlements.sql`.

---

## 3. Android permission declarations (Play Console → App content)
The manifest declares these — each needs a justification in the console:

| Permission | Why | Declaration text |
|---|---|---|
| `SCHEDULE_EXACT_ALARM` | Fire reminders/alarms at the exact user-set time | "TaskEra schedules user-created task & habit reminders/alarms that must trigger at an exact time." |
| `USE_FULL_SCREEN_INTENT` | Alarm-style full-screen reminder | "Used for time-critical task/habit alarm notifications the user explicitly sets." |
| `RECEIVE_BOOT_COMPLETED` | Re-arm scheduled reminders after reboot | (no form; standard) |
| `POST_NOTIFICATIONS` | Notifications | Requested at runtime; no declaration |

> Prefer to skip the exact-alarm review? I can switch reminders to **inexact** alarms (loses
> exact timing) — say the word.

---

## 4. Android receipt validation — **done in code**
Just set `GOOGLE_PLAY_SERVICE_ACCOUNT` + `ANDROID_PACKAGE` secrets (step 1). Create the service
account in Google Cloud → grant it **Financial data / View** access in Play Console.

---

## 5. Store listings

**Identity**
- Name: **TaskEra — Focus & Task Planner**
- Developer: **Port443 LLC** · Category: **Productivity** · Content rating: **13+** (age gate)
- Privacy policy URL: `https://jumbarthi.com/taskera/privacy`
- Support: `https://jumbarthi.com/taskera/support` · Delete account: `https://jumbarthi.com/taskera/delete`

**Short description** (Play, ≤80 chars)
> Plan, focus & execute with Covey's 4 quadrants — tasks, habits, goals & AI.

**Full description**
> TaskEra is an Execution OS for high performers. It organizes everything you do into Covey's
> four quadrants — Do Now, Schedule, Delegate, Eliminate — so your time goes to what matters.
>
> • Tasks with smart quadrant sorting & Eisenhower prioritization
> • Habits with streaks, routines and a 30-day view
> • Goals linked to the tasks and habits that move them
> • Calendar with conflict detection + Gmail/Calendar sync
> • Notes with tags, links and AI summaries
> • Brain Dump — empty your head, AI sorts it into tasks & goals
> • Pomodoro, time tracking, end-of-day reflection, weekly reviews
> • Home-screen widgets, glass themes, 18 languages
>
> Bring your own OpenAI or Claude key, or go Pro for unlimited AI. Your data syncs securely
> across devices. TaskEra is a product of Port443 LLC.

**Keywords** (App Store, ≤100 chars)
> productivity,tasks,todo,habits,focus,eisenhower,planner,goals,pomodoro,calendar,notes,ai

**Screenshots** — regenerate with the in-repo harness, then crop to store specs:
```bash
flutter test integration_test/screenshots_test.dart -d windows \
  --dart-define=SHOT_DIR=C:/Users/imrj0/Projects/taskera_app/screenshots
```
Pick: `10_focus`, `2g_tasks_quad_q1`, `30_habits`, `40_calendar`, `60_notes`, `a0_paywall`.
(Play phone ≥1080×1920; App Store 6.7" = 1290×2796.)

**Data Safety (Play) / Privacy nutrition labels (Apple)** — declare:
| Data | Collected? | Linked? | Purpose |
|---|---|---|---|
| Email | Yes (sign-in) | Linked | Account / app function |
| Tasks, notes, habits, calendar content | Yes (Supabase sync) | Linked | App function |
| Anonymous usage analytics (PostHog) | Yes | **Not** linked (anon id) | Analytics — opt-out in Settings → Privacy |
| Purchases | Yes | Linked | Subscription |
- **No data sold.** Encrypted in transit. Account deletion available in-app.
- ⚠️ Disclose that **note/task text is sent to your AI provider** (Anthropic/OpenAI, or the
  user's own key) for AI features.

---

## 6. Config + QA
**OAuth** — Supabase → Authentication → URL Configuration → Redirect URLs, add:
```
io.supabase.taskeraapp://login-callback
io.supabase.taskeraapp://reset-callback
```
**Email OTP** — put `{{ .Token }}` in the **Confirm signup** AND **Magic Link** email templates.

**Keys** — set `AppConfig.posthogApiKey` + `AppConfig.razorpayUpiLink`.

**Razorpay** — create the Payment Link (include `notes.user_id`), add the webhook URL + secret
(`payments_setup.md` §4).

**Device QA checklist** (can't be done on Windows):
- [ ] Sign up via email OTP code · sign in · skip-auth · sign out
- [ ] Google sign-in on a real Android device
- [ ] Create/edit task, habit, goal, note; go offline → online and confirm sync
- [ ] Reminders/alarms fire at the set time (+ after reboot)
- [ ] Paywall: subscribe (store sandbox), Restore, UPI link
- [ ] AI: connect OpenAI/Claude key → Brain Dump + insights work; a free user sees the upgrade prompt
- [ ] Pro unlocks live after a (sandbox) purchase / Razorpay webhook
