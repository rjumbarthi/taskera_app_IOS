import 'package:flutter/material.dart';
import '../theme/taskera_theme.dart';

class BarChartData {
  final double value; // 0.0 – 1.0 (normalized)
  final Color color;
  final String? label;

  const BarChartData({required this.value, required this.color, this.label});
}

class TaskEraBarChart extends StatelessWidget {
  final List<BarChartData> bars;
  final double height;
  final double barWidth;
  final double gap;

  const TaskEraBarChart({
    super.key,
    required this.bars,
    this.height = 80,
    this.barWidth = 12,
    this.gap = 6,
  });

  @override
  Widget build(BuildContext context) {
    final colors = TaskEraTheme.of(context).colors;
    return SizedBox(
      height: height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 0; i < bars.length; i++) ...[
            if (i > 0) SizedBox(width: gap),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Flexible(
                  child: SizedBox(
                    width: barWidth,
                    height: height * bars[i].value.clamp(0.0, 1.0),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: bars[i].color,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ),
                if (bars[i].label != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    bars[i].label!,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 9,
                      color: colors.ink3,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}
