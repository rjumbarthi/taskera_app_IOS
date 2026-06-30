# Android launch — step by step

Project specifics used below:
- **Package:** `com.port443.kaal`
- **Supabase project ref:** `dutlcoxtxmnqektttffg`
- **Subscription IDs:** `kaal_pro_monthly`, `kaal_pro_annual`
- **Deep-link scheme:** `io.supabase.kaalapp`
- **Edge functions:** `ai-proxy`, `razorpay-webhook`, `validate-purchase`

**Do them in this order** (later steps depend on earlier ones):
1 → 4 (keys/config) → 2 (Play app + products) → 3 (declarations) → backend secrets that depend on Play (Google service account, Razorpay webhook) → 5 (QA).

---

## 1. Deploy the backend (Supabase)
**Prereqs**
- Install the Supabase CLI: `npm i -g supabase` (or `scoop install supabase`).
- `supabase login` (opens browser).

**Get the secret values first**
| Secret | Where |
|---|---|
| `ANTHROPIC_API_KEY` | console.anthropic.com → API Keys (only if you fund AI yourself; users with own keys don't need it) |
| `OPENAI_API_KEY` | platform.openai.com → API Keys (fallback / users w/o own key) |
| `RAZORPAY_WEBHOOK_SECRET` | you choose it when creating the webhook (step 4d) |
| `GOOGLE_PLAY_SERVICE_ACCOUNT` | created in step 2f |
| `ANDROID_PACKAGE` | `com.port443.kaal` |
| `APPLE_SHARED_SECRET` | iOS only — **skip for Android** |

**Run**
```bash
cd <repo>
# edit supabase/deploy.sh and replace the REPLACE_ME values, then:
bash supabase/deploy.sh
```
This deploys the 3 functions and sets secrets. (You can re-run `supabase secrets set GOOGLE_PLAY_SERVICE_ACCOUNT='{...}'` later once you have it.)

**Migrations** — Supabase dashboard → SQL Editor → run each, in order:
`001_initial_schema.sql`, `002_sync_labels_realtime.sql`, `003_notes_columns.sql`, `004_pro_entitlements.sql`.
(All idempotent — safe to re-run. Each should say "Success.")

---

## 4. Config + keys (do early — needed for a working build)
**a. Supabase → Authentication → URL Configuration → Redirect URLs** — add:
```
io.supabase.kaalapp://login-callback
io.supabase.kaalapp://reset-callback
```
**b. Email-OTP templates** — Authentication → Emails → Templates → paste the bodies from
`supabase/templates/magic_link.html` **and** `confirm_signup.html` (both use `{{ .Token }}` so users get a 6-digit code, not a link).

**c. Google sign-in** — Authentication → Providers → Google: enable; the **web** client ID + secret should already be set. In Google Cloud Console → your OAuth client → Authorized redirect URIs, ensure `https://dutlcoxtxmnqektttffg.supabase.co/auth/v1/callback` is listed. (Android uses the browser flow, so no Android OAuth client is required.)

**d. PostHog** (optional analytics) — create a project at app.posthog.com, copy the Project API key (`phc_…`), set `AppConfig.posthogApiKey` + pick US/EU host.

**e. Razorpay** (optional UPI) — create a Payment Link (or `razorpay.me/@handle`); set `AppConfig.razorpayUpiLink`. When you create it, include `notes.user_id`. Then Razorpay Dashboard → Settings → Webhooks → add your `razorpay-webhook` function URL, pick a secret (= `RAZORPAY_WEBHOOK_SECRET`), subscribe to `payment.captured` + `subscription.*`.

> After editing `AppConfig`, rebuild the AAB.

---

## 2. Google Play Console
**a.** Create a Google Play Developer account ($25 one-time) → play.google.com/console.
**b.** Create app: name **Kaal**, default language, type **App**, **Free** (with in-app purchases), accept declarations.
**c.** Build the bundle:
```bash
flutter build appbundle --release
```
Upload `build/app/outputs/bundle/release/app-release.aab` to **Testing → Internal testing** first (faster review, lets you test IAP).
**d.** **Store listing** — use the copy in `go_live.md §5` (name, short/full description). Add: app icon (512×512), feature graphic (1024×500), ≥2 phone screenshots (≥1080×1920 — regenerate with the screenshot harness, see `go_live.md §5`).
**e.** **Content rating** questionnaire → results in **13+** (you have an age gate). **Target audience** → 13+. **Data Safety** form → fill from the table in `go_live.md §5`. **Privacy policy** URL: `https://jumbarthi.com/kaal/privacy`. **App access:** if review needs to log in, provide a test account or note the "Skip — use local storage" option.
**f.** **Subscriptions** — Monetize → Products → Subscriptions:
   - Create **`kaal_pro_monthly`** → base plan "monthly" (auto-renewing, P1M). Set prices per country to match the tiers (US $2.99, … India $0.99). Add an **intro offer** = first month $1.99 (tier 1) etc.
   - Create **`kaal_pro_annual`** → base plan "annual" (P1Y) at the 40%-off yearly price; add the free-trial/intro offer.
   - Activate both.
**g.** **Service account for receipt validation** — Google Cloud Console → create a service account → enable **Google Play Android Developer API**. In Play Console → Users & permissions → invite the service-account email → grant **View financial data, orders, and cancellation survey responses**. Download the JSON key → `supabase secrets set GOOGLE_PLAY_SERVICE_ACCOUNT='{...}'`.

---

## 3. Permission declarations (Play Console → App content)
Your manifest uses two sensitive permissions — declare each with the justification:
| Permission | Console section | Justification |
|---|---|---|
| `SCHEDULE_EXACT_ALARM` | "Alarms & reminders" | "Kaal schedules user-created task & habit reminders/alarms that must trigger at the exact set time." |
| `USE_FULL_SCREEN_INTENT` | "Full-screen intent" | "Used for time-critical task/habit alarm notifications the user explicitly sets." |

(If review pushes back, the fallback is switching to inexact alarms — ask and I'll change the code.)

---

## 5. Device QA (real Android phone, via Internal testing)
1. Add yourself as a **license tester** (Play Console → Settings → License testing) so IAP is free in test.
2. Install the build from the Internal testing link on a real device.
3. Run the checklist:
   - [ ] Email sign-in → receive a **6-digit code** (not a link) → verify
   - [ ] Google sign-in completes
   - [ ] Skip — use local storage works
   - [ ] Create/edit task, habit, goal, note → kill app → reopen → data persists; sign in on a 2nd device → syncs
   - [ ] Set a reminder → it fires at the time → reboot → still fires
   - [ ] Paywall → subscribe (test card) → **Pro unlocks**, AI insight cards switch from "Upgrade" to real output
   - [ ] Restore purchase works
   - [ ] Connect your own OpenAI/Claude key → Brain Dump + insights generate
   - [ ] A free account (no key) sees the upgrade prompt on AI surfaces
4. When green: promote Internal → **Closed/Open testing** (optional) → **Production**.

---

### Minimum for a *functional* Android submission
Backend deployed + migrations (1) → config/keys + email templates (4) → Play app + listing + the 2 subscription products + Data Safety + content rating (2) → permission declarations (3) → QA on a device (5). The Google service account (2g) and Razorpay (4e) can follow shortly after if you launch AI on your own keys first.
