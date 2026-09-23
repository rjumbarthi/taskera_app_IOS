import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/taskera_shape.dart';
import '../theme/taskera_theme.dart';

class ContextMenuItem {
  final String label;
  final IconData? icon;
  final Color? color;
  final VoidCallback onTap;

  const ContextMenuItem({
    required this.label,
    this.icon,
    this.color,
    required this.onTap,
  });
}

/// Shows a TaskEra-styled context menu anchored to touch coordinates.
/// Call via [showTaskEraContextMenu]; do not push as a route.
Future<void> showTaskEraContextMenu({
  required BuildContext context,
  required Offset position,
  required List<ContextMenuItem> items,
}) {
  return _TaskEraContextMenuController.show(
    context: context,
    position: position,
    items: items,
  );
}

class _TaskEraContextMenuController {
  static Future<void> show({
    required BuildContext context,
    required Offset position,
    required List<ContextMenuItem> items,
  }) async {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;
    bool allowDismiss = false;

    entry = OverlayEntry(
      builder: (_) => _ContextMenuOverlay(
        position: position,
        items: items,
        onDismiss: () {
          if (allowDismiss) entry.remove();
        },
      ),
    );

    overlay.insert(entry);

    // Outside-dismiss listener enabled after 450 ms lpBlock delay
    Timer(const Duration(milliseconds: 450), () => allowDismiss = true);
  }
}

class _ContextMenuOverlay extends StatefulWidget {
  final Offset position;
  final List<ContextMenuItem> items;
  final VoidCallback onDismiss;

  const _ContextMenuOverlay({
    required this.position,
    required this.items,
    required this.onDismiss,
  });

  @override
  State<_ContextMenuOverlay> createState() => _ContextMenuOverlayState();
}

class _ContextMenuOverlayState extends State<_ContextMenuOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      duration: const Duration(milliseconds: 180),
      vsync: this,
    );
    _opacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.04), // 8 logical px ÷ ~200 px menu height ≈ 0.04
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = TaskEraTheme.of(context).colors;
    return Stack(
      children: [
        // Dismiss tap area
        Positioned.fill(
          child: GestureDetector(
            onTap: widget.onDismiss,
            behavior: HitTestBehavior.opaque,
            child: const ColoredBox(color: Colors.transparent),
          ),
        ),
        Positioned(
          left: widget.position.dx,
          top: widget.position.dy,
          child: FadeTransition(
            opacity: _opacity,
            child: SlideTransition(
              position: _slide,
              child: Container(
                constraints: const BoxConstraints(minWidth: 160),
                decoration: BoxDecoration(
                  color: colors.surf2,
                  borderRadius: TaskEraShape.card,
                  border: Border.all(width: 0.5, color: colors.bdr),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x33000000),
                      blurRadius: 16,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: TaskEraShape.card,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (int i = 0; i < widget.items.length; i++) ...[
                        if (i > 0)
                          Divider(height: 0, thickness: 0.5, color: colors.bdr),
                        _MenuItemTile(
                          item: widget.items[i],
                          onTap: () {
                            widget.onDismiss();
                            widget.items[i].onTap();
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MenuItemTile extends StatelessWidget {
  final ContextMenuItem item;
  final VoidCallback onTap;

  const _MenuItemTile({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = TaskEraTheme.of(context).colors;
    final itemColor = item.color ?? colors.ink;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (item.icon != null) ...[
              Icon(item.icon, size: 16, color: itemColor),
              const SizedBox(width: 8),
            ],
            Text(
              item.label,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                color: itemColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
