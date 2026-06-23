import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../routing/routes.dart';
import '../../theme/kaal_colors.dart';
import '../../theme/kaal_theme.dart';
import '../../widgets/add_back_button.dart';

class PredictiveAiScreen extends StatelessWidget {
  const PredictiveAiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = KaalTheme.of(context).colors;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 72),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _PageHeader(colors: colors),
          const SizedBox(height: 10),
          _PeakWindowsCard(colors: colors),
          const SizedBox(height: 10),
          Text(
            'AI RECOMMENDATIONS',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
              color: colors.ink3,
              height: 1,
            ),
          ),
          const SizedBox(height: 8),
          _RecommendCard(
            colors: colors,
            title: 'Schedule Q2 work at 9 AM',
            titleColor: colors.successFg,
            body: 'You complete Q2 tasks 78% faster in your 9–11 AM window. Move "Q1 performance review prep" to tomorrow morning.',
            buttonLabel: 'Apply →',
            buttonBg: const Color(0x1F7FBA00),
            buttonColor: colors.successFg,
            borderColor: const Color(0x337FBA00),
          ),
          const SizedBox(height: 6),
          _RecommendCard(
            colors: colors,
            title: 'Avoid Q1 fire-fighting after 3 PM',
            titleColor: KaalColors.warn,
            body: 'Your Q1 completion rate drops 60% after 3 PM. You tend to start urgent tasks late — set a 2 PM Q1 cutoff.',
            buttonLabel: 'Set cutoff →',
            buttonBg: const Color(0x1AFF453A),
            buttonColor: KaalColors.warn,
            borderColor: const Color(0x26FF453A),
          ),
          const SizedBox(height: 6),
          _RecommendCard(
            colors: colors,
            title: 'Tuesday is your best day',
            titleColor: KaalColors.acc2,
            body: '88% task completion on Tuesdays. Front-load your most important Q2 tasks on Tuesday mornings.',
            buttonLabel: 'Apply →',
            buttonBg: KaalColors.accBg,
            buttonColor: KaalColors.acc2,
            borderColor: const Color(0x260A84FF),
          ),
          const SizedBox(height: 12),
          _FooterCard(colors: colors),
        ],
      ),
    );
  }
}

// ── Page header ───────────────────────────────────────────────────────────────

class _PageHeader extends StatelessWidget {
  final KaalColors colors;
  const _PageHeader({required this.colors});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        AddBackButton(onTap: () => context.go(KaalRoutes.focus)),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Peak insights',
              style: TextStyle(
                fontFamily: 'Fraunces',
                fontVariations: [FontVariation('wght', 600)],
                fontSize: 19,
                letterSpacing: -0.5,
                color: colors.ink,
                height: 1.1,
              ),
            ),
            Text(
              'Based on 23 days of data',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                color: colors.ink3,
                letterSpacing: 0.1,
                height: 1.3,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ── Peak focus windows card ───────────────────────────────────────────────────

class _PeakWindowsCard extends StatelessWidget {
  final KaalColors colors;
  const _PeakWindowsCard({required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0x1A5856D6), Color(0x1F0A84FF)],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(width: 0.5, color: const Color(0x400A84FF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            '✦ Your peak focus windows',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
              color: KaalColors.acc2,
              height: 1,
            ),
          ),
          const SizedBox(height: 8),
          Column(
            children: [
              _TimeRow(
                label: '9–11 AM',
                fraction: 0.90,
                barColor: KaalColors.q2,
                badge: 'Q2 🏆',
                badgeColor: KaalColors.q2,
                colors: colors,
              ),
              const SizedBox(height: 6),
              _TimeRow(
                label: '2–4 PM',
                fraction: 0.65,
                barColor: KaalColors.acc,
                badge: 'Mixed',
                badgeColor: KaalColors.acc2,
                colors: colors,
              ),
              const SizedBox(height: 6),
              _TimeRow(
                label: '8–9 PM',
                fraction: 0.45,
                barColor: const Color(0xFFBF5AF2),
                badge: 'Creative',
                badgeColor: const Color(0xFFBF5AF2),
                colors: colors,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TimeRow extends StatelessWidget {
  final String label;
  final double fraction;
  final Color barColor;
  final String badge;
  final Color badgeColor;
  final KaalColors colors;

  const _TimeRow({
    required this.label,
    required this.fraction,
    required this.barColor,
    required this.badge,
    required this.badgeColor,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: colors.ink,
              height: 1,
            ),
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: SizedBox(
              height: 7,
              child: Stack(
                children: [
                  Container(color: colors.surf3),
                  FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: fraction,
                    child: Container(
                      decoration: BoxDecoration(
                        color: barColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 9),
        Text(
          badge,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: badgeColor,
            height: 1,
          ),
        ),
      ],
    );
  }
}

// ── AI recommendation card ────────────────────────────────────────────────────

class _RecommendCard extends StatelessWidget {
  final KaalColors colors;
  final String title;
  final Color titleColor;
  final String body;
  final String buttonLabel;
  final Color buttonBg;
  final Color buttonColor;
  final Color borderColor;

  const _RecommendCard({
    required this.colors,
    required this.title,
    required this.titleColor,
    required this.body,
    required this.buttonLabel,
    required this.buttonBg,
    required this.buttonColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(width: 0.5, color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: titleColor,
              height: 1,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            body,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              color: colors.ink2,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 7),
          GestureDetector(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 5, 12, 5),
              decoration: BoxDecoration(
                color: buttonBg,
                borderRadius: BorderRadius.circular(7),
              ),
              child: Text(
                buttonLabel,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: buttonColor,
                  height: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Footer info card ──────────────────────────────────────────────────────────

class _FooterCard extends StatelessWidget {
  final KaalColors colors;
  const _FooterCard({required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(width: 0.5, color: colors.bdr),
      ),
      child: RichText(
        text: TextSpan(
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 11,
            color: colors.ink3,
            height: 1.6,
          ),
          children: [
            const TextSpan(text: 'Predictions based on '),
            TextSpan(
              text: '23 days',
              style: TextStyle(
                color: colors.ink2,
                fontWeight: FontWeight.w600,
              ),
            ),
            const TextSpan(text: ' of data · '),
            TextSpan(
              text: '47 completions',
              style: TextStyle(
                color: colors.successFg,
                fontWeight: FontWeight.w600,
              ),
            ),
            const TextSpan(text: ' logged · Confidence improves after 30 days'),
          ],
        ),
      ),
    );
  }
}
