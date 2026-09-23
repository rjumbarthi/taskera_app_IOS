# TaskEra — iOS App Store Launch Checklist

Everything needed to get TaskEra onto the App Store, in order. Code changes are
already committed (`5b2a7d6`); the rest is Mac + Apple/Supabase portal work that
only you can do with your logins.

- **Bundle ID:** `com.port443.taskera`
- **Team / Developer:** Port443 LLC (your active Apple Developer account)
- **Privacy policy URL:** https://jumbarthi.com/taskera
- **Support email:** taskera_support@jumbarthi.com

---

## Phase 1 — On your Mac (resolve + verify)

1. [ ] `git pull` in the repo.
2. [ ] `flutter pub get` — resolves `sign_in_with_apple` (it could not resolve on
       the Windows machine due to a TLS/network block).
3. [ ] `cd ios && pod install && cd ..` — installs the new plugin's pod.
4. [ ] `flutter analyze lib/services/auth_service.dart lib/screens/onboarding/`
       — confirm clean. The Apple sign-in code was written but NOT compile-checked
       on Windows (package couldn't resolve). Fix or report any errors.
5. [ ] Commit the updated **`pubspec.lock`** (now contains `sign_in_with_apple`)
       and push, so all repos stay in sync.

## Phase 2 — Xcode (wire the capability)

6. [ ] Open **`ios/Runner.xcworkspace`** (the workspace, NOT `.xcodeproj`).
7. [ ] Runner → **Signing & Capabilities**:
       - Set **Team** (Port443 LLC); confirm bundle id `com.port443.taskera`.
       - **+ Capability → Sign in with Apple**. (`ios/Runner/Runner.entitlements`
         already exists with the entitlement — Xcode will link it.)
8. [ ] Confirm automatic signing resolves a provisioning profile with the
       Sign in with Apple entitlement.

## Phase 3 — Apple Developer portal (developer.apple.com)

9.  [ ] Certificates, Identifiers & Profiles → **Identifiers** → App ID
        `com.port443.taskera` → ensure **Sign In with Apple** is enabled (Xcode
        usually does this in step 7).
10. [ ] **Keys → +** → enable **Sign in with Apple** → **download the `.p8`**;
        note the **Key ID**.
11. [ ] Note your **Team ID** (top-right of the portal).
12. [ ] (For Supabase web/token validation) **Identifiers → + → Services ID**,
        e.g. `com.port443.taskera.signin`; enable Sign in with Apple on it and set
        the return URL to your Supabase callback
        `https://dutlcoxtxmnqektttffg.supabase.co/auth/v1/callback`.

## Phase 4 — Supabase (enable Apple provider)

13. [ ] Dashboard → **Authentication → Providers → Apple → Enable**.
14. [ ] **Client IDs:** add `com.port443.taskera` (the app bundle id). *This is the
        field that makes the native id-token flow work — the critical one.* Add
        the Services ID from step 12 too if you use the web flow.
15. [ ] Fill the **Secret Key** section with **Team ID**, **Key ID**, and the
        **`.p8`** contents so Supabase can validate Apple tokens.

## Phase 5 — App Store Connect

16. [ ] Create the **app record** (bundle id `com.port443.taskera`), name, primary
        category, etc.
17. [ ] Create the **Pro subscription IAP product**. TaskEra uses `in_app_purchase`
        = Apple StoreKit on iOS, so **Pro will not work until this product exists
        and is approved**. Match the product identifiers the app queries.
18. [ ] Fill **App Privacy** ("nutrition labels") — must match your data-safety
        declarations (Personal info, Financial info from IAP, etc.).
19. [ ] Upload screenshots (6.7" + 6.5" + iPad if you ship iPad), description,
        keywords, support URL, privacy URL `https://jumbarthi.com/taskera`.

## Phase 6 — Build & submit (on Mac)

20. [ ] Bump build number if needed (see "Versioning" below).
21. [ ] `flutter build ipa` (or Xcode → Product → **Archive**).
22. [ ] Upload to **TestFlight** (Xcode Organizer → Distribute, or Transporter).
23. [ ] Install via TestFlight on a real iPhone; **test BOTH Sign in with Apple
        AND Google sign-in**, plus the Pro purchase (sandbox).
24. [ ] Submit for **App Store review**.

---

## Guideline blockers — status

| Apple requirement | Status |
|---|---|
| **4.8** Sign in with Apple (because Google login is offered) | ✅ Implemented — verify on device |
| **5.1.1(v)** In-app account deletion | ✅ Already exists — Profile → Edit profile → Delete account |
| **App Privacy** nutrition labels match actual data use | ⚠️ Fill in ASC (Phase 5) |
| **Missing `NS…UsageDescription`** strings cause auto-rejection | ⚠️ Audit `ios/Runner/Info.plist` before submit |

## Notes & gotchas

- **Google sign-in on iOS needs no extra config** — it uses the Supabase browser
  flow, and the `io.supabase.taskeraapp` URL scheme is already in `Info.plist`.
- **AdMob is still on Google TEST IDs** (Android and iOS). The iOS
  `GADApplicationIdentifier` in `Info.plist` is Google's test app id. Real ads
  require the 6 AdMob IDs (2 app ids + 4 unit ids) — see the AdMob walkthrough.
  For iOS ads you'll also want the **SKAdNetwork identifiers** in `Info.plist`.
- **CASA / Google OAuth verification is SEPARATE from Apple.** You can ship to the
  App Store with Gmail/Calendar behind their remote flags regardless of where
  Google verification stands. Apple does not require it.
- **Versioning:** `pubspec.yaml` `version: 1.0.0+9`. The part before `+` is the
  marketing version (CFBundleShortVersionString); after `+` is the build number
  (CFBundleVersion). App Store Connect requires the **build number to increase**
  with every upload to a given marketing version — bump `+9 → +10 …` per upload.

## Apple / Supabase values to have on hand

| Item | Where to get it | Goes into |
|---|---|---|
| Team ID | developer.apple.com (top-right) | Supabase Apple secret |
| Key ID + `.p8` | Apple portal → Keys | Supabase Apple secret |
| App ID `com.port443.taskera` | Apple portal → Identifiers | Supabase Client IDs |
| Services ID (optional) | Apple portal → Identifiers | Supabase Client IDs |
| Supabase callback URL | `https://dutlcoxtxmnqektttffg.supabase.co/auth/v1/callback` | Services ID return URL |
