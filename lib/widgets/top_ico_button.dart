import 'package:flutter/material.dart';

// 38×38 transparent tap area for top-bar action icons.
class TopIcoButton extends StatelessWidget {
  final Widget icon;
  final VoidCallback? onTap;

  const TopIcoButton({super.key, required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 38,
        height: 38,
        child: Center(child: icon),
      ),
    );
  }
}
