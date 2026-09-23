import 'package:flutter/material.dart';
import '../theme/taskera_colors.dart';
import '../theme/taskera_theme.dart';

class TaskEraProgressBar extends StatelessWidget {
  final double value; // 0.0 – 1.0
  final Color? color;
  final double height;

  const TaskEraProgressBar({
    super.key,
    required this.value,
    this.color,
    this.height = 3,
  });

  @override
  Widget build(BuildContext context) {
    final colors = TaskEraTheme.of(context).colors;
    final barColor = color ?? TaskEraColors.acc;
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
