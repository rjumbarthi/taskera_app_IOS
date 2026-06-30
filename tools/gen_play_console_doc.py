"""Generate a formatted .docx step-by-step guide for publishing Kaal on the
Google Play Console. Run: python tools/gen_play_console_doc.py"""
from docx import Document
from docx.shared import Pt, RGBColor, Inches
from docx.enum.text import WD_ALIGN_PARAGRAPH

ACCENT = RGBColor(0x0A, 0x84, 0xFF)
GREY = RGBColor(0x66, 0x66, 0x66)

doc = Document()

# ── base styles ──────────────────────────────────────────────────────────────
normal = doc.styles["Normal"]
normal.font.name = "Calibri"
normal.font.size = Pt(11)


def h1(text):
    p = doc.add_heading(text, level=1)
    for r in p.runs:
        r.font.color.rgb = ACCENT
    return p


def h2(text):
    return doc.add_heading(text, level=2)


def body(text, italic=False, bold=False):
    p = doc.add_paragraph()
    r = p.add_run(text)
    r.italic = italic
    r.bold = bold
    return p


def note(text):
    p = doc.add_paragraph()
    r = p.add_run("Note: ")
    r.bold = True
    r.font.color.rgb = ACCENT
    r2 = p.add_run(text)
    r2.font.color.rgb = GREY
    return p


def steps(items):
    for it in items:
        doc.add_paragraph(it, style="List Number")


def bullets(items):
    for it in items:
        doc.add_paragraph(it, style="List Bullet")


def kv_table(rows):
    t = doc.add_table(rows=0, cols=2)
    t.style = "Light Grid Accent 1"
    for k, v in rows:
        cells = t.add_row().cells
        cells[0].text = k
        cells[1].text = v
        for r in cells[0].paragraphs[0].runs:
            r.bold = True
    doc.add_paragraph()
    return t


# ── Title ────────────────────────────────────────────────────────────────────
title = doc.add_heading("Kaal — Google Play Console Guide", level=0)
sub = doc.add_paragraph("Step-by-step: create the app and publish to Google Play")
sub.runs[0].italic = True
sub.runs[0].font.color.rgb = GREY
doc.add_paragraph("Product of Port443 LLC  ·  Package: com.port443.kaal").runs[0].font.color.rgb = GREY

# ── Before you start ──────────────────────────────────────────────────────────
h1("Before you start — what you need")
bullets([
    "A Google account to register as a developer (one-time $25 fee).",
    "Your signed app bundle: build/app/outputs/bundle/release/app-release.aab (already built, v1.0.0+1).",
    "Backend live: Supabase functions + secrets + migrations + email templates done.",
    "A working support inbox: kaal_support@jumbarthi.com.",
    "Live web pages: privacy policy, support, and account-deletion URLs (below).",
])
kv_table([
    ("App name", "Kaal — Focus & Task Planner"),
    ("Developer", "Port443 LLC"),
    ("Package name", "com.port443.kaal"),
    ("Category", "Productivity"),
    ("Privacy policy", "https://jumbarthi.com/kaal/privacy"),
    ("Support URL", "https://jumbarthi.com/kaal/support"),
    ("Account deletion URL", "https://jumbarthi.com/kaal/delete"),
    ("Support email", "kaal_support@jumbarthi.com"),
    ("Subscription IDs", "kaal_pro_monthly, kaal_pro_annual"),
])

# ── 1. Developer account ──────────────────────────────────────────────────────
h1("1. Create your Google Play Developer account")
steps([
    "Go to play.google.com/console and sign in with the Google account you want to own the app.",
    "Choose account type: 'Organization' (for Port443 LLC) — you'll provide business details and may need D-U-N-S verification.",
    "Pay the one-time $25 USD registration fee.",
    "Complete identity / contact verification. This can take a few hours to a couple of days — start it early.",
])
note("If you registered as an Organization, Google verifies your business before you can publish. Do this first so it isn't a launch-day blocker.")

# ── 2. Create the app ─────────────────────────────────────────────────────────
h1("2. Create the app")
steps([
    "In Play Console, click 'Create app' (top right).",
    "App name: Kaal — Focus & Task Planner.",
    "Default language: English (United States) — or your preferred default.",
    "App or game: App.",
    "Free or paid: Free.  (You'll add in-app subscriptions separately.)",
    "Tick the Declarations: Developer Program Policies + US export laws.",
    "Click 'Create app'. You now land on the app Dashboard.",
])
note("'Free' here means the install is free. Kaal Pro subscriptions are added later under Monetize and do not change this setting.")

# ── 3. Dashboard set-up tasks ─────────────────────────────────────────────────
h1("3. Work through the Dashboard 'Set up your app' tasks")
body("The Dashboard shows a checklist. Complete each item (sections 4–6 below cover the substantive ones):")
bullets([
    "Set up your store listing (Section 4).",
    "Set up your subscriptions (Section 5).",
    "App content / Policy declarations (Section 6).",
    "Select your testing track and upload your build (Section 7).",
])

# ── 4. Store listing ──────────────────────────────────────────────────────────
h1("4. Main store listing")
body("Go to Grow → Store presence → Main store listing. Fill in:")
h2("Text")
kv_table([
    ("App name (≤30)", "Kaal — Focus & Task Planner"),
    ("Short description (≤80)", "Plan, focus & execute with Covey's 4 quadrants — tasks, habits, goals & AI."),
])
body("Full description (paste):")
body(
    "Kaal is an Execution OS for high performers. It organizes everything you do into "
    "Covey's four quadrants — Do Now, Schedule, Delegate, Eliminate — so your time goes "
    "to what matters.\n\n"
    "• Tasks with smart quadrant sorting & Eisenhower prioritization\n"
    "• Habits with streaks, routines and a 30-day view\n"
    "• Goals linked to the tasks and habits that move them\n"
    "• Calendar with conflict detection + Gmail/Calendar sync\n"
    "• Notes with tags, links and AI summaries\n"
    "• Brain Dump — empty your head, AI sorts it into tasks & goals\n"
    "• Pomodoro, time tracking, end-of-day reflection, weekly reviews\n"
    "• Home-screen widgets, glass themes, 18 languages\n\n"
    "Bring your own OpenAI or Claude key, or go Pro for unlimited AI. Your data syncs "
    "securely across devices. Kaal is a product of Port443 LLC."
)
h2("Graphics (upload)")
bullets([
    "App icon — 512×512 PNG  →  playstore/icon_512.png",
    "Feature graphic — 1024×500 PNG  →  playstore/feature_graphic_1024x500.png",
    "Phone screenshots — at least 2, min 1080×1920  →  pick from the /screenshots folder "
    "(e.g. 10_focus, 2g_tasks_quad_q1, 30_habits, 40_calendar, 60_notes, a0_paywall); crop to 9:16.",
])
note("Screenshots must be at least 1080 px on the short side. The /screenshots PNGs are desktop-sized — crop them to a phone 9:16 frame before uploading.")

# ── 5. Subscriptions ──────────────────────────────────────────────────────────
h1("5. Subscriptions (Kaal Pro)")
body("Go to Monetize → Products → Subscriptions. Create two products:")
h2("kaal_pro_monthly")
bullets([
    "Product ID: kaal_pro_monthly",
    "Base plan ID: monthly — billing period P1M (monthly), auto-renewing",
    "Optional intro offer: discounted first month",
])
h2("kaal_pro_annual")
bullets([
    "Product ID: kaal_pro_annual",
    "Base plan ID: annual — billing period P1Y (yearly), auto-renewing (~40% cheaper per month)",
    "Optional free-trial / intro offer",
])
body("Set per-country prices to these USD tiers, then Activate both products:")
t = doc.add_table(rows=1, cols=4)
t.style = "Light Grid Accent 1"
hdr = t.rows[0].cells
for i, txt in enumerate(["Tier", "Example countries", "Monthly", "Yearly (per-month)"]):
    hdr[i].text = txt
    hdr[i].paragraphs[0].runs[0].bold = True
for row in [
    ("1 — High income", "US, CA, GB, EU, AU, JP, SG, AE…", "$2.99", "$1.79"),
    ("2 — Middle income", "BR, MX, TR, ZA, TH, ID, PL…", "$1.99", "$1.19"),
    ("3 — Everywhere else", "India, South Asia, most of Africa", "$0.99", "$0.59"),
]:
    c = t.add_row().cells
    for i, v in enumerate(row):
        c[i].text = v
doc.add_paragraph()
note("Without ACTIVE subscription products, the in-app paywall has nothing to sell. Activate both before testing purchases.")

# ── 6. App content / compliance ───────────────────────────────────────────────
h1("6. App content (policy & compliance)")
body("Go to Policy → App content and complete every section:")
h2("Privacy policy")
bullets(["Enter: https://jumbarthi.com/kaal/privacy"])
h2("Ads")
bullets(["Does your app contain ads?  YES — Google AdMob (free-plan users only; Pro is ad-free)."])
h2("Data safety")
body("Declare the following data as collected:")
t = doc.add_table(rows=1, cols=4)
t.style = "Light Grid Accent 1"
for i, txt in enumerate(["Data", "Collected", "Linked to user", "Purpose"]):
    c = t.rows[0].cells[i]
    c.text = txt
    c.paragraphs[0].runs[0].bold = True
for row in [
    ("Email address", "Yes", "Yes", "Account management"),
    ("App content (tasks, notes, habits, goals, calendar)", "Yes", "Yes", "App functionality (sync)"),
    ("Purchase history", "Yes", "Yes", "Subscription management"),
    ("App activity / analytics", "Yes", "No (anonymous)", "Analytics (opt-out in app)"),
    ("Advertising ID", "Yes", "No", "Advertising (free plan)"),
]:
    c = t.add_row().cells
    for i, v in enumerate(row):
        c[i].text = v
doc.add_paragraph()
bullets([
    "Data sold to third parties: No.",
    "Data encrypted in transit: Yes.",
    "Users can request deletion: Yes — in-app and at https://jumbarthi.com/kaal/delete.",
    "Disclose: note/task text is sent to the AI provider (Anthropic/OpenAI) when AI features are used.",
])
h2("Content rating")
bullets([
    "Complete the questionnaire. Category: Productivity / Utility.",
    "Answer 'No' to violence, sexuality, profanity, gambling, drugs, user location sharing.",
    "Digital purchases: Yes. Expected result: Everyone / PEGI 3.",
])
h2("Target audience")
bullets(["Target age: 13 and over (the app has an age gate). Not designed for children: No."])
h2("Sensitive permissions")
body("Declare these two with the justifications:")
kv_table([
    ("SCHEDULE_EXACT_ALARM", "Kaal schedules user-created task & habit reminders/alarms that must trigger at the exact set time."),
    ("USE_FULL_SCREEN_INTENT", "Used for time-critical task/habit alarm notifications the user explicitly sets."),
])
h2("Account deletion")
bullets([
    "In-app path: Profile → Edit profile → Delete account.",
    "Web URL: https://jumbarthi.com/kaal/delete.",
])
h2("App access")
bullets([
    "If sign-in is needed for review, provide a test account, OR tell reviewers to use "
    "'Skip — use local storage' on the sign-in screen (no account required).",
])

# ── 7. Upload build ───────────────────────────────────────────────────────────
h1("7. Upload your app bundle to Internal testing")
steps([
    "Go to Test and release → Testing → Internal testing.",
    "Click 'Create new release'.",
    "If prompted, accept Play App Signing (recommended — Google manages the signing key).",
    "Upload build/app/outputs/bundle/release/app-release.aab.",
    "Add release notes (e.g. 'First internal build — full app, test ads').",
    "Click Next → fix any warnings → Save → Review release → Start rollout to Internal testing.",
    "Under Testers, add your email(s) to an internal tester list and copy the opt-in link.",
])
note("Upload the .aab (App Bundle) to Play — not the .apk. The .apk is only for sideloading directly onto a device for quick testing.")

# ── 8. Device QA ──────────────────────────────────────────────────────────────
h1("8. Test on a real device")
steps([
    "In Settings → License testing, add your Google account so in-app purchases are free to test.",
    "Open the internal-testing opt-in link on your phone, accept, and install from Play.",
    "Run the checklist below.",
])
bullets([
    "App opens EMPTY (no demo data).",
    "Email sign-in returns a 6-digit code (not a link); Google sign-in works; 'Skip — use local storage' works.",
    "Create task/habit/goal/note → close & reopen → data persists; sign in on a 2nd device → it syncs.",
    "Set a reminder → it fires at the time → reboot → still fires.",
    "End-of-day reflection appears splash-style after 6 PM (toggle on in Settings → Features & smart).",
    "Free user: an interstitial ad appears on tab-switch (capped); 'watch ad for 1 insight' works.",
    "Paywall → subscribe (license tester) → Pro unlocks, ads disappear, AI works.",
    "Restore purchase works; Delete account wipes data and returns to sign-in.",
])

# ── 9. Production ─────────────────────────────────────────────────────────────
h1("9. Promote to production")
steps([
    "When internal testing is green, go to Test and release → Production → Create new release.",
    "Reuse the same .aab (or upload a newer build with a higher versionCode).",
    "Complete the 'Countries / regions' selection.",
    "Save → Review → Start rollout to Production. First review can take a few days.",
])
note("Consider a staged rollout (e.g. 20%) for v1 so you can catch issues before everyone gets it.")

# ── Appendix: before live ads ─────────────────────────────────────────────────
h1("Appendix — switching from test ads to real ads")
body("The current build ships Google TEST ad units (safe, no revenue). When ready to monetize:")
steps([
    "Create an AdMob app + ad units at admob.google.com.",
    "Put the real AdMob app ID in android/app/src/main/AndroidManifest.xml (APPLICATION_ID).",
    "Put the real ad unit IDs in lib/config/ads_config.dart and set useTestAds = false.",
    "Add a UMP consent flow for EU users (required for personalized ads in the EEA).",
    "Bump version to 1.0.1+2 in pubspec.yaml, rebuild the AAB, and upload a new release.",
])

doc.save("docs/Kaal_Google_Play_Console_Guide.docx")
print("WROTE docs/Kaal_Google_Play_Console_Guide.docx")
