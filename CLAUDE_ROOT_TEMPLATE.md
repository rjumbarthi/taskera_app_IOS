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

## File layout

```
<project root>/
├── lib/                            ← your Flutter app
│   ├── main.dart
│   ├── theme/                      ← Phase 1
│   ├── widgets/                    ← Phase 2-3
│   ├── routing/                    ← Phase 4
│   ├── screens/                    ← Phase 5
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

## Cross-platform considerations

- **Backdrop blur (`BackdropFilter`) works on all three platforms.** No API version split.
- **Variable fonts work on all three.** `FontVariation('wght', 600)` for precise weight axis control.
- **Window sizing on Windows:** the app should support resizable windows; the design targets 390×844 logical but should adapt gracefully when wider (consider a centered max-width 480 container on desktop).
- **Long-press on Windows desktop:** right-click should also trigger the context menu equivalent.
- **Status bar / safe area** differs per platform. Use `MediaQuery.of(context).padding.top` for safe area.
