import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../settings/kaal_settings.dart';
import '../theme/kaal_colors.dart';
import '../theme/kaal_theme.dart';
import '../util/platform_layout.dart';
import 'kaal_top_bar.dart';
import 'wallpaper_background.dart';

// Root chrome for every full-tab screen.
// Stack layout: wallpaper (full-bleed) → Scaffold → top bar + body.
// Bottom nav is rendered globally by _NavShell in app_router.dart.
// Desktop: content centered at maxWidth 480; wallpaper bleeds left/right.
// Mobile:  content fills full screen width; no centering constraint.
class AppShell extends ConsumerWidget {
  final String title;
  final String? subtitle;
  final List<Widget> actions;
  final Widget body;

  const AppShell({
    super.key,
    required this.title,
    required this.body,
    this.subtitle,
    this.actions = const [],
  });

  // Floating bottom-nav content height (must match _NavShell._kNavContentHeight).
  static const _kNavContentHeight = 50.0;

  Widget _contentColumn(BuildContext context, KaalColors colors) {
    // Reserve the nav's full footprint (system gesture inset + nav height) below
    // the body so no screen's content or buttons sit under the floating nav.
    // removeBottom stops inner screens from *also* adding the system inset as
    // scroll padding — that would double the gap. The wallpaper still renders
    // full-bleed behind the nav (it's a separate Positioned.fill layer).
    final navReserve = MediaQuery.viewPaddingOf(context).bottom + _kNavContentHeight;
    final column = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        KaalTopBar(title: title, subtitle: subtitle, actions: actions),
        Expanded(
          child: ColoredBox(
            color: colors.bg,
            child: Padding(
              padding: EdgeInsets.only(bottom: navReserve),
              child: MediaQuery.removePadding(
                context: context,
                removeBottom: true,
                child: body,
              ),
            ),
          ),
        ),
      ],
    );
    if (isDesktop) {
      return Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: column,
        ),
      );
    }
    return column;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors   = KaalTheme.of(context).colors;
    final settings  = ref.watch(kaalSettingsProvider);
    final wallpaper = settings.wallpaper;
    final dim       = settings.wallpaperDim;

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
    ));

    return Stack(
      children: [
        Positioned.fill(child: WallpaperBackground(wallpaper: wallpaper, dim: dim)),
        Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            top: false,
            bottom: false,
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxHeight < 80) return const SizedBox.expand();
                return _contentColumn(context, colors);
              },
            ),
          ),
        ),
      ],
    );
  }
}
