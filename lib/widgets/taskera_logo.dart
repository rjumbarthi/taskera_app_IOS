import 'package:flutter/material.dart';

// TaskEra logo mark. File: assets/logo/taskera_logo.png (PNG, not SVG).
//
// Usage:
//   TaskEraLogo(size: 90)           — Quote Splash (large, centered)
//   TaskEraLogo(size: 56)           — Sign In screen
//   TaskEraLogo(size: 36)           — Profile page header
//
// If a vector version (taskera_logo.svg) is added later, swap Image.asset for
// SvgPicture.asset and remove the BoxFit constraint.
class TaskEraLogo extends StatelessWidget {
  final double size;

  const TaskEraLogo({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/logo/taskera_logo.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
    );
  }
}
