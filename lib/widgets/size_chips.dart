import 'package:flutter/material.dart';
import '../theme/kaal_colors.dart';
import '../theme/kaal_shape.dart';
import '../theme/kaal_theme.dart';

const _kSizes = ['sm', 'md', 'lg', 'xl', '2xl'];

class SizeChips extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int>? onChanged;

  const SizeChips({
    super.key,
    required this.selectedIndex,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = KaalTheme.of(context).colors;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < _kSizes.length; i++) ...[
          if (i > 0) const SizedBox(width: 6),
          GestureDetector(
            onTap: () => onChanged?.call(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: KaalShape.filterChip,
                border: Border.all(
                  width: i == selectedIndex ? 1.5 : 0.5,
                  color: i == selectedIndex ? KaalColors.acc : colors.bdr,
                ),
              ),
              child: Text(
                _kSizes[i],
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: i == selectedIndex ? KaalColors.acc : colors.ink3,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
