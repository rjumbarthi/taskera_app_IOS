import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../l10n/app_l10n.dart';
import '../../theme/kaal_colors.dart';
import '../../theme/kaal_theme.dart';
import '../../widgets/add_back_button.dart';

class ConflictsScreen extends StatelessWidget {
  const ConflictsScreen({super.key});

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
                    Text(AppL10n.of(context).conflicts, style: TextStyle(fontFamily: 'Fraunces', fontVariations: [FontVariation('wght', 600)], fontSize: 19, letterSpacing: -0.5, color: colors.ink, height: 1.1)),
                    Text('2 scheduling conflicts detected', style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: colors.ink3, height: 1.2)),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 72),
            children: [
              // Conflict 1 — red (overlap)
              Container(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                decoration: BoxDecoration(
                  color: const Color(0x12FF453A),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(width: 0.5, color: const Color(0x4DFF453A)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded, size: 14, color: Color(0xFFFF6B6B)),
                        const SizedBox(width: 7),
                        const Text('Overlap — Tomorrow 9–10 AM',
                          style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFFFF6B6B))),
                      ],
                    ),
                    const SizedBox(height: 9),
                    // Task A
                    Container(
                      padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border(left: BorderSide(width: 3, color: KaalColors.q1)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Assignment submission', style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w500, color: colors.ink)),
                          Text('9:00–10:30 AM · Q1 · Scheduled', style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: colors.ink3)),
                        ],
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 5),
                      child: Text('⚡ Overlaps by 30 min', textAlign: TextAlign.center,
                        style: TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFFFF6B6B))),
                    ),
                    // Task B
                    Container(
                      padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border(left: BorderSide(width: 3, color: KaalColors.acc2)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Product Roadmap Review', style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w500, color: colors.ink)),
                          Text('10:00 AM–12:00 PM · Calendar event', style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: colors.ink3)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 9),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {},
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(color: KaalColors.acc, borderRadius: BorderRadius.circular(8)),
                              alignment: Alignment.center,
                              child: const Text('Move deck to 8 AM', style: TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {},
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(color: Colors.transparent, borderRadius: BorderRadius.circular(8), border: Border.all(width: 0.5, color: const Color(0x40FF453A))),
                              alignment: Alignment.center,
                              child: const Text('Shorten to 60m', style: TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFFFF6B6B))),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // Conflict 2 — amber (back-to-back)
              Container(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                decoration: BoxDecoration(
                  color: const Color(0x12FFB900),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(width: 0.5, color: const Color(0x4DFFB900)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded, size: 14, color: Color(0xFFFFB900)),
                        const SizedBox(width: 7),
                        const Text('Back-to-back — Friday 2 PM',
                          style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFFFFB900))),
                      ],
                    ),
                    const SizedBox(height: 9),
                    Container(
                      padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border(left: BorderSide(width: 3, color: KaalColors.q2)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Call dentist', style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w500, color: colors.ink)),
                          Text('2:00–2:30 PM · Q2', style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: colors.ink3)),
                        ],
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 5),
                      child: Text('No buffer between tasks', textAlign: TextAlign.center,
                        style: TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFFFFB900))),
                    ),
                    Container(
                      padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border(left: BorderSide(width: 3, color: KaalColors.q2)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Design sync', style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w500, color: colors.ink)),
                          Text('2:30–4:00 PM · Calendar', style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: colors.ink3)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 9),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {},
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0x26FFB900),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              alignment: Alignment.center,
                              child: const Text('Add 10m buffer', style: TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFFFFB900))),
                            ),
                          ),
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {},
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(color: Colors.transparent, borderRadius: BorderRadius.circular(8), border: Border.all(width: 0.5, color: const Color(0x40FFB900))),
                              alignment: Alignment.center,
                              child: const Text('Ignore', style: TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w500, color: Color(0x99FFB900))),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // All clear card
              Container(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                decoration: BoxDecoration(
                  color: const Color(0x0F7FBA00),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(width: 0.5, color: const Color(0x337FBA00)),
                ),
                child: Column(
                  children: [
                    Text('Rest of week looks clear', style: TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w600, color: colors.successFg)),
                    const SizedBox(height: 2),
                    Text('Resolve the 2 conflicts above to confirm', style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: colors.ink3)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
