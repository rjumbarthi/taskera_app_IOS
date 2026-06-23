import 'package:flutter/material.dart';
import '../theme/kaal_theme.dart';

enum KaalWallpaper {
  none,
  aurora3,
  beach,
  nightSky,
  ocean,
  tree,
}

class WallpaperBackground extends StatelessWidget {
  final KaalWallpaper wallpaper;
  final double? dim;

  const WallpaperBackground({
    super.key,
    this.wallpaper = KaalWallpaper.ocean,
    this.dim,
  });

  String? get _assetPath => switch (wallpaper) {
        KaalWallpaper.none     => null,
        KaalWallpaper.aurora3  => 'assets/wallpapers/AURORA3 - Copy.JPG',
        KaalWallpaper.beach    => 'assets/wallpapers/BEACH.JPG',
        KaalWallpaper.nightSky => 'assets/wallpapers/NightSky.JPG',
        KaalWallpaper.ocean    => 'assets/wallpapers/OCEAN.jpg',
        KaalWallpaper.tree     => 'assets/wallpapers/tree.jpg',
      };

  @override
  Widget build(BuildContext context) {
    final theme = KaalTheme.of(context);
    final path = _assetPath;
    if (path == null) {
      return ColoredBox(color: theme.colors.appBg);
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          path,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (context, error, _) =>
              ColoredBox(color: theme.colors.appBg),
        ),
        _scrim(theme.mode),
      ],
    );
  }

  // The wallpaper is shared across all three themes; only the scrim differs:
  //   glass → medium dark gradient (balanced depth)
  //   dark  → strong dark gradient (moody; wallpaper barely visible)
  //   light → soft white wash      (airy, bright, hint of wallpaper colour)
  Widget _scrim(KaalThemeMode mode) {
    // Caller-driven dim (blur / screen-enter overlays): wash white on light,
    // black everywhere else.
    if (dim != null) {
      final op = (0.15 + dim! * 0.80).clamp(0.0, 1.0);
      final base = mode == KaalThemeMode.light
          ? Color.fromRGBO(255, 255, 255, op)
          : Color.fromRGBO(0, 0, 0, op);
      return DecoratedBox(decoration: BoxDecoration(color: base));
    }

    final stops = switch (mode) {
      KaalThemeMode.glass => const [Color(0xCC000000), Color(0xE6000000)],
      KaalThemeMode.dark  => const [Color(0xDE000000), Color(0xF2000000)],
      KaalThemeMode.light => const [Color(0xCCFFFFFF), Color(0xEDFFFFFF)],
    };
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: stops,
        ),
      ),
    );
  }
}
