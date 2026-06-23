import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/providers/integrations_provider.dart';
import '../../l10n/app_l10n.dart';
import '../../theme/kaal_colors.dart';
import '../../theme/kaal_theme.dart';
import '../../widgets/add_back_button.dart';

class GmailSyncScreen extends ConsumerStatefulWidget {
  const GmailSyncScreen({super.key});

  @override
  ConsumerState<GmailSyncScreen> createState() => _GmailSyncScreenState();
}

class _GmailSyncScreenState extends ConsumerState<GmailSyncScreen> {
  bool _connected  = false;
  bool _connecting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(integrationsProvider.notifier).checkStatus();
      if (mounted) {
        setState(() => _connected = ref.read(integrationsProvider).gmailConnected);
      }
    });
  }

  Future<void> _connect() async {
    setState(() => _connecting = true);
    try {
      final ok = await ref.read(integrationsProvider.notifier).connectGmail();
      if (mounted) setState(() { _connected = ok; _connecting = false; });
      if (mounted && !ok) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Could not connect — no token received.'),
          duration: Duration(seconds: 4),
        ));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _connecting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gmail connect failed: $e'), backgroundColor: const Color(0xFFFF453A)),
        );
      }
    }
  }

  Future<void> _disconnect() async {
    await ref.read(integrationsProvider.notifier).disconnectGmail();
    if (mounted) setState(() => _connected = false);
  }

  static const _pending = [
    (
      from: 'Dr. Sharma Clinic', time: '9:14 AM',
      title: 'Dr. Sharma appointment — Apr 8, 10 AM',
      quad: 'Q1 Do Now', quadColor: KaalColors.q1, quadBg: Color(0x1FF25022),
      pri: 'P1', priColor: Color(0xFFFF9500), priBg: Color(0x1FFF9500),
      date: 'Apr 8 · 10 AM', label: '#health', labelColor: Color(0xFFBF5AF2), labelBg: Color(0x1ABF5AF2),
    ),
    (
      from: 'AWS', time: '2 days ago',
      title: r'Pay AWS invoice — Apr 15, $47.20',
      quad: 'Q2 Schedule', quadColor: KaalColors.q2, quadBg: Color(0x1F7FBA00),
      pri: 'P3', priColor: KaalColors.acc2, priBg: Color(0x1F0A84FF),
      date: 'Apr 15', label: '#finance', labelColor: Color(0xFF9FCD44), labelBg: Color(0x1A9FCD44),
    ),
  ];

  static const _settingLabels = [
    'Scan Inbox only',
    'Skip Promotions & Spam',
    'Auto-parse dates & deadlines',
    'Require approval before creating tasks',
  ];

  @override
  Widget build(BuildContext context) {
    final colors = KaalTheme.of(context).colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Sub-bar
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 12, 6),
          child: Row(
            children: [
              AddBackButton(onTap: () => context.pop()),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(AppL10n.of(context).gmailSync, style: TextStyle(fontFamily: 'Fraunces', fontVariations: [FontVariation('wght', 600)], fontSize: 19, letterSpacing: -0.5, color: colors.ink, height: 1.1)),
                    Text('Full email-to-task pipeline', style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: colors.ink3, height: 1.2)),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: EdgeInsets.fromLTRB(12, 0, 12, MediaQuery.of(context).padding.bottom + 24),
            children: [
              // Gmail connection card
              Container(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                decoration: BoxDecoration(
                  color: _connected ? const Color(0x144285F4) : const Color(0x0D4285F4),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(width: 0.5, color: const Color(0x404285F4)),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        _GmailLogo(),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_connected ? 'Gmail' : 'Connect Gmail',
                                  style: TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w600, color: colors.ink, height: 1.2)),
                              Text(_connected ? '● Connected · Syncing every 4h' : '○ Not connected',
                                  style: TextStyle(fontFamily: 'Inter', fontSize: 11,
                                      color: _connected ? colors.successFg : colors.ink3)),
                            ],
                          ),
                        ),
                        if (_connected)
                          GestureDetector(
                            onTap: _disconnect,
                            child: Container(
                              padding: const EdgeInsets.fromLTRB(9, 4, 9, 4),
                              decoration: BoxDecoration(color: const Color(0x1AFF453A), borderRadius: BorderRadius.circular(6)),
                              child: Text(AppL10n.of(context).disconnect, style: const TextStyle(fontFamily: 'Inter', fontSize: 11, color: Color(0xFFFF6B6B))),
                            ),
                          ),
                      ],
                    ),
                    if (_connected) ...[
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          _StatCell(value: '47', label: AppL10n.of(context).emailsScanned, valueColor: colors.ink),
                          Container(width: 0.5, height: 32, color: colors.bdr),
                          _StatCell(value: '9',  label: AppL10n.of(context).tasksCreated,  valueColor: KaalColors.acc2),
                          Container(width: 0.5, height: 32, color: colors.bdr),
                          _StatCell(value: '4',  label: AppL10n.of(context).pendingReview, valueColor: colors.successFg),
                        ],
                      ),
                    ] else ...[
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: _connecting ? null : _connect,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(color: KaalColors.acc, borderRadius: BorderRadius.circular(8)),
                          alignment: Alignment.center,
                          child: _connecting
                              ? const SizedBox(width: 14, height: 14,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : Text('${AppL10n.of(context).connect} Gmail',
                                  style: const TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 14),
              // Pending
              Text('${AppL10n.of(context).pendingApproval.toUpperCase()} · 4',
                style: TextStyle(fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.5, color: colors.ink3)),
              const SizedBox(height: 8),
              for (final p in _pending) ...[
                _PendingCard(item: p, colors: colors),
                const SizedBox(height: 6),
              ],
              const SizedBox(height: 8),
              // Sync settings
              Text(AppL10n.of(context).syncSettings.toUpperCase(),
                style: TextStyle(fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.5, color: colors.ink3)),
              const SizedBox(height: 8),
              _SettingsCard(labels: _settingLabels, colors: colors),
            ],
          ),
        ),
      ],
    );
  }
}

class _GmailLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32, height: 32,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(6), color: Colors.white),
      padding: const EdgeInsets.all(4),
      child: CustomPaint(painter: _GmailPainter()),
    );
  }
}

class _GmailPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    paint.color = const Color(0xFFEA4335);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width * 0.5, size.height * 0.5), paint);
    paint.color = const Color(0xFF4285F4);
    canvas.drawRect(Rect.fromLTWH(size.width * 0.5, 0, size.width * 0.5, size.height * 0.5), paint);
    paint.color = const Color(0xFFEA4335);
    canvas.drawRect(Rect.fromLTWH(0, size.height * 0.5, size.width * 0.5, size.height * 0.5), paint);
    paint.color = const Color(0xFF34A853);
    canvas.drawRect(Rect.fromLTWH(size.width * 0.5, size.height * 0.5, size.width * 0.5, size.height * 0.5), paint);
  }

  @override
  bool shouldRepaint(_GmailPainter old) => false;
}

class _StatCell extends StatelessWidget {
  final String value, label;
  final Color valueColor;
  const _StatCell({required this.value, required this.label, required this.valueColor});

  @override
  Widget build(BuildContext context) {
    final colors = KaalTheme.of(context).colors;
    return Expanded(
      child: Column(
        children: [
          Text(value, style: TextStyle(fontFamily: 'Fraunces', fontSize: 18, fontWeight: FontWeight.w700, color: valueColor, height: 1)),
          const SizedBox(height: 2),
          Text(label, textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Inter', fontSize: 9, color: colors.labelMuted)),
        ],
      ),
    );
  }
}

class _PendingCard extends StatelessWidget {
  final dynamic item;
  final KaalColors colors;
  const _PendingCard({required this.item, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: const Color(0x0D7FBA00),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(width: 0.5, color: const Color(0x407FBA00)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text('From: ', style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: colors.ink3)),
              Text(item.from, style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: colors.ink2)),
              Text(' · ${item.time}', style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: colors.ink3)),
            ],
          ),
          const SizedBox(height: 5),
          Text(item.title, style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w500, color: colors.ink)),
          const SizedBox(height: 4),
          Wrap(
            spacing: 4, runSpacing: 4,
            children: [
              _Tag(label: item.quad, color: item.quadColor, bg: item.quadBg),
              _Tag(label: item.pri,  color: item.priColor,  bg: item.priBg),
              _Tag(label: item.date, color: colors.ink3, bg: Colors.transparent),
              _Tag(label: item.label, color: item.labelColor, bg: item.labelBg),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(color: KaalColors.acc, borderRadius: BorderRadius.circular(8)),
                    alignment: Alignment.center,
                    child: const Text('✓ Add as task', style: TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
                  ),
                ),
              ),
              const SizedBox(width: 5),
              GestureDetector(
                onTap: () {},
                child: Container(
                  padding: const EdgeInsets.fromLTRB(10, 7, 10, 7),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(width: 0.5, color: colors.bdr),
                  ),
                  child: Text(AppL10n.of(context).dismiss, style: TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w500, color: colors.ink3)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final Color color, bg;
  const _Tag({required this.label, required this.color, required this.bg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(6, 2, 6, 2),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(4)),
      child: Text(label, style: TextStyle(fontFamily: 'Inter', fontSize: 10, color: color)),
    );
  }
}

class _SettingsCard extends StatefulWidget {
  final List<String> labels;
  final KaalColors colors;
  const _SettingsCard({required this.labels, required this.colors});

  @override
  State<_SettingsCard> createState() => _SettingsCardState();
}

class _SettingsCardState extends State<_SettingsCard> {
  final List<bool> _on = [true, true, true, true];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
      decoration: BoxDecoration(
        color: const Color(0x0DFFFFFF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(width: 0.5, color: const Color(0x1AFFFFFF)),
      ),
      child: Column(
        children: [
          for (int i = 0; i < widget.labels.length; i++)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 11),
              decoration: BoxDecoration(
                border: i < widget.labels.length - 1
                    ? Border(bottom: BorderSide(width: 0.5, color: widget.colors.bdr))
                    : null,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Text(widget.labels[i], style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: widget.colors.ink2))),
                  _Toggle(value: _on[i], onChanged: (v) => setState(() => _on[i] = v)),
                ],
              ),
            ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 11),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(AppL10n.of(context).neverAutoSendEmails, style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: widget.colors.ink3)),
                Container(
                  padding: const EdgeInsets.fromLTRB(7, 2, 7, 2),
                  decoration: BoxDecoration(color: const Color(0x1A9FCD44), borderRadius: BorderRadius.circular(4)),
                  child: Text(AppL10n.of(context).alwaysOn, style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: widget.colors.successFg)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Toggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  const _Toggle({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 36, height: 21,
        decoration: BoxDecoration(
          color: value ? KaalColors.acc : const Color(0x33FFFFFF),
          borderRadius: BorderRadius.circular(11),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2.5),
            child: Container(width: 16, height: 16, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
          ),
        ),
      ),
    );
  }
}
