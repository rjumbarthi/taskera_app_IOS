import 'package:flutter/material.dart';
import '../theme/taskera_shape.dart';

/// Tiny metadata badge — "Q1 · Overdue", schedule tags, etc.
class TaskEraPill extends StatelessWidget {
  final String label;
  final Color color;
  final Color? bgColor;

  const TaskEraPill({
    super.key,
    required this.label,
    required this.color,
    this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        color: bgColor ?? color.withAlpha(30),
        borderRadius: TaskEraShape.pill,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 9,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
          color: color,
          height: 1.2,
        ),
      ),
    );
  }
}
