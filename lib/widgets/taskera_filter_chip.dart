import 'package:flutter/material.dart';
import '../theme/taskera_colors.dart';
import '../theme/taskera_shape.dart';
import '../theme/taskera_theme.dart';

class TaskEraFilterChip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback? onTap;

  const TaskEraFilterChip({
    super.key,
    required this.label,
    required this.active,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = TaskEraTheme.of(context).colors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: active ? TaskEraColors.accBg : Colors.transparent,
          borderRadius: TaskEraShape.filterChip,
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
            color: active ? TaskEraColors.acc2 : colors.ink3,
          ),
        ),
      ),
    );
  }
}
