import 'package:flutter/material.dart';
import '../theme/taskera_colors.dart';
import '../theme/taskera_shape.dart';
import '../theme/taskera_theme.dart';

class HabitRow extends StatelessWidget {
  final String name;
  final String schedule;
  final List<bool> weekDots; // 7 booleans — true = completed
  final int streak;
  final VoidCallback? onMenu;

  const HabitRow({
    super.key,
    required this.name,
    required this.schedule,
    required this.weekDots,
    required this.streak,
    this.onMenu,
  });

  @override
  Widget build(BuildContext context) {
    final colors = TaskEraTheme.of(context).colors;
    return Container(
      padding: const EdgeInsets.fromLTRB(11, 9, 11, 9),
      decoration: BoxDecoration(
        color: colors.surf2,
        borderRadius: TaskEraShape.card,
        border: Border.all(width: 0.5, color: colors.bdr),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: colors.ink,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  schedule,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    color: colors.ink3,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    for (int i = 0; i < weekDots.length && i < 7; i++) ...[
                      if (i > 0) const SizedBox(width: 4),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: weekDots[i] ? TaskEraColors.acc : colors.surf3,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (streak > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0x1FFF9500),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '🔥 $streak',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFFF9500),
                ),
              ),
            ),
          if (onMenu != null) ...[
            const SizedBox(width: 4),
            GestureDetector(
              onTap: onMenu,
              child: Icon(Icons.more_horiz, size: 20, color: colors.ink3),
            ),
          ],
        ],
      ),
    );
  }
}
