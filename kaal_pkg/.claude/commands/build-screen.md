---
description: Build a single Flutter screen from a screen ID, following the Kaal package workflow.
argument-hint: <screen-id> (e.g. 03-09_task_detail)
---

Build the Flutter screen for `$ARGUMENTS`. Follow this exact sequence:

1. **Read the PNG** — `kaal_pkg/screens_png/$ARGUMENTS.png`. If not found, list matches and ask.

2. **Read the HTML extract** — `kaal_pkg/screens_html/$ARGUMENTS.html`. Per-screen HTML shows initial render state only — scrolled/expanded/filtered/modal states are reflected only in the PNG.

3. **Read SCREEN_MAP.md row** — find $ARGUMENTS in `kaal_pkg/specs/SCREEN_MAP.md`. Note screen id, parent, state notes.

4. **Identify the target file path** — `lib/screens/<section>/<name>_screen.dart`. Section maps from inventory section.

5. **Plan, don't code yet.** List:
   - Which widget functions you'll create (Stateless/Stateful/Consumer)
   - Which existing widgets from `lib/widgets/` you'll reuse
   - Any new widget needed (if missing, stop and ask — don't inline one-offs)
   - Required state (Riverpod provider? local State? scroll controllers?)
   - Gesture wiring (long press? card press scale?)

6. **Build the screen.** Use only:
   - Tokens via `KaalTheme.of(context).colors / .type / .shape / .motion`
   - Widgets from `lib/widgets/`
   - Literal paddings from HTML inline styles or `tokens.json → components_dimensions`
   - No Material defaults (Switch, Card with elevation, AppBar, NavigationBar, ListTile, InkWell ripple, ElevatedButton) unless they match the spec exactly
   - No Cupertino widgets either
   - No invented spacing

7. **Add a preview entry** — register the screen in the gallery (`lib/gallery/gallery_screen.dart`) so it can be viewed without full routing. Use sample data from `lib/data/sample_data.dart`.

8. **Compile** — run `flutter analyze` and fix issues until clean.

9. **Show me** — print the file path, file contents, and confirm:
   - "flutter analyze: 0 issues ✓"
   - "Used widgets: [list]"
   - "Sourced paddings/sizes from: [list with line refs to tokens.json or shared.css]"

10. **Stop. Wait for approval.** Don't run on emulator or commit yet. I'll inspect the gallery preview first. Once I confirm visual match against the PNG, I'll say "commit it."
