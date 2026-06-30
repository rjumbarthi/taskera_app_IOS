"""Generate a DETAILED .docx step-by-step guide for publishing Kaal on the
Google Play Console. Run: python tools/gen_play_console_doc.py"""
from docx import Document
from docx.shared import Pt, RGBColor
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.oxml.ns import qn
from docx.oxml import OxmlElement

ACCENT = RGBColor(0x0A, 0x84, 0xFF)
GREY = RGBColor(0x55, 0x55, 0x55)
WARN = RGBColor(0xC0, 0x39, 0x2B)
GREEN = RGBColor(0x1E, 0x7D, 0x32)

doc = Document()
normal = doc.styles["Normal"]
normal.font.name = "Calibri"
normal.font.size = Pt(11)


def h1(t):
    p = doc.add_heading(t, level=1)
    for r in p.runs:
        r.font.color.rgb = ACCENT
    return p


def h2(t):
    return doc.add_heading(t, level=2)


def h3(t):
    return doc.add_heading(t, level=3)


def body(t, bold=False, italic=False):
    p = doc.add_paragraph()
    r = p.add_run(t)
    r.bold = bold
    r.italic = italic
    return p


def field(label, value):
    """A labelled field line: 'Label — value'."""
    p = doc.add_paragraph(style="List Bullet")
    r = p.add_run(label + " — ")
    r.bold = True
    p.add_run(value)
    return p


def tag(word, text, color):
    p = doc.add_paragraph()
    r = p.add_run(word + " ")
    r.bold = True
    r.font.color.rgb = color
    r2 = p.add_run(text)
    r2.font.color.rgb = GREY
    return p


def note(t): return tag("NOTE:", t, ACCENT)
def warn(t): return tag("WARNING:", t, WARN)
def tip(t):  return tag("TIP:", t, GREEN)


def steps(items):
    for it in items:
        doc.add_paragraph(it, style="List Number")


def bullets(items):
    for it in items:
        doc.add_paragraph(it, style="List Bullet")


def table(headers, rows):
    t = doc.add_table(rows=1, cols=len(headers))
    t.style = "Light Grid Accent 1"
    for i, htxt in enumerate(headers):
        c = t.rows[0].cells[i]
        c.text = htxt
        c.paragraphs[0].runs[0].bold = True
    for row in rows:
        cells = t.add_row().cells
        for i, v in enumerate(row):
            cells[i].text = str(v)
    doc.add_paragraph()
    return t


def pagebreak():
    doc.add_page_break()


# ── COVER ─────────────────────────────────────────────────────────────────────
doc.add_heading("Kaal — Google Play Publishing", level=0)
p = doc.add_paragraph("The complete, detailed step-by-step guide: from a Google account to live on the Play Store.")
p.runs[0].italic = True
p.runs[0].font.color.rgb = GREY
doc.add_paragraph("Product of Port443 LLC")
body("App package: com.port443.kaal     |     First version: 1.0.0+1", italic=True)

h2("How to use this guide")
bullets([
    "Do the sections in order — later steps depend on earlier ones.",
    "Each step says exactly where to click, what to type, and what to expect next.",
    "Boxes marked NOTE / TIP / WARNING contain the details people most often miss.",
    "Section 0 is a reference of every value you'll paste — keep it open in a second window.",
])

# ── 0. REFERENCE VALUES ───────────────────────────────────────────────────────
h1("0. Reference — every value you'll need")
table(["Field", "Value"], [
    ("App name", "Kaal — Focus & Task Planner"),
    ("Developer / publisher", "Port443 LLC"),
    ("Package name (Application ID)", "com.port443.kaal"),
    ("App category", "Productivity"),
    ("Default language", "English (United States)"),
    ("Privacy policy URL", "https://jumbarthi.com/kaal/privacy"),
    ("Support URL", "https://jumbarthi.com/kaal/support"),
    ("Account-deletion URL", "https://jumbarthi.com/kaal/delete"),
    ("Support email", "kaal_support@jumbarthi.com"),
    ("Monthly subscription ID", "kaal_pro_monthly"),
    ("Annual subscription ID", "kaal_pro_annual"),
    ("App bundle to upload", "build/app/outputs/bundle/release/app-release.aab"),
    ("App icon (512x512)", "playstore/icon_512.png"),
    ("Feature graphic (1024x500)", "playstore/feature_graphic_1024x500.png"),
    ("Screenshots", "/screenshots folder (crop to phone 9:16)"),
])
warn("Keep your release keystore (android/app/kaal-release.jks) and android/key.properties backed up in two safe places. If you lose them you can never update the app under the same identity (unless you use Play App Signing — see Section 3).")

pagebreak()

# ── 1. DEVELOPER ACCOUNT ──────────────────────────────────────────────────────
h1("1. Create and verify your Google Play Developer account")
body("Estimated time: 15 minutes of forms + up to 1–3 days for Google's verification.")

h2("1.1  Register")
steps([
    "Open play.google.com/console in a browser and sign in with the Google account that will OWN the app long-term (use a business account you won't lose).",
    "Click 'Get started' / 'Create account'.",
    "Choose the account type: select 'An organization or business' for Port443 LLC (recommended for a company app). 'Yourself' is for individuals.",
    "Enter the developer/organization name 'Port443 LLC' — this is the PUBLIC name shown on your store listing.",
    "Provide the contact details (email, phone) Google will use to reach you. Verify the email and phone when prompted.",
    "Pay the one-time US$25 registration fee with a card.",
])

h2("1.2  Identity & organization verification")
bullets([
    "Google requires identity verification for all developers. For an organization you'll also provide a D-U-N-S number (free to request from Dun & Bradstreet; can take a few days).",
    "You'll enter a legal business address; Google may post or email a verification code.",
    "Set up a Payments profile (Google Payments) so you can receive subscription revenue — add your business bank details and tax info.",
])
warn("Organization verification + D-U-N-S can take several days. Start this on day 1 so it is not what blocks your launch.")
note("Newer developer accounts have an extra gate before they can publish to PRODUCTION — see Section 9.1 (closed-testing requirement). Read it now so you plan for it.")

pagebreak()

# ── 2. CREATE THE APP ─────────────────────────────────────────────────────────
h1("2. Create the app")
body("Estimated time: 2 minutes.")
steps([
    "In Play Console, on the 'All apps' page, click 'Create app' (top-right).",
    "App name: type 'Kaal — Focus & Task Planner' (max 30 characters, shown on the store).",
    "Default language: choose 'English (United States)'.",
    "App or game: select 'App'.",
    "Free or paid: select 'Free'. (The install is free; Kaal Pro is a separate in-app subscription.)",
    "Declarations: tick 'Developer Program Policies' and 'US export laws'.",
    "Click 'Create app'.",
])
note("'Free' cannot be changed to 'Paid' later, but you can always add in-app products/subscriptions to a Free app — which is exactly what Kaal Pro is. So 'Free' is correct.")
tip("After creation you land on the app DASHBOARD. The 'Set up your app' and 'Publish your app' sections list every task with a status. This guide follows that order.")

pagebreak()

# ── 3. APP SIGNING ────────────────────────────────────────────────────────────
h1("3. Understand app signing (important, one-time)")
body("Estimated time: 5 minutes to read; the choice is made when you upload your first build.")
h2("3.1  Two keys")
bullets([
    "Upload key — the key you sign your .aab with locally (your kaal-release.jks). You use it for every upload.",
    "App signing key — the key Google uses to sign the APKs delivered to users. With 'Play App Signing' (default & recommended) Google generates and securely stores this key for you.",
])
h2("3.2  What to do")
bullets([
    "When you upload the first release, ACCEPT Play App Signing (it's the default).",
    "Google keeps the app signing key safe; you only protect your UPLOAD key.",
    "If you ever lose your upload key, Google can reset it — so you are not permanently locked out. This is the main reason to use Play App Signing.",
])
warn("Still back up android/app/kaal-release.jks and key.properties. Losing the upload key is recoverable with Play App Signing, but recovery takes days — avoid it.")

pagebreak()

# ── 4. STORE LISTING ──────────────────────────────────────────────────────────
h1("4. Main store listing")
body("Where: Grow → Store presence → Main store listing. Estimated time: 30–45 minutes (mostly graphics).")

h2("4.1  App details (text)")
field("App name", "Kaal — Focus & Task Planner  (max 30 chars)")
field("Short description", "Plan, focus & execute with Covey's 4 quadrants — tasks, habits, goals & AI.  (max 80 chars)")
body("Full description (max 4000 chars) — paste exactly:", bold=True)
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
warn("Do NOT put fake ratings, 'best app', competitor names, or emojis spam in the title/description — it triggers a policy rejection.")

h2("4.2  Graphics — exact specifications")
table(["Asset", "Spec", "File"], [
    ("App icon", "512 x 512 px, 32-bit PNG, ≤1 MB", "playstore/icon_512.png"),
    ("Feature graphic", "1024 x 500 px, PNG/JPG, no alpha", "playstore/feature_graphic_1024x500.png"),
    ("Phone screenshots", "2–8 images, PNG/JPG, 16:9 or 9:16, each side 320–3840 px", "from /screenshots"),
    ("7-inch tablet (optional)", "up to 8, same rules", "optional"),
    ("10-inch tablet (optional)", "up to 8, same rules", "optional"),
])
bullets([
    "Upload at least 2 phone screenshots (more is better — 4–6 recommended).",
    "Suggested set: 10_focus, 2g_tasks_quad_q1, 30_habits, 40_calendar, 60_notes, a0_paywall.",
    "Crop each /screenshots PNG to a 1080x1920 (9:16) phone frame before uploading.",
])
warn("The 512 app icon and the 1024x500 feature graphic should be fully opaque (no transparency). If your round icon has transparent corners, place it on a solid background first.")

h2("4.3  Store settings")
body("Where: Grow → Store presence → Store settings.")
bullets([
    "App category: Productivity.",
    "Tags: pick relevant ones (productivity, planner, to-do, habits).",
    "Store listing contact details: email kaal_support@jumbarthi.com, website https://jumbarthi.com/kaal, optional phone.",
    "External marketing: leave default unless you run Google Ads.",
])

pagebreak()

# ── 5. SUBSCRIPTIONS ──────────────────────────────────────────────────────────
h1("5. Subscriptions (Kaal Pro)")
body("Where: Monetize → Products → Subscriptions. Estimated time: 30 minutes. Create TWO subscriptions.")

h2("5.1  Create the monthly subscription")
steps([
    "Click 'Create subscription'.",
    "Product ID: type kaal_pro_monthly  (this MUST match the app code; it cannot be changed later).",
    "Name: 'Kaal Pro (Monthly)' — internal/display name.",
    "Click 'Create'.",
    "Add a BASE PLAN → choose 'Auto-renewing'. Base plan ID: monthly.",
    "Billing period: 'Monthly' (P1M). Grace period / account hold: leave defaults.",
    "Set prices: click 'Set prices', choose your countries, and enter the per-country price (use the tier table in 5.3). Save.",
    "Optionally add an OFFER (e.g. discounted first month) under the base plan → 'Add offer'.",
    "Activate the base plan.",
])

h2("5.2  Create the annual subscription")
steps([
    "Create subscription → Product ID: kaal_pro_annual → Name 'Kaal Pro (Annual)' → Create.",
    "Add base plan → 'Auto-renewing', base plan ID: annual, billing period 'Yearly' (P1Y).",
    "Set per-country prices (~40% cheaper per month than monthly — see 5.3).",
    "Optionally add a free-trial or intro offer.",
    "Activate the base plan.",
])

h2("5.3  Price tiers (USD — set on each base plan)")
table(["Tier", "Example countries", "Monthly", "Annual total (per-month)"], [
    ("1 — High income", "US, CA, GB, EU, AU, NZ, JP, SG, KR, AE, IL", "$2.99", "$21.48 ($1.79/mo)"),
    ("2 — Middle income", "BR, MX, TR, ZA, TH, ID, PH, PL, RU, UA", "$1.99", "$14.28 ($1.19/mo)"),
    ("3 — Everywhere else", "India, South Asia, most of Africa", "$0.99", "$7.08 ($0.59/mo)"),
])
warn("Until BOTH subscriptions are ACTIVE, the in-app paywall has nothing to sell and purchases will fail in testing.")
note("Google charges the per-country price you set here; the app's paywall text auto-selects the tier by device region for display.")

h2("5.4  Service account for server receipt validation (optional, can follow later)")
bullets([
    "Google Cloud Console → create a service account → enable 'Google Play Android Developer API'.",
    "Play Console → Users & permissions → invite the service-account email → grant 'View financial data'.",
    "Download the JSON key and set it as the GOOGLE_PLAY_SERVICE_ACCOUNT Supabase secret.",
    "Without this, purchases still unlock Pro via the client fallback; add it for server-verified entitlements.",
])

pagebreak()

# ── 6. APP CONTENT / COMPLIANCE ───────────────────────────────────────────────
h1("6. App content (policy declarations)")
body("Where: Policy → App content. Complete EVERY item — each shows a green check when done. Estimated time: 45–60 minutes.")

h2("6.1  Privacy policy")
field("Privacy policy URL", "https://jumbarthi.com/kaal/privacy")

h2("6.2  App access")
bullets([
    "If parts of the app need a login to review, choose 'All or some functionality is restricted'.",
    "Add instructions: reviewers can tap 'Skip — use local storage' on the sign-in screen to use the app without an account; OR provide a dedicated test email + OTP flow.",
])

h2("6.3  Ads")
bullets([
    "Does your app contain ads? → YES.",
    "Ads are served by Google AdMob to free-plan users only; Kaal Pro is ad-free.",
])

h2("6.4  Content rating")
steps([
    "Click 'Start questionnaire'. Enter email; category: 'Reference, News, or Educational' / Utility-Productivity.",
    "Answer NO to: violence, sexual content, profanity, controlled substances, gambling, user-to-user location sharing, user-generated content sharing to the public.",
    "Digital purchases: YES (subscriptions).",
    "Submit. Expected result: Everyone (PEGI 3 / ESRB Everyone).",
])

h2("6.5  Target audience and content")
bullets([
    "Target age group: 13 and over (Kaal has an in-app age gate).",
    "Is the app designed for children? → No.",
    "This keeps you out of the Families policy program.",
])

h2("6.6  Data safety")
body("Click 'Start'. Declare data COLLECTED and how it's used:")
table(["Data type", "Collected", "Linked to user", "Purpose"], [
    ("Email address", "Yes", "Yes", "Account management, app functionality"),
    ("Name (display name)", "Yes", "Yes", "Account management"),
    ("App content: tasks, notes, habits, goals, calendar", "Yes", "Yes", "App functionality (cloud sync)"),
    ("Purchase history", "Yes", "Yes", "Subscription management"),
    ("App interactions / analytics", "Yes", "No (anonymous)", "Analytics"),
    ("Advertising ID", "Yes", "No", "Advertising / marketing"),
    ("Crash logs / diagnostics", "Yes", "No", "App functionality / analytics"),
])
body("Then answer the policy questions:", bold=True)
bullets([
    "Is all collected data encrypted in transit? → Yes.",
    "Do you provide a way for users to request data deletion? → Yes (in-app + https://jumbarthi.com/kaal/delete).",
    "Is any data SOLD or shared with third parties? → Not sold. Shared only with service providers (cloud hosting, analytics, ad network) to run the app.",
    "Disclose AI processing: text submitted to AI features is sent to the AI provider (Anthropic/OpenAI) to generate the result.",
])
warn("Your Data Safety answers must MATCH what the app actually does and what the Privacy Policy says. Mismatches are a top rejection reason.")

h2("6.7  Sensitive app permissions")
body("The app declares two sensitive permissions; declare each with its justification:")
table(["Permission", "Justification to enter"], [
    ("SCHEDULE_EXACT_ALARM (Alarms & reminders)",
     "Kaal schedules user-created task & habit reminders/alarms that must trigger at the exact set time."),
    ("USE_FULL_SCREEN_INTENT (Full-screen intent)",
     "Used for time-critical task/habit alarm notifications the user explicitly sets."),
])
note("If the reviewer pushes back on exact alarms, the fallback is switching the app to inexact alarms (loses exact timing). Ask your developer to change it only if required.")

h2("6.8  Other declarations")
bullets([
    "Government apps: No.  Financial features: No.  Health: No.  News app: No.  COVID-19 contact tracing: No.",
    "Advertising ID: declare it IS used (matches the AdMob ads + Data Safety).",
    "Data deletion: provide the in-app path (Profile → Edit profile → Delete account) AND the URL https://jumbarthi.com/kaal/delete.",
])

pagebreak()

# ── 7. INTERNAL TESTING ───────────────────────────────────────────────────────
h1("7. Upload the build to Internal testing")
body("Where: Test and release → Testing → Internal testing. Estimated time: 15 minutes + processing.")
h2("7.1  Create the release")
steps([
    "Open Internal testing → click 'Create new release'.",
    "When prompted about app signing, ACCEPT 'Use Play App Signing' (recommended).",
    "Under 'App bundles', click 'Upload' and select build/app/outputs/bundle/release/app-release.aab.",
    "Wait for it to process (a minute). Fix any warnings shown (most are informational).",
    "Release name: defaults to the version (1.0.0+1) — leave it.",
    "Release notes: add e.g. 'First internal build — full app with test ads.'",
    "Click 'Next', resolve any errors, then 'Save' → 'Review release' → 'Start rollout to Internal testing' → confirm.",
])
warn("Upload the .aab (App Bundle), NOT the .apk. The .apk is only for sideloading directly to a device.")

h2("7.2  Add testers")
steps([
    "In Internal testing → 'Testers' tab → create an email list → add your tester Gmail addresses.",
    "Copy the 'Join on the web' opt-in URL and open it on each tester device to accept.",
    "Settings → License testing → add the same Gmail accounts so in-app purchases are FREE to test (test cards).",
])
tip("Internal testing has no review delay and supports up to 100 testers — use it for all your hands-on QA.")

pagebreak()

# ── 8. DEVICE QA ──────────────────────────────────────────────────────────────
h1("8. Test on a real device")
body("Install Kaal from the internal-testing link (Play install — required for purchases to work) and verify:")
bullets([
    "App opens EMPTY — no demo tasks/habits/notes.",
    "Email sign-in returns a 6-DIGIT CODE (not a link); verify it signs in.",
    "Google sign-in completes; 'Skip — use local storage' works.",
    "Create a task, habit, goal, note → close & reopen → data persists.",
    "Sign in on a second device → data syncs.",
    "Set a reminder → it fires at the set time → reboot the phone → it still fires.",
    "End-of-day reflection appears splash-style after 6 PM (enable in Settings → Features & smart).",
    "Free user: an interstitial ad appears at most once every 2 hours on a tab-switch; 'Watch a short ad for one AI insight' works (Google test ads).",
    "Paywall → subscribe as a license tester → Pro unlocks, ads disappear, AI insights generate.",
    "Restore purchase works.",
    "Profile → Edit profile → Delete account → confirm → data is wiped and you return to sign-in.",
])
note("Check Test and release → Pre-launch report after upload — Google auto-runs the app on real devices and reports crashes, accessibility, and security issues.")

pagebreak()

# ── 9. PRODUCTION ─────────────────────────────────────────────────────────────
h1("9. Release to production")

h2("9.1  Closed-testing requirement (read this!)")
warn("Google now requires many NEW personal developer accounts to run a CLOSED test with at least 12 testers opted-in for 14 continuous days before they can apply for production access. Organization accounts may be exempt, but plan for it: if prompted, set up a Closed testing track, recruit 12+ testers, and wait out the 14 days.")
bullets([
    "Test and release → Testing → Closed testing → create a track + tester list of 12+ people.",
    "Keep them opted-in and active for 14 days.",
    "Then use 'Apply for production access' and fill the short questionnaire.",
])

h2("9.2  Create the production release")
steps([
    "Test and release → Production → 'Create new release'.",
    "Add the SAME app bundle (or a newer build with a higher versionCode).",
    "Select 'Countries / regions' → add all the countries you want to launch in.",
    "Add release notes.",
    "Save → 'Review release' → 'Start rollout to Production'.",
    "Optionally set a STAGED rollout percentage (e.g. 20%) to limit risk for v1.",
])

h2("9.3  Review & going live")
bullets([
    "First-time app review typically takes a few days (can be longer). You'll get email updates.",
    "If rejected, the email states the policy and section — fix and resubmit. Common reasons: Data Safety mismatch, missing/incorrect privacy policy, permissions not justified, broken test login.",
    "Once approved and rolled out, the listing goes live on Google Play.",
])

pagebreak()

# ── 10. AFTER LAUNCH ──────────────────────────────────────────────────────────
h1("10. After launch — updating the app")
steps([
    "Make your code changes.",
    "Bump version in pubspec.yaml: increase the +BUILD number every upload (e.g. 1.0.0+1 → 1.0.1+2). Play REJECTS a versionCode it has already seen.",
    "Rebuild: flutter build appbundle --release.",
    "Upload to a testing track first, verify, then promote to Production.",
])
bullets([
    "Respond to user reviews in Play Console → Ratings & reviews (improves ranking).",
    "Watch Android vitals (crashes/ANRs) and the Pre-launch report after each upload.",
    "Use staged rollouts for risky changes; you can halt a rollout if vitals dip.",
])

# ── 11. SWITCH TO REAL ADS ────────────────────────────────────────────────────
h1("11. Appendix — switching from test ads to real AdMob")
body("The current build ships Google TEST ad units (safe, no revenue). To monetize:")
steps([
    "Create an AdMob app + ad units at admob.google.com (one interstitial, one rewarded).",
    "Put the real AdMob APP ID in android/app/src/main/AndroidManifest.xml (com.google.android.gms.ads.APPLICATION_ID).",
    "Put the real ad UNIT IDs in lib/config/ads_config.dart (the _prod* constants) and set useTestAds = false.",
    "Add a UMP (User Messaging Platform) consent flow for EU/EEA users — required for personalized ads.",
    "Bump version (e.g. 1.0.1+2), rebuild the AAB, and upload a new release.",
])
note("Free users currently see at most one interstitial every 2 hours (tab-switch only), plus the optional 'watch ad for one AI insight'. Pro users see no ads.")

# ── 12. TROUBLESHOOTING ───────────────────────────────────────────────────────
h1("12. Appendix — common problems & fixes")
table(["Problem", "Fix"], [
    ("'You need to use a different version code'", "Increase +BUILD in pubspec.yaml and rebuild."),
    ("'App bundle was signed with the wrong key'", "Use the same upload keystore; with Play App Signing, re-upload signed by your upload key."),
    ("Data Safety rejection", "Make Data Safety answers match the Privacy Policy and actual app behavior."),
    ("Purchases fail in test", "Install via Play (internal testing), add account to License testing, ensure both subscriptions are ACTIVE."),
    ("Exact-alarm permission flagged", "Keep the justification; if pushed, switch to inexact alarms in code."),
    ("Icon rejected for transparency", "Make the 512 icon fully opaque (solid background)."),
])

import os
_out = "docs/Kaal_Google_Play_Console_Guide.docx"
try:
    doc.save(_out)
except PermissionError:
    _out = "docs/Kaal_Google_Play_Publishing_Guide.docx"  # old file locked (open in Word)
    doc.save(_out)
print("WROTE", _out)
