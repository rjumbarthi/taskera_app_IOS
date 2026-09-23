# TaskEra — Project Context for Claude Code (Flutter)

This file is auto-loaded by Claude Code on every session. It tells you what this project is, what's in this folder, and where to look for what.

## What this project is

TaskEra is an "Execution OS for high performers" — a Covey 4-quadrant productivity app. The reference is an HTML/CSS/JS prototype (single file, ~14k lines). You're rebuilding it as a **cross-platform Flutter app (Android + iOS + Windows)** as a 1:1 visual + interaction mirror.

- **Framework:** Flutter 3.44+
- **Language:** Dart 3.x
- **UI base:** Material 3 (minimal — used only as scaffolding; all visuals are custom)
- **Targets:** Android (minSdk 28), iOS (12+), Windows (10+)
- **State management:** Riverpod (recommended; can choose at Phase 1 if you want)
- **Local DB:** Drift (recommended for SQL safety + cross-platform)

## How to start a new session

Read these in order:
1. `taskera_pkg/CLAUDE_CODE_PROMPT.md` — the full build instructions
2. `taskera_pkg/specs/SPEC.md` — build spec
3. `taskera_pkg/tokens.json` — design tokens
4. `taskera_pkg/components.md` — component inventory (Flutter targets)
5. `taskera_pkg/specs/SCREEN_MAP.md` — build order

Don't write any code before reading all five.

## Source-of-truth priority

When two sources disagree:
1. `taskera_pkg/screens_png/*.png` — what the user sees (visual ground truth)
2. `taskera_pkg/tokens.json` — verified numeric values
3. `taskera_pkg/shared/shared.css` — class-level CSS
4. `taskera_pkg/screens_html/*.html` — DOM structure
5. `taskera_pkg/components.md` and `specs/SPEC.md` — guidance

Never invent. If a value isn't in the package, ask. If anything conflicts with the PNG, the PNG wins.

**Known PNG divergences (do not "fix" these to match the PNGs):**
- **Focus nav icon (2026-05-26):** PNGs show the old crosshair/concentric-circles design. The canonical icon is the compass/sunburst design in `assets/icons/focus_nav.svg` (8 radial ticks, double rings, filled center dot). Use the SVG as ground truth for this one element; ignore the PNG for the bottom-nav focus icon only.
- **Bottom nav black band (2026-05-27):** Some PNGs show a solid black band behind the bottom nav pill (`#global-bnav-wrap { background: #000 }`). This was a prototype HTML quirk needed because the HTML nav was not full-bleed. In Flutter the glass pill floats directly over the wallpaper with transparent margins — no black wrap is rendered. Do not add a black container behind the nav.
- **SignupScreen (2026-05-28):** The prototype has no dedicated create-account screen. `SignupScreen` (`lib/screens/onboarding/signup_screen.dart`) was added as a Flutter-only feature. It is not in `SCREEN_MAP.md` or any reference PNG. Do not try to match it to a PNG — its design mirrors `SigninScreen` exactly.

## Onboarding & auth flow (implemented 2026-05-28)

The full first-run flow is: **Quote Splash → Sign In → (new user) Sign Up → Onboarding → Focus**

### Route map
| Route constant | Path | File | Notes |
|---|---|---|---|
| `TaskEraRoutes.quote` | `/quote` | `screens/onboarding/quote_splash_screen.dart` | Initial route; auto-advances to signin |
| `TaskEraRoutes.signin` | `/signin` | `screens/onboarding/signin_screen.dart` | Password mode default; OTP toggle |
| `TaskEraRoutes.signup` | `/signup` | `screens/onboarding/signup_screen.dart` | Flutter-only, no prototype PNG |
| `TaskEraRoutes.onboard` | `/onboard` | `screens/onboarding/onboard_screen.dart` | 6-step flow (step 0–5) |

### SigninScreen (`lib/screens/onboarding/signin_screen.dart`)
- Two modes toggled by `bool _otpMode`: **password mode** (Email + Password fields, "Sign in" + "Sign in with email OTP" side-by-side) and **OTP mode** (Email + OTP field, full-width "Sign in with email OTP" button).
- "Forgot password?" / "Resend OTP" — left-aligned, acc color, onTap empty (not yet implemented).
- "New here? Create account" — right-aligned, only visible when `!_otpMode`, routes to `TaskEraRoutes.signup`.
- Social row: Google + Apple (same row), Microsoft + "Skip — use local storage" (same row). Skip goes to `TaskEraRoutes.focus`.
- No bottom nav. No progress bar.

### SignupScreen (`lib/screens/onboarding/signup_screen.dart`)
- Mirrors SigninScreen layout exactly (same wallpaper, SafeArea, padding `fromLTRB(18,22,18,24)`, same private widget set: `_Flbl`, `_FinputField`, `_SocialBtn`).
- Two modes: **password mode** (Email + Password + Confirm Password, "Create Account" acc fill + "Sign up with email OTP" outline side-by-side, "Have an account? Sign in" right link) and **OTP mode** (Email + OTP, "Resend OTP" left link, full-width "Verify & Create Account" button).
- On successful account creation (any method): routes to `TaskEraRoutes.onboard` (starts onboarding at step 0 = age gate).
- Social buttons also route to `TaskEraRoutes.onboard`.
- "← Back to sign in" and "Have an account? Sign in" both route to `TaskEraRoutes.signin`.
- No bottom nav. No progress bar.

### OnboardScreen (`lib/screens/onboarding/onboard_screen.dart`)
- Single `StatefulWidget` with `int _step` (0–5). **No separate screen files per step.**
- Step 0 = AgeGate, 1 = Who are you, 2 = Focus style, 3 = Peak hours, 4 = Goal, 5 = Upsell.
- Step 5 completes onboarding → routes to `TaskEraRoutes.focus`.
- **Progress bar:** 6 segments, height 4px, pinned at the **bottom** of screen (below `Expanded` content, above safe area). Active = `TaskEraColors.acc`, inactive = `Color(0x40FFFFFF)`.
- **Blur overlay:** `BackdropFilter(sigmaX:8, sigmaY:8)` + `Color(0x33000000)` dark overlay applied to the `Expanded` content region only — not the progress bar strip. Cards inside use `Colors.transparent` background (not `colors.surf`), `colors.bdr` border only.
- **No bottom nav** on any onboarding screen. `TaskEraBottomNav` only appears inside `AppShell` (i.e., once the user reaches `/focus` and sibling tabs).
- Layout skeleton:
  ```dart
  Column(children: [
    SizedBox(height: safeTop),          // status bar clearance
    Expanded(child: ClipRect(child: BackdropFilter(...))),  // scrollable content
    Padding(                             // progress bar strip
      padding: EdgeInsets.fromLTRB(20, 12, 20, safeBottom + 14),
      child: _ProgressBar(step: _step),
    ),
  ])
  ```

## Build phases (do these in order)

- **Phase 1:** Design tokens → `lib/theme/`
- **Phase 2:** WallpaperBackground + AppShell
- **Phase 3:** Shared widgets (all of `components.md`) → `lib/widgets/`
- **Phase 4:** Routing → `lib/routing/` (use `go_router`)
- **Phase 5:** Screens, one at a time, in `SCREEN_MAP.md` order → `lib/screens/`
- **Phase 6:** Data layer with Drift → `lib/data/`
- **Phase 7:** Settings persistence with `shared_preferences` → `lib/settings/`
- **Phase 8:** Gestures (long press, scale press, screen enter)

After each phase: show the user what you built, wait for confirmation, then proceed.

## Hard rules

1. Build one screen at a time. No batching. Verify against PNG before moving on.
2. `tokens.json` is the only source of design values. Don't invent.
3. Material defaults (`Switch`, `Card` with elevation, `AppBar`, `NavigationBar`, `ListTile`, `InkWell` ripples, `ElevatedButton`) do NOT match this design. Build custom equivalents.
4. Cupertino defaults also don't match. Don't use them.
5. Glass theme is default. Wallpaper shows through translucent surfaces.
6. Top bar has NO BackdropFilter blur. Only specific overlays use blur (see `tokens.blur_usage`).
7. Long press is 480ms, universal across all rows.
8. `data-parent` on a screen = inherit that parent tab's top bar (via InheritedWidget `CurrentTab`).
9. Don't add features that aren't in the prototype.
10. Don't add elevation/shadows except where specified. Depth comes from translucency over the wallpaper.

## Platform-adaptive layout

Implemented in `lib/util/platform_layout.dart` (`isDesktop` / `isMobile` helpers) and `lib/widgets/app_shell.dart`.

- **Mobile (Android, iOS):** Content fills the full phone screen width. No `ConstrainedBox`. `SafeArea` lifts nav above gesture bar / home indicator. This is the prototype's native target size.
- **Desktop (Windows, macOS, Linux):** Wallpaper fills the full window. Content column (top bar + body + nav) is centered at `maxWidth 480`. Wallpaper bleeds visibly to the left and right of the column. `SafeArea` is a no-op (no system UI overlapping on desktop).
- **Window sizing (Windows):** Initial size 420×900 (set in `windows/runner/main.cpp`). Minimum size 400×700 enforced at runtime via `window_manager`. Window is resizable; content stays centered at 480 max.
- **`window_manager` package:** Used only for `setMinimumSize` and `setTitle` on desktop. No custom title bar or frameless window — standard Win32 chrome is kept for now.

## File layout

```
<project root>/
├── lib/                            ← your Flutter app
│   ├── main.dart
│   ├── theme/                      ← Phase 1
│   ├── widgets/                    ← Phase 2-3
│   ├── routing/                    ← Phase 4
│   ├── screens/
│   │   └── onboarding/
│   │       ├── quote_splash_screen.dart
│   │       ├── signin_screen.dart
│   │       ├── signup_screen.dart   ← Flutter-only (no prototype PNG)
│   │       └── onboard_screen.dart  ← 6-step flow (age gate + 5 steps)
│   ├── screens/                    ← Phase 5 (remaining)
│   ├── data/                       ← Phase 6
│   └── settings/                   ← Phase 7
├── assets/
│   ├── fonts/
│   │   ├── Inter-Variable.ttf
│   │   └── Fraunces-Variable.ttf
│   └── wallpapers/
│       ├── aurora.jpg
│       ├── galaxy.jpg
│       └── ocean.jpg
├── pubspec.yaml
├── CLAUDE.md                       ← you are reading this
├── taskera_pkg/                       ← reference package (read-only)
│   ├── README.md
│   ├── CLAUDE_CODE_PROMPT.md
│   ├── tokens.json
│   ├── components.md
│   ├── taskera-prototype.html
│   ├── screens_png/                ← 100 reference PNGs
│   ├── screens_html/               ← 100 HTML extracts
│   ├── shared/
│   │   ├── shared.css
│   │   └── init.js
│   └── specs/
│       ├── SPEC.md
│       └── SCREEN_MAP.md
└── android/ ios/ windows/          ← platform projects
```
# AI Operating Protocol

## Context Discipline
- Treat context as limited RAM.
- Keep active task scope narrow.
- Warn when context becomes noisy or diluted.
- Recommend compaction around 65-75%.
- Recommend new session around 80-85% if architecture-heavy.

## Persistent Memory
Store critical state in:
- /docs/architecture.md
- /docs/current_state.md
- /docs/api_contracts.md
- /docs/design_system.md
- /docs/todo.md

## Session Handoff
Before reset/compact:
1. summarize completed work
2. summarize pending work
3. list modified files
4. identify risks
5. identify next action

## Drift Detection
Alert me if:
- naming consistency drops
- duplicate logic appears
- architecture deviates
- unrelated files are modified
- repeated bug loops occur


## "Done" definition

Run the Flutter app on each platform next to `taskera-prototype.html` at 390×844 in Chrome. The user can't tell which is which at a glance. Same colors, density, gestures, animations, data.

## Common mistakes to avoid

- Using Material defaults because they're convenient — they don't match.
- Adding shadows / elevation — TaskEra cards are flat translucent.
- Hardcoding colors instead of using the theme palette via `TaskEraTheme.of(context).colors.X`.
- Using `AppBar` — wrong density. Build the top bar from `Container` + `Row`.
- Using `Switch()` or `CupertinoSwitch()` — both wrong shape. Build custom (32×17 track, 13×13 thumb).
- Using `ListTile` — anatomy doesn't match. Build rows from `Row` + `Container`.
- Building three screens before verifying one against its PNG.
- Skipping `components.md` sections and inlining widgets inside screen files.
- Inventing spacing values — use the literal paddings from `tokens.json` per component.
- Treating per-screen HTML as ground truth for scrolled/expanded states — the PNG is ground truth for those.
- **Giving form rows or section wrappers a grey/white background card** — form rows (labels + fields) must be transparent, sitting directly on the wallpaper. Only the input fields themselves (`colors.surf2` fill) and named glass cards (`colors.surf` + `colors.bdr` border) carry a background. Never wrap a form section in a `Container(color: colors.surf)` just to group it.
- **Nesting cards inside cards with opaque backgrounds** — nested containers must use transparent or the correct token color from the PNG, not `colors.surf` or `Colors.white`. When in doubt, check the reference PNG: if you can see the wallpaper through it, the background must be translucent.
- **Using grey (`colors.surf2`) as the background of any card, button, or interactive item** — this is banned. Every parent card/button/item must use a **wallpaper-color-centric tinted background**: the element's semantic/accent color at `0x12` opacity (≈7%) for background and `0x33` opacity for border. For elements with no semantic color use the **theme-aware** neutral tokens `colors.surf2` (fill) + `colors.bdr0` (border) — NOT the raw literals `Color(0x0DFFFFFF)` / `Color(0x1AFFFFFF)`, which are white-only and disappear on the light theme. (The tokens resolve to those white values on dark/glass and to black tints on light.) Exception: surfaces that are intentionally rendered on a fixed-dark background regardless of app theme — the long-press action sheet, the quote splash, and the home-widget mockups in `widget_preview_screen.dart` — keep the white literal `Color(0x1AFFFFFF)`. Canonical example: Focus screen `StatCard` (`bgColor: Color(0x120A84FF)`). This tint should eventually be driven by the active wallpaper dynamically.
- **Making children/nested items inside a card carry any background** — only the outermost parent card/button gets the tinted background. All children (sub-rows, inner buttons, nested items) must be `Colors.transparent`. One level of tint per card hierarchy.

## Cross-platform considerations

- **Backdrop blur (`BackdropFilter`) works on all three platforms.** No API version split.
- **Variable fonts work on all three.** `FontVariation('wght', 600)` for precise weight axis control.
- **Window sizing on Windows:** the app should support resizable windows; the design targets 390×844 logical but should adapt gracefully when wider (consider a centered max-width 480 container on desktop).
- **Long-press on Windows desktop:** right-click should also trigger the context menu equivalent.
- **Status bar / safe area** differs per platform. Use `MediaQuery.of(context).padding.top` for safe area.
