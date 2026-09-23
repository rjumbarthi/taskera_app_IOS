import 'package:flutter/material.dart';
import '../theme/taskera_theme.dart';

enum TaskEraWallpaper {
  none,
  aurora3,
  beach,
  nightSky,
  ocean,
  tree,
}

class WallpaperBackground extends StatelessWidget {
  final TaskEraWallpaper wallpaper;
  final double? dim;

  const WallpaperBackground({
    super.key,
    this.wallpaper = TaskEraWallpaper.ocean,
    this.dim,
  });

  String? get _assetPath => switch (wallpaper) {
        TaskEraWallpaper.none     => null,
        TaskEraWallpaper.aurora3  => 'assets/wallpapers/AURORA3 - Copy.JPG',
        TaskEraWallpaper.beach    => 'assets/wallpapers/BEACH.JPG',
        TaskEraWallpaper.nightSky => 'assets/wallpapers/NightSky.JPG',
        TaskEraWallpaper.ocean    => 'assets/wallpapers/OCEAN.jpg',
        TaskEraWallpaper.tree     => 'assets/wallpapers/tree.jpg',
      };

  @override
  Widget build(BuildContext context) {
    final theme = TaskEraTheme.of(context);
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
  Widget _scrim(TaskEraThemeMode mode) {
    // Caller-driven dim (blur / screen-enter overlays): wash white on light,
    // black everywhere else.
    if (dim != null) {
      final op = (0.15 + dim! * 0.80).clamp(0.0, 1.0);
      final base = mode == TaskEraThemeMode.light
          ? Color.fromRGBO(255, 255, 255, op)
          : Color.fromRGBO(0, 0, 0, op);
      return DecoratedBox(decoration: BoxDecoration(color: base));
    }

    final stops = switch (mode) {
      TaskEraThemeMode.glass => const [Color(0xCC000000), Color(0xE6000000)],
      TaskEraThemeMode.dark  => const [Color(0xDE000000), Color(0xF2000000)],
      TaskEraThemeMode.light => const [Color(0xCCFFFFFF), Color(0xEDFFFFFF)],
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
