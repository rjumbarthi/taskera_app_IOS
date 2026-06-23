import 'package:flutter/material.dart';
import '../theme/kaal_colors.dart';
import '../theme/kaal_theme.dart';

class HeatmapCell {
  final double intensity; // 0.0 = none, 1.0 = full
  final String? tooltip;

  const HeatmapCell({required this.intensity, this.tooltip});
}

class KaalHeatmap extends StatelessWidget {
  final List<HeatmapCell> cells; // expects 28–31 entries for a month
  final Color? color;
  final double cellSize;
  final double gap;

  const KaalHeatmap({
    super.key,
    required this.cells,
    this.color,
    this.cellSize = 14,
    this.gap = 3,
  });

  @override
  Widget build(BuildContext context) {
    final colors = KaalTheme.of(context).colors;
    final baseColor = color ?? KaalColors.acc;
    return Wrap(
      spacing: gap,
      runSpacing: gap,
      children: [
        for (final cell in cells)
          Container(
            width: cellSize,
            height: cellSize,
            decoration: BoxDecoration(
              color: cell.intensity <= 0
                  ? colors.surf3
                  : baseColor.withAlpha((cell.intensity * 255).round()),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
      ],
    );
  }
}
