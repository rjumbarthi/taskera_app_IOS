import 'package:flutter/material.dart';
import '../theme/taskera_colors.dart';
import '../theme/taskera_shape.dart';
import '../theme/taskera_theme.dart';

class TaskEraSegmentedControl extends StatelessWidget {
  final List<String> options;
  final int selectedIndex;
  final ValueChanged<int>? onChanged;

  const TaskEraSegmentedControl({
    super.key,
    required this.options,
    required this.selectedIndex,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = TaskEraTheme.of(context).colors;
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: colors.surf,
        borderRadius: TaskEraShape.roundChip,
        border: Border.all(width: 0.5, color: colors.bdr),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 0; i < options.length; i++)
            GestureDetector(
              onTap: () => onChanged?.call(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: i == selectedIndex ? TaskEraColors.acc : Colors.transparent,
                  borderRadius: TaskEraShape.roundChip,
                ),
                child: Text(
                  options[i],
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: i == selectedIndex ? Colors.white : colors.ink3,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
