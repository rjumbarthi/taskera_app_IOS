import 'package:flutter/material.dart';
import '../theme/kaal_colors.dart';
import '../theme/kaal_theme.dart';

class KaalProgressBar extends StatelessWidget {
  final double value; // 0.0 – 1.0
  final Color? color;
  final double height;

  const KaalProgressBar({
    super.key,
    required this.value,
    this.color,
    this.height = 3,
  });

  @override
  Widget build(BuildContext context) {
    final colors = KaalTheme.of(context).colors;
    final barColor = color ?? KaalColors.acc;
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: colors.surf3,
        borderRadius: BorderRadius.circular(height / 2),
      ),
      child: FractionallySizedBox(
        widthFactor: value.clamp(0.0, 1.0),
        alignment: Alignment.centerLeft,
        child: Container(
          decoration: BoxDecoration(
            color: barColor,
            borderRadius: BorderRadius.circular(height / 2),
          ),
        ),
      ),
    );
  }
}
