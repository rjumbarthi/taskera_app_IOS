import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';

import '../../data/providers/announcements_provider.dart';
import '../../data/providers/database_provider.dart';
import '../../data/providers/feature_flags_provider.dart';
import '../../data/providers/tasks_provider.dart';
import '../../data/providers/integrations_provider.dart';
import '../../services/notification_service.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/providers/ai_access_provider.dart';
import '../../services/purchase_service.dart';
import '../../routing/routes.dart';
import '../../settings/app_launch_prefs.dart';
import '../../settings/taskera_settings.dart';
import '../../settings/prefs_provider.dart';
import '../../widgets/google_access_sheet.dart';
import '../../l10n/app_l10n.dart';
import '../../theme/taskera_colors.dart';
import '../../theme/taskera_theme.dart';

// ── SVG icon strings ──────────────────────────────────────────────────────────

const _svgMonitor = '<svg width="22" height="22" viewBox="0 0 22 22" fill="none" stroke="var(--c)" stroke-width="1.6" stroke-linecap="round"><rect x="2" y="3" width="18" height="14" rx="2"/><path d="M8 21h6M12 17v4"/></svg>';
const _svgCheck   = '<svg width="22" height="22" viewBox="0 0 22 22" fill="none" stroke="var(--c)" stroke-width="1.6" stroke-linecap="round"><polyline points="9 11 12 14 22 4"/><path d="M21 12v7a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11"/></svg>';
const _svgStar    = '<svg width="22" height="22" viewBox="0 0 22 22" fill="none" stroke="var(--c)" stroke-width="1.6" stroke-linecap="round"><path d="M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z"/></svg>';
const _svgStarFill= '<svg width="22" height="22" viewBox="0 0 22 22" fill="white" stroke="none"><path d="M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z"/></svg>';
const _svgCal     = '<svg width="22" height="22" viewBox="0 0 22 22" fill="none" stroke="var(--c)" stroke-width="1.6" stroke-linecap="round"><rect x="3" y="4" width="16" height="16" rx="2"/><path d="M16 2v4M8 2v4M3 10h16"/></svg>';
const _svgLink    = '<svg width="22" height="22" viewBox="0 0 22 22" fill="none" stroke="white" stroke-width="1.6" stroke-linecap="round"><path d="M10 13a5 5 0 0 0 7.54.54l3-3a5 5 0 0 0-7.07-7.07l-1.72 1.71"/><path d="M14 11a5 5 0 0 0-7.54-.54l-3 3a5 5 0 0 0 7.07 7.07l1.71-1.71"/></svg>';
const _svgSync    = '<svg width="22" height="22" viewBox="0 0 22 22" fill="none" stroke="var(--c)" stroke-width="1.6" stroke-linecap="round"><polyline points="1 4 1 10 7 10"/><polyline points="23 20 23 14 17 14"/><path d="M20.49 9A9 9 0 0 0 5.64 5.64L1 10M23 14l-4.64 4.36A9 9 0 0 1 3.51 13"/></svg>';
const _svgBell    = '<svg width="22" height="22" viewBox="0 0 22 22" fill="none" stroke="var(--c)" stroke-width="1.6" stroke-linecap="round"><path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9"/><path d="M13.73 21a2 2 0 0 1-3.46 0"/></svg>';
const _svgTabs    = '<svg width="22" height="22" viewBox="0 0 22 22" fill="none" stroke="var(--c)" stroke-width="1.6" stroke-linecap="round"><rect x="2" y="3" width="18" height="16" rx="2"/><path d="M2 9h18M7 9v10"/></svg>';
const _svgInfo    = '<svg width="22" height="22" viewBox="0 0 22 22" fill="none" stroke="var(--c)" stroke-width="1.6" stroke-linecap="round"><circle cx="11" cy="11" r="9"/><path d="M11 10v5M11 7h.01"/></svg>';

// ── Integration service icon SVGs ─────────────────────────────────────────────

const _icoNotion =
    '<svg width="11" height="11" viewBox="0 0 100 100" fill="white">'
    '<path d="M12 18.6c2 2.4 2.7 2.2 6.4 2L82 16.7c1.3 0 1.4-.6.7-1.2L71.5 7.3c-2.1-1.7-3.1-2-6.3-1.7L8.5 9.7C7.2 9.9 7 10.6 7.5 11.3L12 18.6zM14.7 31.8v54.2c0 3 1.5 4.1 5 3.8l67.5-3.8c3.4-.2 3.8-2 3.8-4.5V28.3c0-2.4-.9-3.7-3-3.5l-70 4c-2.3.2-3.3 1.3-3.3 3zm66.3.7l.1 52-60.5 3.4-.1-52 60.5-3.4zM28.4 46.9c-2.4.1-2.9-1.6-.7-2.5l34-4.2c2.1-.2 2.3 1.1.8 1.8l-34.1 4.9zM27.3 59l-.1-2.1L63 53.8c2.2-.2 2.5 1.4.3 2.4L29.2 59.5l-1.9-.5z"/>'
    '</svg>';

const _icoTodoist =
    '<svg width="11" height="11" viewBox="0 0 24 24" fill="white">'
    '<path d="M21.2 0H2.8C1.3 0 0 1.3 0 2.8v18.4C0 22.7 1.3 24 2.8 24h18.4c1.5 0 2.8-1.3 2.8-2.8V2.8C24 1.3 22.7 0 21.2 0zM5.8 17.9l-2-1.1 5.7-3.3 2 1.1-5.7 3.3zm0-4.8l-2-1.1 5.7-3.3 2 1.1-5.7 3.3zm0-4.8l-2-1.1 5.7-3.3 2 1.1-5.7 3.3zm12.8 8.3l-7.4-4.3 7.4-4.3v8.6zm0-9.6l-7.4-4.3 7.4-4.3v8.6z"/>'
    '</svg>';

const _icoApple =
    '<svg width="11" height="11" viewBox="0 0 22 22" fill="none" stroke="white" stroke-width="1.6" stroke-linecap="round">'
    '<circle cx="11" cy="11" r="9"/><path d="M11 7v4l3 2"/>'
    '</svg>';

const _icoSlack =
    '<svg width="11" height="11" viewBox="0 0 54 54" fill="white">'
    '<path d="M19.712.133a5.381 5.381 0 0 0-5.376 5.387 5.381 5.381 0 0 0 5.376 5.386h5.376V5.52A5.381 5.381 0 0 0 19.712.133m0 14.365H5.376A5.381 5.381 0 0 0 0 19.884a5.381 5.381 0 0 0 5.376 5.387h14.336a5.381 5.381 0 0 0 5.376-5.387 5.381 5.381 0 0 0-5.376-5.386"/>'
    '<path d="M53.76 19.884a5.381 5.381 0 0 0-5.376-5.386 5.381 5.381 0 0 0-5.376 5.386v5.387h5.376a5.381 5.381 0 0 0 5.376-5.387m-14.336 0V5.52A5.381 5.381 0 0 0 34.048.133a5.381 5.381 0 0 0-5.376 5.387v14.364a5.381 5.381 0 0 0 5.376 5.387 5.381 5.381 0 0 0 5.376-5.387"/>'
    '<path d="M34.048 54a5.381 5.381 0 0 0 5.376-5.387 5.381 5.381 0 0 0-5.376-5.386h-5.376v5.386A5.381 5.381 0 0 0 34.048 54m0-14.365h14.336a5.381 5.381 0 0 0 5.376-5.386 5.381 5.381 0 0 0-5.376-5.387H34.048a5.381 5.381 0 0 0-5.376 5.387 5.381 5.381 0 0 0 5.376 5.386"/>'
    '<path d="M0 34.249a5.381 5.381 0 0 0 5.376 5.386 5.381 5.381 0 0 0 5.376-5.386v-5.387H5.376A5.381 5.381 0 0 0 0 34.249m14.336 0v14.364A5.381 5.381 0 0 0 19.712 54a5.381 5.381 0 0 0 5.376-5.387V34.249a5.381 5.381 0 0 0-5.376-5.387 5.381 5.381 0 0 0-5.376 5.387"/>'
    '</svg>';

const _icoJira =
    '<svg width="11" height="11" viewBox="0 0 32 32" fill="white">'
    '<path d="M15.999 0C7.163 0 0 7.163 0 16s7.163 16 15.999 16C24.837 32 32 24.837 32 16S24.837 0 15.999 0zm.001 6l5.758 9.685L16 24 10.242 15.685 16 6z"/>'
    '</svg>';

const _icoAsana =
    '<svg width="11" height="11" viewBox="0 0 32 32" fill="white">'
    '<circle cx="16" cy="10" r="6"/><circle cx="7" cy="23" r="6"/><circle cx="25" cy="23" r="6"/>'
    '</svg>';

const _icoLinear =
    '<svg width="11" height="11" viewBox="0 0 100 100" fill="white">'
    '<path d="M1.22 61.15a54.75 54.75 0 0 0 37.63 37.63L1.22 61.15zM0 49.11l50.89 50.89A55.13 55.13 0 0 0 61.1 98.8L1.2 38.9A55.13 55.13 0 0 0 0 49.11zM6.3 26.63 73.37 93.7a54.9 54.9 0 0 0 11.14-7.02L13.32 15.49A54.9 54.9 0 0 0 6.3 26.63zM19.63 10.96 89.04 80.37a54.84 54.84 0 0 0 7.87-10.25L29.88 3.09a54.84 54.84 0 0 0-10.25 7.87zM37.31 2.08 97.92 62.69A55 55 0 0 0 100 49.94V49A50 50 0 0 0 51 0h-.94A55 55 0 0 0 37.31 2.08z"/>'
    '</svg>';

const _icoTeams =
    '<svg width="11" height="11" viewBox="0 0 24 24" fill="white">'
    '<path d="M20 4.6a2.4 2.4 0 1 1-4.8 0 2.4 2.4 0 0 1 4.8 0zM14 8h6v8h-2v-6h-4V8zM9.5 5.5a2.5 2.5 0 1 1-5 0 2.5 2.5 0 0 1 5 0zM0 9h13v9.5H9.5V12H3.5v6.5H0V9z"/>'
    '</svg>';

const _icoGitHub =
    '<svg width="11" height="11" viewBox="0 0 24 24" fill="white">'
    '<path d="M12 0C5.37 0 0 5.37 0 12c0 5.3 3.44 9.8 8.2 11.38.6.11.82-.26.82-.58v-2.03c-3.34.73-4.04-1.61-4.04-1.61-.54-1.38-1.33-1.75-1.33-1.75-1.09-.74.08-.73.08-.73 1.2.08 1.84 1.24 1.84 1.24 1.07 1.83 2.8 1.3 3.48.99.11-.78.42-1.3.76-1.6-2.66-.3-5.47-1.33-5.47-5.93 0-1.31.47-2.38 1.24-3.22-.12-.3-.54-1.52.12-3.18 0 0 1.01-.32 3.3 1.23a11.5 11.5 0 0 1 3-.4c1.02.004 2.04.14 3 .4 2.28-1.55 3.29-1.23 3.29-1.23.66 1.66.24 2.88.12 3.18.77.84 1.24 1.91 1.24 3.22 0 4.61-2.81 5.63-5.48 5.92.43.37.82 1.1.82 2.22v3.29c0 .32.22.7.83.58C20.57 21.8 24 17.3 24 12c0-6.63-5.37-12-12-12z"/>'
    '</svg>';

const _icoGCal =
    '<svg width="11" height="11" viewBox="0 0 24 24">'
    '<rect x="2" y="2" width="20" height="20" rx="2" fill="#4285F4"/>'
    '<rect x="2" y="8" width="20" height="14" fill="white"/>'
    '<rect x="2" y="8" width="20" height="3" fill="#4285F4"/>'
    '<text x="12" y="19" font-size="7" text-anchor="middle" fill="#4285F4" font-weight="bold">31</text>'
    '</svg>';

const _icoOutlook =
    '<svg width="11" height="11" viewBox="0 0 24 24" fill="white">'
    '<path d="M14 2v8h8L14 2zM13 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2v-8h-7V2zM8 10h8v1H8v-1zm0 3h8v1H8v-1zm0 3h5v1H8v-1z"/>'
    '</svg>';

const _icoGmail =
    '<svg width="11" height="11" viewBox="0 0 24 24">'
    '<path fill="white" d="M24 5.457v13.909c0 .904-.732 1.636-1.636 1.636h-3.819V11.73L12 16.64l-6.545-4.91v9.273H1.636A1.636 1.636 0 0 1 0 19.366V5.457c0-2.023 2.309-3.178 3.927-1.964L5.455 4.64 12 9.548l6.545-4.91 1.528-1.145C21.69 2.28 24 3.434 24 5.457z"/>'
    '</svg>';

const _icoChatGPT =
    '<svg width="11" height="11" viewBox="0 0 24 24" fill="white">'
    '<path d="M22.28 9.28a6 6 0 0 0-.52-4.92 6.06 6.06 0 0 0-6.5-2.9A6 6 0 0 0 10.76 0a6.06 6.06 0 0 0-5.77 4.19 6 6 0 0 0-4 2.9 6.06 6.06 0 0 0 .74 7.1 6 6 0 0 0 .52 4.93 6.06 6.06 0 0 0 6.5 2.9A6 6 0 0 0 13.24 24a6.06 6.06 0 0 0 5.77-4.19 6 6 0 0 0 4-2.9 6.06 6.06 0 0 0-.73-7.63zM13.24 22.5a4.5 4.5 0 0 1-2.89-1.05l.14-.08 4.8-2.77a.8.8 0 0 0 .4-.68v-6.77l2.03 1.17a.07.07 0 0 1 .04.06v5.6a4.51 4.51 0 0 1-4.52 4.52zm-9.7-4.14a4.5 4.5 0 0 1-.54-3.02l.14.09 4.8 2.77a.77.77 0 0 0 .78 0l5.86-3.38v2.34a.08.08 0 0 1-.03.07l-4.85 2.8a4.51 4.51 0 0 1-6.16-1.67zm-1.26-9.9a4.49 4.49 0 0 1 2.35-1.98v5.7a.77.77 0 0 0 .39.67l5.84 3.37-2.03 1.17a.08.08 0 0 1-.07 0l-4.85-2.8a4.51 4.51 0 0 1-1.63-6.13zm16.68 3.87l-5.86-3.38 2.03-1.17a.08.08 0 0 1 .07 0l4.85 2.8a4.5 4.5 0 0 1-.7 8.12v-5.7a.78.78 0 0 0-.39-.67zm2.02-3.04l-.14-.08-4.8-2.77a.78.78 0 0 0-.78 0L9.4 10.83V8.49a.07.07 0 0 1 .03-.07l4.85-2.79a4.5 4.5 0 0 1 6.7 4.66zm-12.7 4.18l-2.03-1.17a.07.07 0 0 1-.04-.06v-5.6a4.5 4.5 0 0 1 7.38-3.46l-.14.08-4.8 2.77a.79.79 0 0 0-.39.68v6.76zm1.1-2.37L12 9.75l2.34 1.35v2.7L12 15.15l-2.34-1.35V11.1z"/>'
    '</svg>';


const _icoICloud =
    '<svg width="13" height="13" viewBox="0 0 24 24" fill="white">'
    '<path d="M18.5 10.5a5.5 5.5 0 0 0-10.9-1A4 4 0 0 0 4 13.5 4 4 0 0 0 8 17.5h10a3.5 3.5 0 0 0 .5-7z"/>'
    '</svg>';

// ── Integration data model ────────────────────────────────────────────────────

enum _IntStatus { connected, active, connect, comingSoon }

class _IntService {
  final String name;
  final String sub;
  final Color iconBg;
  final String iconSvg;
  final _IntStatus status;
  const _IntService(this.name, this.sub, this.iconBg, this.iconSvg, this.status);
}

final _intProductivity = [
  _IntService('Notion', 'Sync pages as tasks · auto-capture action items',
      const Color(0xFF1A1A1A), _icoNotion, _IntStatus.connect),
  _IntService('Todoist', 'Import existing tasks · two-way sync',
      const Color(0xFFDB4035), _icoTodoist, _IntStatus.connect),
  _IntService('Apple Reminders', 'Sync iOS reminders as TaskEra tasks',
      const Color(0xE6FF453A), _icoApple, _IntStatus.connect),
];

final _intWork = [
  _IntService('Slack', 'Capture tasks from messages · /taskera command',
      const Color(0xFF4A154B), _icoSlack, _IntStatus.connect),
  _IntService('Jira', 'Sync issues assigned to you → Q1/Q2 auto-sort',
      const Color(0xFF0052CC), _icoJira, _IntStatus.connect),
  _IntService('Asana', 'Import My Tasks · due dates preserved',
      const Color(0xFFF06A6A), _icoAsana, _IntStatus.connect),
  _IntService('Linear', 'Engineering issues → tasks with sprint context',
      const Color(0xFF5E6AD2), _icoLinear, _IntStatus.connect),
  _IntService('Microsoft Teams', 'Action items from meetings → auto-captured',
      const Color(0xFF6264A7), _icoTeams, _IntStatus.connect),
  _IntService('GitHub', 'Issues & PRs assigned to you → tasks',
      const Color(0xFF24292E), _icoGitHub, _IntStatus.connect),
];

final _intCalEmail = [
  _IntService('Google Calendar', 'Events → tasks · read-only',
      const Color(0xFF4285F4), _icoGCal, _IntStatus.connected),
  _IntService('Gmail', 'Emails parsed on-device · TaskEra suggestions',
      const Color(0xFFEA4335), _icoGmail, _IntStatus.active),
  _IntService('Outlook / Hotmail', 'Calendar & email · corporate SSO',
      const Color(0xFF0078D4), _icoOutlook, _IntStatus.comingSoon),
  _IntService('iCloud Mail', 'Apple Mail · IMAP sign-in',
      const Color(0xFF3693F3), _icoICloud, _IntStatus.comingSoon),
];

const _icoClaude =
    '<svg width="11" height="11" viewBox="0 0 24 24" fill="white">'
    '<path d="M12 2l1.8 6.2L20 10l-6.2 1.8L12 18l-1.8-6.2L4 10l6.2-1.8z"/>'
    '</svg>';

final _intAi = [
  _IntService('ChatGPT / OpenAI', 'Use your own OpenAI key for all AI features',
      const Color(0xFF10A37F), _icoChatGPT, _IntStatus.connect),
  _IntService('Claude (Anthropic)', 'Use your own Claude key for all AI features',
      const Color(0xFFD97757), _icoClaude, _IntStatus.connect),
];

// ── Screen ────────────────────────────────────────────────────────────────────

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  int? _open = 0;

  // Preset end-of-day reflection times (shown on app exit at/after this hour).
  static const _eodHourOptions = [17, 18, 20, 21, 22];
  static const _eodHourLabels  = ['5 PM', '6 PM', '8 PM', '9 PM', '10 PM'];
  late int _eodHour;

  @override
  void initState() {
    super.initState();
    _eodHour = AppLaunchPrefs.eodHour(ref.read(sharedPreferencesProvider));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(integrationsProvider.notifier).checkStatus();
    });
  }

  void _comingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature — coming soon',
            style: const TextStyle(fontFamily: 'Inter', fontSize: 13, color: Colors.white)),
        backgroundColor: const Color(0xFF1C1C1E),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _exportJson(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final db     = ref.read(appDatabaseProvider);
      final tasks  = await db.tasksDao.watchAll().first;
      final habits = await db.habitsDao.watchAll().first;
      final notes  = await db.notesDao.watchAll().first;
      final goals  = await db.goalsDao.watchAll().first;

      final payload = jsonEncode({
        'exported': DateTime.now().toIso8601String(),
        'tasks':  tasks.map((t) => {'id': t.id, 'title': t.title, 'quadrant': t.quadrant,
            'isDone': t.isDone, 'createdAt': t.createdAt.toIso8601String()}).toList(),
        'habits': habits.map((h) => {'id': h.id, 'name': h.name, 'emoji': h.emoji,
            'streakLabel': h.streakLabel, 'weeklyFilledCount': h.weeklyFilledCount}).toList(),
        'notes':  notes.map((n) => {'id': n.id, 'title': n.title, 'body': n.body,
            'isPinned': n.isPinned, 'updatedAt': n.updatedAt.toIso8601String()}).toList(),
        'goals':  goals.map((g) => {'id': g.id, 'title': g.title,
            'progressPct': g.progressPct, 'linkedLabel': g.linkedLabel}).toList(),
      });

      final dir  = await getApplicationDocumentsDirectory();
      final ts   = DateTime.now().toIso8601String().replaceAll(':', '-').substring(0, 19);
      final file = File('${dir.path}/taskera_export_$ts.json');
      await file.writeAsString(payload);

      messenger.showSnackBar(SnackBar(
        content: Text('Exported to ${file.path}',
            style: const TextStyle(fontFamily: 'Inter', fontSize: 12, color: Colors.white)),
        backgroundColor: const Color(0xFF1C1C1E),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ));
    } catch (e) {
      messenger.showSnackBar(SnackBar(
        content: Text('Export failed: $e',
            style: const TextStyle(fontFamily: 'Inter', fontSize: 12, color: Colors.white)),
        backgroundColor: const Color(0xFFFF453A),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  Future<void> _rescheduleAfterToggle() async {
    if (!NotificationService.instance.isReady) return;
    final db = ref.read(appDatabaseProvider);
    final s  = ref.read(taskeraSettingsProvider);
    try {
      final tasks  = await db.tasksDao.watchAll().first;
      final habits = await db.habitsDao.watchAll().first;
      final goals  = await db.goalsDao.watchAll().first;
      final events = await db.calendarDao.watchAll().first;
      await NotificationService.instance.rescheduleAll(
        tasks: tasks, habits: habits, goals: goals, events: events,
        notifToggles: s.toggles,
      );
    } catch (_) {}
  }

  void _toggle(int i) {
    if (i == 6 && _open != 6) {
      ref.read(integrationsProvider.notifier).checkStatus();
    }
    setState(() => _open = _open == i ? null : i);
  }

  // Shown when Dark/Light is picked — points the user at the wallpaper-brightness
  // slider directly below the theme row (each theme stores its own brightness).
  void _showBrightnessHint(int themeIdx) {
    final name = themeIdx == 0 ? '🌙 Dark' : '☀️ Light';
    final navBottom = MediaQuery.viewPaddingOf(context).bottom + 50 + 8;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(
          '$name theme on · adjust wallpaper brightness below to suit',
          style: const TextStyle(fontFamily: 'Inter', fontSize: 13, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1C1C1E),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.fromLTRB(12, 0, 12, navBottom),
        duration: const Duration(seconds: 3),
      ));
  }

  @override
  Widget build(BuildContext context) {
    final colors       = TaskEraTheme.of(context).colors;
    final settings     = ref.watch(taskeraSettingsProvider);
    final notifier     = ref.read(taskeraSettingsProvider.notifier);
    final integrations = ref.watch(integrationsProvider);

    return ListView(
      padding: const EdgeInsets.fromLTRB(0, 4, 0, 32),
      children: [
        _sgrpTaskEraPro(colors),
        _sgrpDisplay(colors, settings, notifier),
        _sgrpTabs(colors, settings, notifier),
        _sgrpTasks(colors, settings, notifier),
        _sgrpCalInbox(colors, settings, notifier, integrations),
        _sgrpFeatures(colors, settings, notifier),
        _sgrpIntegrations(colors),
        _sgrpSyncData(colors),
        _sgrpNotifications(colors, settings, notifier),
        _sgrpAboutLegal(colors),
        const SizedBox(height: 12),
        Center(
          child: Text('TaskEra · v1.0.0',
              style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: colors.ink3)),
        ),
      ],
    );
  }

  // About & Legal — fully inlined here (no separate subscreen).

  Widget _sgrpAboutLegal(TaskEraColors colors) {
    // Only surface the Messages row when there's actually something to show —
    // no empty "no messages" entry.
    final hasMsgs = (ref.watch(announcementsProvider).valueOrNull ?? const []).isNotEmpty;
    final unreadMsgs = ref.watch(unreadAnnouncementCountProvider);
    return _Sgrp(
      isOpen: _open == 9,
      onToggle: () => _toggle(9),
      iconBg: const Color(0x1F8E8E93),
      iconSvg: _svgInfo,
      iconColor: const Color(0xFFAEAEB2),
      title: 'About & Legal',
      body: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          _SetSec('About TaskEra', colors),
          _SetCard(colors: colors, children: [
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _AboutPara('Execution OS for high performers.', colors, strong: true),
                _AboutPara('TaskEra organises everything you do into Covey’s four quadrants — Do Now, Schedule, Delegate, Eliminate — so your time goes to what truly matters. Tasks, habits, goals, calendar and notes, in one focused place.', colors),
                _AboutPara('VERSION  ·  TaskEra v1.0.0', colors, strong: true),
                _AboutPara('CONTACT  ·  taskera_support@jumbarthi.com', colors),
                _AboutPara('TaskEra is a product of Port443 LLC.', colors),
                _AboutPara('© 2026 Port443 LLC. All rights reserved.', colors),
              ]),
            ),
          ]),
          _SetSec('Help & Info', colors),
          _SetCard(colors: colors, children: [
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _AboutPara('THE FOUR QUADRANTS', colors, strong: true),
                _AboutPara('• Q1 Do Now — urgent & important\n• Q2 Schedule — important, not urgent (where you win)\n• Q3 Delegate — urgent, not important\n• Q4 Eliminate — neither', colors),
                _AboutPara('GETTING AROUND', colors, strong: true),
                _AboutPara('• Long-press (or right-click) any row for quick actions.\n• Pull down on Inbox or Calendar to refresh.\n• Tap a task for its score, time, subtasks and to start a focus session.', colors),
                _AboutPara('INBOX', colors, strong: true),
                _AboutPara('• Open an email — TaskEra reads it on your device and suggests tasks, habits, invites and notes to add in one tap. No AI or server is involved; your email content never leaves your device. (Gmail sync is coming in a later release.)', colors),
                _AboutPara('YOUR PROFILE', colors, strong: true),
                _AboutPara('• Stats, streaks, achievements and the weekly review update live as you work.', colors),
              ]),
            ),
          ]),
          _SetSec('Feedback & Legal', colors),
          _SetCard(colors: colors, children: [
            if (hasMsgs) ...[
              _NavRow(label: 'Message from Founder to you',
                  right: unreadMsgs > 0 ? '$unreadMsgs new' : '›',
                  rightColor: unreadMsgs > 0 ? TaskEraColors.acc2 : colors.ink3,
                  colors: colors, onTap: () => context.push(TaskEraRoutes.messages)),
              Divider(height: 0.5, thickness: 0.5, color: colors.bdr),
            ],
            _NavRow(label: 'Report a bug · Request a feature', right: '›', rightColor: TaskEraColors.acc2,
                colors: colors, onTap: () => context.push(TaskEraRoutes.report)),
            Divider(height: 0.5, thickness: 0.5, color: colors.bdr),
            _NavRow(label: 'Terms of Service', right: '›', rightColor: colors.ink3,
                colors: colors, onTap: () => context.push(TaskEraRoutes.legal)),
            Divider(height: 0.5, thickness: 0.5, color: colors.bdr),
            _NavRow(label: 'Privacy Policy', right: '›', rightColor: colors.ink3,
                colors: colors, onTap: () => context.push('${TaskEraRoutes.legal}?tab=privacy')),
            Divider(height: 0.5, thickness: 0.5, color: colors.bdr),
            _NavRow(label: 'Copyright & Licenses', right: '›', rightColor: colors.ink3,
                colors: colors, onTap: () => context.push('${TaskEraRoutes.legal}?tab=copyright')),
            Divider(height: 0.5, thickness: 0.5, color: colors.bdr),
            _NavRow(label: 'Data, Permissions & Ads', right: '›', rightColor: colors.ink3,
                colors: colors, onTap: () => context.push('${TaskEraRoutes.legal}?tab=datainfo')),
            Divider(height: 0.5, thickness: 0.5, color: colors.bdr),
            _SwRow(settingKey: 'analytics', label: 'Share anonymous usage analytics', colors: colors),
            Divider(height: 0.5, thickness: 0.5, color: colors.bdr),
            _NavRow(label: 'Support & Help', right: '›', rightColor: colors.ink3,
                colors: colors, onTap: () => context.push('${TaskEraRoutes.legal}?tab=support')),
            Divider(height: 0.5, thickness: 0.5, color: colors.bdr),
            _NavRow(label: 'Account & data deletion', right: '›', rightColor: colors.ink3,
                colors: colors, onTap: () => context.push('${TaskEraRoutes.legal}?tab=deletion')),
          ]),
        ]),
      ),
    );
  }

  // ── Section builders ──────────────────────────────────────────────────────

  Widget _sgrpTaskEraPro(TaskEraColors colors) {
    final isPro = ref.watch(isProProvider);
    return _Sgrp(
      isOpen: _open == 0,
      onToggle: () => _toggle(0),
      headerColor: const Color(0x145856D6),
      iconWidget: Container(
        width: 24, height: 24,
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF5856D6), TaskEraColors.acc]),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Center(child: SvgPicture.string(_svgStarFill, width: 12, height: 12)),
      ),
      titleWidget: const Text('TaskEra Pro',
          style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w600,
              color: TaskEraColors.acc2, height: 1)),
      // "✦ PRO" badge only for actual subscribers; free users see "Upgrade".
      badge: isPro
          ? Container(
              padding: const EdgeInsets.fromLTRB(7, 2, 7, 2),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF5856D6), TaskEraColors.acc]),
                borderRadius: BorderRadius.circular(5),
              ),
              child: const Text('✦ PRO',
                  style: TextStyle(fontFamily: 'Inter', fontSize: 9, fontWeight: FontWeight.w700,
                      color: Colors.white, height: 1)),
            )
          : Container(
              padding: const EdgeInsets.fromLTRB(7, 2, 7, 2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                border: Border.all(width: 0.5, color: TaskEraColors.acc2),
              ),
              child: const Text('Upgrade',
                  style: TextStyle(fontFamily: 'Inter', fontSize: 9, fontWeight: FontWeight.w700,
                      color: TaskEraColors.acc2, height: 1)),
            ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
        child: _SetCard(colors: colors, children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 8, 4, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: isPro
                  ? _proActiveChildren(context, colors)
                  : [
                Text(AppL10n.of(context).freePlan,
                    style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w700,
                        color: colors.ink, height: 1.3)),
                const SizedBox(height: 4),
                for (final s in ['✓ Tasks, Habits, Calendar, Notes',
                  '✓ AI with your own OpenAI / Claude key',
                  '✓ Basic widgets'])
                  Padding(
                    padding: const EdgeInsets.only(bottom: 3),
                    child: Text(s, style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: colors.ink3, height: 1.4)),
                  ),
                const SizedBox(height: 6),
                Divider(height: 0.5, thickness: 0.5, color: colors.bdr),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text('✦ TaskEra Pro',
                        style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w700,
                            color: TaskEraColors.acc2, height: 1)),
                    const Spacer(),
                    Text('Monthly or annual',
                        style: TextStyle(fontFamily: 'Inter', fontSize: 10, fontWeight: FontWeight.w600,
                            color: colors.ink3, height: 1)),
                  ],
                ),
                const SizedBox(height: 6),
                for (final s in ['✦ Unlimited AI features', '✦ Home screen widget',
                  '✦ Export / share (PDF, image)', '✦ Pro badge + custom themes',
                  '✦ Gmail deep sync'])
                  Padding(
                    padding: const EdgeInsets.only(bottom: 3),
                    child: Text(s, style: TextStyle(fontFamily: 'Inter', fontSize: 11,
                        color: colors.ink2, height: 1.4)),
                  ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () => context.push(TaskEraRoutes.paywall),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFF5856D6), TaskEraColors.acc]),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    alignment: Alignment.center,
                    child: Text(AppL10n.of(context).upgrade,
                        style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w700,
                            color: Colors.white, height: 1)),
                  ),
                ),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: () => context.push(TaskEraRoutes.referral),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                        color: colors.surf2,
                        border: Border.all(width: 0.5, color: colors.bdr0),
                        borderRadius: BorderRadius.circular(11)),
                    alignment: Alignment.center,
                    child: const Text('🎁 Invite → both get 1 month free',
                        style: TextStyle(fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w600,
                            color: TaskEraColors.acc2, height: 1)),
                  ),
                ),
              ],
            ),
          ),
        ]),
      ),
    );
  }

  // Shown in place of the upsell once the user is Pro — no paywall, just status
  // + manage/restore. Reacts live: isProProvider flips on purchase/entitlement.
  List<Widget> _proActiveChildren(BuildContext context, TaskEraColors colors) {
    Widget feature(String s) => Padding(
          padding: const EdgeInsets.only(bottom: 3),
          child: Text(s, style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: colors.ink2, height: 1.4)),
        );
    return [
      Row(children: [
        const Text('✦ TaskEra Pro — active',
            style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w700,
                color: TaskEraColors.acc2, height: 1.3)),
        const Spacer(),
        Text('Thanks for your support',
            style: TextStyle(fontFamily: 'Inter', fontSize: 10, fontWeight: FontWeight.w600,
                color: colors.successFg, height: 1)),
      ]),
      const SizedBox(height: 8),
      for (final s in ['✦ Unlimited AI features', '✦ Home screen widget',
        '✦ Export / share (PDF, image)', '✦ Pro badge + custom themes', '✦ Gmail deep sync'])
        feature(s),
      const SizedBox(height: 10),
      GestureDetector(
        onTap: _managePlaySubscription,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF5856D6), TaskEraColors.acc]),
            borderRadius: BorderRadius.circular(11),
          ),
          alignment: Alignment.center,
          child: const Text('Manage subscription',
              style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w700,
                  color: Colors.white, height: 1)),
        ),
      ),
      const SizedBox(height: 6),
      GestureDetector(
        onTap: _restorePurchase,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
              color: colors.surf2,
              border: Border.all(width: 0.5, color: colors.bdr0),
              borderRadius: BorderRadius.circular(11)),
          alignment: Alignment.center,
          child: const Text('Restore purchase',
              style: TextStyle(fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w600,
                  color: TaskEraColors.acc2, height: 1)),
        ),
      ),
    ];
  }

  // Deep-links to the platform's own subscription management, per Guideline
  // 3.1.1 — TaskEra must not offer a custom cancellation/payment mechanism.
  Future<void> _managePlaySubscription() async {
    final uri = Platform.isIOS
        ? Uri.parse('https://apps.apple.com/account/subscriptions')
        : Uri.parse('https://play.google.com/store/account/subscriptions'
            '?package=com.port443.taskera');
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open subscription settings.')));
      }
    }
  }

  Future<void> _restorePurchase() async {
    try {
      await ref.read(purchaseServiceProvider).restore();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Checking for past purchases…')));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Restore failed. Please try again.')));
      }
    }
  }

  Widget _sgrpDisplay(TaskEraColors colors, TaskEraSettingsState s, TaskEraSettingsNotifier n) {
    const themes      = ['🌙 Dark', '☀️ Light', '🪟 Glass', '📱 System'];
    const fonts       = ['System', 'Serif', 'Rounded', 'Mono'];
    const fontSizes   = ['Sm', 'Md', 'Lg', 'XL'];
    const lineSpacings = ['Compact', 'Normal', 'Relaxed'];
    const accents     = [Color(0xFF0A84FF), Color(0xFF7FBA00), Color(0xFFFF6B00),
      Color(0xFFBF5AF2), Color(0xFFFF2D55), Color(0xFF00BCD4)];
    // Labels match TaskEraSettingsState._wallpapers order exactly (6 entries)
    const wpLabels = ['Ocean', 'Aurora', 'Beach', 'Night Sky', 'Tree'];

    return _Sgrp(
      isOpen: _open == 1,
      onToggle: () => _toggle(1),
      iconBg: const Color(0x1F0A84FF),
      iconSvg: _svgMonitor,
      iconColor: TaskEraColors.acc2,
      title: AppL10n.of(context).display,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SetSec(AppL10n.of(context).languageLabel, colors),
            _SetCard(colors: colors, children: [
              _LangRow(colors: colors, selected: s.lang, onTap: n.setLang),
            ]),
            _SetSec(AppL10n.of(context).themeAndAppearance, colors),
            _SetCard(colors: colors, children: [
              _VtRow(label: AppL10n.of(context).themeAndAppearance, options: themes, selected: s.theme, colors: colors,
                  onTap: (i) {
                    final changed = i != s.theme;
                    n.setTheme(i);
                    // Dark & Light each keep their own wallpaper-brightness; nudge
                    // the user to the slider right below so it matches the new look.
                    if (changed && (i == 0 || i == 1)) _showBrightnessHint(i);
                  }),
              Divider(height: 0.5, thickness: 0.5, color: colors.bdr),
              _DimSliderRow(value: s.wallpaperDim, colors: colors, onChanged: n.setWallpaperDim),
              Divider(height: 0.5, thickness: 0.5, color: colors.bdr),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(AppL10n.of(context).accentColour,
                      style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: colors.ink2, height: 1)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      for (int i = 0; i < accents.length; i++)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () => n.setAccent(i),
                            child: Container(
                              width: 22, height: 22,
                              decoration: BoxDecoration(
                                color: accents[i],
                                shape: BoxShape.circle,
                                border: s.accent == i
                                    ? Border.all(width: 2, color: Colors.white)
                                    : null,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ]),
              ),
              Divider(height: 0.5, thickness: 0.5, color: colors.bdr),
              SizedBox(
                height: 108,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemCount: wpLabels.length,
                  itemBuilder: (context, i) {
                    final sel = s.wallpaperIndex == i;
                    return GestureDetector(
                      onTap: () => n.setWallpaper(i),
                      child: SizedBox(
                        width: 58,
                        child: Column(children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                decoration: BoxDecoration(
                                  border: sel
                                      ? Border.all(width: 2, color: Colors.white)
                                      : Border.all(width: 0.5, color: colors.bdr0),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: _WpThumb(index: i),
                              ),
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(wpLabels[i],
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: 'Inter', fontSize: 9,
                                fontWeight: sel ? FontWeight.w600 : FontWeight.w400,
                                color: sel ? Colors.white : colors.ink3,
                                height: 1,
                              )),
                        ]),
                      ),
                    );
                  },
                ),
              ),
            ]),
            _SetSec(AppL10n.of(context).typography, colors),
            _SetCard(colors: colors, children: [
              _VtRow(label: AppL10n.of(context).fontStyle, options: fonts, selected: s.font, colors: colors,
                  onTap: n.setFont),
              Divider(height: 0.5, thickness: 0.5, color: colors.bdr),
              _VtRow(label: AppL10n.of(context).fontSizeLabel, options: fontSizes, selected: s.fontSize, colors: colors,
                  onTap: n.setFontSize),
              Divider(height: 0.5, thickness: 0.5, color: colors.bdr),
              _VtRow(label: AppL10n.of(context).lineSpacing, options: lineSpacings, selected: s.lineSpacing, colors: colors,
                  onTap: n.setLineSpacing),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _sgrpTasks(TaskEraColors colors, TaskEraSettingsState s, TaskEraSettingsNotifier n) {
    const layouts = ['≡ List view', '⊞ 2×2 Quad'];
    const qnames  = ['Covey', 'Eisenhower'];

    return _Sgrp(
      isOpen: _open == 2,
      onToggle: () => _toggle(2),
      iconBg: const Color(0x1FF25022),
      iconSvg: _svgCheck,
      iconColor: TaskEraColors.q1,
      title: AppL10n.of(context).tasks,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
        child: Column(children: [
          _SetSec(AppL10n.of(context).tasksView, colors),
          _SetCard(colors: colors, children: [
            _VtRow(label: AppL10n.of(context).layoutLabel, options: layouts, selected: s.layout, colors: colors,
                onTap: n.setLayout),
            Divider(height: 0.5, thickness: 0.5, color: colors.bdr),
            _VtRow(label: AppL10n.of(context).quadrantNames, options: qnames, selected: s.qnames, colors: colors,
                onTap: n.setQnames),
            Divider(height: 0.5, thickness: 0.5, color: colors.bdr),
            _SwRow(settingKey: 'listsGrid', label: AppL10n.of(context).showMyChecklists, colors: colors),
          ]),
        ]),
      ),
    );
  }

  Widget _sgrpTabs(TaskEraColors colors, TaskEraSettingsState s, TaskEraSettingsNotifier n) {
    final l = AppL10n.of(context);
    final rows = <(String, String)>[
      ('habits',   l.habitsTracker),
      ('calendar', l.calendarTab),
      ('notes',    l.notesTab),
      ('inbox',    l.inboxLabel),
    ];

    return _Sgrp(
      isOpen: _open == 3,
      onToggle: () => _toggle(3),
      iconBg: const Color(0x1F00BCD4),
      iconSvg: _svgTabs,
      iconColor: const Color(0xFF00BCD4),
      title: AppL10n.of(context).tabsLabel,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
        child: _SetCard(colors: colors, children: [
          for (int i = 0; i < rows.length; i++) ...[
            if (i > 0) Divider(height: 0.5, thickness: 0.5, color: colors.bdr),
            _SwRow(settingKey: rows[i].$1, label: rows[i].$2, colors: colors),
          ],
        ]),
      ),
    );
  }

  Widget _sgrpFeatures(TaskEraColors colors, TaskEraSettingsState s, TaskEraSettingsNotifier n) {
    final l = AppL10n.of(context);
    final rows = <(String, String)>[
      ('scoreRec',   l.scoreRec),
      ('quoteSplash', l.quoteSplash),
      ('eodReflect', l.eodReflect),
      ('focusPeak',  l.peakCard),
      ('focusBrain', l.brainDumpCard),
    ];

    return _Sgrp(
      isOpen: _open == 4,
      onToggle: () => _toggle(4),
      iconWidget: Container(
        width: 24, height: 24,
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF5856D6), TaskEraColors.acc]),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Center(child: SvgPicture.string(_svgStar.replaceAll('var(--c)', 'white'), width: 12, height: 12)),
      ),
      title: AppL10n.of(context).featuresAndSmart,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
        child: _SetCard(colors: colors, children: [
          for (int i = 0; i < rows.length; i++) ...[
            if (i > 0) Divider(height: 0.5, thickness: 0.5, color: colors.bdr),
            _SwRow(settingKey: rows[i].$1, label: rows[i].$2, colors: colors),
            // When the end-of-day reflection is enabled, let the user pick the
            // hour it may appear (it only shows on app exit at/after this time).
            if (rows[i].$1 == 'eodReflect' && s.sw('eodReflect')) ...[
              Divider(height: 0.5, thickness: 0.5, color: colors.bdr),
              _VtRow(
                label: l.eodReflectTime,
                options: _eodHourLabels,
                selected: _eodHourOptions.indexOf(_eodHour).clamp(0, _eodHourOptions.length - 1),
                colors: colors,
                onTap: (idx) {
                  final h = _eodHourOptions[idx];
                  AppLaunchPrefs.setEodHour(ref.read(sharedPreferencesProvider), h);
                  setState(() => _eodHour = h);
                },
              ),
            ],
          ],
        ]),
      ),
    );
  }

  Widget _sgrpCalInbox(TaskEraColors colors, TaskEraSettingsState s, TaskEraSettingsNotifier n, IntegrationsState integrations) {
    final gmailEnabled = ref.watch(gmailEnabledProvider);
    final calendarEnabled = ref.watch(calendarEnabledProvider);
    final inboxCount = ref.watch(inboxTasksProvider).value?.length ?? 0;
    return _Sgrp(
      isOpen: _open == 5,
      onToggle: () => _toggle(5),
      iconBg: const Color(0x1F0A84FF),
      iconSvg: _svgCal,
      iconColor: TaskEraColors.acc2,
      title: AppL10n.of(context).calendarAndInbox,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
        child: _SetCard(colors: colors, children: [
          _NavRow(
              label: AppL10n.of(context).calendarSync,
              right: !calendarEnabled
                  ? 'Soon'
                  : (integrations.googleCalendarConnected ? AppL10n.of(context).connected : ''),
              rightColor: calendarEnabled ? colors.successFg : TaskEraColors.acc2,
              colors: colors, onTap: () => context.go(TaskEraRoutes.calSync)),
          Divider(height: 0.5, thickness: 0.5, color: colors.bdr),
          _NavRow(label: AppL10n.of(context).inboxLabel,
              right: inboxCount > 0 ? '$inboxCount new' : '',
              rightColor: TaskEraColors.warn,
              colors: colors, onTap: () {
                final router = GoRouter.of(context);
                WidgetsBinding.instance.addPostFrameCallback((_) => router.go(TaskEraRoutes.inbox));
              }),
          Divider(height: 0.5, thickness: 0.5, color: colors.bdr),
          _NavRow(label: AppL10n.of(context).gmailSync, right: gmailEnabled ? '' : 'Soon', rightColor: TaskEraColors.acc2,
              colors: colors, onTap: () => context.go(TaskEraRoutes.calGmail)),
          Divider(height: 0.5, thickness: 0.5, color: colors.bdr),
          _SwRow(settingKey: 'suggestTasks', label: AppL10n.of(context).suggestTasksInbox, colors: colors),
        ]),
      ),
    );
  }

  // Shows an API-key entry dialog for OpenAI and triggers connect.
  Future<void> _connectOpenAi() async {
    final colors = TaskEraTheme.of(context).colors;
    String key = '';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('OpenAI API key',
            style: TextStyle(fontFamily: 'Inter', fontSize: 15,
                fontWeight: FontWeight.w600, color: Colors.white)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('Enter your secret API key (sk-…). It powers all of TaskEra’s AI.',
              style: TextStyle(fontFamily: 'Inter', fontSize: 12,
                  color: colors.labelMuted)),
          const SizedBox(height: 12),
          TextField(
            autofocus: true,
            onChanged: (v) => key = v,
            style: const TextStyle(fontFamily: 'Inter', fontSize: 13,
                color: Colors.white),
            decoration: InputDecoration(
              hintText: 'sk-…',
              hintStyle: const TextStyle(color: Color(0x40FFFFFF)),
              filled: true,
              fillColor: colors.bdr0,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
        ]),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel',
                style: TextStyle(fontFamily: 'Inter', color: colors.labelMuted)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Connect',
                style: TextStyle(fontFamily: 'Inter',
                    color: TaskEraColors.acc2, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
    if (confirmed == true && key.trim().isNotEmpty) {
      final ok =
          await ref.read(integrationsProvider.notifier).connectOpenAi(key.trim());
      if (mounted && !ok) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Invalid API key — check and try again'),
          duration: Duration(seconds: 2),
        ));
      }
    }
  }

  // Shows an API-key entry dialog for Claude (Anthropic) and triggers connect.
  Future<void> _connectAnthropic() async {
    final colors = TaskEraTheme.of(context).colors;
    String key = '';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('Claude (Anthropic) API key',
            style: TextStyle(fontFamily: 'Inter', fontSize: 15,
                fontWeight: FontWeight.w600, color: Colors.white)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('Enter your secret API key (sk-ant-…). It powers all of TaskEra’s AI.',
              style: TextStyle(fontFamily: 'Inter', fontSize: 12,
                  color: colors.labelMuted)),
          const SizedBox(height: 12),
          TextField(
            autofocus: true,
            onChanged: (v) => key = v,
            style: const TextStyle(fontFamily: 'Inter', fontSize: 13, color: Colors.white),
            decoration: InputDecoration(
              hintText: 'sk-ant-…',
              hintStyle: const TextStyle(color: Color(0x40FFFFFF)),
              filled: true,
              fillColor: colors.bdr0,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
        ]),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel',
                style: TextStyle(fontFamily: 'Inter', color: colors.labelMuted)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Connect',
                style: TextStyle(fontFamily: 'Inter',
                    color: TaskEraColors.acc2, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
    if (confirmed == true && key.trim().isNotEmpty) {
      final ok =
          await ref.read(integrationsProvider.notifier).connectAnthropic(key.trim());
      if (mounted && !ok) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Invalid API key — check and try again'),
          duration: Duration(seconds: 2),
        ));
      }
    }
  }

  Widget _sgrpIntegrations(TaskEraColors colors) {
    final integrations = ref.watch(integrationsProvider);
    final notifier     = ref.read(integrationsProvider.notifier);
    final disabled     = integrations.loading;

    VoidCallback? tap(bool connected, Future<void> Function() disconnect,
            Future<bool> Function() connect) =>
        disabled
            ? null
            : () async {
                if (connected) {
                  await disconnect();
                } else {
                  final ok = await connect();
                  if (mounted && !ok) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text(
                          'Could not connect — credentials not configured or connection cancelled',
                          style: TextStyle(fontFamily: 'Inter', fontSize: 13,
                              color: Colors.white)),
                      backgroundColor: Color(0xFF1C1C1E),
                      duration: Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                    ));
                  }
                }
              };

    // Remote flag per integration (default OFF → row shows "Soon", connect
    // blocked). Flip a key in the Supabase `app_flags` table to enable one.
    bool fe(String k) => ref.watch(featureEnabledProvider(k));
    // Force "coming soon" when the flag is off, else keep the real status/tap.
    List<_IntStatus> gateS(List<String> keys, List<_IntStatus> st) =>
        [for (var i = 0; i < st.length; i++) fe(keys[i]) ? st[i] : _IntStatus.comingSoon];
    List<VoidCallback?> gateT(List<String> keys, List<String> names, List<VoidCallback?> tp) =>
        [for (var i = 0; i < tp.length; i++) fe(keys[i]) ? tp[i] : (() => _comingSoon(context, names[i]))];

    // Productivity: Notion, Todoist, Apple Reminders
    const pKeys = ['notion', 'todoist', 'apple_reminders'];
    const pNames = ['Notion', 'Todoist', 'Apple Reminders'];
    final productivityStatuses = gateS(pKeys, [
      integrations.notionConnected   ? _IntStatus.connected : _IntStatus.connect,
      integrations.todoistConnected  ? _IntStatus.connected : _IntStatus.connect,
      _IntStatus.connect, // Apple Reminders — native, coming soon
    ]);
    final productivityTaps = gateT(pKeys, pNames, <VoidCallback?>[
      tap(integrations.notionConnected,
          notifier.disconnectNotion, notifier.connectNotion),
      tap(integrations.todoistConnected,
          notifier.disconnectTodoist, notifier.connectTodoist),
      () => _comingSoon(context, 'Apple Reminders'),
    ]);

    // Work & Corporate: Slack, Jira, Asana, Linear, Microsoft Teams, GitHub
    const wKeys = ['slack', 'jira', 'asana', 'linear', 'teams', 'github'];
    const wNames = ['Slack', 'Jira', 'Asana', 'Linear', 'Microsoft Teams', 'GitHub'];
    final workStatuses = gateS(wKeys, [
      integrations.slackConnected    ? _IntStatus.connected : _IntStatus.connect,
      integrations.jiraConnected     ? _IntStatus.connected : _IntStatus.connect,
      integrations.asanaConnected    ? _IntStatus.connected : _IntStatus.connect,
      integrations.linearConnected   ? _IntStatus.connected : _IntStatus.connect,
      integrations.microsoftConnected? _IntStatus.connected : _IntStatus.connect,
      integrations.githubConnected   ? _IntStatus.connected : _IntStatus.connect,
    ]);
    final workTaps = gateT(wKeys, wNames, <VoidCallback?>[
      tap(integrations.slackConnected,
          notifier.disconnectSlack,    notifier.connectSlack),
      tap(integrations.jiraConnected,
          notifier.disconnectJira,     notifier.connectJira),
      tap(integrations.asanaConnected,
          notifier.disconnectAsana,    notifier.connectAsana),
      tap(integrations.linearConnected,
          notifier.disconnectLinear,   notifier.connectLinear),
      tap(integrations.microsoftConnected,
          notifier.disconnectMicrosoft, notifier.connectMicrosoft),
      tap(integrations.githubConnected,
          notifier.disconnectGitHub,   notifier.connectGitHub),
    ]);

    // Calendar & Email: Google Calendar, Gmail · Outlook/iCloud (unbuilt)
    const cKeys = ['calendar', 'gmail', 'outlook', 'icloud'];
    const cNames = ['Google Calendar', 'Gmail', 'Outlook / Hotmail', 'iCloud Mail'];
    final calEmailStatuses = gateS(cKeys, [
      integrations.googleCalendarConnected ? _IntStatus.connected : _IntStatus.connect,
      integrations.gmailConnected          ? _IntStatus.active    : _IntStatus.connect,
      _IntStatus.comingSoon, // Outlook / Hotmail
      _IntStatus.comingSoon, // iCloud Mail
    ]);
    final calEmailTaps = gateT(cKeys, cNames, <VoidCallback?>[
      tap(integrations.googleCalendarConnected,
          notifier.disconnectCalendar,
          () async => await confirmGoogleAccess(context, GoogleAccess.calendar) &&
              await notifier.connectGoogleCalendar()),
      tap(integrations.gmailConnected,
          notifier.disconnectGmail,
          () async => await confirmGoogleAccess(context, GoogleAccess.gmail) &&
              await notifier.connectGmail()),
      () => _comingSoon(context, 'Outlook / Hotmail'),
      () => _comingSoon(context, 'iCloud Mail'),
    ]);

    // AI Assistants: ChatGPT/OpenAI, Claude/Anthropic (bring-your-own-key)
    const aiKeys = ['openai', 'anthropic'];
    const aiNames = ['ChatGPT / OpenAI', 'Claude / Anthropic'];
    final aiStatuses = gateS(aiKeys, [
      integrations.openAiConnected ? _IntStatus.connected : _IntStatus.connect,
      integrations.anthropicConnected ? _IntStatus.connected : _IntStatus.connect,
    ]);
    final aiTaps = gateT(aiKeys, aiNames, <VoidCallback?>[
      disabled
          ? null
          : integrations.openAiConnected
              ? () => notifier.disconnectOpenAi()
              : _connectOpenAi,
      disabled
          ? null
          : integrations.anthropicConnected
              ? () => notifier.disconnectAnthropic()
              : _connectAnthropic,
    ]);

    return _Sgrp(
      isOpen: _open == 6,
      onToggle: () => _toggle(6),
      iconWidget: Container(
        width: 24, height: 24,
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF5856D6), TaskEraColors.acc]),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Center(child: SvgPicture.string(_svgLink, width: 12, height: 12)),
      ),
      title: AppL10n.of(context).integrationsLabel,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _IntStatusPill(colors: colors),
          const SizedBox(height: 12),
          _IntSection(label: 'Productivity', services: _intProductivity, colors: colors,
              onTaps: productivityTaps, liveStatuses: productivityStatuses),
          const SizedBox(height: 10),
          _IntSection(label: 'Work & Corporate', services: _intWork, colors: colors,
              onTaps: workTaps, liveStatuses: workStatuses),
          const SizedBox(height: 10),
          _IntSection(label: 'Calendar & Email', services: _intCalEmail, colors: colors,
              onTaps: calEmailTaps, liveStatuses: calEmailStatuses),
          const SizedBox(height: 10),
          _IntSection(label: 'AI Assistants', services: _intAi, colors: colors,
              onTaps: aiTaps, liveStatuses: aiStatuses),
          const SizedBox(height: 10),
          _IntHowCard(colors: colors),
        ]),
      ),
    );
  }

  Widget _sgrpSyncData(TaskEraColors colors) {
    return _Sgrp(
      isOpen: _open == 7,
      onToggle: () => _toggle(7),
      iconBg: const Color(0x1F7FBA00),
      iconSvg: _svgSync,
      iconColor: colors.successFg,
      title: AppL10n.of(context).syncAndData,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
        child: _SetCard(colors: colors, children: [
          _NavRow(label: AppL10n.of(context).realTimeSync, right: 'Soon', rightColor: colors.ink3,
              colors: colors, onTap: () => _comingSoon(context, 'Real-time sync details')),
          Divider(height: 0.5, thickness: 0.5, color: colors.bdr),
          _SwRow(settingKey: 'cloudSync', label: AppL10n.of(context).cloudSync, colors: colors),
          Divider(height: 0.5, thickness: 0.5, color: colors.bdr),
          _NavRow(label: AppL10n.of(context).connectedDevices, right: 'Soon', rightColor: colors.ink3,
              colors: colors, onTap: () => _comingSoon(context, 'Connected devices')),
          Divider(height: 0.5, thickness: 0.5, color: colors.bdr),
          _NavRow(label: AppL10n.of(context).backUpNow, right: 'Soon',
              rightColor: colors.ink3, colors: colors, onTap: () => _comingSoon(context, 'Backup')),
          Divider(height: 0.5, thickness: 0.5, color: colors.bdr),
          _NavRow(label: AppL10n.of(context).exportJson, right: '›', rightColor: colors.ink3,
              colors: colors, onTap: () => _exportJson(context)),
          Divider(height: 0.5, thickness: 0.5, color: colors.bdr),
          _NavRow(label: AppL10n.of(context).activityLog, right: '›', rightColor: colors.ink3,
              colors: colors, onTap: () => context.push(TaskEraRoutes.activityLogs)),
          Divider(height: 0.5, thickness: 0.5, color: colors.bdr),
          _NavRow(label: AppL10n.of(context).studentMode, right: '›', rightColor: colors.ink3,
              colors: colors, onTap: () => context.push(TaskEraRoutes.studentMode)),
        ]),
      ),
    );
  }

  Widget _sgrpNotifications(TaskEraColors colors, TaskEraSettingsState s, TaskEraSettingsNotifier n) {
    final l = AppL10n.of(context);

    final categories = <(String, String, String)>[
      ('notifTasks',    'Task reminders',         'Due dates · morning briefing · overdue digest'),
      ('notifHabits',   'Habit reminders',         'Daily check-in · streak at risk alert'),
      ('notifGoals',    'Goal check-ins',           'Weekly review · deadline warnings'),
      ('notifCalendar', 'Calendar alerts',          '15-min event reminders'),
      ('notifInbox',    'Inbox digest',             'Daily action items summary'),
      ('notifFocus',    'Focus & Pomodoro',         'Weekly review reminder'),
    ];

    final alerts = <(String, String)>[
      ('q1Alert',   l.q1UrgentAlerts),
      ('q2Nudge',   l.q2DailyNudge),
      ('reminders', l.taskReminders),
      ('overload',  l.q1OverloadWarning),
      ('q2Neglect', l.q2NeglectNudge),
    ];

    return _Sgrp(
      isOpen: _open == 8,
      onToggle: () => _toggle(8),
      iconBg: const Color(0x1FFF6B6B),
      iconSvg: _svgBell,
      iconColor: TaskEraColors.warn,
      title: AppL10n.of(context).notificationsLabel,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
        child: Column(children: [
          _SetSec('Channels', colors),
          _SetCard(colors: colors, children: [
            for (int i = 0; i < categories.length; i++) ...[
              if (i > 0) Divider(height: 0.5, thickness: 0.5, color: colors.bdr),
              _NotifSwRow(
                settingKey: categories[i].$1,
                label: categories[i].$2,
                sub: categories[i].$3,
                colors: colors,
                afterChange: _rescheduleAfterToggle,
              ),
            ],
          ]),
          _SetSec('Smart Alerts', colors),
          _SetCard(colors: colors, children: [
            for (int i = 0; i < alerts.length; i++) ...[
              if (i > 0) Divider(height: 0.5, thickness: 0.5, color: colors.bdr),
              _SwRow(settingKey: alerts[i].$1, label: alerts[i].$2, colors: colors),
            ],
          ]),
          _SetSec('Do The Next', colors),
          _SetCard(colors: colors, children: [
            _SwRow(settingKey: 'dtnNotif', label: 'Ongoing "Do The Next" card', colors: colors),
            Divider(height: 0.5, thickness: 0.5, color: colors.bdr),
            _SwRow(settingKey: 'dtnLockScreen', label: 'Show on lock screen', colors: colors),
          ]),
        ]),
      ),
    );
  }
}

// ── Reusable section widgets ──────────────────────────────────────────────────

class _Sgrp extends StatelessWidget {
  final bool isOpen;
  final VoidCallback onToggle;
  final Color? headerColor;
  final Color? iconBg;
  final String? iconSvg;
  final Color? iconColor;
  final Widget? iconWidget;
  final Widget? titleWidget;
  final String? title;
  final Widget? badge;
  final Widget body;

  const _Sgrp({
    required this.isOpen,
    required this.onToggle,
    required this.body,
    this.headerColor,
    this.iconBg,
    this.iconSvg,
    this.iconColor,
    this.iconWidget,
    this.titleWidget,
    this.title,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    final colors = TaskEraTheme.of(context).colors;
    Widget ico = iconWidget ?? Container(
      width: 24, height: 24,
      decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(6)),
      child: Center(
        child: SvgPicture.string(
          (iconSvg ?? '').replaceAll('var(--c)', _hexOf(iconColor ?? Colors.white)),
          width: 12, height: 12,
        ),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GestureDetector(
          onTap: onToggle,
          child: Container(
            color: headerColor ?? Colors.transparent,
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            child: Row(children: [
              ico,
              const SizedBox(width: 8),
              Expanded(
                child: titleWidget ?? Text(title ?? '',
                    style: TextStyle(fontFamily: 'Inter', fontSize: 13,
                        fontWeight: FontWeight.w600, color: colors.ink, height: 1)),
              ),
              if (badge != null) ...[badge!, const SizedBox(width: 6)],
              AnimatedRotation(
                turns: isOpen ? 0.25 : 0,
                duration: const Duration(milliseconds: 200),
                child: Text('›', style: TextStyle(fontFamily: 'Inter', fontSize: 18,
                    color: colors.ink3, height: 1)),
              ),
            ]),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeInOut,
          child: isOpen ? body : const SizedBox.shrink(),
        ),
        Divider(height: 0.5, thickness: 0.5, color: colors.bdr),
      ],
    );
  }

  String _hexOf(Color c) =>
      '#${(c.r * 255).round().toRadixString(16).padLeft(2, '0')}${(c.g * 255).round().toRadixString(16).padLeft(2, '0')}${(c.b * 255).round().toRadixString(16).padLeft(2, '0')}';
}

class _SetSec extends StatelessWidget {
  final String label;
  final TaskEraColors colors;
  const _SetSec(this.label, this.colors);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 6, 0, 4),
      child: Text(label.toUpperCase(),
          style: TextStyle(fontFamily: 'Inter', fontSize: 9,
              fontWeight: FontWeight.w600, color: colors.ink3, letterSpacing: 0.5, height: 1)),
    );
  }
}

class _SetCard extends StatelessWidget {
  final TaskEraColors colors;
  final List<Widget> children;
  const _SetCard({required this.colors, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(width: 0.5, color: colors.bdr),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }
}

// Paragraph text for the About & Legal group (mirrors the old subscreen style).
class _AboutPara extends StatelessWidget {
  final String text;
  final TaskEraColors colors;
  final bool strong;
  const _AboutPara(this.text, this.colors, {this.strong = false});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
        child: Text(text,
            style: TextStyle(fontFamily: 'Inter', fontSize: 12,
                fontWeight: strong ? FontWeight.w700 : FontWeight.w400,
                letterSpacing: strong ? 0.3 : 0,
                color: strong ? colors.ink2 : colors.ink3, height: 1.6)),
      );
}

class _SwRow extends ConsumerWidget {
  final String settingKey;
  final String label;
  final TaskEraColors colors;
  const _SwRow({required this.settingKey, required this.label, required this.colors});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final value = ref.watch(taskeraSettingsProvider.select((s) => s.sw(settingKey)));
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 9, 12, 9),
      child: Row(children: [
        Expanded(child: Text(label,
            style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: colors.ink, height: 1))),
        _Sw(
          value: value,
          onChanged: (v) => ref.read(taskeraSettingsProvider.notifier).toggle(settingKey, v),
        ),
      ]),
    );
  }
}

class _NotifSwRow extends ConsumerWidget {
  final String settingKey;
  final String label;
  final String sub;
  final TaskEraColors colors;
  final Future<void> Function()? afterChange;
  const _NotifSwRow({
    required this.settingKey, required this.label, required this.sub,
    required this.colors, this.afterChange,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final value = ref.watch(taskeraSettingsProvider.select((s) => s.sw(settingKey)));
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      child: Row(children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label,
                style: TextStyle(fontFamily: 'Inter', fontSize: 13,
                    color: colors.ink, height: 1)),
            const SizedBox(height: 3),
            Text(sub,
                style: TextStyle(fontFamily: 'Inter', fontSize: 11,
                    color: colors.ink3, height: 1.3)),
          ]),
        ),
        const SizedBox(width: 10),
        _Sw(
          value: value,
          onChanged: (v) {
            ref.read(taskeraSettingsProvider.notifier).toggle(settingKey, v);
            afterChange?.call();
          },
        ),
      ]),
    );
  }
}

class _NavRow extends StatelessWidget {
  final String label;
  final String right;
  final Color rightColor;
  final TaskEraColors colors;
  final VoidCallback onTap;
  const _NavRow({required this.label, required this.right, required this.rightColor,
    required this.colors, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 9, 12, 9),
        child: Row(children: [
          Expanded(child: Text(label,
              style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: colors.ink, height: 1))),
          Text(right,
              style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: rightColor, height: 1)),
          if (right != '›') ...[
            const SizedBox(width: 4),
            Text('›', style: TextStyle(fontFamily: 'Inter', fontSize: 14, color: colors.ink3, height: 1)),
          ],
        ]),
      ),
    );
  }
}

class _VtRow extends StatelessWidget {
  final String label;
  final List<String> options;
  final int selected;
  final TaskEraColors colors;
  final ValueChanged<int> onTap;
  const _VtRow({required this.label, required this.options, required this.selected,
    required this.colors, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 7),
          child: Text(label,
              style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: colors.ink2, height: 1)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              for (int i = 0; i < options.length; i++)
                Expanded(
                  child: GestureDetector(
                    onTap: () => onTap(i),
                    child: Container(
                      margin: EdgeInsets.only(right: i < options.length - 1 ? 3 : 0),
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      decoration: BoxDecoration(
                        color: selected == i ? TaskEraColors.accBg : colors.surf2,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          width: 0.5,
                          color: selected == i ? const Color(0x4D0A84FF) : colors.bdr0,
                        ),
                      ),
                      child: Text(options[i],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Inter', fontSize: 10, fontWeight: FontWeight.w500,
                            color: selected == i ? TaskEraColors.acc2 : colors.ink3,
                            height: 1,
                          )),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ]),
    );
  }
}

class _LangRow extends StatefulWidget {
  final TaskEraColors colors;
  final int selected;
  final ValueChanged<int> onTap;
  const _LangRow({required this.colors, required this.selected, required this.onTap});

  @override
  State<_LangRow> createState() => _LangRowState();
}

class _LangRowState extends State<_LangRow> {
  static const _worldLangs = [
    'English', '日本語', 'Deutsch', '한국어', 'Français',
    '中文', 'Español', 'Português', 'Italiano', 'Nederlands', 'العربية',
  ];

  Widget _chip(int idx, String label) {
    final sel = widget.selected == idx;
    return GestureDetector(
      onTap: () => widget.onTap(idx),
      child: Container(
        padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
        decoration: BoxDecoration(
          color: sel ? TaskEraColors.accBg : widget.colors.surf2,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(width: 0.5,
              color: sel ? const Color(0x4D0A84FF) : widget.colors.bdr0),
        ),
        child: Text(label, style: TextStyle(
          fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w500,
          color: sel ? TaskEraColors.acc2 : widget.colors.ink3,
          height: 1,
        )),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: Wrap(
        spacing: 4, runSpacing: 4,
        children: [
          for (int i = 0; i < _worldLangs.length; i++) _chip(i, _worldLangs[i]),
        ],
      ),
    );
  }
}

// ── Wallpaper thumbnail — index matches TaskEraSettingsState._wallpapers ────────

class _WpThumb extends StatelessWidget {
  final int index;
  const _WpThumb({required this.index});

  // Order matches TaskEraSettingsState._wallpapers exactly
  static const _paths = [
    'assets/wallpapers/OCEAN.jpg',          // 0 ocean
    'assets/wallpapers/AURORA3 - Copy.JPG', // 1 aurora3
    'assets/wallpapers/BEACH.JPG',          // 2 beach
    'assets/wallpapers/NightSky.JPG',       // 3 nightSky
    'assets/wallpapers/tree.jpg',           // 4 tree
  ];

  @override
  Widget build(BuildContext context) {
    if (index >= _paths.length) return const ColoredBox(color: Color(0xFF0D0D14));
    return Image.asset(
      _paths[index],
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => const ColoredBox(color: Color(0xFF0D0D14)),
    );
  }
}

// ── Wallpaper brightness slider ───────────────────────────────────────────────

class _DimSliderRow extends StatelessWidget {
  final double value;
  final TaskEraColors colors;
  final ValueChanged<double> onChanged;
  const _DimSliderRow({required this.value, required this.colors, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppL10n.of(context).brightness,
              style: TextStyle(fontFamily: 'Inter', fontSize: 13,
                  color: colors.ink, height: 1)),
          const SizedBox(height: 8),
          Row(
            children: [
              Text('☀', style: TextStyle(fontSize: 13, color: colors.ink2)),
              Expanded(
                child: SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 2,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                    activeTrackColor: TaskEraColors.acc,
                    inactiveTrackColor: const Color(0x33FFFFFF),
                    thumbColor: TaskEraColors.acc,
                    overlayColor: TaskEraColors.accBg,
                  ),
                  child: Slider(
                    value: value,
                    min: 0.0,
                    max: 1.0,
                    onChanged: onChanged,
                  ),
                ),
              ),
              Text('●', style: TextStyle(fontSize: 10, color: colors.ink2)),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Integration section widgets ───────────────────────────────────────────────

class _IntStatusPill extends ConsumerWidget {
  final TaskEraColors colors;
  const _IntStatusPill({required this.colors});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(integrationsProvider);
    final count = (s.googleCalendarConnected ? 1 : 0) +
        (s.gmailConnected       ? 1 : 0) +
        (s.microsoftConnected   ? 1 : 0) +
        (s.notionConnected      ? 1 : 0) +
        (s.todoistConnected     ? 1 : 0) +
        (s.slackConnected       ? 1 : 0) +
        (s.jiraConnected        ? 1 : 0) +
        (s.asanaConnected       ? 1 : 0) +
        (s.linearConnected      ? 1 : 0) +
        (s.githubConnected      ? 1 : 0) +
        (s.openAiConnected      ? 1 : 0);

    return Container(
      padding: const EdgeInsets.fromLTRB(10, 8, 12, 8),
      decoration: BoxDecoration(
        color: const Color(0x14159121),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(width: 0.5, color: const Color(0x409FCD44)),
      ),
      child: Row(children: [
        s.loading
            ? SizedBox(
                width: 18, height: 18,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: colors.successFg))
            : Icon(Icons.check_rounded, color: colors.successFg, size: 18),
        const SizedBox(width: 8),
        Text('$count integration${count == 1 ? '' : 's'} active',
            style: TextStyle(fontFamily: 'Inter', fontSize: 13,
                fontWeight: FontWeight.w600, color: colors.successFg, height: 1)),
        const Spacer(),
        Text(count == 0 ? 'None connected' : 'Syncing',
            style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: colors.ink3, height: 1)),
      ]),
    );
  }
}

class _IntSection extends StatelessWidget {
  final String label;
  final List<_IntService> services;
  final TaskEraColors colors;
  final List<VoidCallback?>? onTaps;
  final List<_IntStatus?>? liveStatuses;
  const _IntSection({required this.label, required this.services, required this.colors,
      this.onTaps, this.liveStatuses});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.only(bottom: 6, left: 2),
        child: Text(label.toUpperCase(),
            style: TextStyle(fontFamily: 'Inter', fontSize: 9,
                fontWeight: FontWeight.w700, letterSpacing: 0.5,
                color: colors.ink3, height: 1)),
      ),
      Container(
        decoration: BoxDecoration(
          color: colors.surf2,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(width: 0.5, color: colors.bdr),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (int i = 0; i < services.length; i++) ...[
              if (i > 0) Divider(height: 0.5, thickness: 0.5, color: colors.bdr),
              _IntServiceRow(
                service: services[i], colors: colors,
                isFirst: i == 0, isLast: i == services.length - 1,
                onTap: onTaps != null && i < onTaps!.length ? onTaps![i] : null,
                liveStatus: liveStatuses != null && i < liveStatuses!.length
                    ? liveStatuses![i]
                    : null,
              ),
            ],
          ],
        ),
      ),
    ]);
  }
}

class _IntServiceRow extends StatelessWidget {
  final _IntService service;
  final TaskEraColors colors;
  final bool isFirst;
  final bool isLast;
  final VoidCallback? onTap;
  final _IntStatus? liveStatus;
  const _IntServiceRow({required this.service, required this.colors,
      required this.isFirst, required this.isLast, this.onTap, this.liveStatus});

  @override
  Widget build(BuildContext context) {
    final effectiveStatus = liveStatus ?? service.status;
    final isHighlighted = effectiveStatus == _IntStatus.active;

    return GestureDetector(
      onTap: onTap ?? () {},
      child: Container(
        decoration: BoxDecoration(
          color: isHighlighted ? TaskEraColors.accBg : Colors.transparent,
          borderRadius: BorderRadius.vertical(
            top: isFirst ? const Radius.circular(9) : Radius.zero,
            bottom: isLast ? const Radius.circular(9) : Radius.zero,
          ),
        ),
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        child: Row(children: [
          Container(
            width: 26, height: 26,
            decoration: BoxDecoration(
              color: service.name == 'Google Calendar'
                  ? Colors.white
                  : service.iconBg,
              borderRadius: BorderRadius.circular(6),
              border: service.name == 'Google Calendar'
                  ? Border.all(width: 0.5, color: colors.bdr0)
                  : null,
            ),
            child: Center(child: SvgPicture.string(service.iconSvg, width: 14, height: 14)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(service.name,
                  style: TextStyle(fontFamily: 'Inter', fontSize: 13,
                      color: isHighlighted ? TaskEraColors.acc2 : colors.ink, height: 1)),
              const SizedBox(height: 3),
              Text(service.sub,
                  style: TextStyle(fontFamily: 'Inter', fontSize: 11,
                      color: colors.ink3, height: 1.3)),
            ]),
          ),
          const SizedBox(width: 8),
          _IntStatusBadge(status: effectiveStatus, colors: colors),
        ]),
      ),
    );
  }
}

class _IntStatusBadge extends StatelessWidget {
  final _IntStatus status;
  final TaskEraColors colors;
  const _IntStatusBadge({required this.status, required this.colors});

  @override
  Widget build(BuildContext context) {
    if (status == _IntStatus.connected || status == _IntStatus.active) {
      return Container(
        padding: const EdgeInsets.fromLTRB(7, 3, 7, 3),
        decoration: BoxDecoration(
          color: const Color(0x1F9FCD44),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(status == _IntStatus.connected ? 'Connected' : 'Active',
            style: TextStyle(fontFamily: 'Inter', fontSize: 10,
                fontWeight: FontWeight.w600, color: colors.successFg, height: 1)),
      );
    }
    if (status == _IntStatus.comingSoon) {
      return Container(
        padding: const EdgeInsets.fromLTRB(7, 3, 7, 3),
        decoration: BoxDecoration(
          color: colors.surf2,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text('Soon', style: TextStyle(fontFamily: 'Inter', fontSize: 10,
            fontWeight: FontWeight.w600, color: colors.ink3, height: 1)),
      );
    }
    return Text('${AppL10n.of(context).connect} ›',
        style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: colors.ink3, height: 1));
  }
}

class _IntHowCard extends StatelessWidget {
  final TaskEraColors colors;
  const _IntHowCard({required this.colors});

  @override
  Widget build(BuildContext context) {
    const steps = [
      'Connect your work tool — TaskEra reads tasks/issues assigned to you',
      'AI scores each item and suggests Q1/Q2/Q3/Q4 based on deadline + importance',
      'You confirm — task lands in the right quadrant with full context from source',
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 11, 12, 12),
      decoration: BoxDecoration(
        color: TaskEraColors.accBg,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(width: 0.5, color: const Color(0x330A84FF)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('✦ How integrations work',
            style: TextStyle(fontFamily: 'Inter', fontSize: 11,
                fontWeight: FontWeight.w700, letterSpacing: 0.4,
                color: TaskEraColors.acc2, height: 1)),
        const SizedBox(height: 10),
        for (int i = 0; i < steps.length; i++) ...[
          if (i > 0) const SizedBox(height: 8),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              width: 16, height: 16,
              decoration: const BoxDecoration(color: TaskEraColors.acc, shape: BoxShape.circle),
              alignment: Alignment.center,
              child: Text('${i + 1}',
                  style: const TextStyle(fontFamily: 'Inter', fontSize: 9,
                      fontWeight: FontWeight.w700, color: Colors.white, height: 1)),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(steps[i],
                  style: TextStyle(fontFamily: 'Inter', fontSize: 12,
                      color: colors.ink2, height: 1.5)),
            ),
          ]),
        ],
      ]),
    );
  }
}

// ── Custom toggle ─────────────────────────────────────────────────────────────

class _Sw extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  const _Sw({required this.value, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged?.call(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 32, height: 17,
        decoration: BoxDecoration(
          color: value ? TaskEraColors.acc : const Color(0x33FFFFFF),
          borderRadius: BorderRadius.circular(999),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 13, height: 13,
            margin: const EdgeInsets.all(2),
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
          ),
        ),
      ),
    );
  }
}
