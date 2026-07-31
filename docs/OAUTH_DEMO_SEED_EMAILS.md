# OAuth Demo — Seed Emails for the Reviewer Inbox

Send these **to** `kaal_support@jumbarthi.com` **from any other address** (e.g.
`r@jumbarthi.com` or a Gmail account). Leave them **unread**.

## Why it must be done this way

1. Kaal only processes **new incoming** mail — the app tells the user *"Only new
   incoming emails are processed into tasks & habits — your existing inbox
   history isn't scanned"* (`inbox_screen.dart:387`). So these have to actually
   **arrive** in the inbox as new unread messages. Sending from another account
   is the only way.
2. Every **subject line is deliberately bland** and the actionable content lives
   in the **body**. This is the entire point: it forces Kaal to read the message
   body, which proves `gmail.metadata` (headers only) cannot power the feature.
   In the video, open one of these and show the subject says nothing useful while
   the body drives the task/habit.

## How the on-device parser reacts (so you know what to expect)

From `_kaalSuggest()` in `inbox_screen.dart` — pure keyword matching, no AI, no
network:

- **Every** email → a **Task** suggestion + a **Note** suggestion.
- Body contains `urgent | asap | immediately | overdue | deadline | action
  required | approval needed | invoice | payment due | past due` → the task is
  **Q1 (urgent)**.
- Body contains `daily | weekly | every day | routine | gym | workout | exercise
  | meditat | journal | reading | practice | streak | habit` → also a **Habit**
  suggestion.
- Body contains `meeting | invite | rsvp | schedule | zoom | google meet | teams
  | webinar | appointment` → also a calendar **Invite** suggestion.

---

## TASK emails (bland subject → task extracted from body)

### Email 1 — becomes a Q1 task
- **From:** Finance Team
- **Subject:** `Quick note`
- **Body:**
```
Hi,

Following up on the Q3 budget draft. The deadline is this Friday, so
please review the figures and reply with your sign-off before then.

Thanks
```
*Trigger: "deadline" → Q1 task. Subject reveals nothing — the whole request is in the body.*

### Email 2 — becomes a Q1 task
- **From:** Priya (client)
- **Subject:** `Re: catching up`
- **Body:**
```
Hey,

Don't forget the client invoice for the March project still needs to go
out. Can you send it today? It's already a bit past due.

Cheers
```
*Trigger: "invoice", "past due" → Q1 task.*

### Email 3 — becomes a Q1 task
- **From:** Ops
- **Subject:** `hello`
- **Body:**
```
The website migration is urgent — the current host expires tomorrow and we
need to move the DNS immediately or the site goes down. Please handle it
today.
```
*Trigger: "urgent", "immediately" → Q1 task.*

---

## HABIT emails (bland subject → habit extracted from body)

### Email 4 — becomes a habit (+ task + note)
- **From:** Coach
- **Subject:** `checking in`
- **Body:**
```
Great session today! Remember the plan: hit the gym every day this week and
do your 20-minute workout each morning before breakfast. Consistency is what
builds the streak.
```
*Triggers: "gym", "every day", "workout", "streak" → Habit suggestion.*

### Email 5 — becomes a habit (+ task + note)
- **From:** Sam
- **Subject:** `a thought`
- **Body:**
```
I've been meaning to tell you — starting a daily meditation and journaling
routine changed everything for me. Even 10 minutes of meditation each day
plus a few lines in a journal helps. You should try it.
```
*Triggers: "daily", "meditat", "journal", "routine" → Habit suggestion.*

### Email 6 — becomes a habit (+ task + note)
- **From:** Book Club
- **Subject:** `book rec`
- **Body:**
```
You asked for a reading habit idea — try reading 10 pages every day. Building
a daily reading practice is the easiest way to get through more books this
year.
```
*Triggers: "reading", "every day", "daily", "practice", "habit" → Habit suggestion.*

---

## BONUS — one Calendar/Invite email (optional, ties Gmail → calendar)

### Email 7 — becomes a calendar invite suggestion
- **From:** Alex
- **Subject:** `sync`
- **Body:**
```
Can we schedule a 30-minute meeting tomorrow at 3 PM to review the roadmap?
I'll send a Google Meet invite once you confirm.
```
*Triggers: "schedule", "meeting", "invite", "google meet", "3 PM" → Invite
suggestion with time slot 3 PM.*

---

## Recommended demo sequence (pairs with OAUTH_DEMO_VIDEO_SCRIPT.md Scene 5)

1. Open **Email 1 ("Quick note")** — point out the subject says nothing.
2. Hold on the visible **body** for ~5 seconds so the reviewer can read it.
3. Show Kaal's extracted **Task** suggestion, add it, switch to Tasks tab, show it created.
4. Open **Email 4 ("checking in")** — show the extracted **Habit** suggestion, add it, switch to Habits tab, show it created.
5. Say aloud: *"gmail.metadata returns only headers — subject, sender, date. None
   of these subjects contain the task or habit. The feature requires the message
   body, which is why gmail.readonly is necessary."*

## Also seed the Google **Calendar** (separate from these emails)

The calendar demo reads real Google Calendar events, not email invites. In the
`kaal_support@jumbarthi.com` Google Calendar, add **4–6 events over the next 7
days, with two that overlap in time** so Kaal's conflict detection has something
real to show.
