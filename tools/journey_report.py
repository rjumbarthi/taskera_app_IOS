#!/usr/bin/env python
# Kaal — full journey: every attempt (concept -> native -> prototype -> Flutter)
# + current state. Self-contained HTML (inline SVG); PDF via headless Edge.
import html, datetime

ACCENT="#0A84FF"; INK="#F2F2F7"; INK2="#C8C8D0"; INK3="#8A8A94"
BG="#0B0B12"; CARD="#15151F"; BORDER="#2A2A38"
KT="#7F52FF"; HTMLC="#FF9F0A"; DART="#0A84FF"; IOS="#FF375F"; DOC="#8E8E93"; WEB="#30D158"

# Chronological — (date, name, stack, size_label, loc, color, star)
ATTEMPTS=[
 ("Apr 22","Kaal-app","Concept &amp; planning","7 spec docs",0,DOC,False),
 ("Apr 29","KaalFocusTaskPlanner","Android skeleton · Kotlin","Gradle scaffold",0,KT,False),
 ("Apr 29","KaalIOS","iOS skeleton · Swift / Xcode","Xcode scaffold",0,IOS,False),
 ("May 16","KaalFocusTaskPlanner_CC","Native Android · Kotlin","6,825 LOC",6825,KT,False),
 ("May 18","KaalFocusTaskPlanner","Native Android · Kotlin","6,173 LOC",6173,KT,False),
 ("May 26","Kaal","Native Android · Kotlin","7,306 LOC",7306,KT,False),
 ("May 26","Prototype","HTML / CSS / JS reference","14,011 LOC",14011,HTMLC,False),
 ("Jun 23","kaal_app","Flutter · Android·iOS·Web·Windows","45,966 LOC",45966,DART,True),
 ("Jun 24","kaal-site","Web · GitHub Pages","518 LOC",518,WEB,False),
]

# Size comparison — only the substantive code artifacts
SIZES=[
 ("Native Android #1 · KFTP_CC (Kotlin)",6825,KT),
 ("Native Android #2 · KFTP (Kotlin)",6173,KT),
 ("Native Android #3 · Kaal (Kotlin)",7306,KT),
 ("Prototype (HTML/CSS/JS)",14011,HTMLC),
 ("Flutter app — current (Dart)",45966,DART),
]

TIMELINE=[
 ("Apr","Concept &amp; planning","A planning repo (Kaal-app) — ~7 spec/markdown docs defining the product before any code."),
 ("Apr","Native skeletons — both platforms","Parallel scaffolds: an Android project (Kotlin/Gradle) and an iOS project (Swift/Xcode) to test the native route on each platform."),
 ("May","Native Android in Kotlin · 3 iterations","Committed to native Android — three rebuilds in Android Studio (KFTP_CC, KFTP, Kaal), ~6–7k Kotlin lines each, ~20k lines of native exploration total."),
 ("May","The prototype","A 14,011-line single-file HTML/CSS/JS prototype + 100-screen reference pack — locking the exact visuals &amp; interactions as the source of truth."),
 ("Jun","The Flutter pivot","Rather than maintain separate Kotlin + Swift codebases, pivoted to Flutter — one codebase now targets Android, iOS, Web &amp; Windows. Grew to 45,966 Dart LOC."),
 ("Jun","Site &amp; release","Marketing site on jumbarthi.com, privacy/terms, Supabase keep-alive CI, first signed release AAB — then the polish pass."),
]

SHIPPED=[
 "59 screens across 10 feature areas (Focus, Tasks, Habits, Calendar, Notes, Inbox/AI, Profile, Settings, Onboarding)",
 "Drift local database (15 tables) + Supabase cloud sync &amp; auth",
 "Notifications — reminders + reschedule-on-boot; Google sign-in &amp; Calendar",
 "19-language localization · 3 themes + per-theme wallpaper brightness",
 "Onboarding wired (goal → real task); streak engine with skip-protection",
 "One codebase → 4 platforms; signed release AAB builds",
]
PENDING=[
 "Gmail sync — flag off, awaiting OAuth verification + CASA",
 "Photo upload — “coming soon”",
 "Secondary integrations (Outlook, WhatsApp, Slack, Telegram) — display-only",
 "Reschedule-to-date model (skip = today only); persona personalization not yet surfaced",
 "App-wide nav-clearance change needs a visual QA pass · 2 open TODOs",
]

def hbars(items):
    mx=max(v for _,v,_ in items)
    out=[]
    for name,loc,color in items:
        w=loc/mx*100
        out.append(f'<div class="bar"><div class="barhead"><span>{html.escape(name)}</span>'
                   f'<span class="barval">{loc:,}<i>lines</i></span></div>'
                   f'<div class="track"><div class="fill" style="width:{w:.1f}%;background:{color}"></div></div></div>')
    return "".join(out)

now=datetime.date.today().strftime("%B %d, %Y")
kt_total=6825+6173+7306

rows="".join(
 f'<tr{" class=star" if star else ""}><td class="dt">{d}</td>'
 f'<td><span class="pill" style="background:{c}22;color:{c};border-color:{c}55">{html.escape(stack)}</span></td>'
 f'<td class="nm">{html.escape(name)}{" ★" if star else ""}</td>'
 f'<td class="sz">{html.escape(size)}</td></tr>'
 for d,name,stack,size,loc,c,star in ATTEMPTS)

tl="".join(
 f'<div class="step"><div class="sdot"></div><div class="sbody">'
 f'<div class="sphase">{m}</div><b>{t}</b><span>{d}</span></div></div>'
 for m,t,d in TIMELINE)

def col(items,mark,mc):
    return "".join(f'<div class="ci"><span class="ck" style="color:{mc}">{mark}</span><span>{x}</span></div>' for x in items)

doc=f"""<!doctype html><html><head><meta charset="utf-8"><title>Kaal — Full Journey</title>
<style>
@page {{ size:A4; margin:14mm; }}
*{{box-sizing:border-box}}
body{{margin:0;background:{BG};color:{INK};font-family:-apple-system,Segoe UI,Inter,Roboto,sans-serif;-webkit-print-color-adjust:exact;print-color-adjust:exact}}
.wrap{{max-width:920px;margin:0 auto;padding:36px 34px}}
h1{{font-size:28px;margin:0 0 4px;letter-spacing:-.5px}}
.sub{{color:{INK3};font-size:13px;margin-bottom:22px}}
.card{{background:{CARD};border:1px solid {BORDER};border-radius:16px;padding:20px 22px;margin-bottom:18px}}
.card h2{{font-size:16px;margin:0 0 4px}} .card .cap{{font-size:12px;color:{INK3};margin:0 0 14px}}
.big{{display:flex;gap:11px;margin-bottom:20px}}
.bx{{flex:1;background:{CARD};border:1px solid {BORDER};border-radius:14px;padding:14px}}
.bx .n{{font-size:21px;font-weight:700}} .bx .l{{font-size:11px;color:{INK3};margin-top:3px}}
table{{width:100%;border-collapse:collapse;font-size:12.5px}}
td{{padding:8px 6px;border-bottom:1px solid {BORDER};vertical-align:middle}}
tr.star td{{background:rgba(10,132,255,.10)}}
.dt{{color:{INK3};white-space:nowrap;font-variant-numeric:tabular-nums;width:54px}}
.nm{{font-weight:700;color:{INK};white-space:nowrap}}
.sz{{color:{INK2};text-align:right;white-space:nowrap}}
.pill{{display:inline-block;padding:2px 8px;border-radius:20px;border:1px solid;font-size:11px;font-weight:600}}
.bar{{margin:11px 0}} .barhead{{display:flex;justify-content:space-between;font-size:12.5px;color:{INK2};margin-bottom:5px}}
.barval{{font-weight:700;color:{INK}}} .barval i{{font-style:normal;color:{INK3};font-weight:400;font-size:11px;margin-left:6px}}
.track{{height:10px;background:#23232E;border-radius:6px;overflow:hidden}} .fill{{height:100%;border-radius:6px}}
.step{{display:flex;gap:13px;padding-bottom:15px;position:relative}}
.sdot{{width:12px;height:12px;border-radius:50%;background:{ACCENT};margin-top:3px;flex:none;box-shadow:0 0 0 4px rgba(10,132,255,.18)}}
.step:not(:last-child)::before{{content:'';position:absolute;left:5.5px;top:15px;bottom:0;width:1.5px;background:{BORDER}}}
.sbody b{{font-size:13.5px}} .sbody span{{display:block;font-size:12.5px;color:{INK2};line-height:1.5;margin-top:2px}}
.sphase{{font-size:10px;letter-spacing:1.2px;text-transform:uppercase;color:{ACCENT};font-weight:700}}
.cols{{display:flex;gap:22px}} .cols>div{{flex:1}}
.colh{{font-size:13px;font-weight:700;margin-bottom:9px}}
.ci{{display:flex;gap:8px;padding:5px 0;font-size:12px;color:{INK2};line-height:1.45;align-items:flex-start}}
.ck{{font-weight:700;flex:none}}
.ins{{background:linear-gradient(90deg,rgba(127,82,255,.14),rgba(10,132,255,.14));border:1px solid {BORDER};border-radius:14px;padding:16px 18px;font-size:13.5px;color:{INK};line-height:1.55;margin-bottom:18px}}
.ins b{{color:{ACCENT}}}
.foot{{color:{INK3};font-size:11px;line-height:1.6}}
</style></head><body><div class="wrap">

<h1>Kaal — the full journey</h1>
<div class="sub">Every build from concept to today: concept → native (Android + iOS) → prototype → the Flutter pivot · {now}</div>

<div class="big">
  <div class="bx"><div class="n">8</div><div class="l">Kaal builds in ~2 months</div></div>
  <div class="bx"><div class="n">4</div><div class="l">stacks tried (Kotlin · Swift · HTML · Dart)</div></div>
  <div class="bx"><div class="n">~{kt_total//1000}k</div><div class="l">Kotlin lines across 3 native attempts</div></div>
  <div class="bx"><div class="n">45,966</div><div class="l">Dart lines in the current app</div></div>
</div>

<div class="ins">
  <b>The arc:</b> Kaal started as planning docs, then chased <b>native</b> — an iOS (Swift) skeleton and <b>three</b>
  native-Android (Kotlin) rebuilds through May (~20k lines of exploration). After locking the design in a 14k-line
  HTML prototype, the project <b>pivoted to Flutter</b> so a single codebase could ship Android, iOS, Web and Windows —
  the current 45,966-line app.
</div>

<div class="card">
  <h2>Every Kaal attempt</h2>
  <p class="cap">Chronological · ★ = current production project.</p>
  <table>{rows}</table>
</div>

<div class="card">
  <h2>Relative size of the real builds</h2>
  <p class="cap">Each native Android attempt was ~6–7k Kotlin; the Flutter app is ~3× the prototype and ~6× any single native attempt — but covers four platforms.</p>
  {hbars(SIZES)}
</div>

<div class="card">
  <h2>The journey</h2>
  {tl}
</div>

<div class="card">
  <h2>Current state</h2>
  <p class="cap">Core product is feature-complete and building signed releases; the rest is integrations gated on external approval, plus polish.</p>
  <div class="cols">
    <div><div class="colh" style="color:#30D158">✓ Shipped / built</div>{col(SHIPPED,'✓','#30D158')}</div>
    <div><div class="colh" style="color:#FF9F0A">○ Coming soon / pending</div>{col(PENDING,'○','#FF9F0A')}</div>
  </div>
</div>

<div class="card">
  <p class="foot">Line counts are over each project's working tree (Kotlin <code>.kt</code>, Dart <code>.dart</code> excl. generated, prototype HTML/CSS/JS). Dates are folder timestamps. Earliest concept/skeleton repos (Kaal-app docs, OneDrive Android/iOS scaffolds) carried little code and are shown without a line count. Generated ORM code (13,005 lines) is excluded from the app total. Auto-generated {now}.</p>
</div>

</div></body></html>"""

with open("kaal_journey_report.html","w",encoding="utf-8") as f: f.write(doc)
print("wrote kaal_journey_report.html", len(doc), "bytes")
