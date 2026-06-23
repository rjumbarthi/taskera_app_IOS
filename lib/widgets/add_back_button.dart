import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/kaal_theme.dart';

// 38×38 back-chevron button. Transparent bg, no border.
// SVG stroke color = ink2 by default; per-screen overrides applied by caller.
class AddBackButton extends StatelessWidget {
  final VoidCallback? onTap;
  final Color? strokeColor;

  const AddBackButton({super.key, this.onTap, this.strokeColor});

  static const _svg =
      '<svg viewBox="0 0 22 22" fill="none" xmlns="http://www.w3.org/2000/svg">'
      '<path d="M15 18l-6-6 6-6" stroke="white" stroke-width="2" stroke-linecap="round"/>'
      '</svg>';

  @override
  Widget build(BuildContext context) {
    final colors = KaalTheme.of(context).colors;
    final color = strokeColor ?? colors.ink2;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 38,
        height: 38,
        child: Center(
          child: SvgPicture.string(
            _svg,
            width: 18,
            height: 18,
            colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
          ),
        ),
      ),
    );
  }
}
