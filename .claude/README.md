# `.claude/` — Claude Code helpers for Kaal (Flutter)

Slash commands and an optional hook for Claude Code.

## Setup

Copy this folder to your project root:

```
YourFlutterProject/
├── .claude/                ← copy from kaal_pkg/.claude/ to project root
│   ├── commands/
│   │   ├── build-screen.md
│   │   ├── diff-png.md
│   │   ├── verify-tokens.md
│   │   └── find-css.md
│   ├── hooks.json          ← optional, runs flutter analyze after edits
│   └── README.md
├── CLAUDE.md
├── kaal_pkg/
└── lib/
```

`.claude/` lives at the **project root**, not inside `kaal_pkg/`.

## Slash commands

Type `/` in Claude Code to see them.

### `/build-screen 03-09_task_detail`
Builds a single Flutter screen from a screen ID. Forces the workflow: read PNG → read HTML → plan → build → analyze → present for visual review. Stops before commit.

### `/diff-png 03-09_task_detail`
Compares current Flutter render to the reference PNG. Lists drift without fixing.

### `/verify-tokens`
Audits `lib/theme/` Dart files against `tokens.json`.

### `/find-css .sgrp`
Looks up a CSS class in `shared.css` and the prototype HTML. Returns rules with line numbers.

## Optional: auto-analyze hook

`hooks.json` runs `flutter analyze` after every `.dart` edit. Catches errors immediately.

Enable: move to `<project-root>/.claude/hooks.json` (already correct if you copied the whole folder).
Disable: delete or rename.

## Adding your own commands

`.claude/commands/<name>.md` with frontmatter:

```markdown
---
description: One-line summary
argument-hint: <args>
---

Instructions. Use $ARGUMENTS for user input after the command.
```

Kaal-specific ideas:
- `/seed-data` — generate Drift seed data from the prototype `<script>` block
- `/check-no-material` — grep for forbidden Material defaults (Switch, Card with elevation, AppBar, ListTile, InkWell, ElevatedButton)
- `/run-windows` — build and launch the Windows desktop variant
