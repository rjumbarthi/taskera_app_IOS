import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../settings/taskera_settings.dart';
import 'wallpaper_background.dart';

/// Opaque themed backdrop for bottom sheets / modals. Renders the app wallpaper
/// (+ the active theme's brightness dim) behind [child], clipped to [borderRadius],
/// so the parent screen never shows through the sheet's translucent surface — the
/// sheet reads as a glass panel over the wallpaper, exactly like a full screen.
///
/// Wrap the sheet's content (which keeps its own translucent `surf` + border):
/// ```dart
/// Container(
///   margin: ...,
///   child: TaskEraSheetSurface(
///     borderRadius: BorderRadius.circular(22),
///     child: Container(decoration: BoxDecoration(color: colors.surf, ...), child: ...),
///   ),
/// )
/// ```
class TaskEraSheetSurface extends ConsumerWidget {
  final Widget child;
  final BorderRadius borderRadius;
  const TaskEraSheetSurface({
    super.key,
    required this.child,
    this.borderRadius = const BorderRadius.vertical(top: Radius.circular(20)),
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(taskeraSettingsProvider);
    return ClipRRect(
      borderRadius: borderRadius,
      child: Stack(
        children: [
          Positioned.fill(
            child: WallpaperBackground(
              wallpaper: settings.wallpaper,
              dim: settings.wallpaperDim,
            ),
          ),
          child,
        ],
      ),
    );
  }
}
