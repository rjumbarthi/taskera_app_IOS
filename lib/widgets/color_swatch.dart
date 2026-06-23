import 'package:flutter/material.dart';

class KaalColorSwatch extends StatelessWidget {
  final Color color;
  final bool selected;
  final VoidCallback? onTap;

  const KaalColorSwatch({
    super.key,
    required this.color,
    required this.selected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedScale(
        scale: selected ? 1.15 : 1.0,
        duration: const Duration(milliseconds: 140),
        child: Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(
              width: 2,
              color: selected ? Colors.white : Colors.transparent,
            ),
          ),
        ),
      ),
    );
  }
}
