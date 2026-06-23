---
description: Audit lib/theme/ Dart files against kaal_pkg/tokens.json for drift.
---

Audit `lib/theme/` Dart files against `kaal_pkg/tokens.json`. Strict comparison — every value should match.

## Files to audit

- `lib/theme/kaal_colors.dart`
- `lib/theme/kaal_type.dart`
- `lib/theme/kaal_shape.dart`
- `lib/theme/kaal_motion.dart`
- `lib/theme/kaal_theme.dart`

## Checks

### 1. Colors (kaal_colors.dart vs tokens.json)
For each of `themes.default_root`, `themes.glass`, `themes.light`, `themes.dark`:
- Every `--name: value` in tokens.json has a corresponding Dart property
- Hex values match exactly. `#0A84FF` → `Color(0xFF0A84FF)`. **Verify full alpha prefix `0xFF` on every opaque color.**
- `rgba(r,g,b,a)` → `Color(0xAARRGGBB)` where AA = round(a × 255).
- Top-level constants exist: KaalAcc, KaalAcc2, KaalAccBg, KaalQ1, KaalQ2, KaalQ3, KaalQ4, KaalWarn, KaalSuccess.

### 2. Typography (kaal_type.dart vs tokens.json)
- All 7 sizes from `typography_scale`: xs=9, sm=11, md=13, lg=15, xl=19, 2xl=23, hero=30 (as `double` in Dart, applied via `fontSize:`).
- Inter and Fraunces declared via `TextStyle(fontFamily: 'Inter', ...)` etc. — names must match `pubspec.yaml` font family.
- **Verify Fraunces 750 uses `fontVariations: [FontVariation('wght', 750)]`** — the only way to hit non-standard weights with variable fonts in Flutter.
- Semantic styles exist: displayTitle (Fraunces 600 23 letterSpacing -0.5), displayNumber (Fraunces 700 19), pomodoroTimer (Fraunces 750 46 + tabular figures).

### 3. Shapes (kaal_shape.dart vs tokens.json.radii_used)
- BorderRadius constants for: card=12, statCard=14, switchTrack=9, sgrpIcon=8, setIco=6, pill=3, bottomNav=16.
- No invented scale.

### 4. Motion (kaal_motion.dart vs tokens.json.transitions)
- Duration constants: fastPress=120, defaultDuration=200, screenSlideIn=220, longPress=480, pulse=110, outsideDismissDelay=450, lpBlockWindow=700, screenCleanup=280 (all `Duration(milliseconds: X)`).
- scalePressed = 0.97 (double).
- easingDefault = `Curves.ease` or equivalent.
- easingSpring = `Cubic(0.34, 1.56, 0.64, 1.0)`.

### 5. KaalTheme (kaal_theme.dart)
- `enum KaalThemeMode { glass, dark, light }` exists.
- `KaalTheme` InheritedWidget with `colors`, `type`, `shape`, `motion` getters.
- `KaalTheme.of(context)` static accessor.
- A Riverpod provider (`themeProvider`) exposes the current mode.

## Output format

```
## Token audit report

### kaal_colors.dart
- [✓] / [✗] [check] [details]
- ...

### kaal_type.dart
...

### kaal_shape.dart
...

### kaal_motion.dart
...

### kaal_theme.dart
...

### Summary
- Total checks: N | Passing: X | Failing: Y
- Drift detected: [list with file:line + fix needed]
```

**Don't fix anything.** Report only.
