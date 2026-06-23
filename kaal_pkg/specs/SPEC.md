# Kaal — Build Spec (Flutter)

This package contains everything needed to rebuild the Kaal prototype as a native Flutter app (Dart, Material 3 scaffolding only) targeting **Android (minSdk 28), iOS (12+), and Windows (10+)** as a 1:1 visual + interaction mirror.

## What's in this package

| Path | Purpose |
|------|---------|
| `screens_png/*.png` (100 files) | **Visual ground truth** for each screen. The Flutter render must match. `SCREEN_MAP.md` has 101 rows; row 3 (Sign Up) is Flutter-only with no PNG. |
| `screens_html/*.html` (100 files) | Self-contained HTML extracts: raw markup of each screen. Use for structure and inline styles. No HTML file for the Flutter-only Sign Up screen. |
| `shared/shared.css` | The prototype's full stylesheet. All CSS custom properties, themes, and class rules. |
| `shared/init.js` | Bootstrap script that runs on each per-screen HTML to organize Settings, etc. |
| `tokens.json` | Machine-readable design tokens. **Every value extracted from CSS — not estimated.** |
| `components.md` | Component inventory with verified dimensions and Flutter widget targets. |
| `specs/SCREEN_MAP.md` | Build order with state notes per screen. |
| `kaal-prototype.html` | The original prototype (1.6 MB). Open in 390×844 browser viewport to interact. |

## Source-of-truth priority

When values disagree, use this order:
1. `screens_png/*.png`
2. `tokens.json`
3. `shared/shared.css`
4. `screens_html/*.html`
5. `components.md` + this SPEC

## Stack

- **Flutter 3.44+**
- **Dart 3.x**
- **Material 3** as scaffolding only (everything visual is custom)
- **Riverpod** for state management
- **go_router** for routing
- **Drift** for local SQL database
- **shared_preferences** for settings
- **flutter_svg** for SVG icons from prototype

## Known limitations of this package

1. **Per-screen HTML shows only the initial render state.** It does NOT show: scrolled, filtered, expanded, modal, or dynamic-content states. **For these, the PNG is the ground truth.**

2. **The 0.5px hairline border may not render on all devices.** Fall back to 1 px with 0.5× alpha.

3. **Backdrop blur works on all platforms in Flutter** — no API version split. `BackdropFilter(filter: ImageFilter.blur(...))` is consistent everywhere.

4. **Several screen IDs map to the same prototype screen.** Example: `05-02_fab_add_task.png` and "Quick Add" both render `p-quickadd`. The PNG distinguishes states.

5. **Settings JS transformations.** The Settings screen runs `organizeSettingsGroups()` which reorders, renames ("AI & Smart features" → "Features, Tabs & Smart"), and moves the Account group to Profile. Per-screen HTML's `init.js` does this when opened in a browser, but raw HTML is pre-transformation order.

## Flutter-only additions (no prototype PNG)

These screens and behaviors were added during the Flutter build. They have no reference PNG or HTML extract. Do not attempt to match them to prototype files.

### 1. Sign Up screen (`/signup`, `lib/screens/onboarding/signup_screen.dart`) — added 2026-05-28
The prototype has a Sign In screen but no dedicated Sign Up / Create Account screen. A full registration screen was built for the Flutter app. Design mirrors Sign In exactly.
- **Password mode:** Email + Password + Confirm Password fields; "Create Account" (accent fill) + "Sign up with email OTP" (accent outline) buttons side-by-side.
- **OTP mode:** Email + OTP field; "Resend OTP" left link; full-width "Verify & Create Account" button.
- Social buttons (Google, Apple, Microsoft) route to `/onboard` on success.
- "← Back to sign in" and "Have an account? Sign in" route to `/signin`.
- No bottom nav, no progress bar.

### 2. Email-OTP sign-in mode (`SigninScreen`, `_otpMode = true`) — added 2026-05-27
The prototype Sign In screen shows a single password field. The Flutter implementation adds a toggled OTP mode:
- Tapping "Sign in with email OTP" replaces the Password field with a 6-digit OTP field.
- "Forgot password?" label becomes "Resend OTP".
- "New here? Create account" link is hidden in OTP mode.
- The two-button row collapses to a single full-width "Sign in with email OTP" button.

### 3. Age gate merged into OnboardScreen (step 0) — added 2026-05-28
The prototype has a separate `p-agegate` screen (`01-08_age_gate.png`). In Flutter it was merged as **step 0** of `OnboardScreen` rather than a separate route, because the flow is linear (age gate always precedes onboarding). `KaalRoutes.agegate` remains defined in `routes.dart` but its `app_router.dart` entry is a placeholder; the real implementation is `_Step0` inside `OnboardScreen`. The 6-step progress bar is present on the age gate step (0 segments active).

### 4. Onboarding 6-step progress bar — added 2026-05-28
The prototype onboarding PNGs show a progress indicator but its exact segment count varies. The Flutter implementation uses a **fixed 6-segment bar** (segments = total step count 0–5). Each segment is 4 px tall: active = `KaalColors.acc`, inactive = `Color(0x40FFFFFF)`. The bar is pinned at the **bottom** of the screen below the scrollable content area, not at the top.

## Build phases

### Phase 0 — Setup
- `flutter create kaal_app --platforms=android,ios,windows --org com.kaal`
- Add deps: flutter_riverpod, go_router, flutter_svg, drift, sqlite3_flutter_libs, path_provider, shared_preferences (+ dev: drift_dev, build_runner)
- Download Inter + Fraunces variable TTFs into `assets/fonts/`
- Set minSdk 28 (Android), deployment target 12.0 (iOS)

### Phase 1 — Tokens (`lib/theme/`)
Translate `tokens.json` into Dart. See CLAUDE_CODE_PROMPT.md Phase 1.

### Phase 2 — Chrome (`lib/widgets/`)
WallpaperBackground, AppShell, KaalTopBar, KaalBottomNav, TopIcoButton, AddBackButton. Build BEFORE any screen.

### Phase 3 — Shared widgets (`lib/widgets/`)
All of components.md sections A–F. Test each in a gallery preview screen.

### Phase 4 — Routing (`lib/routing/`)
go_router with ~55 routes. CurrentTab InheritedWidget for sub-screen parent inheritance.

### Phase 5 — Screens (`lib/screens/<section>/`)
One at a time, in SCREEN_MAP.md order. For each:
1. Open PNG.
2. Open HTML in browser at 390×844.
3. Build screen.
4. Run on at least one platform. Diff against PNG.
5. Fix drift. Commit.

### Phase 6 — Data (`lib/data/`)
Drift database. Entities + repositories + Riverpod providers. Seed sample data on first run.

### Phase 7 — Settings (`lib/settings/`)
shared_preferences.

### Phase 8 — Gestures
Universal long press (480ms), card press scale, screen enter animation. Right-click = long-press on Windows desktop.

## Non-negotiables

1. PNG is visual ground truth.
2. `tokens.json` is the only source of design values.
3. Build screens in SCREEN_MAP.md order. Don't skip.
4. After each screen: run, diff, fix, commit.
5. PNG wins over HTML when they disagree.
6. No Material defaults that don't match. Build custom.
7. No Cupertino either — also doesn't match.
8. Top bar has no `BackdropFilter`. Only overlays use blur.
9. Long press is 480ms, universal.
10. Glass theme is default.
11. Cross-platform: support Android, iOS, Windows. Right-click triggers context menu on Windows.

## Cross-platform notes

- **Windows window sizing:** the design targets 390×844 logical. On Windows, the app may be wider — consider a centered max-width 480 px container for desktop, or scale the design to fill while preserving proportions. Discuss approach in Phase 2.
- **iOS safe area:** honor `MediaQuery.padding.top/bottom`.
- **Android edge-to-edge:** call `SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge)` so the wallpaper bleeds behind status/nav bars.
- **Variable font weight:** use `FontVariation('wght', value)` for precise weight axis on Fraunces (e.g. 750 for Pomodoro).
- **Hardware long-press:** Flutter's `GestureDetector.onLongPress` defaults to 500ms. Override with `RawGestureDetector` + `LongPressGestureRecognizer(duration: Duration(milliseconds: 480))`.

## "Done" definition

Open the Flutter app on Android, iOS, AND Windows. Open `kaal-prototype.html` in Chrome at 390×844. Switch between any pair: the user cannot tell which is which at a glance. Same colors, density, gestures, animations, data, across all platforms.
