import 'package:flutter/material.dart';

// TaskEra logo mark. File: assets/logo/taskera_icon_glass.png (PNG, not SVG) —
// the same glossy glass four-square icon used as the app's launcher icon.
//
// Usage:
//   TaskEraLogo(size: 90)           — Quote Splash (large, centered)
//   TaskEraLogo(size: 56)           — Sign In screen
//   TaskEraLogo(size: 36)           — Profile page header
//
// If a vector version is added later, swap Image.asset for SvgPicture.asset
// and remove the BoxFit constraint.
class TaskEraLogo extends StatelessWidget {
  final double size;

  const TaskEraLogo({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/logo/taskera_icon_glass.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
    );
  }
}
