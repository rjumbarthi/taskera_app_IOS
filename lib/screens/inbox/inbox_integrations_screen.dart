import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_l10n.dart';
import '../../theme/kaal_colors.dart';
import '../../theme/kaal_theme.dart';
import '../../widgets/add_back_button.dart';

class InboxIntegrationsScreen extends StatelessWidget {
  const InboxIntegrationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors  = KaalTheme.of(context).colors;
    final safeBot = MediaQuery.of(context).padding.bottom;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 12, 6),
          child: Row(
            children: [
              AddBackButton(onTap: () => context.pop()),
              const SizedBox(width: 8),
              Text(
                'Integrations',
                style: TextStyle(
                  fontFamily: 'Fraunces', fontVariations: [FontVariation('wght', 600)], fontSize: 19,
                  letterSpacing: -0.5, color: colors.ink,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: EdgeInsets.fromLTRB(12, 0, 12, safeBot + 24),
            children: [
              _SectionLabel('Email', colors),
        const SizedBox(height: 6),
        _IntegrationRow(
          emoji: '📧',
          iconBg: const Color(0x1FFFB900),
          title: 'Gmail',
          sub: 'Auto-parse tasks from emails',
          connected: true,
          accentColor: KaalColors.q4,
          colors: colors,
        ),
        const SizedBox(height: 6),
        _IntegrationRow(
          emoji: '📬',
          iconBg: const Color(0x1A00A4EF),
          title: 'Outlook',
          sub: 'Microsoft 365 inbox parsing',
          connected: false,
          accentColor: KaalColors.q3,
          colors: colors,
        ),
        const SizedBox(height: 6),
        _IntegrationRow(
          emoji: '📮',
          iconBg: const Color(0x1A7FBA00),
          title: 'Apple Mail',
          sub: 'iOS / macOS mail parsing',
          connected: false,
          accentColor: KaalColors.q2,
          colors: colors,
        ),
        const SizedBox(height: 12),
        _SectionLabel('Messaging', colors),
        const SizedBox(height: 6),
        _IntegrationRow(
          emoji: '💬',
          iconBg: const Color(0x1A7FBA00),
          title: 'WhatsApp',
          sub: 'Extract tasks from chats',
          connected: false,
          accentColor: const Color(0xFF25D366),
          colors: colors,
        ),
        const SizedBox(height: 6),
        _IntegrationRow(
          emoji: '🔷',
          iconBg: const Color(0x1A0A84FF),
          title: 'Slack',
          sub: 'Turn messages into tasks',
          connected: false,
          accentColor: KaalColors.acc,
          colors: colors,
        ),
        const SizedBox(height: 6),
        _IntegrationRow(
          emoji: '✈️',
          iconBg: const Color(0x1A0A84FF),
          title: 'Telegram',
          sub: 'Auto-capture from saved messages',
          connected: false,
          accentColor: const Color(0xFF229ED9),
          colors: colors,
        ),
        const SizedBox(height: 12),
        _SectionLabel('How it works', colors),
        const SizedBox(height: 8),
        _HowItWorksCard(colors: colors),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Section label ─────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  final KaalColors colors;
  const _SectionLabel(this.text, this.colors);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 4, 0, 0),
      child: Text(text.toUpperCase(),
          style: TextStyle(fontFamily: 'Inter', fontSize: 9,
              fontWeight: FontWeight.w700, letterSpacing: 0.5,
              color: colors.ink3, height: 1)),
    );
  }
}

// ── Integration row ───────────────────────────────────────────────────────────

class _IntegrationRow extends StatelessWidget {
  final String emoji;
  final Color iconBg;
  final String title;
  final String sub;
  final bool connected;
  final Color accentColor;
  final KaalColors colors;
  const _IntegrationRow({required this.emoji, required this.iconBg,
      required this.title, required this.sub, required this.connected,
      required this.accentColor, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: colors.surf,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(width: 0.5, color: colors.bdr),
      ),
      child: Row(children: [
        Container(
          width: 32, height: 32,
          decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(9)),
          alignment: Alignment.center,
          child: Text(emoji, style: const TextStyle(fontSize: 16)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title,
                style: TextStyle(fontFamily: 'Inter', fontSize: 13,
                    fontWeight: FontWeight.w600, color: colors.ink, height: 1.2)),
            Text(sub,
                style: TextStyle(fontFamily: 'Inter', fontSize: 11,
                    color: colors.ink3, height: 1.3)),
          ]),
        ),
        const SizedBox(width: 8),
        if (connected)
          Container(
            padding: const EdgeInsets.fromLTRB(8, 3, 8, 3),
            decoration: BoxDecoration(
              color: const Color(0x1A7FBA00),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(width: 0.5, color: const Color(0x337FBA00)),
            ),
            child: Text(AppL10n.of(context).connected,
                style: const TextStyle(fontFamily: 'Inter', fontSize: 10,
                    fontWeight: FontWeight.w600, color: KaalColors.q2, height: 1)),
          )
        else
          Container(
            padding: const EdgeInsets.fromLTRB(8, 3, 8, 3),
            decoration: BoxDecoration(
              color: const Color(0x1A0A84FF),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(width: 0.5, color: const Color(0x330A84FF)),
            ),
            child: Text(AppL10n.of(context).connect,
                style: const TextStyle(fontFamily: 'Inter', fontSize: 10,
                    fontWeight: FontWeight.w600, color: KaalColors.acc, height: 1)),
          ),
      ]),
    );
  }
}

// ── How it works card ─────────────────────────────────────────────────────────

class _HowItWorksCard extends StatelessWidget {
  final KaalColors colors;
  const _HowItWorksCard({required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      decoration: BoxDecoration(
        color: colors.surf,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(width: 0.5, color: colors.bdr),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: 28, height: 28,
            decoration: BoxDecoration(
              color: const Color(0x1A0A84FF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.auto_awesome_rounded, color: KaalColors.acc, size: 14),
          ),
          const SizedBox(width: 10),
          Text(AppL10n.of(context).aiPoweredInboxParsing,
              style: TextStyle(fontFamily: 'Inter', fontSize: 13,
                  fontWeight: FontWeight.w600, color: colors.ink, height: 1)),
        ]),
        const SizedBox(height: 10),
        _Step(n: '1', text: AppL10n.of(context).connectEmailOrApp, colors: colors),
        const SizedBox(height: 7),
        _Step(n: '2', text: AppL10n.of(context).kaalReadsWithAi, colors: colors),
        const SizedBox(height: 7),
        _Step(n: '3', text: AppL10n.of(context).actionItemsSurfaced, colors: colors),
        const SizedBox(height: 7),
        _Step(n: '4', text: AppL10n.of(context).approveOrDismiss, colors: colors),
      ]),
    );
  }
}

class _Step extends StatelessWidget {
  final String n;
  final String text;
  final KaalColors colors;
  const _Step({required this.n, required this.text, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        width: 18, height: 18,
        decoration: BoxDecoration(
          color: const Color(0x1A0A84FF),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Text(n,
            style: const TextStyle(fontFamily: 'Inter', fontSize: 9,
                fontWeight: FontWeight.w700, color: KaalColors.acc, height: 1)),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: Text(text,
            style: TextStyle(fontFamily: 'Inter', fontSize: 12,
                color: colors.ink2, height: 1.4)),
      ),
    ]);
  }
}
