# Kaal — Flutter Build Instructions for Claude Code

You're building the Kaal app in Flutter (Dart, Material 3 scaffolding only) targeting **Android (minSdk 28), iOS (12+), and Windows (10+)**. A package of verified specs is provided in `kaal_pkg/`. Use it. Do not improvise dimensions, colors, or timings — every value you need is in the package.

## Where everything lives

```
kaal_pkg/
├── README.md                       ← start here
├── CLAUDE.md                       ← session-level rules
├── CLAUDE_CODE_PROMPT.md           ← you are reading this
├── tokens.json                     ← VERIFIED design tokens
├── components.md                   ← 30+ Flutter widgets with verified dimensions
├── kaal-prototype.html             ← original prototype (open in 390×844 browser)
├── screens_png/                    ← 100 reference PNGs (visual ground truth)
├── screens_html/                   ← 100 self-contained HTML extracts
├── shared/
│   ├── shared.css                  ← full prototype stylesheet
│   └── init.js                     ← bootstrap that runs on each per-screen HTML
└── specs/
    ├── SPEC.md                     ← build spec
    └── SCREEN_MAP.md               ← build order with state notes
```

## Source-of-truth priority

1. **`screens_png/*.png`** — what the user sees
2. **`tokens.json`** — verified numeric values
3. **`shared/shared.css`** — class-level CSS
4. **`screens_html/*.html`** — DOM structure
5. **`components.md` and `SPEC.md`** — guidance

Never invent. If a value isn't in the package, ask. If it conflicts with the PNG, the PNG wins.

## Read order before any code

1. `kaal_pkg/README.md`
2. `kaal_pkg/specs/SPEC.md`
3. `kaal_pkg/tokens.json` — all of it
4. `kaal_pkg/components.md` — all of it
5. `kaal_pkg/specs/SCREEN_MAP.md` — full table

## Phase 0 — Project setup

1. `flutter create kaal_app --platforms=android,ios,windows --org com.kaal`
2. Open `pubspec.yaml` and add:
   ```yaml
   dependencies:
     flutter:
       sdk: flutter
     flutter_riverpod: ^2.5.0           # state management
     go_router: ^14.0.0                 # routing
     flutter_svg: ^2.0.10               # for SVG icons from prototype
     drift: ^2.18.0                     # local database
     sqlite3_flutter_libs: ^0.5.0       # sqlite native libs
     path_provider: ^2.1.0              # file paths
     shared_preferences: ^2.2.0         # settings persistence

   dev_dependencies:
     drift_dev: ^2.18.0
     build_runner: ^2.4.0
   ```
3. Configure platform setups:
   - Android: ensure `compileSdk = 34`, `minSdk = 28`
   - iOS: set deployment target 12.0
   - Windows: enable in `flutter config --enable-windows-desktop` (already enabled per flutter doctor)

4. Download Inter Variable and Fraunces Variable TTFs into `assets/fonts/`. Update `pubspec.yaml`:
   ```yaml
   flutter:
     assets:
       - assets/wallpapers/
     fonts:
       - family: Inter
         fonts:
           - asset: assets/fonts/Inter-Variable.ttf
       - family: Fraunces
         fonts:
           - asset: assets/fonts/Fraunces-Variable.ttf
   ```

5. Run `flutter pub get`.

## Phase 1 — Design tokens

Translate `tokens.json` into Dart under `lib/theme/`:

- `lib/theme/kaal_colors.dart` — three `KaalColors` classes for Glass, Dark, Light from `themes.*` in tokens.json. Plus top-level constants: KaalAcc, KaalAcc2, KaalAccBg, KaalQ1–KaalQ4, KaalWarn, KaalSuccess.
- `lib/theme/kaal_type.dart` — TextStyles using Fraunces (display) and Inter (body). Type scale: xs=9, sm=11, md=13, lg=15, xl=19, 2xl=23, hero=30. For Fraunces 750, use `FontVariation('wght', 750)`.
- `lib/theme/kaal_shape.dart` — `BorderRadius` constants: card=12, statCard=14, switchTrack=9, sgrpIcon=8, setIco=6, pill=3, bottomNav=16.
- `lib/theme/kaal_motion.dart` — Duration constants: fastPress=120ms, defaultDuration=200ms, screenSlideIn=220ms, longPress=480ms, pulse=110ms, outsideDismissDelay=450ms, lpBlockWindow=700ms.
- `lib/theme/kaal_theme.dart` — `KaalTheme` InheritedWidget that exposes `.colors`, `.type`, `.shape`, `.motion`. Provide via `KaalTheme.of(context)` accessor.
- `enum KaalThemeMode { glass, dark, light }`. Wire to a top-level Riverpod provider.

**Do not** define a global spacing scale. The prototype uses literal paddings per component — port them per-component as you build.

## Phase 2 — Chrome

- `lib/widgets/wallpaper_background.dart` — `Image.asset(...)` full-bleed, `BoxFit.cover`. Default wallpaper Aurora.
- `lib/widgets/app_shell.dart` — Stack: WallpaperBackground at bottom, then a Scaffold with `backgroundColor: Colors.transparent` and `extendBodyBehindAppBar: true`. Top bar and bottom nav as slots.
- `lib/widgets/kaal_top_bar.dart` — Custom widget. NO `AppBar`. Padding from components.md A2. Title in Fraunces 600 23sp letterSpacing -0.5.
- `lib/widgets/kaal_bottom_nav.dart` — 6 icons row, NO `BottomNavigationBar`. Active state with accent color.
- `lib/widgets/top_ico_button.dart` — 30dp circle button.
- `lib/widgets/add_back_button.dart` — 38dp circular back chevron.

Top bar uses `backdrop-filter: none` — NO `BackdropFilter`. Wallpaper shows through directly. Only specific overlays use blur (see `tokens.blur_usage`).

## Phase 3 — Shared widgets

Build every widget in `components.md` (sections A–F) before any screen. Each file in `lib/widgets/<name>.dart` with a matching `lib/widgets/<name>_preview.dart` (using `flutter run` or a separate gallery screen since Flutter has no `@Preview` like Compose).

Build all 7 groups (Surfaces, Pills, Rows, Controls, FAB, Stats, Overlays) before Phase 4.

## Phase 4 — Routing

`lib/routing/app_router.dart` using `go_router`. ~55 routes following `tokens.json` and `SCREEN_MAP.md`. Implement parent-tab inheritance via an `InheritedWidget` (`CurrentTab`) exposed at the root.

Tab order: Focus, Tasks, Habits, Calendar, Notes, AI Inbox. Focus is default.

## Phase 5 — Screens (one at a time, in order)

For each row in `specs/SCREEN_MAP.md`:

1. Open `screens_png/<file>.png` — visual target.
2. Open `screens_html/<file>.html` at 390×844 in Chrome (DevTools device toolbar).
3. Read the "State notes" column in `SCREEN_MAP.md`.
4. Build the screen at `lib/screens/<section>/<name>_screen.dart`, using tokens (Phase 1), widgets (Phase 3), and routing (Phase 4).
5. Run on emulator/simulator (`flutter run` on Android, iOS, or Windows).
6. Diff against PNG. Fix any visible drift before committing.
7. Commit with message `screen: <name>`. Move to next row.

**One screen at a time. Don't batch. Don't move on with known drift.**

## Phase 6 — Data layer

Drift database in `lib/data/`. Tables: Tasks, Subtasks, Habits, HabitLogs, Notes, Goals, CalendarEvents, InviteSlots, FocusSessions, Achievements, SettingsKV. Seed sample data on first run from the prototype's `<script>` block (DTN_TASKS, sample habits, notes, goals).

Repositories expose Streams. ViewModels (Riverpod `StateNotifierProvider` or `AsyncNotifierProvider`) per screen. UI reads from providers via `ref.watch`.

## Phase 7 — Settings persistence

`shared_preferences`. Keys: `theme`, `accent`, `font_style`, `simple_mode`, `quad_names`, `features_*`, `wallpaper_choice`, `onboarded`, `splash_day_iso`, `typography_size_{title,section,body,label,tag,number}`.

## Phase 8 — Gestures

From `components.md` section G:
- Long press: 480ms (override default 500ms with `LongPressGestureRecognizer(duration: 480ms)`)
- Cancel if drag > 9 px (track in `onPanUpdate`)
- Inner pulse: 110ms scale 1.0 → 0.97 → 1.0
- Context menu outside-dismiss listener delayed 450ms after open
- lpBlock guard: 700ms after long-press fires
- Card press scale 0.97 over 120ms via `AnimatedScale`
- Screen enter 220ms slide-in-right via custom `PageRouteBuilder`

Universal: tasks, habits, notes, calendar rows.

**Cross-platform note:** On Windows desktop, right-click should ALSO trigger the context menu equivalent. Wire both via the same handler.

## Known limitations of the package

1. Per-screen HTML shows initial render state only. Scrolled/filtered/expanded/modal states are PNG-only.
2. 0.5px hairline borders may not render on all devices/platforms. Fall back to 1.0 px with 0.5× alpha multiplier.
3. Backdrop blur in Flutter works on all three platforms (no API-level split like Compose).
4. Several screen IDs map to the same prototype screen — distinguished only by scroll position.
5. Settings runs JS at render time in the prototype to reorganize groups (move Account to Profile, rename "AI & Smart features"). Honor the final structure.

## Non-negotiables

1. The PNG is the visual ground truth. Match it.
2. `tokens.json` is the only source of design values. Don't invent.
3. Build screens in the order in `SCREEN_MAP.md`. Don't skip.
4. After each screen: run, diff against PNG, fix, commit.
5. When the per-screen HTML and PNG disagree, the PNG wins.
6. No Material defaults that don't match. Build custom equivalents.
7. Top bar has no BackdropFilter blur. Only overlays use blur.
8. Long press is 480ms, universal.
9. Glass theme is default.
10. Don't add features that aren't in the prototype.
11. Cross-platform compatibility: Windows resizable, right-click = long-press equivalent, safe area honored on iOS.

## "Done" definition

Run the Flutter app on Android emulator, iOS simulator, AND Windows next to `kaal-prototype.html` at 390×844 in Chrome. The user should not be able to identify which is the prototype at a glance, on any platform. Same colors, density, gestures, animations, data.

## How to start

1. Confirm `kaal_pkg/` is in the project root and `flutter doctor` reports green.
2. Read README, SPEC, tokens.json, components.md, SCREEN_MAP in that order.
3. Phase 0 (project setup) → Phase 1 (tokens) → Phase 2 (chrome). Show the user `lib/theme/`, then chrome before continuing.
4. Phase 3 (widgets). Show the gallery preview before continuing.
5. First onboarding screen (Quote Splash). Show emulator render + PNG side by side before moving on.
6. Continue screen by screen.

Don't proceed past Phase 3 without confirmation. Don't ship a screen with visible drift from the PNG.
