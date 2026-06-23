import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:googleapis/gmail/v1.dart' as gml;

import '../../data/database.dart' show TasksCompanion;
import '../../data/providers/database_provider.dart';
import '../../routing/routes.dart';
import '../../services/google_service.dart';
import '../../l10n/app_l10n.dart';
import '../../theme/kaal_colors.dart';
import '../../theme/kaal_theme.dart';

// ── Data ──────────────────────────────────────────────────────────────────────

class _Email {
  const _Email({
    required this.sender,
    required this.subject,
    required this.preview,
    required this.time,
    this.unread = false,
  });
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

  @override
  void initState() {
    super.initState();
    _loadEmails();
  }

  Future<void> _loadEmails() async {
    final gs = ref.read(googleServiceProvider);
    if (!await gs.isAnyConnected) return;
    setState(() { _loading = true; _gmailConnected = true; });
    try {
      final msgs = await gs.fetchUnreadMessages(maxResults: 60);
      final cutoff = DateTime.now().subtract(const Duration(days: 14));
      final emails  = <_Email>[];
      final actions = <_ActionItem>[];
      for (final msg in msgs) {
        final date = _msgDate(msg);
        if (date != null && date.isBefore(cutoff)) continue;
        final subject = _header(msg, 'Subject');
        final from    = _header(msg, 'From');
        final sender  = _extractSender(from);
        emails.add(_Email(
          sender: sender,
          subject: subject.isEmpty ? '(no subject)' : subject,
          preview: from,
          time: _relativeTime(date),
          unread: true,
        ));
        final action = _classify(subject, sender);
        if (action != null) actions.add(action);
      }
      if (mounted) setState(() { _fetchedEmails = emails; _fetchedActions = actions; });
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
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
    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 72),
      children: [
        const SizedBox(height: 6),
        _SourcePills(
          colors: colors,
          gmailConnected: _gmailConnected,
          onGmailTap: () => context.go(KaalRoutes.calGmail),
          onMessagesTap: () => ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Messages integration coming soon',
                  style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: Colors.white)),
              backgroundColor: const Color(0xFF1C1C1E),
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          ),
          onAddTap: () => _showAddItemSheet(context),
        ),
        const SizedBox(height: 6),
        _StatsGrid(
          total: _fetchedEmails.length,
          unread: _fetchedEmails.where((e) => e.unread).length,
          added: _convertedActions.length,
          actions: _fetchedActions.length,
          colors: colors,
        ),
        const SizedBox(height: 6),
        if (!_gmailConnected && !_loading) ...[
          _ConnectGmailPrompt(colors: colors, onConnect: _loadEmails),
          const SizedBox(height: 8),
        ],
        _SectionRow(
          left: Text(AppL10n.of(context).recentInboxLabel,
            style: TextStyle(fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w700,
                letterSpacing: 0.5, color: colors.ink3, height: 1)),
        ),
        const SizedBox(height: 4),
        if (_loading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 28),
            child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: KaalColors.acc)),
          )
        else if (visibleEmails.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 28),
            child: Center(
              child: Text(_gmailConnected ? AppL10n.of(context).noEmailsLastTwoWeeks : AppL10n.of(context).connectGmailSeeEmails,
                style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: colors.ink3)),
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
    );
  }
}

// ── Source pills ──────────────────────────────────────────────────────────────

class _SourcePills extends StatelessWidget {
  final KaalColors colors;
  final bool gmailConnected;
  final VoidCallback onGmailTap;
  final VoidCallback onMessagesTap;
  final VoidCallback onAddTap;
  const _SourcePills({
    required this.colors,
    required this.gmailConnected,
    required this.onGmailTap,
    required this.onMessagesTap,
    required this.onAddTap,
  });

  static const _gmailSvg =
      '<svg width="11" height="11" viewBox="0 0 24 24">'
      '<path fill="#4285F4" d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"/>'
      '<path fill="#34A853" d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"/>'
      '<path fill="#FBBC05" d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l3.66-2.84z"/>'
      '<path fill="#EA4335" d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z"/>'
      '</svg>';

  static const _msgSvg =
      '<svg width="18" height="18" viewBox="0 0 22 22" fill="none">'
      '<path d="M3 4C3 3.44772 3.44772 3 4 3H18C18.5523 3 19 3.44772 19 4V14C19 14.5523 18.5523 15 18 15H13L8 19V15H4C3.44772 15 3 14.5523 3 14V4Z" fill="#34C759"/>'
      '</svg>';

  static const _addSvg =
      '<svg width="22" height="22" viewBox="0 0 22 22" fill="none" stroke="white" '
      'stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">'
      '<path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"/>'
      '<polyline points="22,6 12,13 2,6"/>'
      '</svg>';

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _Pill(
          icon: SvgPicture.string(_gmailSvg, width: 14, height: 14),
          label: AppL10n.of(context).gmail,
          hasGreenDot: gmailConnected,
          prominent: true,
          colors: colors,
          onTap: onGmailTap,
        ),
        const SizedBox(width: 5),
        _Pill(
          icon: SvgPicture.string(_msgSvg, width: 14, height: 14),
          label: AppL10n.of(context).messages,
          hasGreenDot: true,
          prominent: true,
          colors: colors,
          onTap: onMessagesTap,
        ),
        const SizedBox(width: 5),
        _Pill(
          icon: SvgPicture.string(_addSvg, width: 14, height: 14,
              colorFilter: ColorFilter.mode(colors.ink3, BlendMode.srcIn)),
          label: '+ Add',
          hasGreenDot: false,
          prominent: false,
          colors: colors,
          onTap: onAddTap,
        ),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  final Widget icon;
  final String label;
  final bool   hasGreenDot;
  final bool   prominent;
  final KaalColors colors;
  final VoidCallback? onTap;
  const _Pill({required this.icon, required this.label, required this.hasGreenDot,
      required this.prominent, required this.colors, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(8, 5, 8, 5),
        decoration: BoxDecoration(
          color: colors.surf,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(width: 0.5, color: prominent ? colors.bdr2 : colors.bdr),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            icon,
            const SizedBox(width: 5),
            Text(label, style: TextStyle(fontFamily: 'Inter', fontSize: 11,
                color: prominent ? colors.ink2 : colors.ink3, height: 1)),
            if (hasGreenDot) ...[
              const SizedBox(width: 5),
              Container(width: 5, height: 5, decoration: const BoxDecoration(color: KaalColors.q2, shape: BoxShape.circle)),
            ],
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

class _EmailDetailSheet extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 20 + MediaQuery.of(context).padding.bottom),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(email.sender, style: TextStyle(fontFamily: 'Inter', fontSize: 14,
                  fontWeight: FontWeight.w700, color: colors.ink, height: 1)),
              Text(email.time, style: TextStyle(fontFamily: 'Inter', fontSize: 11,
                  color: colors.ink3, height: 1)),
            ],
          ),
          const SizedBox(height: 4),
          Text(email.subject, style: TextStyle(fontFamily: 'Inter', fontSize: 13,
              fontWeight: FontWeight.w600, color: colors.ink, height: 1.3)),
          const SizedBox(height: 6),
          Text(email.preview, style: TextStyle(fontFamily: 'Inter', fontSize: 12,
              color: colors.ink3, height: 1.5)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: onArchive,
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
                  onTap: onSnooze,
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
