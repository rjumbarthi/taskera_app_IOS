import 'package:flutter/material.dart';
import '../theme/taskera_colors.dart';
import '../theme/taskera_motion.dart';

class TaskEraFab extends StatefulWidget {
  final VoidCallback? onTap;

  const TaskEraFab({super.key, this.onTap});

  @override
  State<TaskEraFab> createState() => _TaskEraFabState();
}

class _TaskEraFabState extends State<TaskEraFab> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? TaskEraMotion.scalePressed : 1.0,
        duration: TaskEraMotion.fastPress,
        child: Container(
          width: 38,
          height: 38,
          decoration: const BoxDecoration(
            color: TaskEraColors.acc,
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
