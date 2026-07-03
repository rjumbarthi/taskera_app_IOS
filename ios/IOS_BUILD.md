# Building the Kaal iOS app (from Windows, via Codemagic)

You can't build an iOS `.ipa` on Windows — Apple's toolchain is macOS-only.
This project uses **Codemagic** (cloud macOS build servers) to compile, sign,
and ship the IPA to **TestFlight**, so no Mac is required. Config lives in
`codemagic.yaml` at the repo root.

## What you need
- An **Apple Developer Program** membership ($99/yr) — you have this. ✅
- A **Codemagic** account (free tier: 500 macOS build-minutes/month).
- This repo pushed to GitHub / GitLab / Bitbucket.

## One-time setup

### 1. App Store Connect — create the app record
1. Go to <https://appstoreconnect.apple.com> → **Apps** → **+** → **New App**.
2. Platform: iOS. Bundle ID: **`com.port443.kaal`**
   - If the bundle ID isn't listed, register it first at
     <https://developer.apple.com/account/resources/identifiers> (Identifiers →
     **+** → App IDs → App → `com.port443.kaal`).
3. After the app is created, open it → **App Information** → copy the numeric
   **Apple ID** (a 10-digit number). Put it in `codemagic.yaml` as
   `APP_STORE_APP_ID`.

### 2. App Store Connect API key (lets Codemagic sign + upload)
1. App Store Connect → **Users and Access** → **Integrations** → **App Store
   Connect API** → **Generate API Key** (or **+**).
2. Access role: **App Manager** (or Admin). Download the `.p8` file (you can
   only download it once). Note the **Key ID** and **Issuer ID**.

### 3. Codemagic — connect + add the key
1. Sign in at <https://codemagic.io> and add/authorize this repository.
2. **Team settings → Integrations → App Store Connect → Manage keys → Add key**:
   - Name it **exactly** `KaalAppStoreConnect` (must match `codemagic.yaml`).
   - Upload the `.p8`, and paste the **Key ID** + **Issuer ID**.
3. Codemagic auto-detects `codemagic.yaml`. Automatic code signing will fetch /
   create the distribution certificate + provisioning profile for
   `com.port443.kaal` using that API key — nothing to upload manually.

### 4. Run it
- Open the app in Codemagic → workflow **"Kaal iOS — TestFlight"** →
  **Start new build**, or just push to your default branch.
- On success: the signed **`.ipa`** appears under the build's **Artifacts**
  (downloadable), and it's also pushed to **TestFlight** automatically.
- Install on your iPhone via the **TestFlight** app once it finishes processing
  (a few minutes after upload).

## Notes / gotchas
- **Build number** is auto-incremented from the latest TestFlight build, so you
  won't hit "build number already used" rejections. `versionName` stays `1.0.0`
  (from `pubspec.yaml`) until you bump it.
- **Home-screen widget (`DtnWidget`)**: currently NOT an Xcode target (just
  source files + `ios/DtnWidget/SETUP.md`). It is not part of this build. If you
  later add it as a target in Xcode, you'll also need to:
  - register bundle id `com.port443.kaal.DtnWidget`,
  - add App Group `group.com.kaal.kaal_app` to both targets,
  - Codemagic automatic signing will then pick up both profiles.
- **AdMob**: ensure `GADApplicationIdentifier` is present in
  `ios/Runner/Info.plist` (required or the app crashes on launch) — this is
  app config, unrelated to CI.
- Want an **ad-hoc build** (direct device install without TestFlight) instead of
  App Store? Change `distribution_type: app_store` → `ad_hoc` in `codemagic.yaml`
  and register your test devices' UDIDs in the Apple Developer portal.

## Alternative: if you get a Mac later
```bash
flutter build ipa --release
# → build/ios/ipa/*.ipa, then upload via Xcode Organizer or Transporter
```
