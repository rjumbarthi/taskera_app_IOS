import 'dart:async';
import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../util/platform_layout.dart';

// ── Public API ────────────────────────────────────────────────────────────────

/// A single action item shown in the long-press context menu.
class KaalMenuAction {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool destructive;

  const KaalMenuAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.destructive = false,
  });
}

/// Wraps [child] with:
/// - 480ms long press → glass context menu (bottom sheet)
/// - Right-click on desktop → same menu, immediately
/// - Scale-down to 0.97 on press; restores on release or menu show
///
/// Example:
/// ```dart
/// KaalLongPressMenu(
///   actions: [
///     KaalMenuAction(icon: Icons.edit, label: 'Edit', onTap: () { ... }),
///     KaalMenuAction(icon: Icons.delete_rounded, label: 'Delete',
///                    onTap: () { ... }, destructive: true),
///   ],
///   child: MyRow(),
/// )
/// ```
class KaalLongPressMenu extends StatefulWidget {
  final Widget child;
  final List<KaalMenuAction> actions;
  final String? menuTitle;
  final VoidCallback? onTap;
  final double scaleDown;

  const KaalLongPressMenu({
    super.key,
    required this.child,
    required this.actions,
    this.menuTitle,
    this.onTap,
    this.scaleDown = 0.97,
  });

  @override
  State<KaalLongPressMenu> createState() => _KaalLongPressMenuState();
}

class _KaalLongPressMenuState extends State<KaalLongPressMenu> {
  bool _pressed = false;
  Timer? _timer;

  void _onDown(BuildContext context) {
    _setPressed(true);
    _timer?.cancel();
    _timer = Timer(const Duration(milliseconds: 480), () => _openMenu(context));
  }

  void _onUp() {
    _timer?.cancel();
    _setPressed(false);
  }

  void _onCancel() {
    _timer?.cancel();
    _setPressed(false);
  }

  void _setPressed(bool v) {
    if (_pressed != v && mounted) setState(() => _pressed = v);
  }

  Future<void> _openMenu(BuildContext context) async {
    _timer?.cancel();
    _setPressed(false);
    HapticFeedback.mediumImpact();
    await showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      // Size to the menu's content. Without this the sheet is capped at ~half the
      // screen, so taller menus overflow — overlapping text and spilling the
      // content past the sheet over the screen below.
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: const Color(0x8C000000),
      builder: (_) => _MenuSheet(
        title: widget.menuTitle,
        actions: widget.actions,
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget child = AnimatedScale(
      scale: _pressed ? widget.scaleDown : 1.0,
      duration: _pressed
          ? const Duration(milliseconds: 80)
          : const Duration(milliseconds: 140),
      curve: Curves.easeOut,
      child: widget.child,
    );

    // Desktop: right-click triggers menu immediately
    if (isDesktop) {
      child = Listener(
        onPointerDown: (event) {
          if (event.buttons == kSecondaryMouseButton) {
            _openMenu(context);
          }
        },
        child: child,
      );
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown:   (_) => _onDown(context),
      onTapUp:     (_) => _onUp(),
      onTapCancel: _onCancel,
      onTap:       widget.onTap,
      child: child,
    );
  }
}

// ── Bottom-sheet menu ─────────────────────────────────────────────────────────

class _MenuSheet extends StatelessWidget {
  final String? title;
  final List<KaalMenuAction> actions;
  const _MenuSheet({this.title, required this.actions});

  @override
  Widget build(BuildContext context) {
    final safeBot = MediaQuery.of(context).padding.bottom;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xD9000000),
            borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
            border: Border(
              top:   BorderSide(width: 0.5, color: Color(0x33FFFFFF)),
              left:  BorderSide(width: 0.5, color: Color(0x33FFFFFF)),
              right: BorderSide(width: 0.5, color: Color(0x33FFFFFF)),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag indicator
              Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 6),
                child: Container(
                  width: 36, height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0x40FFFFFF),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Optional title
              if (title != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 2, 20, 10),
                  child: Text(title!,
                      style: const TextStyle(
                        fontFamily: 'Inter', fontSize: 11,
                        color: Color(0x80FFFFFF), height: 1,
                      )),
                ),

              // Action rows
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0x1AFFFFFF),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Column(
                  children: [
                    for (int i = 0; i < actions.length; i++) ...[
                      if (i > 0)
                        const Divider(height: 0, thickness: 0.5,
                            indent: 48, color: Color(0x1AFFFFFF)),
                      _ActionRow(action: actions[i]),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Cancel
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  height: 52,
                  decoration: BoxDecoration(
                    color: const Color(0x1AFFFFFF),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  alignment: Alignment.center,
                  child: const Text('Cancel',
                      style: TextStyle(
                        fontFamily: 'Inter', fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white, height: 1,
                      )),
                ),
              ),

              SizedBox(height: safeBot + 12),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionRow extends StatefulWidget {
  final KaalMenuAction action;
  const _ActionRow({required this.action});

  @override
  State<_ActionRow> createState() => _ActionRowState();
}

class _ActionRowState extends State<_ActionRow> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final fg = widget.action.destructive
        ? const Color(0xFFFF453A)
        : Colors.white;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown:   (_) => setState(() => _pressed = true),
      onTapUp:     (_) => setState(() => _pressed = false),
      onTapCancel: ()  => setState(() => _pressed = false),
      onTap: () {
        Navigator.of(context).pop();
        widget.action.onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: _pressed ? const Color(0x1AFFFFFF) : Colors.transparent,
        ),
        child: Row(children: [
          Icon(widget.action.icon, color: fg.withAlpha(204), size: 20),
          const SizedBox(width: 14),
          Expanded(
            child: Text(widget.action.label,
                style: TextStyle(
                  fontFamily: 'Inter', fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: fg, height: 1,
                )),
          ),
        ]),
      ),
    );
  }
}
