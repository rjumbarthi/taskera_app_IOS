import 'package:flutter/material.dart';
import '../theme/kaal_colors.dart';
import '../theme/kaal_motion.dart';

class KaalFab extends StatefulWidget {
  final VoidCallback? onTap;

  const KaalFab({super.key, this.onTap});

  @override
  State<KaalFab> createState() => _KaalFabState();
}

class _KaalFabState extends State<KaalFab> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? KaalMotion.scalePressed : 1.0,
        duration: KaalMotion.fastPress,
        child: Container(
          width: 38,
          height: 38,
          decoration: const BoxDecoration(
            color: KaalColors.acc,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Color(0x800A84FF),
                blurRadius: 14,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: const Center(
            child: Text(
              '+',
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.w300,
                color: Colors.white,
                height: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
