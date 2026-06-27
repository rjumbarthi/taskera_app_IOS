import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'kaal_colors.dart';
import 'kaal_motion.dart';
import 'kaal_shape.dart';
import 'kaal_type.dart';

enum KaalThemeMode { glass, dark, light }

final kaalThemeModeProvider = StateProvider<KaalThemeMode>(
  (ref) => KaalThemeMode.glass,
);

class KaalThemeData {
  final KaalColors colors;
  final KaalType type;
  final KaalShape shape;
  final KaalMotion motion;
  final KaalThemeMode mode;
  final String fontFamily;
  final double fontSizeScale;

  const KaalThemeData({
    required this.colors,
    required this.type,
    required this.shape,
    required this.motion,
    required this.mode,
    this.fontFamily    = 'Inter',
    this.fontSizeScale = 1.0,
  });

  factory KaalThemeData.fromMode(
    KaalThemeMode mode, {
    Color  accent        = const Color(0xFF0A84FF),
    Color  accent2       = const Color(0xFF409CFF),
    Color  accentBg      = const Color(0x1F0A84FF),
    String fontFamily    = 'Inter',
    double fontSizeScale = 1.0,
  }) {
    final base = switch (mode) {
      KaalThemeMode.glass => KaalColors.glass,
      KaalThemeMode.dark  => KaalColors.dark,
      KaalThemeMode.light => KaalColors.light,
    };
    final colors = KaalColors(
      bg: base.bg, appBg: base.appBg,
      surf: base.surf, surf3: base.surf3,
      ink: base.ink, ink2: base.ink2, ink3: base.ink3, ink4: base.ink4,
      bdr: base.bdr, bdr2: base.bdr2,
      successFg: base.successFg, labelMuted: base.labelMuted,
      accent: accent, accent2: accent2, accentBg: accentBg,
    );
    return KaalThemeData(
      colors: colors,
      type:   const KaalType(),
      shape:  const KaalShape(),
      motion: const KaalMotion(),
      mode:   mode,
      fontFamily:    fontFamily,
      fontSizeScale: fontSizeScale,
    );
  }
}

class KaalTheme extends InheritedWidget {
  final KaalThemeData data;

  const KaalTheme({
    super.key,
    required this.data,
    required super.child,
  });

  static KaalThemeData of(BuildContext context) {
    final widget = context.dependOnInheritedWidgetOfExactType<KaalTheme>();
    assert(widget != null, 'No KaalTheme found in widget tree');
    return widget!.data;
  }

  @override
  bool updateShouldNotify(KaalTheme oldWidget) =>
      data.mode           != oldWidget.data.mode ||
      data.colors.accent  != oldWidget.data.colors.accent ||
      data.fontFamily     != oldWidget.data.fontFamily ||
      data.fontSizeScale  != oldWidget.data.fontSizeScale;
}
