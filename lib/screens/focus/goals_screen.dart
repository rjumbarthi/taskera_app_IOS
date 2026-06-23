import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/database.dart' show Goal;
import '../../data/providers/goals_provider.dart';
import '../../theme/kaal_colors.dart';
import '../../theme/kaal_theme.dart';
import '../../widgets/add_back_button.dart';

// ── Data ──────────────────────────────────────────────────────────────────────

enum _LinkType { task, habit }

class _LinkedItem {
  final String title;
  final bool done;
  final String? badge;
  final Color? badgeColor;
  final Color quadColor;
  const _LinkedItem({required this.title})
      : done = false,
        badge = null,
        badgeColor = null,
        quadColor = KaalColors.q2;
}

class _Goal {
  final String emoji;
  final String title;
  final String sub;
  final double pct;
  final Color pctColor;
  final String linkedLabel;
  final List<_LinkedItem> items;
  final _LinkType linkType;
  const _Goal({
    required this.emoji,
    required this.title,
    required this.sub,
    required this.pct,
    required this.pctColor,
    required this.linkedLabel,
    required this.items,
    required this.linkType,
  });
}

// ── DB → display model mapping ─────────────────────────────────────────────

_Goal _rowToGoal(Goal r) => _Goal(
      emoji: r.emoji,
      title: r.title,
      sub: r.subtitle,
      pct: r.progressPct,
      pctColor: Color(r.accentColorValue),
      linkedLabel: r.linkedLabel,
      items: const [],
      linkType: r.linkType == 'habit' ? _LinkType.habit : _LinkType.task,
    );

// ── Screen ────────────────────────────────────────────────────────────────────

class GoalsScreen extends ConsumerWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = KaalTheme.of(context).colors;
    final goals = ref.watch(goalsProvider).value ?? [];
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SubHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Quote banner
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                      decoration: BoxDecoration(
                        color: const Color(0x0F7FBA00), // rgba(127,186,0,.06)
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(width: 0.5, color: const Color(0x337FBA00)),
                      ),
                      child: Text(
                        '"Goals without Q2 tasks are just wishes. Map every goal to at least one scheduled action."',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          color: colors.successFg,
                          height: 1.6,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Goal cards
                    ...goals.map((row) {
                      final g = _rowToGoal(row);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: GestureDetector(
                          onTap: () => context.push('/focus/goals/${row.id}'),
                          child: _GoalCard(goal: g, goalId: row.id, colors: colors),
                        ),
                      );
                    }),

                    // Add goal row
                    GestureDetector(
                      onTap: () => context.push('/focus/editgoal'),
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                      padding: const EdgeInsets.all(13),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          width: 0.5,
                          color: colors.bdr2,
                          style: BorderStyle.none, // dashed not supported natively
                        ),
                      ),
                      child: _DashedBorderBox(
                        color: colors.bdr2,
                        radius: 14,
                        child: Padding(
                          padding: const EdgeInsets.all(13),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add, size: 14, color: colors.ink3),
                              const SizedBox(width: 8),
                              Text(
                                'Add a new goal (max 5)',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 14,
                                  color: colors.ink3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        // FAB
        Positioned(
          right: 16,
          bottom: 16 + MediaQuery.paddingOf(context).bottom,
          child: GestureDetector(
            onTap: () => context.push('/focus/editgoal'),
            child: Container(
              width: 48, height: 48,
              decoration: const BoxDecoration(
                color: KaalColors.acc,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.add, color: Colors.white, size: 22),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Sub-header ────────────────────────────────────────────────────────────────

class _SubHeader extends StatelessWidget {
  const _SubHeader();

  @override
  Widget build(BuildContext context) {
    final colors = KaalTheme.of(context).colors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 6),
      child: Row(
        children: [
          AddBackButton(onTap: () => context.pop()),
          const SizedBox(width: 2),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Goals',
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
                '3 active · mapped to Q2',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  color: colors.ink3,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Goal card ─────────────────────────────────────────────────────────────────

class _GoalCard extends StatelessWidget {
  final _Goal goal;
  final int goalId;
  final KaalColors colors;
  const _GoalCard({required this.goal, required this.goalId, required this.colors});

  @override
  Widget build(BuildContext context) {
    final accent = goal.pctColor;
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: accent.withAlpha(0x12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(width: 1.0, color: accent.withAlpha(0x4D)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header row
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: accent.withAlpha(0x1F),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Text(goal.emoji, style: const TextStyle(fontSize: 18)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      goal.title,
                      style: const TextStyle(
                        fontFamily: 'Fraunces',
                        fontVariations: [FontVariation('wght', 600)],
                        fontSize: 14,
                        color: Color(0xFFF2F2F7),
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      goal.sub,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: colors.ink3,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${(goal.pct * 100).round()}%',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: goal.pctColor,
                ),
              ),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: () => context.push('/focus/editgoal/$goalId'),
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Icon(Icons.edit_rounded, size: 13, color: colors.ink3),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: Container(
              height: 5,
              color: colors.surf3,
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: goal.pct,
                child: ColoredBox(color: accent),
              ),
            ),
          ),

          const SizedBox(height: 9),

          // Linked label
          Text(
            goal.linkedLabel,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              fontWeight: goal.items.isNotEmpty ? FontWeight.w700 : FontWeight.w400,
              letterSpacing: goal.items.isNotEmpty ? 0.4 : 0,
              color: colors.ink3,
            ),
          ),

          // Task/habit rows (only first goal has them in the PNG)
          if (goal.items.isNotEmpty) ...[
            const SizedBox(height: 6),
            Column(
              children: goal.items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: _LinkedRow(item: item, dotColor: goal.pctColor, colors: colors),
              )).toList(),
            ),
          ],

          const SizedBox(height: 9),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 7),
                    decoration: BoxDecoration(
                      color: goal.linkType == _LinkType.habit
                          ? const Color(0x1ABF5AF2)
                          : KaalColors.accBg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      goal.linkType == _LinkType.habit ? '+ Link habit' : '+ Link task',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: goal.linkType == _LinkType.habit
                            ? const Color(0xFFBF5AF2)
                            : KaalColors.acc2,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: GestureDetector(
                  onTap: () => context.push('/focus/goals/$goalId'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 7),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(width: 0.5, color: colors.bdr),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'View all →',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: colors.ink2,
                      ),
                    ),
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

// ── Linked task/habit row ─────────────────────────────────────────────────────

class _LinkedRow extends StatelessWidget {
  final _LinkedItem item;
  final Color dotColor;
  final KaalColors colors;
  const _LinkedRow({required this.item, required this.dotColor, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          // Status dot
          item.done
              ? Container(
                  width: 11, height: 11,
                  decoration: BoxDecoration(color: item.quadColor, shape: BoxShape.circle),
                  alignment: Alignment.center,
                  child: const Icon(Icons.check_rounded, size: 7, color: Colors.white),
                )
              : Container(
                  width: 11, height: 11,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(width: 1.5, color: item.quadColor),
                  ),
                ),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              item.title,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                color: item.done ? colors.ink3 : item.quadColor,
                decoration: item.done ? TextDecoration.lineThrough : null,
                decorationColor: colors.ink3,
                height: 1.3,
              ),
            ),
          ),
          if (item.badge != null) ...[
            const SizedBox(width: 6),
            Text(
              item.badge!,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                color: item.badgeColor,
                height: 1.3,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Dashed border box ─────────────────────────────────────────────────────────

class _DashedBorderBox extends StatelessWidget {
  final Widget child;
  final Color color;
  final double radius;
  const _DashedBorderBox({required this.child, required this.color, required this.radius});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedBorderPainter(color: color, radius: radius),
      child: child,
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double radius;
  _DashedBorderPainter({required this.color, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;
    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          Radius.circular(radius)));
    const dashLen = 5.0;
    const gapLen  = 4.0;
    final metrics = path.computeMetrics();
    for (final m in metrics) {
      double dist = 0;
      while (dist < m.length) {
        canvas.drawPath(m.extractPath(dist, dist + dashLen), paint);
        dist += dashLen + gapLen;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter old) =>
      old.color != color || old.radius != radius;
}
