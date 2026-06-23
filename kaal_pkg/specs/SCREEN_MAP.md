# Kaal — Screen Map

Cross-reference: PNG file ⇄ HTML extract ⇄ prototype screen id ⇄ inventory label.

Rows are also the **build order** for Claude Code.

> **Flutter-only rows** (marked `†`) have no prototype PNG or HTML. They were added during the Flutter build and are not in the original 100-screen inventory. Do not try to match them to a PNG.

| # | PNG | HTML | Screen ID | Parent | Section | Label | State notes |
|---|-----|------|-----------|--------|---------|-------|-------------|
| 1 | `01-01_quote_splash.png` | `01-01_quote_splash.html` | `p-quote` | `—` | Onboarding & Auth | Quote Splash |  |
| 2 | `01-02_signin.png` | `01-02_signin.html` | `p-signin` | `—` | Onboarding & Auth | Sign In | Password mode default; OTP toggle (`_otpMode`). "New here? Create account" (right, `!_otpMode`) routes to `/signup`. Social: Google+Apple row, Microsoft+Skip row. No bottom nav. |
| 3 † | (none — Flutter-only) | (none) | `p-signup` | `—` | Onboarding & Auth | Sign Up | **Flutter-only addition** — no prototype PNG. Mirrors Sign In design. Password mode: Email+Password+ConfirmPassword, "Create Account"+OTP-outline buttons. OTP mode: Email+OTP, full-width "Verify & Create Account". On success → `/onboard`. "← Back to sign in" → `/signin`. No bottom nav. |
| 4 | `01-03_onboard_who.png` | `01-03_onboard_who.html` | `p-onboard` | `—` | Onboarding & Auth | Onboard – Who are you? | **Step 1 of 6** in `OnboardScreen` (`_step=1`). 1 active progress segment. BackdropFilter blur+dark overlay on content area. Cards: transparent bg, `colors.bdr` border. |
| 5 | `01-04_onboard_focus_style.png` | `01-04_onboard_focus_style.html` | `p-onboard` | `—` | Onboarding & Auth | Onboard – Focus Style | **Step 2 of 6** (`_step=2`). 2 active progress segments. See PNG. |
| 6 | `01-05_onboard_peak_hours.png` | `01-05_onboard_peak_hours.html` | `p-onboard` | `—` | Onboarding & Auth | Onboard – Peak Hours | **Step 3 of 6** (`_step=3`). 3 active progress segments. See PNG. |
| 7 | `01-06_onboard_step4.png` | `01-06_onboard_step4.html` | `p-onboard` | `—` | Onboarding & Auth | Onboard – Step 4 | **Step 4 of 6** (`_step=4`). 4 active progress segments. See PNG. |
| 8 | `01-07_onboard_step5.png` | `01-07_onboard_step5.html` | `p-onboard` | `—` | Onboarding & Auth | Onboard – Step 5 (Upsell) | **Step 5 of 6** (`_step=5`). All 5 non-gate segments active. On CTA → `/focus`. See PNG. |
| 9 | `01-08_age_gate.png` | `01-08_age_gate.html` | `p-agegate` | `—` | Onboarding & Auth | Age Gate | **Step 0 of 6** in `OnboardScreen` (`_step=0`). 0 active progress segments. **Not a separate Flutter screen** — implemented as `_Step0` inside `OnboardScreen`. `KaalRoutes.agegate` is unused. "I am 13+" → `_step=1`. "I am under 13" → SnackBar. "← Back to sign in" → `/signin`. |
| 10 | `02-01_focus_dashboard.png` | `02-01_focus_dashboard.html` | `p-dash` | `—` | Focus | Focus – Dashboard |  |
| 11 | `02-02_focus_today_plan.png` | `02-02_focus_today_plan.html` | `p-dash` | `—` | Focus | Focus – Today Plan (scrolled) | Same screen as Dashboard, scrolled to show TODAY'S PLAN section. See PNG. |
| 12 | `02-03_focus_active_tasks.png` | `02-03_focus_active_tasks.html` | `p-focuslist` | `focus` | Focus | Focus – Active Tasks | openFocusFilter('active') — see PNG |
| 13 | `02-04_focus_done_tasks.png` | `02-04_focus_done_tasks.html` | `p-focuslist` | `focus` | Focus | Focus – Done Tasks | openFocusFilter('done') |
| 14 | `02-05_focus_overdue.png` | `02-05_focus_overdue.html` | `p-focuslist` | `focus` | Focus | Focus – Overdue Tasks | openFocusFilter('overdue') |
| 15 | `02-06_focus_list.png` | `02-06_focus_list.html` | `p-focuslist` | `focus` | Focus | Focus List | openFocusFilter('today') |
| 16 | `02-07_pomodoro.png` | `02-07_pomodoro.html` | `p-pomodoro` | `focus` | Focus | Pomodoro |  |
| 17 | `02-08_braindump.png` | `02-08_braindump.html` | `p-braindump` | `focus` | Focus | Brain Dump |  |
| 18 | `02-09_goals.png` | `02-09_goals.html` | `p-goals` | `focus` | Focus | Goals |  |
| 19 | `02-10_goal_detail.png` | `02-10_goal_detail.html` | `p-goaldetail` | `goals` | Focus | Goal Detail |  |
| 20 | `02-11_edit_goal.png` | `02-11_edit_goal.html` | `p-editgoal` | `goaldetail` | Focus | Edit Goal |  |
| 21 | `02-12_predictive_ai.png` | `02-12_predictive_ai.html` | `p-predictive` | `focus` | Focus | Predictive AI |  |
| 22 | `02-13_reschedule.png` | `02-13_reschedule.html` | `p-reschedule` | `focus` | Focus | Reschedule |  |
| 23 | `02-14_eod_reflect.png` | `02-14_eod_reflect.html` | `p-reflect` | `focus` | Focus | EOD Reflect |  |
| 24 | `02-15_weekly_review.png` | `02-15_weekly_review.html` | `p-weeklyreview` | `profile` | Focus | Weekly Review |  |
| 25 | `03-01_tasks_list.png` | `03-01_tasks_list.html` | `p-tasks` | `—` | Tasks | Tasks – List View |  |
| 26 | `03-02_tasks_list_scrolled.png` | `03-02_tasks_list_scrolled.html` | `p-tasks` | `—` | Tasks | Tasks – List Scrolled | Same as List View, scrolled. See PNG. |
| 27 | `03-03_tasks_with_completed.png` | `03-03_tasks_with_completed.html` | `p-tasks` | `—` | Tasks | Tasks – With Completed | Scrolled to show completed footer. See PNG. |
| 28 | `03-04_tasks_completed_expanded.png` | `03-04_tasks_completed_expanded.html` | `p-panel-comp` | `tasks` | Tasks | Tasks – Completed Expanded | Full-screen completed panel overlay |
| 29 | `03-05_tasks_hold_menu.png` | `03-05_tasks_hold_menu.html` | `p-tasks` | `—` | Tasks | Tasks – Hold Menu | Long-press context menu overlay on a task. See PNG. |
| 30 | `03-06_tasks_2x2_quad.png` | `03-06_tasks_2x2_quad.html` | `p-tasks` | `—` | Tasks | Tasks – 2×2 Quad | Layout toggled to 2×2 quad view |
| 31 | `03-07_tasks_2x2_completed_expanded.png` | `03-07_tasks_2x2_completed_expanded.html` | `p-panel-comp` | `tasks` | Tasks | Tasks – 2×2 Completed Expanded |  |
| 32 | `03-08_completed_panel.png` | `03-08_completed_panel.html` | `p-panel-comp` | `tasks` | Tasks | Completed Panel |  |
| 33 | `03-09_task_detail.png` | `03-09_task_detail.html` | `p-taskdetail` | `_dynamic` | Tasks | Task Detail |  |
| 34 | `03-10_edit_task.png` | `03-10_edit_task.html` | `p-edittask` | `_dynamic` | Tasks | Edit Task |  |
| 35 | `03-11_edit_task_bottom.png` | `03-11_edit_task_bottom.html` | `p-edittask` | `_dynamic` | Tasks | Edit Task – Bottom | Scrolled to bottom |
| 36 | `03-14_inbox_panel.png` | `03-14_inbox_panel.html` | `p-inbox` | `tasks` | Tasks | Inbox Panel |  |
| 37 | `03-15_board_q1_q2.png` | `03-15_board_q1_q2.html` | `p-board` | `tasks` | Tasks | Board – Q1+Q2 |  |
| 38 | `03-16_board_q3_q4.png` | `03-16_board_q3_q4.html` | `p-board` | `tasks` | Tasks | Board – Q3+Q4 | Scrolled to bottom |
| 39 | `03-17_upcoming.png` | `03-17_upcoming.html` | `p-upcoming` | `tasks` | Tasks | Upcoming |  |
| 40 | `03-18_labels.png` | `03-18_labels.html` | `p-labels` | `tasks` | Tasks | Labels |  |
| 41 | `03-19_filters.png` | `03-19_filters.html` | `p-filters` | `tasks` | Tasks | Filters |  |
| 42 | `03-20_day_schedule.png` | `03-20_day_schedule.html` | `p-schedule` | `tasks` | Tasks | Day Schedule |  |
| 43 | `03-21_smart_recurrence.png` | `03-21_smart_recurrence.html` | `p-recurring` | `focus` | Tasks | Smart Recurrence |  |
| 44 | `12-01_analytics.png` | `12-01_analytics.html` | `p-analytics` | `tasks` | Tasks | Analytics |  |
| 45 | `12-02_time_track.png` | `12-02_time_track.html` | `p-timetrack` | `_dynamic` | Tasks | Time Tracker |  |
| 46 | `04-01_q1.png` | `04-01_q1.html` | `p-quad-q1` | `_dynamic` | Quadrants | Q1 – Urgent+Important | Populated via openQuad('q1') |
| 47 | `04-02_q2.png` | `04-02_q2.html` | `p-quad-q2` | `_dynamic` | Quadrants | Q2 – Important | Populated via openQuad('q2') |
| 48 | `04-03_q3.png` | `04-03_q3.html` | `p-quad-q3` | `_dynamic` | Quadrants | Q3 – Urgent | Populated via openQuad('q3') |
| 49 | `04-04_q4.png` | `04-04_q4.html` | `p-quad-q4` | `_dynamic` | Quadrants | Q4 – Eliminate | Populated via openQuad('q4') |
| 50 | `05-02_fab_add_task.png` | `05-02_fab_add_task.html` | `p-quickadd` | `tasks` | FAB | FAB Add Task | Same as Quick Add screen |
| 51 | `05-03_fab_add_task_bot.png` | `05-03_fab_add_task_bot.html` | `p-quickadd` | `tasks` | FAB | FAB Add Task (Bottom) | Scrolled to bottom |
| 52 | `05-04_fab_add_habit.png` | `05-04_fab_add_habit.html` | `p-addhabit` | `habits` | FAB | FAB Add Habit | Same as Add Habit screen |
| 53 | `05-05_fab_add_habit_bot.png` | `05-05_fab_add_habit_bot.html` | `p-addhabit` | `habits` | FAB | FAB Add Habit (Bottom) | Scrolled to bottom |
| 54 | `05-06_fab_add_invite.png` | `05-06_fab_add_invite.html` | `p-addslot` | `cal` | FAB | FAB Add Invite | Same as Add Slot screen |
| 55 | `05-07_fab_add_invite_bot.png` | `05-07_fab_add_invite_bot.html` | `p-addslot` | `cal` | FAB | FAB Add Invite (Bottom) | Scrolled to bottom |
| 56 | `05-08_fab_add_note.png` | `05-08_fab_add_note.html` | `p-noteeditor` | `notes` | FAB | FAB Add Note | Same as Note Editor screen |
| 57 | `05-09_fab_add_note_bot.png` | `05-09_fab_add_note_bot.html` | `p-noteeditor` | `notes` | FAB | FAB Add Note (Bottom) | Scrolled to bottom |
| 58 | `06-01_habits.png` | `06-01_habits.html` | `p-habits` | `—` | Habits | Habits |  |
| 59 | `06-02_addhabit_top.png` | `06-02_addhabit_top.html` | `p-addhabit` | `habits` | Habits | Add Habit – Top |  |
| 60 | `06-03_addhabit_bot.png` | `06-03_addhabit_bot.html` | `p-addhabit` | `habits` | Habits | Add Habit – Bottom | Scrolled to bottom |
| 61 | `06-04_edit_habit.png` | `06-04_edit_habit.html` | `p-addhabit` | `habits` | Habits | Edit Habit | Same form as Add Habit, with prefilled fields. Title changes to 'Edit Habit'. |
| 62 | `06-05_habit_detail.png` | `06-05_habit_detail.html` | `p-habitdetail` | `habits` | Habits | Habit Detail |  |
| 63 | `06-06_habit_stats.png` | `06-06_habit_stats.html` | `p-habitstats` | `habits` | Habits | Habit Stats |  |
| 64 | `06-07_achievements.png` | `06-07_achievements.html` | `p-achievements` | `habits` | Habits | Achievements |  |
| 65 | `07-01_calendar.png` | `07-01_calendar.html` | `p-cal` | `—` | Calendar | Calendar |  |
| 66 | `07-02_gmail_sync.png` | `07-02_gmail_sync.html` | `p-gmail` | `cal` | Calendar | Gmail Sync |  |
| 67 | `07-03_cal_sync.png` | `07-03_cal_sync.html` | `p-calsync` | `cal` | Calendar | Cal Sync |  |
| 68 | `07-04_conflicts.png` | `07-04_conflicts.html` | `p-conflicts` | `cal` | Calendar | Conflicts |  |
| 69 | `06-08_add_slot.png` | `06-08_add_slot.html` | `p-addslot` | `cal` | Calendar | Add Slot |  |
| 70 | `08-01_notes.png` | `08-01_notes.html` | `p-notes` | `—` | Notes | Notes |  |
| 71 | `08-02_note_editor.png` | `08-02_note_editor.html` | `p-noteeditor` | `notes` | Notes | Note Editor |  |
| 72 | `09-01_ai_inbox.png` | `09-01_ai_inbox.html` | `p-email` | `—` | Inbox | Inbox |  |
| 73 | `10-01_settings_pro.png` | `10-01_settings_pro.html` | `p-settings` | `—` | Settings | Kaal Pro | Sgrp 'Kaal Pro' expanded |
| 74 | `10-02_settings_pro_content.png` | `10-02_settings_pro_content.html` | `p-settings` | `—` | Settings | Kaal Pro (Content) | Sgrp 'Kaal Pro' expanded, scrolled |
| 75 | `10-03_settings_display.png` | `10-03_settings_display.html` | `p-settings` | `—` | Settings | Display | Sgrp 'Display' expanded |
| 76 | `10-04_settings_display_content.png` | `10-04_settings_display_content.html` | `p-settings` | `—` | Settings | Display (Content) | Sgrp 'Display' expanded, scrolled |
| 77 | `10-04b_settings_display_bottom.png` | `10-04b_settings_display_bottom.html` | `p-settings` | `—` | Settings | Display (Bottom) | Sgrp 'Display' expanded, scrolled to bottom (wallpaper picker) |
| 78 | `10-05_settings_tasks.png` | `10-05_settings_tasks.html` | `p-settings` | `—` | Settings | Tasks | Sgrp 'Tasks' expanded |
| 79 | `10-06_settings_tasks_content.png` | `10-06_settings_tasks_content.html` | `p-settings` | `—` | Settings | Tasks (Content) | Sgrp 'Tasks' expanded, scrolled |
| 80 | `10-07_settings_features.png` | `10-07_settings_features.html` | `p-settings` | `—` | Settings | Features & Smart | Sgrp 'Features, Tabs & Smart' expanded (renamed via JS) |
| 81 | `10-08_settings_features_content.png` | `10-08_settings_features_content.html` | `p-settings` | `—` | Settings | Features (Content) | Sgrp expanded, scrolled |
| 82 | `10-09_settings_calendar.png` | `10-09_settings_calendar.html` | `p-settings` | `—` | Settings | Calendar & Inbox | Sgrp expanded |
| 83 | `10-10_settings_calendar_content.png` | `10-10_settings_calendar_content.html` | `p-settings` | `—` | Settings | Calendar (Content) | Sgrp expanded, scrolled |
| 84 | `10-11_settings_integrations.png` | `10-11_settings_integrations.html` | `p-settings` | `—` | Settings | Integrations | Sgrp expanded |
| 85 | `10-12_settings_integrations_content.png` | `10-12_settings_integrations_content.html` | `p-integrations` | `profile` | Settings | Integrations (Content) | Separate p-integrations screen |
| 86 | `10-13_settings_sync.png` | `10-13_settings_sync.html` | `p-settings` | `—` | Settings | Sync & Data | Sgrp expanded |
| 87 | `10-14_settings_sync_content.png` | `10-14_settings_sync_content.html` | `p-settings` | `—` | Settings | Sync (Content) | Sgrp expanded, scrolled |
| 88 | `10-15_settings_account.png` | `10-15_settings_account.html` | `p-profile` | `—` | Settings | Account (under Profile) | Account sgrp moved to Profile screen, expanded |
| 89 | `10-16_settings_account_content.png` | `10-16_settings_account_content.html` | `p-profile` | `—` | Settings | Account Content | Account sgrp expanded, scrolled |
| 90 | `10-17_settings_notifs.png` | `10-17_settings_notifs.html` | `p-notifcenter` | `profile` | Settings | Notifications | Separate p-notifcenter screen |
| 91 | `10-18_settings_notifs_content.png` | `10-18_settings_notifs_content.html` | `p-notifcenter` | `profile` | Settings | Notifications (Content) | Scrolled to bottom |
| 92 | `10-19_settings_widget.png` | `10-19_settings_widget.html` | `p-widget` | `focus` | Settings | Widget Preview | Separate p-widget screen |
| 93 | `11-01_profile_top.png` | `11-01_profile_top.html` | `p-profile` | `—` | Profile | Profile – Top |  |
| 94 | `11-02_profile_mid.png` | `11-02_profile_mid.html` | `p-profile` | `—` | Profile | Profile – Middle | Scrolled to middle |
| 95 | `11-03_profile_bot.png` | `11-03_profile_bot.html` | `p-profile` | `—` | Profile | Profile – Bottom | Scrolled to bottom |
| 96 | `11-04_profile_edit.png` | `11-04_profile_edit.html` | `p-profileedit` | `profile` | Profile | Edit Profile |  |
| 97 | `11-05_referral.png` | `11-05_referral.html` | `p-referral` | `profile` | Profile | Referral |  |
| 98 | `11-06_student_mode.png` | `11-06_student_mode.html` | `p-studentmode` | `profile` | Profile | Student Mode |  |
| 99 | `12-03_search.png` | `12-03_search.html` | `p-search` | `_dynamic` | Tools | Search |  |
| 100 | `13-01_paywall.png` | `13-01_paywall.html` | `p-paywall` | `—` | Legal & Paywall | Paywall |  |
| 101 | `13-02_legal.png` | `13-02_legal.html` | `p-legal` | `—` | Legal & Paywall | Legal |  |