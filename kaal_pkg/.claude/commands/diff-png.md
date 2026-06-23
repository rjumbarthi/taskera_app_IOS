---
description: Compare the current Flutter render to a reference PNG and list visible differences.
argument-hint: <screen-id> (e.g. 03-09_task_detail)
---

Compare the Flutter render of `$ARGUMENTS` against the reference PNG. Do NOT fix yet — list issues, we triage together.

1. **Capture current render.** Options in order of preference:
   - Use `flutter screenshot --out=/tmp/flutter_current.png` if running.
   - Otherwise: `adb exec-out screencap -p > /tmp/flutter_current.png` (Android).
   - Otherwise: ask user to screenshot manually and save to `/tmp/flutter_current.png`.

2. **Open the reference** — `kaal_pkg/screens_png/$ARGUMENTS.png`.

3. **Compare visually.** Walk these in order:
   - **Overall layout** — all sections present? Anything missing or extra?
   - **Top bar** — title text, Fraunces 600 23, subtitle, right icons. Padding and alignment.
   - **Bottom nav** — 6 icons, active state on correct tab.
   - **Cards** — radius (12 default, 14 stat card), padding, border (0.5 hairline), background translucency.
   - **Colors** — accents (acc=#0A84FF), quadrants (Q1 red-orange, Q2 green, Q3 blue, Q4 yellow), text inks (ink/ink2/ink3).
   - **Typography** — Fraunces vs Inter per element. Sizes from `tokens.json → typography_scale`.
   - **Spacing** — gaps between cards (commonly 7-8), section paddings.
   - **Icons** — correct icon, correct size (top-bar 30 circle with 14-18 inner SVG; back 38 circle with 18 inner).
   - **Specific component dims** — switches (32×17), pills (filter vs tiny), stat cards.
   - **Wallpaper** — visible through translucent surfaces? No opaque overlay?

4. **Output format.**
   ```
   ## Diff report for $ARGUMENTS

   ### Matches (no action)
   - [items]

   ### Drift (needs fix)
   - **[severity: critical | medium | minor]** [element]: [observed] → [expected]
     - Source of truth: [PNG / tokens.json key / components.md section]

   ### Cannot verify from screenshot
   - [items needing closer inspection: animations, gesture behavior, scroll states]
   ```

5. **Stop. Wait for triage decision.** Don't fix anything. I'll tell you which items to address.
