import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_l10n.dart';
import '../../theme/kaal_colors.dart';
import '../../theme/kaal_theme.dart';
import '../../widgets/add_back_button.dart';

class WeeklyReviewScreen extends StatefulWidget {
  const WeeklyReviewScreen({super.key});

  @override
  State<WeeklyReviewScreen> createState() => _WeeklyReviewScreenState();
}

class _WeeklyReviewScreenState extends State<WeeklyReviewScreen> {
  final _biggestWinCtrl = TextEditingController(
    text: 'Completed the design system and shipped the auth flow ahead of schedule.',
  );
  final _drainCtrl = TextEditingController();
  final _priorityCtrl = TextEditingController(
    text: 'Finish MVP core features and get to beta-ready state.',
  );

  @override
  void dispose() {
    _biggestWinCtrl.dispose();
    _drainCtrl.dispose();
    _priorityCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = KaalTheme.of(context).colors;
    final l = AppL10n.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Sub-header — matches profile branch sub-screen pattern
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 12, 6),
          child: Row(
            children: [
              AddBackButton(onTap: () => context.pop()),
              const SizedBox(width: 2),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l.weeklyReviewLabel,
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
                    'Week 17 · Apr 21–27',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      color: colors.ink3,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Biggest Win
                _SectionCard(
                  bgColor: const Color(0x147FBA00),
                  borderColor: const Color(0x407FBA00),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '🏆 BIGGEST WIN',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                          color: colors.successFg,
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 7),
                      _ExpandingField(
                        controller: _biggestWinCtrl,
                        hint: l.weeklyWinHint,
                        colors: colors,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // Week Summary
                _SectionCard(
                  bgColor: Colors.transparent,
                  borderColor: colors.bdr,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'WEEK SUMMARY',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                          color: colors.ink3,
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 9),
                      Row(
                        children: [
                          Expanded(child: _StatBox(value: '18', label: 'Done',   valueColor: KaalColors.q2,           colors: colors)),
                          const SizedBox(width: 5),
                          Expanded(child: _StatBox(value: '3',  label: 'Missed', valueColor: KaalColors.q1,           colors: colors)),
                          const SizedBox(width: 5),
                          Expanded(child: _StatBox(value: '3/4',label: 'Habits', valueColor: const Color(0xFFBF5AF2), colors: colors)),
                          const SizedBox(width: 5),
                          Expanded(child: _StatBox(value: '14h',label: 'Logged', valueColor: KaalColors.acc2,         colors: colors)),
                        ],
                      ),
                      const SizedBox(height: 9),
                      _QuadBar(label: 'Q1', color: KaalColors.q1, fraction: 0.70, count: '7',  colors: colors),
                      const SizedBox(height: 5),
                      _QuadBar(label: 'Q2', color: KaalColors.q2, fraction: 1.00, count: '10', colors: colors),
                      const SizedBox(height: 5),
                      _QuadBar(label: 'Q3', color: KaalColors.q3, fraction: 0.50, count: '5',  colors: colors),
                      const SizedBox(height: 5),
                      _QuadBar(label: 'Q4', color: KaalColors.q4, fraction: 0.20, count: '2',  colors: colors),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // What drained energy?
                _SectionCard(
                  bgColor: const Color(0x0FFF453A),
                  borderColor: const Color(0x33FF453A),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '⚡ WHAT DRAINED ENERGY?',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                          color: Color(0xFFFF8080),
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 7),
                      _ExpandingField(
                        controller: _drainCtrl,
                        hint: l.weeklyBlockerHint,
                        colors: colors,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // Next week's #1 priority
                _SectionCard(
                  bgColor: KaalColors.accBg,
                  borderColor: const Color(0x400A84FF),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '🎯 NEXT WEEK\'S #1 PRIORITY',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                          color: KaalColors.acc2,
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 7),
                      _ExpandingField(
                        controller: _priorityCtrl,
                        hint: l.weeklySuccessHint,
                        colors: colors,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // Kaal AI insight
                Container(
                  padding: const EdgeInsets.fromLTRB(12, 11, 12, 11),
                  decoration: BoxDecoration(
                    color: const Color(0x12BF5AF2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(width: 0.5, color: const Color(0x33BF5AF2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 13,
                            height: 13,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(3),
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Color(0xFF5856D6), KaalColors.acc],
                              ),
                            ),
                          ),
                          const SizedBox(width: 5),
                          const Text(
                            'Kaal AI · Week insight',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFBF5AF2),
                              height: 1,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text.rich(
                        TextSpan(
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            color: colors.ink3,
                            height: 1.55,
                          ),
                          children: [
                            const TextSpan(text: 'Your Q2 completion rate was '),
                            TextSpan(
                              text: '40% above your average',
                              style: TextStyle(
                                color: colors.ink2,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const TextSpan(
                              text: '. You do best when Tuesdays are fully blocked for deep work. Consider protecting that again next week.',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // Save button
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    decoration: BoxDecoration(
                      color: const Color(0x127FBA00),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(width: 0.5, color: const Color(0x407FBA00)),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Save review ✓',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: colors.successFg,
                        height: 1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Shared section card wrapper ───────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final Color bgColor;
  final Color borderColor;
  final Widget child;

  const _SectionCard({
    required this.bgColor,
    required this.borderColor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(width: 0.5, color: borderColor),
      ),
      child: child,
    );
  }
}

// ── Auto-expanding text field (transparent, borderless) ───────────────────────

class _ExpandingField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final KaalColors colors;

  const _ExpandingField({
    required this.controller,
    required this.hint,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: null,
      style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: colors.ink, height: 1.5),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(fontFamily: 'Inter', fontSize: 13, color: colors.ink3, height: 1.5),
        border: InputBorder.none,
        isDense: true,
        contentPadding: EdgeInsets.zero,
      ),
    );
  }
}

// ── Stat box — tinted with the value's semantic color ────────────────────────

class _StatBox extends StatelessWidget {
  final String value;
  final String label;
  final Color valueColor;
  final KaalColors colors;

  const _StatBox({
    required this.value,
    required this.label,
    required this.valueColor,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(4, 7, 4, 7),
      decoration: BoxDecoration(
        color: valueColor.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(width: 0.5, color: valueColor.withValues(alpha: 0.25)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Fraunces',
              fontSize: 19,
              fontWeight: FontWeight.w600,
              color: valueColor,
              height: 1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(fontFamily: 'Inter', fontSize: 9, color: colors.ink3, height: 1.2),
          ),
        ],
      ),
    );
  }
}

// ── Quad progress bar row ─────────────────────────────────────────────────────

class _QuadBar extends StatelessWidget {
  final String label;
  final Color color;
  final double fraction;
  final String count;
  final KaalColors colors;

  const _QuadBar({
    required this.label,
    required this.color,
    required this.fraction,
    required this.count,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 18,
          child: Text(
            label,
            style: TextStyle(fontFamily: 'Inter', fontSize: 9, color: color, height: 1),
          ),
        ),
        const SizedBox(width: 7),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: SizedBox(
              height: 5,
              child: Stack(
                children: [
                  Container(color: colors.surf3),
                  FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: fraction,
                    child: Container(
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 7),
        SizedBox(
          width: 20,
          child: Text(
            count,
            style: TextStyle(fontFamily: 'Inter', fontSize: 9, color: colors.ink3, height: 1),
          ),
        ),
      ],
    );
  }
}
