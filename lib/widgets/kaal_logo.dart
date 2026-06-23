import 'package:flutter/material.dart';

// Kaal logo mark. File: assets/logo/kaal_logo.png (PNG, not SVG).
//
// Usage:
//   KaalLogo(size: 90)           — Quote Splash (large, centered)
//   KaalLogo(size: 56)           — Sign In screen
//   KaalLogo(size: 36)           — Profile page header
//
// If a vector version (kaal_logo.svg) is added later, swap Image.asset for
// SvgPicture.asset and remove the BoxFit constraint.
class KaalLogo extends StatelessWidget {
  final double size;

  const KaalLogo({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/logo/kaal_logo.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
    );
  }
}
