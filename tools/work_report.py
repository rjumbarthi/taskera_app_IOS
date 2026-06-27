#!/usr/bin/env python
# Generates a self-contained HTML work-distribution report for the Kaal project.
# Charts are hand-rolled inline SVG (no external libs / no network).
import math, html, datetime

# ---- Data (lines of code, from `wc -l` over lib/, generated code excluded) ----
GENERATED = 13005          # Drift ORM codegen (database.g.dart) — machine-made
HANDWRITTEN = 45966
FILES = 165

# Architectural areas: (label, loc, files, color)
AREAS = [
    ("Feature screens",        35141, 59, "#0A84FF"),
    ("Shared UI widgets",       3914, 43, "#5E5CE6"),
    ("Integrations & services", 2267, 18, "#30D158"),
    ("Data & persistence",      2152, 25, "#FF9F0A"),
    ("Routing & navigation",     909,  4, "#BF5AF2"),
    ("Localization (19 langs)",  421,  2, "#FF375F"),
    ("Design system / theme",    375,  5, "#64D2FF"),
    ("App state & settings",     313,  3, "#FFD60A"),
    ("Config / util / entry",    474,  6, "#8E8E93"),
]

# Screens by feature: (label, loc, files)
FEATURES = [
    ("Tasks",       8079, 16),
    ("Focus",       7492, 12),
    ("Settings",    4922,  6),
    ("Habits",      3555,  6),
    ("Onboarding",  3041,  4),
    ("Calendar",    2042,  4),
    ("Profile",     1896,  3),
    ("Inbox / AI",  1592,  2),
    ("Misc (search, paywall, legal, gallery)", 1556, 4),
    ("Notes",        966,  2),
]

# High-level "where did the work go" buckets
BUCKETS = [
    ("Building features (screens + widgets)", 39055, "#0A84FF"),
    ("Backend: data, services, routing",       5328, "#30D158"),
    ("Design system & localization",            796, "#BF5AF2"),
    ("App infrastructure & state",              787, "#FFD60A"),
]

TOP_FILES = [
    ("settings/settings_screen.dart", 1761),
    ("tasks/tasks_screen.dart", 1755),
    ("settings/widget_preview_screen.dart", 1738),
    ("inbox/inbox_screen.dart", 1305),
    ("onboarding/onboard_screen.dart", 1290),
    ("focus/focus_screen.dart", 1191),
    ("tasks/edit_task_screen.dart", 1019),
    ("calendar/calendar_screen.dart", 983),
    ("habits/habits_screen.dart", 977),
    ("profile/profile_screen.dart", 939),
]

# Recent polishing/bug-fix session (this engagement) — qualitative
RECENT = [
    ("Theming", "Fixed light/dark surface tokens (surf2/bdr0 across ~100 sites); per-theme wallpaper brightness; edit-profile black-tint fix."),
    ("Layout / nav", "Central bottom-nav clearance so content/buttons stop hiding under the floating nav; Tasks list & 2×2 spacing."),
    ("Gestures / bugs", "Checkmark tap no longer opens details (habits + tasks); dead-zone buffer around the checkmark; streak no longer wiped on un-check; skip now protects the streak."),
    ("Features wired", "Onboarding answers persisted + goal → real task; 'Something came up?' skip card wired per-habit & globally; Tasks timer kept in Tasks tab."),
    ("Copy / polish", "Removed fake ratings; Invite added before Sign-out; App Store → App Store/Play Store; Privacy/Terms split; contact details updated; photo & Gmail set to 'coming soon'."),
]

ACCENT = "#0A84FF"
INK, INK2, INK3 = "#F2F2F7", "#C8C8D0", "#8A8A94"
BG, CARD, BORDER = "#0B0B12", "#15151F", "#2A2A38"

def pct(v, total): return v / total * 100.0

def donut(items, total, cx=130, cy=130, r=104, hole=58):
    # items: list of (label, value, color)
    out = []
    ang = -90.0
    for t in items:
        val, color = t[1], t[-1]
        sweep = val / total * 360.0
        a0 = math.radians(ang); a1 = math.radians(ang + sweep)
        x0, y0 = cx + r*math.cos(a0), cy + r*math.sin(a0)
        x1, y1 = cx + r*math.cos(a1), cy + r*math.sin(a1)
        xi0, yi0 = cx + hole*math.cos(a0), cy + hole*math.sin(a0)
        xi1, yi1 = cx + hole*math.cos(a1), cy + hole*math.sin(a1)
        large = 1 if sweep > 180 else 0
        out.append(
            f'<path d="M {x0:.2f} {y0:.2f} A {r} {r} 0 {large} 1 {x1:.2f} {y1:.2f} '
            f'L {xi1:.2f} {yi1:.2f} A {hole} {hole} 0 {large} 0 {xi0:.2f} {yi0:.2f} Z" '
            f'fill="{color}"/>'
        )
        ang += sweep
    out.append(f'<text x="{cx}" y="{cy-6}" text-anchor="middle" fill="{INK}" '
               f'font-size="26" font-weight="700">{total:,}</text>')
    out.append(f'<text x="{cx}" y="{cy+14}" text-anchor="middle" fill="{INK3}" '
               f'font-size="11" letter-spacing="1">LINES OF CODE</text>')
    return f'<svg viewBox="0 0 260 260" width="260" height="260">{"".join(out)}</svg>'

def legend(items, total):
    rows = []
    for t in items:
        label, val, color = t[0], t[1], t[-1]
        rows.append(
            f'<div class="lg"><span class="dot" style="background:{color}"></span>'
            f'<span class="lglabel">{html.escape(label)}</span>'
            f'<span class="lgval">{pct(val,total):.1f}%<i>{val:,}</i></span></div>')
    return "".join(rows)

def hbars(items, color=ACCENT, unit="LOC"):
    mx = max(v for _, v, *_ in items)
    rows = []
    for t in items:
        label, val = t[0], t[1]
        files = t[2] if len(t) > 2 else None
        w = val / mx * 100.0
        extra = f' · {files} files' if files is not None else ''
        rows.append(
            f'<div class="bar"><div class="barhead"><span>{html.escape(label)}</span>'
            f'<span class="barval">{val:,}<i>{unit}{extra}</i></span></div>'
            f'<div class="track"><div class="fill" style="width:{w:.1f}%;background:{color}"></div></div></div>')
    return "".join(rows)

now = datetime.date.today().strftime("%B %d, %Y")
total_areas = sum(a[1] for a in AREAS)

doc = f"""<!doctype html><html><head><meta charset="utf-8">
<title>Kaal — Work Distribution Report</title>
<style>
@page {{ size: A4; margin: 16mm; }}
* {{ box-sizing: border-box; }}
body {{ margin:0; background:{BG}; color:{INK};
  font-family:-apple-system,Segoe UI,Inter,Roboto,sans-serif; -webkit-print-color-adjust:exact; print-color-adjust:exact; }}
.wrap {{ max-width:900px; margin:0 auto; padding:40px 36px; }}
h1 {{ font-size:30px; margin:0 0 4px; letter-spacing:-.5px; }}
.sub {{ color:{INK3}; font-size:13px; margin-bottom:28px; }}
.grid {{ display:grid; grid-template-columns:1fr 1fr 1fr 1fr; gap:12px; margin-bottom:30px; }}
.stat {{ background:{CARD}; border:1px solid {BORDER}; border-radius:14px; padding:16px; }}
.stat .n {{ font-size:24px; font-weight:700; }}
.stat .l {{ font-size:11px; color:{INK3}; margin-top:3px; }}
.card {{ background:{CARD}; border:1px solid {BORDER}; border-radius:16px; padding:22px 24px; margin-bottom:22px; }}
.card h2 {{ font-size:16px; margin:0 0 4px; }}
.card .cap {{ font-size:12px; color:{INK3}; margin:0 0 18px; }}
.split {{ display:flex; gap:26px; align-items:center; }}
.split .leg {{ flex:1; }}
.lg {{ display:flex; align-items:center; gap:9px; padding:5px 0; font-size:13px; }}
.dot {{ width:11px; height:11px; border-radius:3px; flex:none; }}
.lglabel {{ flex:1; color:{INK2}; }}
.lgval {{ font-weight:700; }}
.lgval i {{ font-style:normal; color:{INK3}; font-weight:400; margin-left:8px; font-size:11px; }}
.bar {{ margin:11px 0; }}
.barhead {{ display:flex; justify-content:space-between; font-size:12.5px; color:{INK2}; margin-bottom:5px; }}
.barval {{ font-weight:700; color:{INK}; }}
.barval i {{ font-style:normal; color:{INK3}; font-weight:400; font-size:11px; margin-left:6px; }}
.track {{ height:9px; background:#23232E; border-radius:6px; overflow:hidden; }}
.fill {{ height:100%; border-radius:6px; }}
table {{ width:100%; border-collapse:collapse; font-size:13px; }}
td {{ padding:7px 0; border-bottom:1px solid {BORDER}; color:{INK2}; }}
td.n {{ text-align:right; font-weight:700; color:{INK}; }}
.note {{ font-size:12px; color:{INK3}; line-height:1.6; }}
.rk {{ display:flex; gap:12px; padding:9px 0; border-bottom:1px solid {BORDER}; }}
.rk b {{ color:{ACCENT}; min-width:120px; font-size:13px; }}
.rk span {{ color:{INK2}; font-size:12.5px; line-height:1.5; }}
.foot {{ color:{INK3}; font-size:11px; margin-top:8px; }}
</style></head><body><div class="wrap">

<h1>Kaal — Where the work went</h1>
<div class="sub">Effort distribution across the codebase · generated {now} · proxy = lines of hand-written code</div>

<div class="grid">
  <div class="stat"><div class="n">{HANDWRITTEN:,}</div><div class="l">hand-written Dart LOC</div></div>
  <div class="stat"><div class="n">{FILES}</div><div class="l">Dart source files</div></div>
  <div class="stat"><div class="n">10</div><div class="l">feature areas</div></div>
  <div class="stat"><div class="n">{GENERATED:,}</div><div class="l">generated (ORM) LOC*</div></div>
</div>

<div class="card">
  <h2>Code by architectural area</h2>
  <p class="cap">How the {total_areas:,} hand-written lines split across the app's layers.</p>
  <div class="split">
    <div>{donut(AREAS, total_areas)}</div>
    <div class="leg">{legend(AREAS, total_areas)}</div>
  </div>
</div>

<div class="card">
  <h2>Where did the work go? — by character of work</h2>
  <p class="cap">Higher-level grouping. UI/feature building dominates; the rest is backend, design-system and infra.</p>
  {hbars(BUCKETS, ACCENT)}
</div>

<div class="card">
  <h2>Feature surfaces — screens by area</h2>
  <p class="cap">Within the {AREAS[0][1]:,} lines of feature screens, the biggest investments were Tasks and Focus.</p>
  {hbars(FEATURES, "#5E5CE6")}
</div>

<div class="card">
  <h2>Largest single files</h2>
  <table>{''.join(f'<tr><td>{html.escape(n)}</td><td class="n">{v:,}</td></tr>' for n,v in TOP_FILES)}</table>
</div>

<div class="card">
  <h2>Recent session — polishing &amp; bug-fixing</h2>
  <p class="cap">Qualitative summary of the most recent engagement (not time-tracked).</p>
  {''.join(f'<div class="rk"><b>{html.escape(t)}</b><span>{html.escape(d)}</span></div>' for t,d in RECENT)}
</div>

<div class="card">
  <h2>Method &amp; caveats</h2>
  <p class="note">
  Effort here is approximated by <b>lines of hand-written Dart</b> per area — a rough proxy, not real time tracking
  (the project's git history is a single squashed commit, so per-commit effort over time can't be reconstructed).
  LOC under-counts dense work like the <b>localization</b> file (19 languages packed into long single lines) and
  visual/polish work (which often changes few lines for big effect). <br><br>
  * The {GENERATED:,} generated lines (Drift database.g.dart) are machine-produced from table definitions and are
  excluded from the effort totals — they represent &lt;1 hour of schema authoring, not {GENERATED:,} lines of labour.
  </p>
  <div class="foot">Kaal · Flutter cross-platform productivity app · report auto-generated from the working tree.</div>
</div>

</div></body></html>"""

with open("kaal_work_report.html", "w", encoding="utf-8") as f:
    f.write(doc)
print("wrote kaal_work_report.html", len(doc), "bytes")
