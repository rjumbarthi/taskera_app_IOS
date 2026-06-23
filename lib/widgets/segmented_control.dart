import 'package:flutter/material.dart';
import '../theme/kaal_colors.dart';
import '../theme/kaal_shape.dart';
import '../theme/kaal_theme.dart';

class KaalSegmentedControl extends StatelessWidget {
  final List<String> options;
  final int selectedIndex;
  final ValueChanged<int>? onChanged;

  const KaalSegmentedControl({
    super.key,
    required this.options,
    required this.selectedIndex,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = KaalTheme.of(context).colors;
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: colors.surf,
        borderRadius: KaalShape.roundChip,
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
                  color: i == selectedIndex ? KaalColors.acc : Colors.transparent,
                  borderRadius: KaalShape.roundChip,
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
