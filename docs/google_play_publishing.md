# TaskEra — Google Play publishing guide

The end-to-end path from your machine to the Play Store. Field-by-field values
(listing copy, prices, Data Safety answers) live in **`play_store_submission.md`** —
this doc is the *process*. Do the steps in order.

- **Package:** `com.port443.taskera`
- **Subscriptions:** `taskera_pro_monthly`, `taskera_pro_annual`
- **Supabase ref:** `dutlcoxtxmnqektttffg`

---

## 0. Pre-flight (do before building)

- [ ] **App starts empty.** `kSeedDemoData = false` in `lib/config/feature_flags.dart`
      (already set). New users get a blank app. ✅
- [ ] **Real AdMob IDs.** In `lib/config/ads_config.dart` set `useTestAds = false` and
      fill the `_prod*` ad-unit IDs; put your real AdMob **app ID** in
      `android/app/src/main/AndroidManifest.xml` (`com.google.android.gms.ads.APPLICATION_ID`).
      *(Leave test IDs only if you intend to ship without live ads at first.)*
- [ ] **Version.** Bump `version:` in `pubspec.yaml` for each upload — format
      `x.y.z+BUILD`. The `+BUILD` (versionCode) **must increase every upload**
      (e.g. `1.0.0+1` → `1.0.1+2`).
- [ ] **Keystore present.** `android/key.properties` + `android/app/taskera-release.jks`
      exist (gitignored). Keep a secure backup — losing the keystore means you can
      never update the app.
- [ ] **Backend live.** Functions deployed, secrets set, migrations run, OTP
      templates + redirect URLs done. (See `go_live.md`.) Deploy the new function:
      `supabase functions deploy delete-account`.

---

## 1. Build the signed AAB

```bash
flutter clean
flutter pub get
flutter build appbundle --release
```
Output: **`build/app/outputs/bundle/release/app-release.aab`**.

> If the build falls back to debug signing, `key.properties` isn't being found —
> confirm it sits in `android/` and points at the `.jks`.

Sanity-check the empty state first by installing the release build on a device:
```bash
flutter install --release      # app should open with NO tasks/habits/notes
```

---

## 2. Create the app in Play Console

1. **play.google.com/console** → pay the one-time **$25** registration (if new).
2. **Create app** → Name **TaskEra**, language English, type **App**, **Free**,
   accept the declarations.
3. Note: you'll upload to **Internal testing** first (fast review, lets you test
   subscriptions + ads on a real device before public release).

---

## 3. Store listing  *(values: `play_store_submission.md §3`)*

- **App name**, **short description** (≤80), **full description**.
- **Graphics** (in `/playstore`):
  - App icon **512×512** → `playstore/icon_512.png`
  - Feature graphic **1024×500** → `playstore/feature_graphic_1024x500.png`
  - **≥2 phone screenshots** (≥1080×1920) → pick from `/screenshots` (e.g.
    `10_focus`, `2g_tasks_quad_q1`, `30_habits`, `40_calendar`, `60_notes`, `a0_paywall`),
    crop to a 9:16 frame.
- Category **Productivity**; contact email; privacy policy
  `https://jumbarthi.com/taskera/privacy`.

---

## 4. Subscriptions  *(values: `play_store_submission.md §4`)*

Monetize → Products → **Subscriptions** → create:
- **`taskera_pro_monthly`** — base plan `monthly`, P1M, auto-renew; intro offer (1st month).
- **`taskera_pro_annual`** — base plan `annual`, P1Y, auto-renew (~40% off); optional trial.
- Set per-country prices to the **tier matrix** in the submission doc. **Activate both.**

> Without active subscription products the paywall has nothing to sell.

---

## 5. App content / compliance  *(answers: `play_store_submission.md §5`)*

Complete every section under **App content**:
- [ ] **Privacy policy** URL
- [ ] **Data Safety** — declare email, user content, purchases, anonymous analytics,
      and **advertising ID** (AdMob). No data sold; encrypted in transit; deletion available.
- [ ] **Ads** — **Yes** (AdMob, free users only).
- [ ] **Content rating** questionnaire → Everyone/13+.
- [ ] **Target audience** → 13+.
- [ ] **Permissions** — declare `SCHEDULE_EXACT_ALARM` + `USE_FULL_SCREEN_INTENT`
      with the justifications in the submission doc.
- [ ] **Account deletion** — in-app (Profile → Edit profile → Delete account) **and**
      web URL `https://jumbarthi.com/taskera/delete`.
- [ ] **App access** — give a test login, or point reviewers to "Skip — use local storage".

---

## 6. Upload & internal test

1. **Testing → Internal testing → Create release** → upload the `.aab`.
2. Add release notes; **Save → Review release → Start rollout to Internal testing**.
3. **Settings → License testing** → add your Google account (makes IAP free to test).
4. Install via the internal-testing link on a **real Android device** and run QA:
   - [ ] Email OTP sign-in returns a **6-digit code**; Google sign-in works; skip-auth works
   - [ ] App opens **empty**; create task/habit/goal/note → kill/reopen → persists; syncs across devices
   - [ ] Reminder fires at the set time; survives reboot
   - [ ] Paywall → subscribe (license tester) → **Pro unlocks**, ads disappear, AI works
   - [ ] Free user: interstitial appears on tab-switch (capped); "watch ad for 1 insight" works
   - [ ] Restore purchase; Delete account wipes data and returns to sign-in

---

## 7. Promote to production

When internal testing is green:
**Internal → (optional) Closed/Open testing → Production → Create release → Roll out.**
First review can take a few days. Staged rollout (e.g. 20%) is recommended for v1.

---

## Updating later
Bump `version:` (higher `+BUILD`), `flutter build appbundle --release`, upload a new
release to the desired track. Same keystore every time.
