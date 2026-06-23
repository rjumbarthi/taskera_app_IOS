# Kaal — Components Inventory (VERIFIED, Flutter target)

Every dimension below was extracted from `kaal-prototype.html` CSS — not estimated. Reference `tokens.json` for additional context. **Use these literal values** in your Flutter widgets.

> **Rule:** 1 CSS pixel in the prototype = 1 logical pixel in Flutter (use raw double values, no scaling). Design canvas: 390 × 844 logical pixels (iPhone 14 size).

---

## A. Layout & Chrome

### A1. WallpaperBackground
**Source:** `tokens.json → wallpaper_options`. Four choices: None, Galaxy, Ocean, Aurora.
**Flutter:** Stack with `Positioned.fill(child: Image.asset('assets/wallpapers/aurora.jpg', fit: BoxFit.cover))` at the root of the MaterialApp's home. Above it, everything else.
**Constraint:** Behind every translucent surface, including status bar (use `SystemUiOverlayStyle(statusBarColor: Colors.transparent)`). Static — does not scroll with content.

### A2. TopBar
**CSS source:** `.top-bar` (line 90)
- Padding: EdgeInsets.fromLTRB(16, 12 + safeAreaTop, 4, 4)
- Background: `Colors.transparent`
- **No backdrop blur** — `BackdropFilter` NOT applied here.
- Two rows: row1 (title left, icon group right) + optional row2 (subtitle)

**Title:** `Text(title, style: TextStyle(fontFamily: 'Fraunces', fontWeight: FontWeight.w600, fontSize: 23, letterSpacing: -0.5, height: 1))`
**Subtitle:** `Text(subtitle, style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w400, fontSize: 11, letterSpacing: 0.2))`

**Right slot icons:** 30×30 circles, `BoxDecoration(shape: BoxShape.circle, color: surf2, border: Border.all(width: 0.5, color: bdr))`. Inner SVG 14–18 px via `flutter_svg`.
**Avatar:** `ClipOval(child: SizedBox(width: 24, height: 24, child: Image.network(...)))`.

### A3. InheritedBar (parent-tab top bar inheritance)
Sub-screens that visually live under a parent tab inherit that tab's top bar. **Flutter:** wrap the navigation host with an `InheritedWidget` (`CurrentTab`) that exposes the active root tab. Sub-screens read it and render that tab's top bar widget above their own content.
`data-parent="_dynamic"` means "current tab" — read from the InheritedWidget at runtime.

### A4. BottomNav (global, 6 tabs, icons-only)
**CSS source:** `#global-bnav-wrap .bnav` (line 85) and `.bnav` embedded (line 122)
- Outer wrap: `Container(color: Colors.black, padding: EdgeInsets.fromLTRB(16, 6, 16, 8 + safeAreaBottom), constraints: BoxConstraints(minHeight: 52))`
- Embedded: bg surf2, `BorderRadius.circular(16)`, padding `EdgeInsets.fromLTRB(2, 4, 2, 6)`, min height 44
- Items: `Expanded(flex: 1, child: ...)` with `AnimatedScale` for press feedback (`transition: transform .12s`)
- **Press scale: 0.88** (CSS source: `.bt:active { transform: scale(.88) }` shared.css line 103) — intentionally deeper than the general card press scale of 0.97 (`transitions.scale_pressed`). Do not unify these.
- Active item: accent color + subtle glow (`BoxShadow` with accent at 0.4 alpha, 8 blur)

**Order:** Focus, Tasks, Habits, Calendar, Notes, Inbox. No text labels.

**Focus icon:** compass/sunburst — 8 radial tick lines, two concentric rings (r=8, r=2.5), filled center dot (r=1). Asset: `assets/icons/focus_nav.svg`. Always accent-colored (`KaalColors.acc`), always 26×26 px regardless of active state. Note: `kaal_pkg/screens_png/` PNGs show an older crosshair design — the SVG asset is the ground truth for this icon.
**Hiding tabs:** when Settings → Features disables a tab, omit it from the children list entirely. Remaining items use `Expanded` so they redistribute.

### A5. FAB
**CSS source:** `.fab` (line 136)
- Size: 38×38 circle
- Color: KaalAcc (`#0A84FF`)
- Shadow: `BoxShadow(color: Color(0x800A84FF), blurRadius: 14, offset: Offset(0, 4))`
- Position: `Positioned(bottom: max(78, 78 + safeAreaBottom), right: 18, child: ...)` on mobile breakpoint
- Inner "+": `Text('+', style: TextStyle(fontSize: 23, fontWeight: FontWeight.w300, color: Colors.white))`
- `AnimatedScale(scale: pressed ? 0.97 : 1.0, duration: Duration(milliseconds: 120))`
**Constraint:** Visible only on Tasks and Habits tabs. Opens FAB chooser as a **bottom sheet**, not a full screen.

---

## B. Cards & Surfaces

### B1. GlassCard (generic translucent surface)
**CSS source:** `background: var(--surf)` + `border: 0.5px solid var(--bdr)` + `border-radius: 12px`
**Flutter:**
```dart
Container(
  decoration: BoxDecoration(
    color: tokens.colors.surf,                  // alpha already baked into glass theme
    borderRadius: BorderRadius.circular(12),
    border: Border.all(width: 0.5, color: tokens.colors.bdr),
  ),
  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
  child: child,
)
```
**No elevation / no shadow.** Depth comes from translucency over the wallpaper.

### B2. QuadrantCard `.qcard`
**CSS source:** Line 200
- `borderRadius: 12`, padding `EdgeInsets.fromLTRB(11, 10, 11, 10)`
- `constraints: BoxConstraints(minHeight: 72)` (68 on small viewports)
- Background `tokens.colors.surf`, border `0.5px tokens.colors.bdr2`
- `transition: transform .12s` → `AnimatedScale(scale: pressed ? 0.97 : 1.0, duration: 120ms)`
- Count number (`.qc-count`): `Positioned(bottom: 9, right: 11, child: Text(count, style: TextStyle(fontFamily: 'Fraunces', fontWeight: FontWeight.w700, fontSize: 19, color: ink.withOpacity(0.9))))`

**Tints:** Q1 #F25022 (orange-red), Q2 #7FBA00 (green), Q3 #00A4EF (blue), Q4 #FFB900 (yellow). Apply as a faint left border or background tint.

### B3. StatCard `.sc`
**CSS source:** Line 193
- `borderRadius: 14` (**not 12** — exception)
- padding `EdgeInsets.fromLTRB(6, 10, 6, 8)`
- Background surf, border `0.5 bdr`, text-align center
- `BoxShadow(color: Color(0x1F000000), blurRadius: 8, offset: Offset(0, 2))` (0.12 alpha)
- Number `.sc-n`: Fraunces 700 19sp, height 1
- Label `.sc-l`: Inter 11sp

### B4. SettingsCard `.set-card`
Container with surf bg, radius 12, border 0.5 bdr. Contains stacked `.set-row` items separated by `Divider(thickness: 0.5, color: bdr, height: 0)`.

### B5. SettingsGroup `.sgrp` (collapsible)
**CSS source:** Line 688
- borderRadius 12, border 0.5 bdr, margin-bottom 8
- Header `.sgrp-hdr`: padding `EdgeInsets.fromLTRB(12, 10, 12, 10)`, gap 8
- Icon `.sgrp-ico`: 28×28 with `BorderRadius.circular(8)`
- Title `.sgrp-title`: Inter 13 weight 600
- Chevron `.sgrp-chev`: rotates 90° via `AnimatedRotation(turns: expanded ? 0.25 : 0, duration: 200ms)`
- Body: `AnimatedSize` + `AnimatedSwitcher` or `AnimatedCrossFade` between collapsed and expanded

---

## C. Rows & Lists

### C1. TaskRow `.tr`
**CSS source:** Line 352
- Background `Color(0x0AFFFFFF)` (rgba(255,255,255,.04))
- borderRadius 12, padding `EdgeInsets.symmetric(horizontal: 12, vertical: 9)`
- Row with `crossAxisAlignment: CrossAxisAlignment.start, mainAxisSpacing: 8` (via `SizedBox(width: 8)` between children)

**Long press:** `GestureDetector(onLongPressStart: (details) {...}, onLongPress: () {...})`. 480ms threshold built into `onLongPress` (the platform default is 500ms; explicitly override using `LongPressGestureRecognizer` with `duration: Duration(milliseconds: 480)`).

### C2. HabitRow `.habit-card-full`
**CSS source:** Line 462
- Background surf2, radius 12, padding `EdgeInsets.fromLTRB(11, 9, 11, 9)`, border 0.5 bdr
- Children: name, schedule pill, 7-day dot grid (`Row` of 7 `Container`s 8×8 each), streak badge, ⋯ menu trigger

### C3. NoteRow
`GlassCard` with title (Inter weight 600), 1-line preview (`Text(..., maxLines: 1, overflow: TextOverflow.ellipsis)`), tag + timestamp row at bottom.

### C4. TimelineRow (Today's Plan)
Two-column `Row`: time string left (e.g. "08:30 AM" in Inter ink2), content right. Left border `Container(width: 3, color: quadrantColor)`.

### C5. Tiny Pill `.pill`
**CSS source:** Line 369
- Font: Inter weight 600, size 9, letterSpacing 0.2
- padding `EdgeInsets.symmetric(horizontal: 4, vertical: 1)`
- borderRadius 3
- For metadata badges like "Q1 · Overdue"

### C6. Filter Chip (larger pill)
Used in `.fl-pill-*`.
- Inter weight 600, size 9
- padding `EdgeInsets.symmetric(horizontal: 10, vertical: 4)`
- borderRadius 6
- **Active:** bg `tokens.colors.accBg`, color `tokens.colors.acc2`, border `0.5 Color(0x330A84FF)`
- **Ghost:** transparent, color ink3

### C7. SettingsRow `.set-row`
- padding `EdgeInsets.fromLTRB(11, 9, 11, 9)`, gap 8
- borderBottom: thin Divider 0.5 bdr below each row
- Icon `.set-ico`: 22×22, radius 6
- Label: Inter 13 weight 400 ink2 height 1.3
- Value: Inter 13 ink3

---

## D. Controls

### D1. Toggle Switch `.sw`
**CSS source:** Line 709 — **verified exact dimensions**
- Track: 32×17, radius 9
- Track off: `tokens.colors.surf3`; on: `tokens.colors.acc`
- Thumb: 13×13, circle, white, `BoxShadow(color: Color(0x4D000000), blurRadius: 3, offset: Offset(0, 1))`
- Thumb off position: top 2, left 2; on transform: translateX 14
- Animate thumb position with `AnimatedAlign` or `AnimatedPositioned` over 200ms.

**Flutter:** Build custom — do NOT use `Switch()` or `CupertinoSwitch()`:
```dart
GestureDetector(
  onTap: () => onChanged(!value),
  child: Container(
    width: 32, height: 17,
    decoration: BoxDecoration(
      color: value ? colors.acc : colors.surf3,
      borderRadius: BorderRadius.circular(9),
    ),
    child: AnimatedAlign(
      duration: const Duration(milliseconds: 200),
      alignment: value ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: Container(
          width: 13, height: 13,
          decoration: const BoxDecoration(
            color: Colors.white, shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: Color(0x4D000000), blurRadius: 3, offset: Offset(0, 1))],
          ),
        ),
      ),
    ),
  ),
)
```

### D2. ColorSwatch `.csw`
- 20×20 circle
- `border: 2 transparent`, selected: `2 Colors.white`
- `transition: transform .14s` → `AnimatedScale`
- Selected scale 1.15

### D3. SegmentedControl
Pill container with N buttons. Selected has accent fill, others transparent with ink3 text. Used for Theme picker, Font style, Layout, Quadrant names.

### D4. SizeChips (typography)
Row of 5 chips (sm/md/lg/xl/2xl). Selected has accent outline.

### D5. ContextMenu (long-press menu)
Anchored at touch coords. Use `showMenu` is NOT suitable (Material default styling). Build with `OverlayEntry` + `Positioned(left: touchX, top: touchY, child: ...)`.
- Open animation: fade + 8px slide-up over 180ms via `AnimatedOpacity` + `AnimatedSlide`
- **Critical timing:** outside-dismiss listener enabled only after 450ms delay
- **lpBlock guard:** after long-press fires, store `lastLongPressTime = DateTime.now().millisecondsSinceEpoch`. Inline `onTap` handlers check `if (now - lastLongPressTime < 700) return`.

### D6. AddBackButton `.add-back`
**CSS source:** Line 503
- 38×38 circle, transparent bg, no border
- Inner SVG 18px, stroke `tokens.colors.ink2`, strokeWidth 2
- `IconButton` with custom icon and `padding: EdgeInsets.zero, constraints: BoxConstraints(minWidth: 38, minHeight: 38)`

---

## E. Stats & Visualizations

### E1. ProgressBar
Thin horizontal bar (3 px tall), rounded ends. `Container` with `BorderRadius.circular(1.5)` + animated `FractionallySizedBox(widthFactor: value)`.

### E2. ProgressRing
Circular arc with stroke ~4. Use `CustomPaint` with `Canvas.drawArc`.

### E3. Heatmap
Monthly grid of small colored cells. `GridView.count(crossAxisCount: 7, ...)` with each cell colored by completion intensity.

### E4. BarChart
`CustomPaint` drawing vertical bars colored per quadrant. Or `flutter_charts` if you want a pre-built solution — but match the prototype's simple geometry.

### E5. TrendLine
`CustomPaint` with `Path` using `cubicTo` for smooth curves. Match the prototype's SVG `<path>`.

### E6. DonutChart
`CustomPaint` concentric arcs. Center text shows total hours. Q1/Q2/Q3 + Unplanned segments.

### E7. Pomodoro Timer Display
- Font: Fraunces 750, size 46
- `FontFeature.tabularFigures()` for stable digit width
- Color ink

---

## F. Overlays & Sheets

### F1. CompletedPanel (`p-panel-comp`)
Full-screen overlay. `Navigator.push(MaterialPageRoute(...))` with `transitionsBuilder` for slide-from-bottom 220ms. Header: back chevron + "✓ Completed" title.

### F2. AI Nudge Card
"✨ KAAL AI" prefix. CTA button + optional Dismiss. Used in Calendar (this-week nudge) and Quadrants (score-based recommendation).

### F3. FAB Chooser Sheet
`showModalBottomSheet` with `isScrollControlled: true, backgroundColor: Colors.transparent` and custom child styled to match. Overlay scrim:
```dart
BackdropFilter(
  filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
  child: Container(color: Color(0x80000000)),
)
```

### F4. Reward Modal `#kaal-reward-modal`
`showDialog` with `barrierColor: Color(0x99000000)`, wrap content in `BackdropFilter(filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6))`.

### F5. Streak Protect Dialog `#streak-protect-dialog`
Same pattern as F4 but `barrierColor: Color(0xA6000000)` and `blur(4)`.

---

## G. Gestures (universal behavior)

| Gesture | Spec | Flutter implementation |
|---|---|---|
| **Long press** | 480ms hold | `LongPressGestureRecognizer(duration: Duration(milliseconds: 480))` registered manually, or `GestureDetector(onLongPress:)` with `RawGestureDetector` if you need custom timing |
| **Long-press cancel** | Drag > 9 px | Track drag delta in `onPanUpdate` of `GestureDetector`; cancel pending long press |
| **Long-press pulse** | 110 ms pulse before menu | `AnimationController(duration: 110ms)` scale 1.0 → 0.97 → 1.0 |
| **Context menu outside-dismiss delay** | 450ms | `Future.delayed(Duration(milliseconds: 450), () => allowDismiss = true)` |
| **lpBlock window** | 700 ms | Store timestamp; inline `onTap` guards against this window |
| **Card press scale** | 0.97 over 120ms | `AnimatedScale(scale: pressed ? 0.97 : 1.0, duration: 120ms)` |
| **Screen enter animation** | 220ms slide-in-right (ease) | Custom `PageRouteBuilder` with `SlideTransition(position: tween.animate(curve))` |

---

## H. Theme variants

Three themes: **glass** (default), **dark**, **light**. Provide via `InheritedWidget` (`KaalTheme`) that exposes `KaalColors` based on current theme. Persist user choice in `shared_preferences`.

---

## J. Auth form widgets (Sign In / Sign Up screens)

These private widgets appear in both `signin_screen.dart` and `signup_screen.dart`. They are screen-private (leading `_`), but their spec is documented here so they are built consistently if either screen is modified. Do **not** extract them into `lib/widgets/` — they are auth-screen-specific.

### J1. `_Flbl` — Field label
Small ALL-CAPS label above each text input.
- `Text(label)`: Inter, 11sp, weight 700, letterSpacing 0.5, color `colors.ink3`
- Bottom padding: 5px

### J2. `_FinputField` — Text input field
Consistent text field for auth screens.
- `fillColor`: `colors.surf`
- `contentPadding`: symmetric(h:12, v:11)
- `borderRadius`: 12
- `enabledBorder`: 0.5px `colors.bdr`
- `focusedBorder`: 1px `KaalColors.acc`
- `hintStyle`: Inter 14sp `colors.ink3`
- `style`: Inter 14sp `colors.ink`
- Supports `obscureText` for password fields; `keyboardType` override for OTP (numeric)

### J3. `_SocialBtn` — OAuth provider button
Used for Google, Apple, and Microsoft buttons.
- Background: `colors.surf`, border: 0.5px `colors.bdr`, radius: 12
- Padding: symmetric vertical 11
- Row layout: 18×18 icon + 8px gap + Inter 13sp weight 500 `colors.ink` label
- Icons are inline SVG strings (`SvgPicture.string`): Google (multicolor), Apple (dynamic `colors.ink`), Microsoft (four-color squares)

### J4. "or continue with" divider
Horizontal rule with centered label. Used between action buttons and social buttons.
- Two `Expanded(child: Container(height: 0.5, color: colors.bdr))` with `Padding(h:16)` text between them
- Label: Inter 11sp `colors.ink3`

### J5. `_AvatarStack` — Overlapping avatar initials (Sign In only)
Three overlapping 20×20 circles with 6px overlap. Each has a colored bg, white 9sp Inter weight 700 initial, and 1.5px border in `colors.bg`. Used in the social proof row ("12,400+ users ⭐ 4.9 App Store").

### J6. OTP mode toggle pattern
Both Sign In and Sign Up have a `bool _otpMode` flag. When `true`:
- Password / Confirm-Password fields are replaced by a single OTP field (numeric, 6-digit hint)
- Primary action button becomes full-width
- "Forgot password?" label → "Resend OTP"
- "New here? Create account" link is hidden (Sign In only)
- "Have an account? Sign in" link remains visible (Sign Up)

## I. Anti-patterns — do NOT do

- Don't use `Switch()` or `CupertinoSwitch()` — both wrong shape. Build custom (D1).
- Don't use Material `Card` with `elevation > 0` — Kaal cards are flat translucent.
- Don't use `AppBar` — wrong insets, density, defaults. Build the top bar from `Container` + `Row`.
- Don't use `BottomNavigationBar` or `NavigationBar` — wrong proportions and styling.
- Don't use `InkWell` ripples — Kaal uses scale(0.97) on press.
- Don't use `ElevatedButton` for any tappable surface — wrap in `GestureDetector` + `AnimatedScale`.
- Don't add `BoxShadow` for "depth" — depth comes from translucency.
- Don't apply `BackdropFilter` to top bars or every card — only to overlays specified in `tokens.json → blur_usage` (modals, FAB chooser).
- Don't use `Padding` with `MediaQuery.of(context).viewInsets` defaults; honor the prototype's specific paddings.
- Don't use Material `ListTile` — its anatomy doesn't match. Build rows from `Row` + `Container`.
