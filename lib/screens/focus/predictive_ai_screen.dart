import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/providers/tasks_provider.dart';
import '../../routing/routes.dart';
import '../../theme/taskera_colors.dart';
import '../../theme/taskera_theme.dart';
import '../../widgets/add_back_button.dart';

/// "Peak insights" — derived entirely from the user's real task-completion
/// history (`doneTasksProvider`). No mock data: peak focus windows, best day,
/// and recommendations are computed from when tasks were actually completed.
class PredictiveAiScreen extends ConsumerWidget {
  const PredictiveAiScreen({super.key});

  static const _weekdays = [
    '', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday',
  ];

  static String _windowLabel(int h) {
    final h2 = (h + 2) % 24;
    String hr(int x) => (x % 12 == 0 ? 12 : x % 12).toString();
    final p1 = h >= 12 ? 'PM' : 'AM';
    final p2 = h2 >= 12 ? 'PM' : 'AM';
    return p1 == p2 ? '${hr(h)}–${hr(h2)} $p1' : '${hr(h)} $p1–${hr(h2)} $p2';
  }

  // (badge label, accent color) for a quadrant id.
  static (String, Color) _quadInfo(int q) {
    switch (q) {
      case 1: return ('Q1', TaskEraColors.q1);
      case 2: return ('Q2 🏆', TaskEraColors.q2);
      case 3: return ('Q3', TaskEraColors.q3);
      case 4: return ('Q4', TaskEraColors.q4);
      default: return ('Focus', TaskEraColors.acc2);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = TaskEraTheme.of(context).colors;

    final done = (ref.watch(doneTasksProvider).value ?? [])
        .where((t) => t.doneAt != null)
        .toList();

    final completions = done.length;
    final activeDays = done
        .map((t) => DateTime(t.doneAt!.year, t.doneAt!.month, t.doneAt!.day))
        .toSet()
        .length;

    // Hour-of-day buckets + per-hour dominant quadrant.
    final hourCounts = <int, int>{};
    final hourQuad = <int, Map<int, int>>{};
    final weekdayCounts = <int, int>{};
    for (final t in done) {
      final h = t.doneAt!.hour;
      hourCounts[h] = (hourCounts[h] ?? 0) + 1;
      (hourQuad[h] ??= {})[t.quadrant] = ((hourQuad[h]![t.quadrant]) ?? 0) + 1;
      weekdayCounts[t.doneAt!.weekday] = (weekdayCounts[t.doneAt!.weekday] ?? 0) + 1;
    }

    final topHours = hourCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final windows = topHours.take(3).toList();
    final maxCount = windows.isEmpty ? 1 : windows.first.value;

    // Need a little history before insights are meaningful.
    final hasEnough = completions >= 3;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _PageHeader(
            colors: colors,
            subtitle: hasEnough
                ? 'Based on $activeDays ${activeDays == 1 ? 'day' : 'days'} of data'
                : 'Complete a few tasks to unlock insights',
          ),
          SizedBox(height: 10),

          if (!hasEnough)
            _EmptyState(colors: colors, completions: completions)
          else ...[
            _PeakWindowsCard(
              colors: colors,
              windows: [
                for (final e in windows)
                  (
                    label: _windowLabel(e.key),
                    fraction: (e.value / maxCount).clamp(0.08, 1.0).toDouble(),
                    quad: hourQuad[e.key]!
                        .entries
                        .reduce((a, b) => a.value >= b.value ? a : b)
                        .key,
                  ),
              ],
            ),
            SizedBox(height: 10),
            Text(
              'INSIGHTS',
              style: TextStyle(
                fontFamily: TaskEraTheme.of(context).fontFamily,
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
                color: colors.ink3,
                height: 1,
              ),
            ),
            SizedBox(height: 8),
            ..._buildRecommendations(
              colors: colors,
              done: done,
              completions: completions,
              windows: windows,
              maxCount: maxCount,
              weekdayCounts: weekdayCounts,
              hourQuad: hourQuad,
            ),
            SizedBox(height: 12),
            _FooterCard(
              colors: colors,
              activeDays: activeDays,
              completions: completions,
            ),
          ],
        ],
      ),
    );
  }

  List<Widget> _buildRecommendations({
    required TaskEraColors colors,
    required List<dynamic> done,
    required int completions,
    required List<MapEntry<int, int>> windows,
    required int maxCount,
    required Map<int, int> weekdayCounts,
    required Map<int, Map<int, int>> hourQuad,
  }) {
    final recs = <Widget>[];

    // 1) Peak window.
    if (windows.isNotEmpty) {
      final top = windows.first;
      final pct = (top.value / completions * 100).round();
      recs.add(_RecommendCard(
        colors: colors,
        title: 'Peak window: ${_windowLabel(top.key)}',
        titleColor: colors.successFg,
        body: '$pct% of your completions land in this window. '
            'Protect it for your most important deep work.',
        borderColor: const Color(0x337FBA00),
      ));
    }

    // 2) Best day of week.
    if (weekdayCounts.isNotEmpty) {
      final best = weekdayCounts.entries.reduce((a, b) => a.value >= b.value ? a : b);
      recs.add(_RecommendCard(
        colors: colors,
        title: '${_weekdays[best.key]} is your best day',
        titleColor: TaskEraColors.acc2,
        body: '${best.value} of $completions completions happen on '
            '${_weekdays[best.key]}s. Front-load important tasks then.',
        borderColor: const Color(0x260A84FF),
      ));
    }

    // 3) Dominant quadrant in the peak window.
    if (windows.isNotEmpty) {
      final qm = hourQuad[windows.first.key]!;
      final domQ = qm.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
      final (label, color) = _quadInfo(domQ);
      recs.add(_RecommendCard(
        colors: colors,
        title: 'You favour $label work at your peak',
        titleColor: color,
        body: domQ == 2
            ? 'Great — your sharpest hours go to important, non-urgent work. Keep it up.'
            : 'Most peak-hour completions are $label. Try reserving this window for Q2 (important, not urgent) work.',
        borderColor: color.withAlpha(0x33),
      ));
    }

    return [
      for (int i = 0; i < recs.length; i++) ...[
        if (i > 0) SizedBox(height: 6),
        recs[i],
      ],
    ];
  }
}

// ── Page header ───────────────────────────────────────────────────────────────

class _PageHeader extends StatelessWidget {
  final TaskEraColors colors;
  final String subtitle;
  const _PageHeader({required this.colors, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        AddBackButton(onTap: () => context.go(TaskEraRoutes.focus)),
        SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Peak insights',
              style: TextStyle(
                fontFamily: TaskEraTheme.of(context).type.numberFontFamily,
                fontVariations: const [FontVariation('wght', 600)],
                fontSize: 19,
                letterSpacing: -0.5,
                color: colors.ink,
                height: 1.1,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontFamily: TaskEraTheme.of(context).fontFamily,
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

// ── Empty / not-enough-data state ─────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final TaskEraColors colors;
  final int completions;
  const _EmptyState({required this.colors, required this.completions});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '✦ Not enough data yet',
            style: TextStyle(
              fontFamily: TaskEraTheme.of(context).fontFamily,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: TaskEraColors.acc2,
              height: 1.2,
            ),
          ),
          SizedBox(height: 6),
          Text(
            completions == 0
                ? 'Complete a few tasks and TaskEra will learn when you do your best work — your peak focus windows, best days and patterns appear here.'
                : 'You\'ve logged $completions ${completions == 1 ? 'completion' : 'completions'}. A handful more and your peak focus windows will appear here.',
            style: TextStyle(
              fontFamily: TaskEraTheme.of(context).fontFamily,
              fontSize: 13,
              color: colors.ink2,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Peak focus windows card ───────────────────────────────────────────────────

typedef _Window = ({String label, double fraction, int quad});

class _PeakWindowsCard extends StatelessWidget {
  final TaskEraColors colors;
  final List<_Window> windows;
  const _PeakWindowsCard({required this.colors, required this.windows});

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
          Text(
            '✦ Your peak focus windows',
            style: TextStyle(
              fontFamily: TaskEraTheme.of(context).fontFamily,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
              color: TaskEraColors.acc2,
              height: 1,
            ),
          ),
          SizedBox(height: 8),
          Column(
            children: [
              for (int i = 0; i < windows.length; i++) ...[
                if (i > 0) SizedBox(height: 6),
                Builder(builder: (_) {
                  final w = windows[i];
                  final (badge, color) = PredictiveAiScreen._quadInfo(w.quad);
                  return _TimeRow(
                    label: w.label,
                    fraction: w.fraction,
                    barColor: color,
                    badge: badge,
                    badgeColor: color,
                    colors: colors,
                  );
                }),
              ],
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
  final TaskEraColors colors;

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
          width: 92,
          child: Text(
            label,
            style: TextStyle(
              fontFamily: TaskEraTheme.of(context).fontFamily,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: colors.ink,
              height: 1,
            ),
          ),
        ),
        SizedBox(width: 9),
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
        SizedBox(width: 9),
        Text(
          badge,
          style: TextStyle(
            fontFamily: TaskEraTheme.of(context).fontFamily,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: colors.textOrPlain(badgeColor),
            height: 1,
          ),
        ),
      ],
    );
  }
}

// ── Insight card (data-derived) ───────────────────────────────────────────────

class _RecommendCard extends StatelessWidget {
  final TaskEraColors colors;
  final String title;
  final Color titleColor;
  final String body;
  final Color borderColor;

  const _RecommendCard({
    required this.colors,
    required this.title,
    required this.titleColor,
    required this.body,
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
              fontFamily: TaskEraTheme.of(context).fontFamily,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: colors.textOrPlain(titleColor),
              height: 1.2,
            ),
          ),
          SizedBox(height: 3),
          Text(
            body,
            style: TextStyle(
              fontFamily: TaskEraTheme.of(context).fontFamily,
              fontSize: 13,
              color: colors.ink2,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Footer info card ──────────────────────────────────────────────────────────

class _FooterCard extends StatelessWidget {
  final TaskEraColors colors;
  final int activeDays;
  final int completions;
  const _FooterCard({
    required this.colors,
    required this.activeDays,
    required this.completions,
  });

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
            fontFamily: TaskEraTheme.of(context).fontFamily,
            fontSize: 11,
            color: colors.ink3,
            height: 1.6,
          ),
          children: [
            TextSpan(text: 'Based on '),
            TextSpan(
              text: '$activeDays ${activeDays == 1 ? 'day' : 'days'}',
              style: TextStyle(color: colors.ink2, fontWeight: FontWeight.w600),
            ),
            TextSpan(text: ' of data · '),
            TextSpan(
              text: '$completions ${completions == 1 ? 'completion' : 'completions'}',
              style: TextStyle(color: colors.successFg, fontWeight: FontWeight.w600),
            ),
            TextSpan(text: ' logged · Confidence improves after 30 days'),
          ],
        ),
      ),
    );
  }
}
