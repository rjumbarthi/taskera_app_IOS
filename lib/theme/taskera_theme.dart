import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'taskera_colors.dart';
import 'taskera_motion.dart';
import 'taskera_shape.dart';
import 'taskera_type.dart';

enum TaskEraThemeMode { glass, dark, light }

final taskeraThemeModeProvider = StateProvider<TaskEraThemeMode>(
  (ref) => TaskEraThemeMode.glass,
);

class TaskEraThemeData {
  final TaskEraColors colors;
  final TaskEraType type;
  final TaskEraShape shape;
  final TaskEraMotion motion;
  final TaskEraThemeMode mode;
  final String fontFamily;
  final double fontSizeScale;

  const TaskEraThemeData({
    required this.colors,
    required this.type,
    required this.shape,
    required this.motion,
    required this.mode,
    this.fontFamily    = 'Inter',
    this.fontSizeScale = 1.0,
  });

  factory TaskEraThemeData.fromMode(
    TaskEraThemeMode mode, {
    Color  accent        = const Color(0xFF0A84FF),
    Color  accent2       = const Color(0xFF409CFF),
    Color  accentBg      = const Color(0x1F0A84FF),
    String fontFamily    = 'Inter',
    double fontSizeScale = 1.0,
  }) {
    final base = switch (mode) {
      TaskEraThemeMode.glass => TaskEraColors.glass,
      TaskEraThemeMode.dark  => TaskEraColors.dark,
      TaskEraThemeMode.light => TaskEraColors.light,
    };
    final colors = TaskEraColors(
      bg: base.bg, appBg: base.appBg,
      surf: base.surf, surf3: base.surf3,
      ink: base.ink, ink2: base.ink2, ink3: base.ink3, ink4: base.ink4,
      bdr: base.bdr, bdr2: base.bdr2,
      successFg: base.successFg, labelMuted: base.labelMuted,
      accent: accent, accent2: accent2, accentBg: accentBg,
    );
    return TaskEraThemeData(
      colors: colors,
      type:   const TaskEraType(),
      shape:  const TaskEraShape(),
      motion: const TaskEraMotion(),
      mode:   mode,
      fontFamily:    fontFamily,
      fontSizeScale: fontSizeScale,
    );
  }
}

class TaskEraTheme extends InheritedWidget {
  final TaskEraThemeData data;

  const TaskEraTheme({
    super.key,
    required this.data,
    required super.child,
  });

  static TaskEraThemeData of(BuildContext context) {
    final widget = context.dependOnInheritedWidgetOfExactType<TaskEraTheme>();
    assert(widget != null, 'No TaskEraTheme found in widget tree');
    return widget!.data;
  }

  @override
  bool updateShouldNotify(TaskEraTheme oldWidget) =>
      data.mode           != oldWidget.data.mode ||
      data.colors.accent  != oldWidget.data.colors.accent ||
      data.fontFamily     != oldWidget.data.fontFamily ||
      data.fontSizeScale  != oldWidget.data.fontSizeScale;
}
