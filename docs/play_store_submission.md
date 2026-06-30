# Kaal — Google Play submission pack

Single source of truth for every Play Console field. Copy/paste each value into the
matching console screen. Generated assets live in `/playstore`.

- **Package:** `com.port443.kaal`
- **Developer:** Port443 LLC
- **Supabase ref:** `dutlcoxtxmnqektttffg`
- **Subscription IDs:** `kaal_pro_monthly`, `kaal_pro_annual`

---

## 3. Store listing

### Identity (Main store listing)
| Field | Value |
|---|---|
| App name | `Kaal — Focus & Task Planner` |
| Developer name | `Port443 LLC` |
| Category | Productivity |
| Email | `r@jumbarthi.com` |
| Privacy policy | `https://jumbarthi.com/kaal/privacy` |
| Support URL | `https://jumbarthi.com/kaal/support` |
| Delete-account URL | `https://jumbarthi.com/kaal/delete` |

### Short description (≤80 chars)
```
Plan, focus & execute with Covey's 4 quadrants — tasks, habits, goals & AI.
```

### Full description
```
Kaal is an Execution OS for high performers. It organizes everything you do into Covey's
four quadrants — Do Now, Schedule, Delegate, Eliminate — so your time goes to what matters.

• Tasks with smart quadrant sorting & Eisenhower prioritization
• Habits with streaks, routines and a 30-day view
• Goals linked to the tasks and habits that move them
• Calendar with conflict detection + Gmail/Calendar sync
• Notes with tags, links and AI summaries
• Brain Dump — empty your head, AI sorts it into tasks & goals
• Pomodoro, time tracking, end-of-day reflection, weekly reviews
• Home-screen widgets, glass themes, 18 languages

Bring your own OpenAI or Claude key, or go Pro for unlimited AI. Your data syncs securely
across devices. Kaal is a product of Port443 LLC.
```

### Graphic assets
| Asset | Spec | Status |
|---|---|---|
| App icon | 512×512 PNG | ✅ `playstore/icon_512.png` (generated) |
| Feature graphic | 1024×500 PNG | ✅ `playstore/feature_graphic_1024x500.png` (generated) |
| Phone screenshots | ≥2, ≥1080×1920 | ⏳ generate via harness (below) |

**Generate screenshots:**
```bash
flutter test integration_test/screenshots_test.dart -d windows \
  --dart-define=SHOT_DIR=C:/Users/imrj0/Projects/kaal_app/playstore/screenshots
```
Pick & upload: `10_focus`, `2g_tasks_quad_q1`, `30_habits`, `40_calendar`, `60_notes`, `a0_paywall`.
(Play requires ≥1080px on the shortest side; crop to a 9:16 phone frame.)

---

## 4. Subscriptions (Monetize → Products → Subscriptions)

Create **two** subscriptions. Play bills in local currency; set the per-country prices to the
USD tiers below (Play converts, then you fine-tune). Tiers come from `lib/config/pricing.dart`.

### Product A — `kaal_pro_monthly`
- Base plan id: `monthly` · Billing period **P1M** · Auto-renewing
- Intro offer (new subscribers): **first month** at intro price, then standard monthly

### Product B — `kaal_pro_annual`
- Base plan id: `annual` · Billing period **P1Y** · Auto-renewing (≈40% off monthly)
- Optional intro/free-trial offer

### Price matrix (USD — set on each base plan)
| Tier | Countries | Monthly | Annual (total / per-mo) | Monthly intro (1st month) |
|---|---|---|---|---|
| **1** High-income | US, CA, GB, IE, AU, NZ, DE, FR, NL, BE, LU, AT, CH, LI, SE, NO, DK, FI, IS, IT, ES, PT, MT, CY, JP, SG, HK, KR, TW, AE, QA, KW, BH, SA, IL | **$2.99** | **$21.48** ($1.79/mo) | **$1.99** |
| **2** Middle-income | CN, BR, MX, RU, AR, CL, CO, PE, UY, CR, PA, PL, CZ, HU, RO, GR, SK, SI, HR, RS, BG, LT, LV, EE, UA, TR, TH, MY, ID, PH, VN, ZA, EG, MA, KZ, OM, JO, LB | **$1.99** | **$14.28** ($1.19/mo) | **$0.99** |
| **3** Everywhere else (incl. **India**, South Asia, most of Africa) | all others | **$0.99** | **$7.08** ($0.59/mo) | **$0.00** (free first month) |

> Tip: set the Tier-1 price as the default, then override Tier-2 and Tier-3 country groups.
> Activate both products. The paywall's display copy auto-selects the tier from device region;
> actual charge = the Play price you set here.

### India / UPI note
Play's checkout already offers UPI in India inside the in-app purchase — no separate SDK.
The Razorpay link (`razorpay.me/@Kaal_App`) is the *web* fallback only; it can't auto-grant Pro
yet (generic link has no `user_id`), so keep Play IAP as the primary path on Android.

---

## 5. App content / compliance forms

### a. Permission declarations (App content → Sensitive permissions)
| Permission | Console section | Justification (paste) |
|---|---|---|
| `SCHEDULE_EXACT_ALARM` | Alarms & reminders | `Kaal schedules user-created task & habit reminders/alarms that must trigger at the exact set time.` |
| `USE_FULL_SCREEN_INTENT` | Full-screen intent | `Used for time-critical task/habit alarm notifications the user explicitly sets.` |
| `RECEIVE_BOOT_COMPLETED` | — | Standard, no form (re-arms reminders after reboot) |
| `POST_NOTIFICATIONS` | — | Runtime-requested, no form |

### b. Data Safety
**Collected & linked to the user:**
| Data type | Collected | Linked | Purpose |
|---|---|---|---|
| Email address | Yes | Yes | Account management, app functionality |
| User content (tasks, notes, habits, goals, calendar) | Yes | Yes | App functionality (Supabase sync) |
| Purchase history | Yes | Yes | Subscription management |
| App usage / analytics (PostHog) | Yes | **No** (anonymous id) | Analytics — opt-out in Settings → Privacy |
| Device / advertising ID (AdMob) | Yes | **No** | Advertising (free plan only; Pro is ad-free) |

- **Data sold:** No
- **Encrypted in transit:** Yes
- **Account deletion available:** Yes → `https://jumbarthi.com/kaal/delete`
- ⚠️ **Disclose:** note/task text is sent to the AI provider (Anthropic/OpenAI, or the user's
  own key) when AI features are used.

### c. Content rating (IARC questionnaire)
Category: **Reference, News, or Educational / Productivity**. Answer **No** to every content
question (no violence, sexuality, profanity, gambling, controlled substances, user-to-user
location sharing). Digital purchases: **Yes** (subscriptions). → Expected result: **Everyone / PEGI 3**.

### d. Target audience & content
- Target age: **13+** (you have an in-app age gate). Not designed for children → No.

### e. App access (for review)
If sign-in is required to review: provide a test email, OR point reviewers to
**"Skip — use local storage"** on the sign-in screen (no account needed to evaluate the app).

### f. Ads
Contains ads: **Yes** — Google AdMob (interstitial + rewarded), shown to **free-plan users only**;
Kaal Pro is ad-free. Before release: set real AdMob app ID + ad unit IDs (see `lib/config/ads_config.dart`
and AndroidManifest `APPLICATION_ID`), flip `useTestAds = false`, and add a UMP consent flow for EU users.

### g. Government / financial / health: **No** to all.

---

## Release track
1. Upload `build/app/outputs/bundle/release/app-release.aab` → **Testing → Internal testing** first.
2. Add yourself as a **license tester** (Settings → License testing) so IAP is free to test.
3. Run device QA (§6 of `go_live.md`).
4. Promote Internal → Closed/Open (optional) → **Production**.
</content>
</invoke>
