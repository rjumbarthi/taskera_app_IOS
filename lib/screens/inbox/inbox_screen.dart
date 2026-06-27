import 'dart:async';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:googleapis/gmail/v1.dart' as gml;

import '../../data/database.dart'
    show TasksCompanion, HabitsCompanion, NotesCompanion, CalendarEventsCompanion;
import '../../config/feature_flags.dart';
import '../../data/providers/database_provider.dart';
import '../../services/google_service.dart';
import '../../l10n/app_l10n.dart';
import '../../theme/kaal_colors.dart';
import '../../theme/kaal_theme.dart';

// ── Data ──────────────────────────────────────────────────────────────────────

class _Email {
  const _Email({
    required this.id,
    required this.sender,
    required this.subject,
    required this.preview,
    required this.time,
    this.date,
    this.unread = false,
  });
  final String id; // Gmail message id (empty for Outlook — full body uses preview)
  final DateTime? date; // received time, for merging/sorting across mailboxes
  final String sender;
  final String  subject;
  final String  preview;
  final String  time;
  final bool    unread;
}

class _ActionItem {
  const _ActionItem({
    required this.title,
    required this.source,
    required this.quadLabel,
    required this.dotColor,
    required this.btnBg,
    required this.btnBorder,
    required this.btnText,
  });
  final String title;
  final String source;
  final String quadLabel;
  final Color  dotColor;
  final Color  btnBg;
  final Color  btnBorder;
  final Color  btnText;
}

// ── Screen ────────────────────────────────────────────────────────────────────

class InboxScreen extends ConsumerStatefulWidget {
  const InboxScreen({super.key});

  @override
  ConsumerState<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends ConsumerState<InboxScreen> {
  final _readEmails       = <int>{};
  final _archivedEmails   = <int>{};
  final _convertedActions = <int>{};

  List<_Email>      _fetchedEmails  = [];
  List<_ActionItem> _fetchedActions = [];
  bool _loading       = false;
  bool _gmailConnected = false;
  DateTime? _lastSync;
  Timer? _autoSync;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadEmails();
    // While the inbox is open, auto-refresh every 5 minutes.
    _autoSync = Timer.periodic(const Duration(minutes: 5), (_) {
      if (mounted) _loadEmails();
    });
  }

  @override
  void dispose() {
    _autoSync?.cancel();
    super.dispose();
  }

  Future<void> _loadEmails() async {
    // Gmail sync is coming in a later release — don't attempt to connect/fetch.
    if (!kGmailSyncEnabled) { if (mounted) setState(() => _gmailConnected = false); return; }
    final gs = ref.read(googleServiceProvider);
    final connected = await gs.isGmailConnected;
    if (!mounted) return;
    if (!connected) { setState(() => _gmailConnected = false); return; }
    setState(() { _loading = true; _gmailConnected = true; _error = null; });

    final cutoff  = DateTime.now().subtract(const Duration(days: 14));
    final emails  = <_Email>[];
    final actions = <_ActionItem>[];
    try {
      for (final msg in await gs.fetchUnreadMessages(maxResults: 60)) {
        final date = _msgDate(msg);
        if (date != null && date.isBefore(cutoff)) continue;
        final subject = _header(msg, 'Subject');
        final from    = _header(msg, 'From');
        final sender  = _extractSender(from);
        emails.add(_Email(
          id: msg.id ?? '',
          sender: sender,
          subject: subject.isEmpty ? '(no subject)' : subject,
          preview: (msg.snippet?.trim().isNotEmpty ?? false) ? msg.snippet!.trim() : from,
          time: _relativeTime(date), date: date, unread: true,
        ));
        final a = _classify(subject, sender);
        if (a != null) actions.add(a);
      }
      emails.sort((a, b) => (b.date ?? DateTime(2000)).compareTo(a.date ?? DateTime(2000)));
      if (mounted) setState(() { _fetchedEmails = emails; _fetchedActions = actions; _lastSync = DateTime.now(); });
    } catch (e) {
      if (mounted) setState(() => _error = _gmailError(e));
    }
    if (mounted) setState(() => _loading = false);
  }

  // Maps a Gmail API failure to a clear, actionable message.
  static String _gmailError(Object e) {
    final s = e.toString().toLowerCase();
    if (s.contains('401') || s.contains('unauthor') || s.contains('invalid_grant') || s.contains('expired') || s.contains('invalid credentials')) {
      return 'Gmail access expired. Tap Connect Gmail to reconnect and refresh access.';
    }
    if (s.contains('403') || s.contains('insufficient') || s.contains('permission') || s.contains('scope') || s.contains('access_denied')) {
      return 'Gmail permission not granted. Reconnect and allow read-only Gmail access.';
    }
    return "Couldn't load Gmail. Pull down to retry.";
  }

  static String _syncAgo(DateTime dt) {
    final d = DateTime.now().difference(dt);
    if (d.inSeconds < 10) return 'just now';
    if (d.inMinutes < 1) return '${d.inSeconds}s ago';
    if (d.inHours < 1)   return '${d.inMinutes}m ago';
    if (d.inDays < 1)    return '${d.inHours}h ago';
    return '${d.inDays}d ago';
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(fontFamily: 'Inter', fontSize: 13, color: Colors.white, height: 1.35)),
      backgroundColor: const Color(0xFF1C1C1E),
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 2),
    ));
  }

  // Connect Gmail. Gmail sync needs a Google account — if the app was signed
  // into with a different method (email, OTP) or not at all, explain what's
  // needed instead of silently doing nothing.
  Future<void> _connectGmail() async {
    if (!kGmailSyncEnabled) { _snack('Gmail sync — coming soon in the next update.'); return; }
    final gs = ref.read(googleServiceProvider);

    if (await gs.isGmailConnected) { await _loadEmails(); return; }

    if (!gs.isSignedIn) {
      _snack('Gmail sync needs a Google account. Sign in with Google (Profile → Sign in) to connect your inbox.');
      return;
    }
    if (!gs.isGoogleAccount) {
      _snack("You're signed in without Google, so Gmail can't be connected. Sign out, then sign in with Google to sync your inbox.");
      return;
    }

    setState(() => _loading = true);
    bool ok = false;
    try { ok = await gs.connectGmail(); } catch (_) {}
    if (!mounted) return;
    setState(() => _loading = false);
    if (ok) {
      await _loadEmails();
    } else {
      _snack("Couldn't connect Gmail. Try again and grant Gmail (read-only) access when Google asks.");
    }
  }

  static String _header(gml.Message msg, String name) {
    for (final h in msg.payload?.headers ?? <gml.MessagePartHeader>[]) {
      if (h.name == name) return h.value ?? '';
    }
    return '';
  }

  static DateTime? _msgDate(gml.Message msg) {
    final ms = int.tryParse(msg.internalDate ?? '');
    return ms != null ? DateTime.fromMillisecondsSinceEpoch(ms) : null;
  }

  static String _extractSender(String from) {
    final m = RegExp(r'^([^<]+)<').firstMatch(from);
    if (m != null) return m.group(1)!.trim();
    final at = from.indexOf('@');
    return at > 0 ? from.substring(0, at).trim() : (from.isEmpty ? 'Unknown' : from);
  }

  static String _relativeTime(DateTime? dt) {
    if (dt == null) return '';
    final d = DateTime.now().difference(dt);
    if (d.inMinutes < 60) return '${d.inMinutes}m ago';
    if (d.inHours < 24) return '${d.inHours}h ago';
    if (d.inDays < 7) return '${d.inDays}d ago';
    return '${(d.inDays / 7).floor()}w ago';
  }

  static _ActionItem? _classify(String subject, String sender) {
    final lo = subject.toLowerCase();
    if (lo.contains('invitation') || lo.contains('invite') ||
        lo.contains('rsvp') || lo.contains('join us') ||
        lo.contains("you're invited") || lo.contains('you are invited')) {
      return _ActionItem(
        title: subject, source: 'From $sender', quadLabel: 'Invite',
        dotColor: KaalColors.q4,
        btnBg: const Color(0x1ABF5AF2), btnBorder: const Color(0x40BF5AF2),
        btnText: const Color(0xFFBF5AF2),
      );
    }
    if (lo.contains('invoice') || lo.contains('action required') ||
        lo.contains('deadline') || lo.contains('urgent') ||
        lo.contains('approval') || lo.contains('overdue')) {
      return _ActionItem(
        title: subject, source: 'From $sender', quadLabel: 'Q1 · Task',
        dotColor: KaalColors.q1,
        btnBg: const Color(0x1AFF453A), btnBorder: const Color(0x40FF453A),
        btnText: KaalColors.q1,
      );
    }
    if (lo.contains('meeting') || lo.contains('schedule') ||
        lo.contains('appointment') || lo.contains('calendar') ||
        lo.contains('follow up') || lo.contains('follow-up')) {
      return _ActionItem(
        title: subject, source: 'From $sender', quadLabel: 'Q2 · Plan',
        dotColor: KaalColors.q2,
        btnBg: const Color(0x1A7FBA00), btnBorder: const Color(0x407FBA00),
        btnText: KaalColors.q2,
      );
    }
    return null;
  }

  void _showAddItemSheet(BuildContext context) {
    final colors = KaalTheme.of(context).colors;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: const Color(0x8C000000),
      isScrollControlled: true,
      builder: (sheetCtx) => _AddItemSheet(
        colors: colors,
        onAdd: (title, quadrant) async {
          final messenger = ScaffoldMessenger.of(context);
          await ref.read(appDatabaseProvider).tasksDao.insertTask(
            TasksCompanion(
              title: Value(title),
              quadrant: Value(quadrant),
              sortOrder: const Value(0),
            ),
          );
          if (!mounted) return;
          messenger.showSnackBar(
            SnackBar(
              content: Text('Added to Q$quadrant',
                  style: const TextStyle(fontFamily: 'Inter', fontSize: 13, color: Colors.white)),
              backgroundColor: const Color(0xFF1C1C1E),
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      ),
    );
  }

  void _showEmailDetail(BuildContext context, int index) {
    final email = _fetchedEmails[index];
    setState(() => _readEmails.add(index));
    final colors = KaalTheme.of(context).colors;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: const Color(0x8C000000),
      isScrollControlled: true,
      builder: (sheetCtx) => _EmailDetailSheet(
        email: email,
        colors: colors,
        onArchive: () {
          setState(() => _archivedEmails.add(index));
          Navigator.pop(sheetCtx);
        },
        onSnooze: () => Navigator.pop(sheetCtx),
      ),
    );
  }

  Future<void> _convertToTask(BuildContext context, int actionIndex, _ActionItem item) async {
    final quad = int.tryParse(item.quadLabel.replaceAll(RegExp(r'[^0-9]'), '')) ?? 1;
    final messenger = ScaffoldMessenger.of(context);
    final addedToLabel = AppL10n.of(context).addedTo;
    await ref.read(appDatabaseProvider).tasksDao.insertTask(
      TasksCompanion(
        title: Value(item.title),
        quadrant: Value(quad),
        sortOrder: const Value(0),
      ),
    );
    if (!mounted) return;
    setState(() => _convertedActions.add(actionIndex));
    messenger.showSnackBar(
      SnackBar(
        content: Text('$addedToLabel Q$quad',
            style: const TextStyle(fontFamily: 'Inter', fontSize: 13, color: Colors.white)),
        backgroundColor: const Color(0xFF1C1C1E),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = KaalTheme.of(context).colors;
    final visibleEmails = [
      for (int i = 0; i < _fetchedEmails.length; i++)
        if (!_archivedEmails.contains(i)) i,
    ];
    return RefreshIndicator(
      onRefresh: _loadEmails,
      color: KaalColors.acc2,
      backgroundColor: const Color(0xFF1C1C1E),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
        children: [
        const SizedBox(height: 6),
        _SourcePills(
          colors: colors,
          gmailConnected: _gmailConnected,
          onGmail: _connectGmail,
          onSoon: (name) => _snack('$name is coming soon.'),
        ),
        const SizedBox(height: 6),
        _AddManuallyButton(colors: colors, onTap: () => _showAddItemSheet(context)),
        const SizedBox(height: 6),
        _StatsGrid(
          total: _fetchedEmails.length,
          unread: _fetchedEmails.where((e) => e.unread).length,
          added: _convertedActions.length,
          actions: _fetchedActions.length,
          colors: colors,
        ),
        const SizedBox(height: 6),
        if (kGmailSyncEnabled && !_gmailConnected && !_loading) ...[
          _ConnectGmailPrompt(colors: colors, onConnect: _connectGmail),
          const SizedBox(height: 8),
        ],
        _SectionRow(
          left: Text(AppL10n.of(context).recentInboxLabel,
            style: TextStyle(fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w700,
                letterSpacing: 0.5, color: colors.ink3, height: 1)),
          right: _lastSync != null
              ? Text('↻ Updated ${_syncAgo(_lastSync!)}',
                  style: TextStyle(fontFamily: 'Inter', fontSize: 9, color: colors.ink3, height: 1))
              : (_loading
                  ? Text('↻ Syncing…',
                      style: TextStyle(fontFamily: 'Inter', fontSize: 9, color: KaalColors.acc2, height: 1))
                  : null),
        ),
        const SizedBox(height: 4),
        if (_loading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 28),
            child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: KaalColors.acc)),
          )
        else if (visibleEmails.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
            child: Center(
              child: Text(
                _error ?? (!kGmailSyncEnabled
                    ? 'Gmail sync is coming soon. Add tasks manually above for now.'
                    : (_gmailConnected ? AppL10n.of(context).noEmailsLastTwoWeeks : AppL10n.of(context).connectGmailSeeEmails)),
                textAlign: TextAlign.center,
                style: TextStyle(fontFamily: 'Inter', fontSize: 13, height: 1.4,
                    color: _error != null ? KaalColors.warn : colors.ink3)),
            ),
          )
        else
          for (final i in visibleEmails) ...[
            _EmailItem(
              email: _fetchedEmails[i],
              isRead: _readEmails.contains(i),
              colors: colors,
              onTap: () => _showEmailDetail(context, i),
              onLongPress: () => _showEmailDetail(context, i),
            ),
            const SizedBox(height: 4),
          ],
        if (_fetchedActions.isNotEmpty) ...[
          const SizedBox(height: 2),
          _SectionRow(
            left: Text('✦ ${AppL10n.of(context).aiFound} ${_fetchedActions.length} ${AppL10n.of(context).actionableItems}',
              style: TextStyle(fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w700,
                  letterSpacing: 0.5, color: colors.successFg, height: 1)),
            right: Text(AppL10n.of(context).fromYourInbox,
              style: TextStyle(fontFamily: 'Inter', fontSize: 9, color: colors.ink3, height: 1)),
          ),
          const SizedBox(height: 4),
          for (int i = 0; i < _fetchedActions.length; i++) ...[
            _ActionCard(
              item: _fetchedActions[i],
              colors: colors,
              isConverted: _convertedActions.contains(i),
              onConvert: () => _convertToTask(context, i, _fetchedActions[i]),
            ),
            const SizedBox(height: 4),
          ],
        ],
        ],
      ),
    );
  }
}

// ── Source pills ──────────────────────────────────────────────────────────────

class _SourcePills extends StatelessWidget {
  final KaalColors colors;
  final bool gmailConnected;
  final VoidCallback onGmail;
  final void Function(String name) onSoon;
  const _SourcePills({
    required this.colors,
    required this.gmailConnected,
    required this.onGmail,
    required this.onSoon,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 5,
      runSpacing: 5,
      children: [
        _SourceChip(
          emoji: '📧', label: 'Gmail', accent: const Color(0xFFEA4335),
          connected: kGmailSyncEnabled && gmailConnected,
          soon: !kGmailSyncEnabled,
          colors: colors,
          onTap: kGmailSyncEnabled ? onGmail : () => onSoon('Gmail'),
        ),
        _SourceChip(
          emoji: '📨', label: 'Outlook', accent: const Color(0xFF0A84FF),
          soon: true, colors: colors, onTap: () => onSoon('Outlook'),
        ),
        _SourceChip(
          emoji: '☁️', label: 'iCloud', accent: const Color(0xFF8E8E93),
          soon: true, colors: colors, onTap: () => onSoon('iCloud Mail'),
        ),
        _SourceChip(
          emoji: '💬', label: 'SMS / iMessage', accent: const Color(0xFF34C759),
          soon: true, colors: colors, onTap: () => onSoon('SMS / iMessage'),
        ),
      ],
    );
  }
}

class _SourceChip extends StatelessWidget {
  final String emoji;
  final String label;
  final Color accent;
  final bool connected;
  final bool soon;
  final KaalColors colors;
  final VoidCallback onTap;
  const _SourceChip({
    required this.emoji,
    required this.label,
    required this.accent,
    required this.colors,
    required this.onTap,
    this.connected = false,
    this.soon = false,
  });

  @override
  Widget build(BuildContext context) {
    final active = connected;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.fromLTRB(8, 6, 10, 6),
        decoration: BoxDecoration(
          color: active ? accent.withAlpha(0x12) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(width: 0.5, color: active ? accent.withAlpha(0x59) : colors.bdr),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 12)),
            const SizedBox(width: 5),
            Text(label, style: TextStyle(fontFamily: 'Inter', fontSize: 11,
                fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                color: active ? colors.ink : colors.ink2, height: 1)),
            if (connected) ...[
              const SizedBox(width: 5),
              Container(width: 5, height: 5, decoration: const BoxDecoration(color: KaalColors.q2, shape: BoxShape.circle)),
            ] else if (soon) ...[
              const SizedBox(width: 5),
              Text('Soon', style: TextStyle(fontFamily: 'Inter', fontSize: 8,
                  fontWeight: FontWeight.w700, letterSpacing: 0.3, color: colors.ink3, height: 1)),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Add manually button ───────────────────────────────────────────────────────

class _AddManuallyButton extends StatelessWidget {
  final KaalColors colors;
  final VoidCallback onTap;
  const _AddManuallyButton({required this.colors, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: colors.surf2,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(width: 0.5, color: colors.bdr),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add_rounded, size: 15, color: KaalColors.acc2),
            const SizedBox(width: 5),
            Text('Add task manually', style: TextStyle(fontFamily: 'Inter', fontSize: 12,
                fontWeight: FontWeight.w600, color: colors.ink2, height: 1)),
          ],
        ),
      ),
    );
  }
}

// ── Add item sheet ────────────────────────────────────────────────────────────

class _AddItemSheet extends StatefulWidget {
  final KaalColors colors;
  final Future<void> Function(String title, int quadrant) onAdd;
  const _AddItemSheet({required this.colors, required this.onAdd});

  @override
  State<_AddItemSheet> createState() => _AddItemSheetState();
}

class _AddItemSheetState extends State<_AddItemSheet> {
  final _ctrl = TextEditingController();
  int _quad = 1;
  bool _saving = false;

  static const _quads = [
    (n: 'Q1', color: KaalColors.q1, bg: Color(0x1AF25022), border: Color(0x40F25022)),
    (n: 'Q2', color: KaalColors.q2, bg: Color(0x1A7FBA00), border: Color(0x407FBA00)),
    (n: 'Q3', color: KaalColors.q3, bg: Color(0x1A00A4EF), border: Color(0x4000A4EF)),
    (n: 'Q4', color: KaalColors.q4, bg: Color(0x1AFFB900), border: Color(0x40FFB900)),
  ];

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final title = _ctrl.text.trim();
    if (title.isEmpty || _saving) return;
    setState(() => _saving = true);
    final nav = Navigator.of(context);
    await widget.onAdd(title, _quad);
    if (mounted) nav.pop();
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors;
    final bottom = MediaQuery.of(context).viewInsets.bottom + MediaQuery.of(context).padding.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 20 + bottom),
      decoration: const BoxDecoration(
        color: Color(0xFF1C1C1E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(width: 36, height: 4, margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(color: const Color(0x40FFFFFF), borderRadius: BorderRadius.circular(2))),
          ),
          Text('Add to inbox', style: TextStyle(fontFamily: 'Inter', fontSize: 14,
              fontWeight: FontWeight.w700, color: colors.ink, height: 1)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
            decoration: BoxDecoration(
              color: colors.surf2,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(width: 0.5, color: colors.bdr),
            ),
            child: TextField(
              controller: _ctrl,
              autofocus: true,
              style: TextStyle(fontFamily: 'Inter', fontSize: 14, color: colors.ink, height: 1.4),
              decoration: InputDecoration(
                hintText: 'Task title…',
                hintStyle: TextStyle(fontFamily: 'Inter', fontSize: 14, color: colors.ink3),
                border: InputBorder.none,
              ),
              onSubmitted: (_) => _submit(),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              for (int i = 0; i < _quads.length; i++) ...[
                if (i > 0) const SizedBox(width: 6),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _quad = i + 1),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: _quad == i + 1 ? _quads[i].bg : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          width: 0.5,
                          color: _quad == i + 1 ? _quads[i].border : colors.bdr,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(_quads[i].n,
                          style: TextStyle(fontFamily: 'Inter', fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _quad == i + 1 ? _quads[i].color : colors.ink3, height: 1)),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: _submit,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(color: KaalColors.acc, borderRadius: BorderRadius.circular(10)),
              alignment: Alignment.center,
              child: _saving
                  ? const SizedBox(width: 18, height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Add task', style: TextStyle(fontFamily: 'Inter', fontSize: 14,
                      fontWeight: FontWeight.w600, color: Colors.white, height: 1)),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Connect Gmail prompt ──────────────────────────────────────────────────────

class _ConnectGmailPrompt extends StatelessWidget {
  final KaalColors colors;
  final VoidCallback onConnect;
  const _ConnectGmailPrompt({required this.colors, required this.onConnect});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: BoxDecoration(
        color: const Color(0x0D4285F4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(width: 0.5, color: const Color(0x404285F4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(AppL10n.of(context).connectGmailInbox,
              style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w600, color: colors.ink)),
          const SizedBox(height: 4),
          Text(AppL10n.of(context).inboxEmptyHint,
              style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: colors.ink3, height: 1.4)),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: onConnect,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 9),
              decoration: BoxDecoration(color: KaalColors.acc, borderRadius: BorderRadius.circular(8)),
              alignment: Alignment.center,
              child: Text('${AppL10n.of(context).connect} Gmail',
                  style: const TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Stats grid ────────────────────────────────────────────────────────────────

class _StatsGrid extends StatelessWidget {
  final int total, unread, added, actions;
  final KaalColors colors;
  const _StatsGrid({required this.total, required this.unread, required this.added,
      required this.actions, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatCell(value: '$actions', label: AppL10n.of(context).aiItems, valueColor: KaalColors.acc2,         colors: colors),
        const SizedBox(width: 4),
        _StatCell(value: '$unread',  label: AppL10n.of(context).unread, valueColor: const Color(0xFFFF8080), colors: colors),
        const SizedBox(width: 4),
        _StatCell(value: '$added',   label: AppL10n.of(context).added,  valueColor: KaalColors.q2,           colors: colors),
        const SizedBox(width: 4),
        _StatCell(value: '$total',   label: AppL10n.of(context).total,  valueColor: null,                    colors: colors),
      ],
    );
  }
}

class _StatCell extends StatelessWidget {
  final String value;
  final String label;
  final Color? valueColor;
  final KaalColors colors;
  const _StatCell({required this.value, required this.label, required this.valueColor, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.fromLTRB(6, 8, 6, 8),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(width: 0.5, color: colors.bdr2),
        ),
        child: Column(
          children: [
            Text(value, textAlign: TextAlign.center,
              style: TextStyle(fontFamily: 'Fraunces', fontSize: 15, fontWeight: FontWeight.w700,
                  color: valueColor ?? colors.ink3, height: 1)),
            const SizedBox(height: 2),
            Text(label, textAlign: TextAlign.center,
              style: TextStyle(fontFamily: 'Inter', fontSize: 9, color: colors.ink3, height: 1)),
          ],
        ),
      ),
    );
  }
}

// ── Section row helper ────────────────────────────────────────────────────────

class _SectionRow extends StatelessWidget {
  final Widget left;
  final Widget? right;
  const _SectionRow({required this.left, this.right});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [left, ?right],
    );
  }
}

// ── Email item ────────────────────────────────────────────────────────────────

class _EmailItem extends StatelessWidget {
  final _Email email;
  final bool   isRead;
  final KaalColors colors;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _EmailItem({
    required this.email,
    required this.isRead,
    required this.colors,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final showUnread = email.unread && !isRead;
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      onSecondaryTap: onLongPress,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 9, 12, 9),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(width: 0.5, color: colors.bdr),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Container(
                width: 5, height: 5,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: showUnread ? KaalColors.acc : Colors.transparent,
                ),
              ),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(email.sender, style: TextStyle(fontFamily: 'Inter', fontSize: 13,
                          fontWeight: FontWeight.w700, color: colors.ink, height: 1)),
                      Text(email.time, style: TextStyle(fontFamily: 'Inter', fontSize: 9,
                          color: colors.ink3, height: 1)),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(email.subject, style: TextStyle(fontFamily: 'Inter', fontSize: 11,
                      fontWeight: FontWeight.w600, color: colors.ink, height: 1.2),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text(email.preview, style: TextStyle(fontFamily: 'Inter', fontSize: 9,
                      color: colors.ink3, height: 1.3),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Email detail bottom sheet ─────────────────────────────────────────────────

// ── Kaal AI email → suggestions ───────────────────────────────────────────────

enum _SugType { task, habit, invite, note }

class _Suggestion {
  final _SugType type;
  final String title;
  final String detail;
  final int quadrant;      // task
  final String timeSlot;   // invite
  final DateTime? when;    // invite
  const _Suggestion({
    required this.type,
    required this.title,
    required this.detail,
    this.quadrant = 2,
    this.timeSlot = 'TBD',
    this.when,
  });
}

String _cleanSubject(String s) {
  var t = s.replaceAll(RegExp(r'^(re|fwd|fw)\s*:\s*', caseSensitive: false), '').trim();
  if (t.length > 80) t = '${t.substring(0, 77)}…';
  return t.isEmpty ? '(no subject)' : t;
}

String? _firstTimeSlot(String text) {
  final m = RegExp(r'\b(\d{1,2})(?::(\d{2}))?\s*(am|pm)\b', caseSensitive: false).firstMatch(text);
  if (m == null) return null;
  final min = m.group(2);
  final ap  = m.group(3)!.toUpperCase();
  return min != null ? '${m.group(1)}:$min $ap' : '${m.group(1)} $ap';
}

// Heuristic "Kaal AI": turns an email into add-to-Kaal suggestions.
List<_Suggestion> _kaalSuggest(String subject, String sender, String body) {
  final text  = '$subject\n$body'.toLowerCase();
  final clean = _cleanSubject(subject);
  final out   = <_Suggestion>[];

  int quad = 2;
  if (RegExp(r'urgent|asap|immediately|overdue|deadline|action required|approval needed|invoice|payment due|past due').hasMatch(text)) {
    quad = 1;
  } else if (RegExp(r'newsletter|promotion|\bsale\b|% off|unsubscribe|digest|no-reply').hasMatch(text)) {
    quad = 4;
  }
  out.add(_Suggestion(type: _SugType.task, title: clean, detail: 'Q$quad · follow up on this email', quadrant: quad));

  if (RegExp(r'meeting|invitation|\binvite\b|rsvp|calendar|schedule|reschedule|zoom|google meet|\bteams\b|webinar|appointment|join us').hasMatch(text)) {
    final slot = _firstTimeSlot(text);
    out.add(_Suggestion(
      type: _SugType.invite, title: clean,
      detail: slot != null ? 'Tomorrow · $slot' : 'Add to calendar',
      timeSlot: slot ?? 'TBD',
      when: DateTime.now().add(const Duration(days: 1)),
    ));
  }

  if (RegExp(r'\b(daily|weekly|every day|every week|each day|routine|gym|workout|exercise|meditat|journal|reading|practice|streak|habit)\b').hasMatch(text)) {
    out.add(_Suggestion(type: _SugType.habit, title: clean, detail: 'Build a recurring habit'));
  }

  out.add(_Suggestion(type: _SugType.note, title: clean, detail: 'Save email as a note'));
  return out;
}

// ── Email detail sheet (full body + Kaal AI add-cards) ────────────────────────

class _EmailDetailSheet extends ConsumerStatefulWidget {
  final _Email email;
  final KaalColors colors;
  final VoidCallback onArchive;
  final VoidCallback onSnooze;

  const _EmailDetailSheet({
    required this.email,
    required this.colors,
    required this.onArchive,
    required this.onSnooze,
  });

  @override
  ConsumerState<_EmailDetailSheet> createState() => _EmailDetailSheetState();
}

class _EmailDetailSheetState extends ConsumerState<_EmailDetailSheet> {
  String? _body;
  bool _loadingBody = true;
  final Set<int> _added = {};

  @override
  void initState() {
    super.initState();
    _fetchBody();
  }

  Future<void> _fetchBody() async {
    var body = widget.email.preview;
    try {
      if (widget.email.id.isNotEmpty) {
        final full = await ref.read(googleServiceProvider).fetchMessageFull(widget.email.id);
        if (full != null) body = GoogleService.plainTextBody(full);
      }
    } catch (_) {}
    if (mounted) setState(() { _body = body; _loadingBody = false; });
  }

  Future<void> _add(_Suggestion s, int index) async {
    final db = ref.read(appDatabaseProvider);
    String where;
    switch (s.type) {
      case _SugType.task:
        await db.tasksDao.insertTask(TasksCompanion(title: Value(s.title), quadrant: Value(s.quadrant)));
        where = 'Tasks';
      case _SugType.habit:
        await db.habitsDao.insertHabit(HabitsCompanion(
          emoji: const Value('✉️'),
          name: Value(s.title),
          frequencyLabel: const Value('Daily'),
          streakLabel: const Value('0 days'),
          streakColorValue: Value(const Color(0xFF8E8E93).toARGB32()),
          accentColorValue: Value(KaalColors.acc.toARGB32()),
        ));
        where = 'Habits';
      case _SugType.note:
        await db.notesDao.insertNote(NotesCompanion(
          title: Value(s.title),
          body: Value(_body ?? widget.email.preview),
          timeLabel: const Value('now'),
          aiLabel: const Value('✦ From email'),
        ));
        where = 'Notes';
      case _SugType.invite:
        await db.calendarDao.insertEvent(CalendarEventsCompanion(
          title: Value(s.title),
          timeSlot: Value(s.timeSlot),
          colorValue: Value(const Color(0xFFBF5AF2).toARGB32()),
          isInvite: const Value(true),
          eventDate: Value(s.when),
        ));
        where = 'Calendar';
    }
    if (!mounted) return;
    setState(() => _added.add(index));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Added to $where',
          style: const TextStyle(fontFamily: 'Inter', fontSize: 13, color: Colors.white)),
      backgroundColor: const Color(0xFF1C1C1E),
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 2),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors;
    final email  = widget.email;
    final suggestions = _kaalSuggest(email.subject, email.sender, _body ?? email.preview);

    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 20 + MediaQuery.of(context).padding.bottom),
      decoration: const BoxDecoration(
        color: Color(0xFF1C1C1E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(width: 36, height: 4, margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(color: const Color(0x40FFFFFF), borderRadius: BorderRadius.circular(2))),
            ),
            Row(
              children: [
                Expanded(
                  child: Text(email.sender, maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w700, color: colors.ink, height: 1)),
                ),
                const SizedBox(width: 8),
                Text(email.time, style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: colors.ink3, height: 1)),
              ],
            ),
            const SizedBox(height: 4),
            Text(email.subject, style: TextStyle(fontFamily: 'Inter', fontSize: 13,
                fontWeight: FontWeight.w600, color: colors.ink, height: 1.3)),
            const SizedBox(height: 8),
            // Full body
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.32),
              child: _loadingBody
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 18),
                      child: Center(child: SizedBox(width: 18, height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: KaalColors.acc))),
                    )
                  : SingleChildScrollView(
                      child: Text(_body!.isEmpty ? '(no preview available)' : _body!,
                          style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: colors.ink2, height: 1.5)),
                    ),
            ),
            const SizedBox(height: 14),
            // Kaal AI suggestions
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(6, 2, 6, 2),
                  decoration: BoxDecoration(color: KaalColors.accBg, borderRadius: BorderRadius.circular(4)),
                  child: const Text('✦ KAAL AI', style: TextStyle(fontFamily: 'Inter', fontSize: 9,
                      fontWeight: FontWeight.w700, color: KaalColors.acc2)),
                ),
                const SizedBox(width: 6),
                Text('Suggested — add to Kaal', style: TextStyle(fontFamily: 'Inter', fontSize: 11,
                    fontWeight: FontWeight.w600, color: colors.ink3)),
              ],
            ),
            const SizedBox(height: 8),
            for (int i = 0; i < suggestions.length; i++) ...[
              _SuggestionCard(
                s: suggestions[i],
                added: _added.contains(i),
                colors: colors,
                onAdd: () => _add(suggestions[i], i),
              ),
              const SizedBox(height: 6),
            ],
            const SizedBox(height: 8),
            // Archive / Snooze
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: widget.onArchive,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0x1A8E8E93),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(width: 0.5, color: const Color(0x338E8E93)),
                      ),
                      alignment: Alignment.center,
                      child: Text(AppL10n.of(context).archive, style: const TextStyle(fontFamily: 'Inter', fontSize: 13,
                          color: Color(0xFF8E8E93), height: 1)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    onTap: widget.onSnooze,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0x1AFFB900),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(width: 0.5, color: const Color(0x40FFB900)),
                      ),
                      alignment: Alignment.center,
                      child: Text(AppL10n.of(context).snooze, style: const TextStyle(fontFamily: 'Inter', fontSize: 13,
                          color: Color(0xFFFFB900), height: 1)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Kaal AI suggestion card ───────────────────────────────────────────────────

class _SuggestionCard extends StatelessWidget {
  final _Suggestion s;
  final bool added;
  final KaalColors colors;
  final VoidCallback onAdd;
  const _SuggestionCard({required this.s, required this.added, required this.colors, required this.onAdd});

  ({String label, String emoji, Color color}) get _meta => switch (s.type) {
        _SugType.task   => (label: 'Task',   emoji: '✓',  color: KaalColors.acc2),
        _SugType.habit  => (label: 'Habit',  emoji: '🔁', color: const Color(0xFFBF5AF2)),
        _SugType.invite => (label: 'Invite', emoji: '📅', color: const Color(0xFFBF5AF2)),
        _SugType.note   => (label: 'Note',   emoji: '📝', color: KaalColors.q4),
      };

  @override
  Widget build(BuildContext context) {
    final m = _meta;
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 8, 8, 8),
      decoration: BoxDecoration(
        color: m.color.withAlpha(0x12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(width: 0.5, color: m.color.withAlpha(0x40)),
      ),
      child: Row(
        children: [
          Text(m.emoji, style: const TextStyle(fontSize: 15)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(5, 1, 5, 1),
                  decoration: BoxDecoration(color: m.color.withAlpha(0x26), borderRadius: BorderRadius.circular(3)),
                  child: Text(m.label.toUpperCase(), style: TextStyle(fontFamily: 'Inter', fontSize: 8,
                      fontWeight: FontWeight.w700, color: m.color)),
                ),
                const SizedBox(height: 3),
                Text(s.title, maxLines: 2, overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w500, color: colors.ink, height: 1.25)),
                const SizedBox(height: 1),
                Text(s.detail, maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontFamily: 'Inter', fontSize: 10, color: colors.ink3, height: 1.2)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: added ? null : onAdd,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
              decoration: BoxDecoration(
                color: added ? Colors.transparent : m.color.withAlpha(0x26),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(width: 0.5, color: m.color.withAlpha(added ? 0x33 : 0x66)),
              ),
              child: Text(added ? '✓ Added' : '+ Add', style: TextStyle(fontFamily: 'Inter', fontSize: 11,
                  fontWeight: FontWeight.w700, color: added ? colors.ink3 : m.color)),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Actionable item card ──────────────────────────────────────────────────────

class _ActionCard extends StatelessWidget {
  final _ActionItem item;
  final KaalColors  colors;
  final bool        isConverted;
  final VoidCallback onConvert;

  const _ActionCard({
    required this.item,
    required this.colors,
    required this.isConverted,
    required this.onConvert,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(width: 0.5, color: colors.bdr),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Container(width: 5, height: 5, decoration: BoxDecoration(color: item.dotColor, shape: BoxShape.circle)),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title, style: TextStyle(fontFamily: 'Inter', fontSize: 13,
                    fontWeight: FontWeight.w500, color: colors.ink, height: 1.2)),
                const SizedBox(height: 1),
                Text(item.source, style: TextStyle(fontFamily: 'Inter', fontSize: 11,
                    color: colors.ink3, height: 1)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (isConverted)
            Container(
              padding: const EdgeInsets.fromLTRB(7, 3, 7, 3),
              decoration: BoxDecoration(
                color: const Color(0x1F7FBA00),
                borderRadius: BorderRadius.circular(5),
                border: Border.all(width: 0.5, color: const Color(0x407FBA00)),
              ),
              child: Text('✓ Added', style: TextStyle(fontFamily: 'Inter', fontSize: 11,
                  color: colors.successFg, height: 1)),
            )
          else
            GestureDetector(
              onTap: onConvert,
              child: Container(
                padding: const EdgeInsets.fromLTRB(7, 3, 7, 3),
                decoration: BoxDecoration(
                  color: item.btnBg,
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(width: 0.5, color: item.btnBorder),
                ),
                child: Text(item.quadLabel, style: TextStyle(fontFamily: 'Inter', fontSize: 11,
                    color: item.btnText, height: 1)),
              ),
            ),
        ],
      ),
    );
  }
}
