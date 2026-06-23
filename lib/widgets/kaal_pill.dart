import 'package:flutter/material.dart';
import '../theme/kaal_shape.dart';

/// Tiny metadata badge — "Q1 · Overdue", schedule tags, etc.
class KaalPill extends StatelessWidget {
  final String label;
  final Color color;
  final Color? bgColor;

  const KaalPill({
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
        borderRadius: KaalShape.pill,
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
