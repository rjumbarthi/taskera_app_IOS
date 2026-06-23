import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../theme/kaal_motion.dart';
import '../theme/kaal_shape.dart';
import '../theme/kaal_theme.dart';

class TaskRow extends StatefulWidget {
  final String title;
  final bool completed;
  final Widget? trailing;
  final VoidCallback? onTap;
  // Receives the global position so callers can anchor a ContextMenu there.
  final void Function(Offset globalPosition)? onLongPress;
  final ValueChanged<bool>? onCheckChanged;

  const TaskRow({
    super.key,
    required this.title,
    this.completed = false,
    this.trailing,
    this.onTap,
    this.onLongPress,
    this.onCheckChanged,
  });

  @override
  State<TaskRow> createState() => _TaskRowState();
}

class _TaskRowState extends State<TaskRow> with SingleTickerProviderStateMixin {
  bool _pressed = false;

  // 110 ms pulse: 1.0 → 0.97 → 1.0 in two 55 ms halves.
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      duration: const Duration(milliseconds: 55),
      vsync: this,
    );
    _pulseAnim = Tween<double>(begin: 1.0, end: KaalMotion.scalePressed)
        .animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  Future<void> _fireLongPress(Offset globalPosition) async {
    if (widget.onLongPress == null) return;
    setState(() => _pressed = false); // release tap visual before pulse
    await _pulseCtrl.forward();       // 55 ms: scale down
    await _pulseCtrl.reverse();       // 55 ms: scale back up  → total 110 ms
    widget.onLongPress!(globalPosition);
  }

  @override
  Widget build(BuildContext context) {
    final colors = KaalTheme.of(context).colors;

    return Listener(
      // Right-click on Windows/desktop = secondary button → same action as long press.
      onPointerDown: (event) {
        if (event.buttons & kSecondaryMouseButton != 0) {
          _fireLongPress(event.position);
        }
      },
      child: RawGestureDetector(
        behavior: HitTestBehavior.opaque,
        gestures: {
          // 480 ms long press — overrides Flutter's platform default of 500 ms.
          LongPressGestureRecognizer:
              GestureRecognizerFactoryWithHandlers<LongPressGestureRecognizer>(
            () => LongPressGestureRecognizer(duration: KaalMotion.longPress),
            (instance) {
              instance.onLongPressStart =
                  (details) => _fireLongPress(details.globalPosition);
            },
          ),
          TapGestureRecognizer:
              GestureRecognizerFactoryWithHandlers<TapGestureRecognizer>(
            () => TapGestureRecognizer(),
            (instance) {
              instance
                ..onTap = widget.onTap
                ..onTapDown = (_) { setState(() => _pressed = true); }
                ..onTapUp = (_) { setState(() => _pressed = false); }
                ..onTapCancel = () { setState(() => _pressed = false); };
            },
          ),
        },
        child: AnimatedBuilder(
          animation: _pulseAnim,
          builder: (_, child) => Transform.scale(
            // Tap press and LP pulse are combined: whichever is smaller wins.
            scale: _pressed
                ? KaalMotion.scalePressed
                : _pulseAnim.value,
            child: child,
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: const Color(0x0AFFFFFF),
              borderRadius: KaalShape.card,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => widget.onCheckChanged?.call(!widget.completed),
                  child: Container(
                    width: 20,
                    height: 20,
                    margin: const EdgeInsets.only(top: 1),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(width: 1.5, color: colors.bdr2),
                      color: widget.completed ? colors.bdr2 : Colors.transparent,
                    ),
                    child: widget.completed
                        ? Icon(Icons.check, size: 12, color: colors.ink3)
                        : null,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.title,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: widget.completed ? colors.ink3 : colors.ink,
                      decoration: widget.completed
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      height: 1.4,
                    ),
                  ),
                ),
                if (widget.trailing != null) ...[
                  const SizedBox(width: 8),
                  widget.trailing!,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
