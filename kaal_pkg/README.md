# Kaal — Claude Code Build Package (Flutter)

This package gives Claude Code a complete, verified spec for building the Kaal cross-platform app in Flutter (Android + iOS + Windows) as a 1:1 mirror of the HTML prototype.

## Stack

- **Flutter 3.44+**, **Dart 3.x**
- **Material 3** as scaffolding only — all visuals custom
- **Riverpod** for state, **go_router** for routing, **Drift** for SQL, **shared_preferences** for settings
- **Platforms:** Android (minSdk 28), iOS (12+), Windows (10+)

## Quick start

1. Drop the `kaal_pkg/` folder into your Flutter project root (next to `lib/`).
2. Copy `kaal_pkg/CLAUDE_ROOT_TEMPLATE.md` to `<project-root>/CLAUDE.md` so Claude Code auto-loads it.
3. Copy `kaal_pkg/.claude/` to `<project-root>/.claude/` for slash commands.
4. In project root:
   ```
   claude
   ```
5. First message:
   ```
   Read kaal_pkg/CLAUDE_CODE_PROMPT.md and follow it. Start with Phase 0 (project setup), then Phase 1.
   ```

## Package contents

```
kaal_pkg/
├── README.md                       ← you are here
├── CLAUDE.md                       ← session rules
├── CLAUDE_ROOT_TEMPLATE.md         ← copy this to <project-root>/CLAUDE.md
├── CLAUDE_CODE_PROMPT.md           ← full build instructions for Claude Code
├── tokens.json                     ← verified design tokens
├── components.md                   ← verified component inventory (Flutter targets)
├── kaal-prototype.html             ← original prototype (1.6 MB)
├── screens_png/                    ← 100 reference PNGs (ground truth); SCREEN_MAP.md has 101 rows — row 3 (Sign Up) is Flutter-only with no PNG
├── screens_html/                   ← 100 per-screen HTML extracts (matching the 100 PNGs; no HTML for row 3)
├── shared/
│   ├── shared.css                  ← full prototype stylesheet
│   └── init.js                     ← bootstrap script for Settings/Profile
├── specs/
│   ├── SPEC.md                     ← build spec
│   └── SCREEN_MAP.md               ← build order, with state notes
└── .claude/
    ├── commands/
    │   ├── build-screen.md
    │   ├── diff-png.md
    │   ├── verify-tokens.md
    │   └── find-css.md
    ├── hooks.json                  ← optional auto-analyze hook
    └── README.md
```

## Per-screen workflow

For each row in `specs/SCREEN_MAP.md`:
1. Open `screens_png/<file>.png` — visual target.
2. Open `screens_html/<file>.html` in a browser at 390×844 — structural reference.
3. Build the Flutter screen using tokens from `tokens.json` and widgets from `components.md`.
4. Run on at least one platform (`flutter run`) and diff against the PNG.
5. Fix any drift. Commit.

## Verification

All numeric values in `tokens.json` and `components.md` were extracted from `kaal-prototype.html` CSS, not estimated.

## Ground truth priority

PNG > tokens.json > shared.css > HTML extract > markdown guidance.

## Why Flutter for Kaal

- One codebase for Android + iOS + Windows
- `BackdropFilter` blur works on all platforms (no API version split like Compose)
- `FontVariation` for clean variable font weight axes
- Hot reload for fast iteration
- The CSS-based prototype's structure ports almost 1:1 to Flutter widgets
