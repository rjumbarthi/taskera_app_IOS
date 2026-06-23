import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/repositories/focus_session_repository.dart';
import '../../theme/kaal_colors.dart';
import '../../theme/kaal_theme.dart';
import '../../widgets/add_back_button.dart';

// Token sizing (kaal_pkg/tokens.json): fs-sm = 11px, fs-lg = 15px.
const double _fsSm = 11;
const double _fsLg = 15;

// Immutable quadrant colors.
const _kQuadColor = {1: KaalColors.q1, 2: KaalColors.q2, 3: KaalColors.q3, 4: KaalColors.q4};

class WeeklyFocusReviewScreen extends ConsumerWidget {
  const WeeklyFocusReviewScreen({super.key});

  static String _fmt(int seconds) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    if (h > 0) return m > 0 ? '${h}h ${m}m' : '${h}h';
    if (m > 0) return '${m}m';
    return '${seconds}s';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors   = KaalTheme.of(context).colors;
    final sessions = ref.watch(weeklyFocusSessionsProvider).valueOrNull ?? [];

    // Aggregate seconds per quadrant (1–4).
    final perQuad = <int, int>{1: 0, 2: 0, 3: 0, 4: 0};
    for (final s in sessions) {
      perQuad[s.quadrant] = (perQuad[s.quadrant] ?? 0) + s.durationSeconds;
    }
    final total = perQuad.values.fold<int>(0, (a, b) => a + b);
    final maxQ  = perQuad.values.fold<int>(0, (a, b) => a > b ? a : b);

    // Dominant quadrant for the headline insight.
    int domQuad = 1;
    perQuad.forEach((q, sec) { if (sec > (perQuad[domQuad] ?? 0)) domQuad = q; });
    final domPct = total > 0 ? (perQuad[domQuad]! / total * 100).round() : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Sub-header
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 12, 6),
          child: Row(
            children: [
              AddBackButton(onTap: () => context.pop()),
              const SizedBox(width: 2),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Weekly Review',
                      style: TextStyle(fontFamily: 'Fraunces',
                          fontVariations: const [FontVariation('wght', 600)],
                          fontSize: 19, letterSpacing: -0.5, color: colors.ink, height: 1.1)),
                  Text('Focus time by quadrant',
                      style: TextStyle(fontFamily: 'Inter', fontSize: _fsSm,
                          color: colors.ink3, height: 1.3)),
                ],
              ),
            ],
          ),
        ),

        Expanded(
          child: total == 0
              ? _EmptyState(colors: colors)
              : SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ── Headline insight ──────────────────────────────────
                      Container(
                        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                        decoration: BoxDecoration(
                          color: colors.surf2,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(width: 0.5, color: colors.bdr),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('THIS WEEK',
                                style: TextStyle(fontFamily: 'Inter', fontSize: 9,
                                    fontWeight: FontWeight.w700, letterSpacing: 0.5,
                                    color: colors.ink3, height: 1)),
                            const SizedBox(height: 8),
                            Text.rich(
                              TextSpan(
                                style: TextStyle(fontFamily: 'Fraunces',
                                    fontVariations: const [FontVariation('wght', 600)],
                                    fontSize: 22, color: colors.ink, height: 1.2),
                                children: [
                                  TextSpan(text: '$domPct% ',
                                      style: TextStyle(color: _kQuadColor[domQuad])),
                                  TextSpan(text: 'in Q$domQuad this week'),
                                ],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text('${_fmt(total)} focused across ${sessions.length} '
                                '${sessions.length == 1 ? 'session' : 'sessions'}',
                                style: TextStyle(fontFamily: 'Inter', fontSize: _fsSm,
                                    color: colors.ink3, height: 1.3)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),

                      // ── Per-quadrant bars ─────────────────────────────────
                      Text('TIME PER QUADRANT',
                          style: TextStyle(fontFamily: 'Inter', fontSize: 9,
                              fontWeight: FontWeight.w700, letterSpacing: 0.5,
                              color: colors.ink3, height: 1)),
                      const SizedBox(height: 10),
                      for (final q in [1, 2, 3, 4])
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _QuadBar(
                            quad: q,
                            seconds: perQuad[q]!,
                            fraction: maxQ > 0 ? perQuad[q]! / maxQ : 0,
                            pct: total > 0 ? (perQuad[q]! / total * 100).round() : 0,
                            label: _fmt(perQuad[q]!),
                            colors: colors,
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

class _QuadBar extends StatelessWidget {
  final int quad;
  final int seconds;
  final double fraction;
  final int pct;
  final String label;
  final KaalColors colors;
  const _QuadBar({required this.quad, required this.seconds, required this.fraction,
    required this.pct, required this.label, required this.colors});

  @override
  Widget build(BuildContext context) {
    final color = _kQuadColor[quad]!;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 24,
          child: Text('Q$quad',
              style: TextStyle(fontFamily: 'Inter', fontSize: _fsSm,
                  fontWeight: FontWeight.w700, color: color, height: 1)),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: SizedBox(
              height: 8,
              child: Stack(
                children: [
                  Container(color: colors.surf2),
                  FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: fraction.clamp(0.0, 1.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: color, borderRadius: BorderRadius.circular(4)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 62,
          child: Text('$label · $pct%',
              textAlign: TextAlign.right,
              style: TextStyle(fontFamily: 'Inter', fontSize: _fsSm,
                  color: colors.ink3, height: 1)),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  final KaalColors colors;
  const _EmptyState({required this.colors});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.timelapse_outlined, size: 40, color: colors.ink3),
            const SizedBox(height: 12),
            Text('No focus sessions yet',
                style: TextStyle(fontFamily: 'Inter', fontSize: _fsLg,
                    fontWeight: FontWeight.w700, color: colors.ink, height: 1.2)),
            const SizedBox(height: 6),
            Text('Start a focus session from any task to\nsee your weekly breakdown here.',
                textAlign: TextAlign.center,
                style: TextStyle(fontFamily: 'Inter', fontSize: _fsSm,
                    color: colors.ink3, height: 1.5)),
          ],
        ),
      ),
    );
  }
}
