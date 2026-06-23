import 'package:flutter/material.dart';
import '../theme/kaal_colors.dart';
import '../theme/kaal_shape.dart';
import '../theme/kaal_theme.dart';

class KaalToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;

  const KaalToggle({super.key, required this.value, this.onChanged});

  @override
  Widget build(BuildContext context) {
    final colors = KaalTheme.of(context).colors;
    return GestureDetector(
      onTap: () => onChanged?.call(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 32,
        height: 17,
        decoration: BoxDecoration(
          color: value ? KaalColors.acc : colors.surf3,
          borderRadius: KaalShape.switchTrack,
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: const Padding(
            padding: EdgeInsets.all(2),
            child: _Thumb(),
          ),
        ),
      ),
    );
  }
}

class _Thumb extends StatelessWidget {
  const _Thumb();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 13,
      height: 13,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Color(0x4D000000),
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
    );
  }
}
