# Kaal — App Store & Play Store submission checklist

App facts (reuse everywhere):
- **App name:** Kaal — Focus & Task Planner
- **Android package:** `com.kaal.kaal_app` · **min SDK 28**
- **Support email:** r.official@jumbarthi.com · **Address:** Hyderabad, India
- **URLs:** Privacy `https://jumbarthi.com/kaal/privacy` · Terms `…/terms` · Support `…/support` · Account/Data deletion `…/delete`
- **Auth:** email/OTP + Google, Apple, Microsoft (or skip → local-only) · backend Supabase
- **Sensitive bits:** notifications, exact alarms + full-screen alarm, Google Calendar (read-only), Kaal Pro subscription. Gmail sync & photo upload are **disabled ("coming soon")**.

---

## Shared assets to prepare
- [ ] App icon (512×512 PNG for Play, 1024×1024 for Apple)
- [ ] Feature graphic 1024×500 (Play)
- [ ] Screenshots: phone (≥2), 7"/10" tablet (Play), 6.7" + 6.5" iPhone, 12.9" iPad (Apple)
- [ ] Short description (≤80 chars) + full description (≤4000)
- [ ] Promo/marketing copy, keywords (Apple)
- [ ] Category: **Productivity**
- [ ] Content rating: everyone / 4+ (no mature content)
- [ ] Signed release **AAB** (Play) and **IPA** (Apple, via Xcode/Transporter)

---

## Google Play Console

**Store listing & setup**
- [ ] Store listing (name, descriptions, graphics, category Productivity)
- [ ] Contact details: email r.official@jumbarthi.com, website jumbarthi.com/kaal
- [ ] **Privacy policy URL** → `https://jumbarthi.com/kaal/privacy`

**App content (Policy → App content)**
- [ ] **App access:** app is usable without an account (Skip → local storage). Provide reviewers a test account anyway, or note "no login required — tap Skip on sign-in."
- [ ] **Ads:** declare **No ads**.
- [ ] **Content rating** questionnaire → submit (productivity, no UGC sharing).
- [ ] **Target audience & content:** 13+ (matches Terms "13+"). Not designed for children.
- [ ] **Data safety** form (see section below).
- [ ] **Government / financial / health apps:** No.
- [ ] **News app:** No. **COVID/contact-tracing:** No.

**Sensitive / declared permissions** ⚠️ (these can trigger review)
- [ ] **Account deletion URL** (App content → Data deletion) → `https://jumbarthi.com/kaal/delete` *(required — Play Data Deletion policy)*
- [ ] **Exact alarm** (`SCHEDULE_EXACT_ALARM`): used for reminders/alarms. Be ready to justify in the alarm/permissions declaration; it's user-grantable so usually OK.
- [ ] **Full-screen intent** (`USE_FULL_SCREEN_INTENT`, Android 14+): justify in the declaration as "user-set full-screen alarms." ⚠️ A task planner *may* get pushback — if so, fall back to non-full-screen alarms (heads-up + sound).
- [ ] **`RECEIVE_BOOT_COMPLETED`** — declared for re-arming alarms after reboot (fine).
- [ ] **No** foreground-service, location, SMS, call-log, or "all files" permissions (confirm none crept in).

**Google OAuth (because of Google Calendar)**
- [ ] Google Calendar uses a **sensitive** scope (`calendar.readonly`). Complete **OAuth consent screen** setup + verification in Google Cloud Console (logo, app domain jumbarthi.com, privacy/terms links, scopes justification). *(No CASA needed — that's only for the disabled Gmail `gmail.readonly` restricted scope.)*
- [ ] OAuth consent links must point to the live privacy/terms URLs (now live ✅).

**Monetization**
- [ ] Create **Kaal Pro** subscription(s) (monthly/annual) in Play Console → Subscriptions; wire base plans/offers; matches in-app paywall.

**Release**
- [ ] Upload signed **AAB**, set release notes.
- [ ] Internal testing track first → fix any **Pre-launch report** crashes → Production.

---

## Apple App Store Connect

**App information**
- [ ] Privacy Policy URL → `https://jumbarthi.com/kaal/privacy`
- [ ] Support URL → `https://jumbarthi.com/kaal/support`
- [ ] Category: Productivity · Age rating questionnaire

**App Privacy (nutrition labels)** — see data section below
- [ ] Fill "Data Types" collected + linkage + tracking (Kaal does **no tracking**, **no ads**)

**Guideline gotchas** ⚠️
- [ ] **Account deletion (4.8 / 5.1.1(v)):** in-app deletion is **required** and must be easy to find → confirm **Profile → Edit profile → Delete account** works. (Web page `…/delete` is a bonus, not a substitute.)
- [ ] **Sign in with Apple (4.8):** because you offer Google/Microsoft sign-in, you **must** also offer **Sign in with Apple** — it's already in the sign-in screen ✅ (verify it's functional on iOS).
- [ ] **Subscriptions (3.1):** use StoreKit/In-App Purchase only (no external payment links). Your "Cancel in App Store/Play Store" copy is correct. Set up subscription group + localized terms.
- [ ] **Web links:** Support/Delete links open in browser — fine.

**Technical**
- [ ] `Info.plist` usage strings present where needed (notifications don't need one; **no** camera/photo strings since photo upload is disabled — confirm no stray `NSPhotoLibraryUsageDescription` claims).
- [ ] **Export compliance:** uses only standard HTTPS/TLS encryption → set `ITSAppUsesNonExemptEncryption = NO` (or answer "No" in App Store Connect).
- [ ] Background modes: remote/local notifications enabled as needed.

**App Review notes**
- [ ] Demo account OR note: "No login required — tap **Skip — use local storage** on the sign-in screen."
- [ ] Note that **Gmail sync** and **photo upload** are intentionally shown as "coming soon" (not functional yet).

---

## Data Safety (Play) / App Privacy (Apple) — answers for Kaal

Kaal works **fully offline with no account**; the below applies **only when the user signs in** (sync).

| Data type | Collected? | Purpose | Shared? | Notes |
|---|---|---|---|---|
| Email address | Yes (if signed in) | Account, auth | No (only service provider Supabase) | |
| Name (display name) | Yes (if signed in) | Account/profile | No | |
| App activity / user content (tasks, habits, goals, notes, calendar entries, focus history) | Yes (if signed in, for sync) | App functionality (cross-device sync) | No | Never used for ads |
| Calendar (Google, read-only) | Read to display only | App functionality | No | Not stored/sold; Limited Use |
| Device/other IDs | Only as needed for auth/sync | Functionality | No | |
| Crash logs / diagnostics | If applicable | App stability | No | Aggregated/anonymized |
| Financial / payment info | **No** | — | — | Handled by App Store / Google Play |
| Location, contacts, photos, messages, health | **No** | — | — | |

Cross-cutting answers:
- [ ] **Data encrypted in transit:** Yes (TLS).
- [ ] **Data encrypted at rest:** Yes (Supabase / device).
- [ ] **Users can request deletion:** Yes → `https://jumbarthi.com/kaal/delete` and in-app.
- [ ] **Selling data:** No. **Sharing with third parties:** Only processors (cloud hosting/auth) under contract.
- [ ] **Tracking (Apple ATT):** No tracking → no ATT prompt required.
- [ ] **Ads:** None.

---

## Final pre-submit smoke test
- [ ] Live URLs all return 200 over HTTPS (privacy/terms/support/delete) ✅
- [ ] In-app: Settings → About & Legal shows Terms, Privacy, Support, Account & data deletion
- [ ] In-app: Profile → Edit profile → Delete account works
- [ ] Sign-in: email/OTP, Google, **Apple** (iOS), Skip-to-local all work
- [ ] Subscription paywall purchase + restore flow
- [ ] Notifications/reminders/alarms fire on a real device (esp. exact-alarm + full-screen)
