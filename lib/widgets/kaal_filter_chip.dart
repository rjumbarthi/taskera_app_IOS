import 'package:flutter/material.dart';
import '../theme/kaal_colors.dart';
import '../theme/kaal_shape.dart';
import '../theme/kaal_theme.dart';

class KaalFilterChip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback? onTap;

  const KaalFilterChip({
    super.key,
    required this.label,
    required this.active,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = KaalTheme.of(context).colors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: active ? KaalColors.accBg : Colors.transparent,
          borderRadius: KaalShape.filterChip,
          border: Border.all(
            width: 0.5,
            color: active ? const Color(0x330A84FF) : Colors.transparent,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 9,
            fontWeight: FontWeight.w600,
            color: active ? KaalColors.acc2 : colors.ink3,
          ),
        ),
      ),
    );
  }
}
