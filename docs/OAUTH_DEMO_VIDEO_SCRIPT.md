# Google OAuth Verification — Demo Video Script

For the re-submission after the "Third-Party Data Safety Team" rejection.

**App:** TaskEra — Focus & Task Planner
**Scopes requested:** `gmail.readonly`, `calendar.events.readonly`
**Both scopes are READ-ONLY.** The app performs no writes or deletes to any
Google account, so the reviewer's "Source Account Impact" requirement does not
apply — but say so out loud on camera anyway (see Scene 6).

---

## ⚠️ BEFORE RECORDING — fix the scope mismatch

Google's email lists the scopes under verification as:

- `https://www.googleapis.com/auth/gmail.readonly`
- `https://www.googleapis.com/auth/calendar.readonly`   ← **WRONG / STALE**

The app actually requests `calendar.events.readonly` (narrower). Their email
explicitly requires: *"The scopes requested by your app or manifest must exactly
match the scopes configured and submitted for verification."*

**Recording before fixing this guarantees another rejection** — the consent
screen in your video will show `calendar.events.readonly` while the Console
submission says `calendar.readonly`.

### Fix in Google Cloud Console

1. Google Cloud Console → **APIs & Services** → **OAuth consent screen** → **Data access** (or "Scopes")
2. **Remove** `.../auth/calendar.readonly`
3. **Add** `.../auth/calendar.events.readonly`
4. Keep `.../auth/gmail.readonly`
5. Save. Confirm the scope table lists **exactly two** scopes and nothing else.

Do not resolve this the other way (widening the app back to `calendar.readonly`).
Narrowing is what the least-privilege policy rewards, and the app only ever calls
`events.list` — it never reads calendar lists or settings.

---

## Why the last video was rejected

> *"does not sufficiently demonstrate why the following scope(s) are necessary
> **or why narrower permissions cannot be used**"*

This is the crux. For each scope you must prove the **narrower alternative is
insufficient**:

| Scope | Narrower alternative Google will suggest | What you must show to rule it out |
|---|---|---|
| `gmail.readonly` | `gmail.metadata` (headers only — From/Subject/Date) | The app **reading and displaying the message BODY**, and deriving task suggestions from that body text |
| `calendar.events.readonly` | *(already the narrowest read scope for events)* | Events being listed and used for conflict detection + prep-task suggestions |

**The single most important shot in the entire video is Scene 5** — opening an
email and showing its body text on screen, then showing a task created from
content that only exists in the body. Without that, Google will conclude
`gmail.metadata` suffices and reject again. A list of senders and subjects is
*not enough* — that is exactly what metadata provides.

---

## Recording setup

- **Device:** real Android device (not an emulator), screen-recorded
- **Account:** `taskera_support@jumbarthi.com`
- **Seed the account first** — this matters:
  - **5–10 unread emails** in the Gmail inbox. At least two must contain a clear
    actionable request *in the body*, not in the subject. Example body text:
    *"Hi — can you send the Q3 budget draft by Friday and book a 30-min review
    with the finance team?"* Subject should be bland (e.g. "Quick note") so it's
    self-evident the app needed the body.
  - **4–6 calendar events** over the next 7 days, including **two that overlap**
    so conflict detection has something real to find.
- **One continuous take.** No cuts, no time-skips, no still frames. Cuts read as
  hiding failures.
- **Narrate in English**, or add burned-in English subtitles.
- **Length:** 4–7 minutes. Do not rush the consent screen.
- **Upload:** YouTube, **Unlisted**. Paste the link in your reply to the email.

---

## The script

### Scene 1 — Identify the app (0:00–0:20)

> "This is TaskEra, Focus and Task Planner — a personal productivity app.
> The package name is `com.jumbarthi.taskera` and the OAuth client is in the Google
> Cloud project 'TaskEra — Focus & Task Planner'.
> I'm requesting two read-only scopes: `gmail.readonly` and
> `calendar.events.readonly`. The app never writes to or deletes from the user's
> Google account."

**On screen:** app launching to the Focus tab.

---

### Scene 2 — Show the feature is opt-in (0:20–0:45)

Navigate: **Settings → Calendar & Inbox**

> "Google integration is entirely optional. Nothing is connected by default and
> the app is fully usable without it. Here are the two connect entry points —
> Calendar Sync and Inbox."

**On screen:** the Calendar & Inbox settings group, showing both rows in a
disconnected state.

---

### Scene 3 — Calendar consent screen (0:45–1:45) ★ CRITICAL

Tap **Calendar Sync** → tap **Connect**.

When the Google consent screen appears:

- **STOP. Do not tap through.**
- If scopes are collapsed, tap **"Show all services"** / the expand arrow.
- **Hold still for a full 5 seconds** on the expanded, readable scope list.
- Slowly scroll so every line is legible.

> "Here is the consent screen. It shows the app name TaskEra, and the requested
> permission: see your Google Calendar events — `calendar.events.readonly`.
> This is read-only. Note this is the events-only scope, not the broader
> `calendar.readonly` — the app never reads calendar lists or settings."

Then grant access.

---

### Scene 4 — Calendar functionality, maximum extent (1:45–3:00)

Show, in this order:

1. **Synced events list** — the events you seeded now appearing in TaskEra.
   > "These events came from `events.list` on the primary calendar."
2. **Conflict detection** — open the conflicts view showing your two overlapping events.
   > "TaskEra reads event start and end times to detect scheduling conflicts and
   > surface them here."
3. **Prep-task suggestions** — show the "Suggest prep tasks from events" feature
   producing a task from an event.
   > "Event titles and times are used to suggest preparation tasks."
4. **Say the read-only line explicitly:**
   > "Every calendar operation is a read. TaskEra never creates, edits, or deletes
   > calendar events. This is why the read-only events scope is sufficient — and
   > why nothing broader is requested."

---

### Scene 5 — Gmail, the decisive scene (3:00–5:30) ★★ MOST CRITICAL

Navigate to the Gmail connect entry → tap **Connect Gmail**.

**Consent screen — same treatment as Scene 3:**
- Expand via **"Show all services"** if collapsed
- Hold 5 seconds, fully readable

> "The consent screen shows `gmail.readonly` — read-only access to Gmail."

Grant access. Then:

**5a. The list view (metadata level)**
> "After connecting, TaskEra lists unread messages — sender, subject, and date."

**5b. Now prove metadata is NOT enough — this is the shot that matters**

Tap the email whose subject is bland but whose body contains the real request.

> "This is the critical part. Notice the subject line here says only 'Quick
> note' — it contains no actionable information. When I open the message, TaskEra
> fetches the **full message body**."

**Hold on the visible body text for 5 seconds.** The reviewer must be able to
read the actual sentence.

> "The body says: *'send the Q3 budget draft by Friday and book a 30-minute
> review with the finance team.'* TaskEra parses this body text on the device and
> extracts these suggestions."

**5c. Show the extracted suggestions and add one**

> "TaskEra has extracted two suggested tasks from the body content. I'll add this
> one."

Tap to add → **switch to the Tasks tab and show the created task.**

> "The task now exists in TaskEra, created from information that appeared **only in
> the message body**."

**5d. State the justification in one sentence**

> "This is why `gmail.readonly` is required and why `gmail.metadata` is not
> sufficient. `gmail.metadata` returns only headers — sender, subject, and date.
> It does not return message bodies. The core feature of this screen is turning
> the content of an email into a task, which is impossible without body access.
> TaskEra reads a body only when the user explicitly opens that message, and it
> never sends, modifies, deletes, or archives any email."

---

### Scene 6 — Read-only + data handling close (5:30–6:30)

> "To summarize. TaskEra requests two scopes, both read-only:
> `calendar.events.readonly` and `gmail.readonly`.
>
> Because both are read-only, there are no write or delete operations to
> demonstrate in the source Google account — the app cannot modify anything
> there.
>
> All parsing happens on the device. TaskEra does not use AI or machine learning on
> email or calendar content, and email and calendar data are never sent to any
> AI or third-party service. Google user data is not used for advertising, is not
> sold, and is not transferred except as required to provide these user-facing
> features. This complies with the Google API Services User Data Policy,
> including the Limited Use requirements."

Then show disconnection:

Navigate to the sync screen → tap **Disconnect**.

> "The user can revoke access at any time from within the app, which deletes the
> stored tokens from the device."

---

## Pre-upload checklist

- [ ] Cloud Console scope list = exactly `gmail.readonly` + `calendar.events.readonly`
- [ ] Consent screens shown **expanded and readable**, held ≥5 seconds each
- [ ] Email **body text legible on screen** for ≥5 seconds (Scene 5b)
- [ ] Task visibly created from body-only content (Scene 5c)
- [ ] Spoken sentence explaining why `gmail.metadata` is insufficient (Scene 5d)
- [ ] Both scopes exercised end-to-end, not just connected
- [ ] Read-only / no-write stated aloud
- [ ] One continuous take, no cuts
- [ ] Uploaded **Unlisted**, link works in a signed-out browser

---

## Reply email template

> Hello,
>
> Thank you for the review. I have made the following changes:
>
> **1. Scope configuration corrected.** The app requests
> `https://www.googleapis.com/auth/calendar.events.readonly`, not
> `calendar.readonly`. I have updated the Google Cloud Console configuration so
> the submitted scopes now exactly match those requested by the app. The two
> scopes under verification are:
>
> - `https://www.googleapis.com/auth/gmail.readonly`
> - `https://www.googleapis.com/auth/calendar.events.readonly`
>
> **2. New demonstration video:** <UNLISTED YOUTUBE LINK>
>
> The video shows both consent screens with all scopes expanded and readable,
> and demonstrates the full operational functionality of each scope.
>
> **Justification for `gmail.readonly`:** TaskEra's core inbox feature converts the
> *content* of an email into tasks, habits, and notes. The video demonstrates
> opening a message whose subject contains no actionable information and
> extracting tasks from the message **body**. `gmail.metadata` returns only
> headers and cannot support this feature. Bodies are read only when the user
> explicitly opens a message.
>
> **Justification for `calendar.events.readonly`:** TaskEra reads event times to
> detect scheduling conflicts and suggest preparation tasks. The app calls only
> `events.list` on the primary calendar. I deliberately chose the events-only
> scope over the broader `calendar.readonly` because the app never needs calendar
> lists or settings.
>
> **Both scopes are read-only.** The app performs no write or delete operations
> on any Google account, so there are no source-account changes to demonstrate.
>
> All parsing is performed on-device. Google user data is never sent to any AI or
> third-party service, is not used for advertising, and is not sold, in
> compliance with the Limited Use requirements.
>
> Best regards,
> Rajesh Jumbarthi
