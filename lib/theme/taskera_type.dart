import 'package:flutter/material.dart';

class TaskEraType {
  // Type scale (CSS px = logical px, 1:1)
  static const double xs   = 9;
  static const double sm   = 11;
  static const double md   = 13;
  static const double lg   = 15;
  static const double xl   = 19;
  static const double x2l  = 23;
  static const double hero = 30;

  // Semantic aliases
  static const double titleSize   = xl;   // 19
  static const double sectionSize = lg;   // 15
  static const double bodySize    = md;   // 13
  static const double labelSize   = sm;   // 11
  static const double tagSize     = xs;   // 9
  static const double numberSize  = x2l; // 23

  static const _interFeatures = <FontFeature>[
    FontFeature('cv11'),
    FontFeature('ss01'),
    FontFeature('ss03'),
    FontFeature('cv02'),
    FontFeature('cv03'),
    FontFeature('cv04'),
    FontFeature('liga'),
    FontFeature('calt'),
  ];

  // General UI text font (Settings → Display → Typography → Font style) and
  // the dedicated font for numeral/stat displays (Settings → Typography →
  // Number style) — both resolved once per theme build in TaskEraThemeData.fromMode.
  final String fontFamily;
  final String numberFontFamily;

  const TaskEraType({this.fontFamily = 'Inter', this.numberFontFamily = 'Fraunces'});

  // Top bar title: 600 23sp, ls -0.5
  TextStyle get topBarTitle => TextStyle(
    fontFamily: fontFamily,
    fontVariations: const [FontVariation('wght', 600)],
    fontSize: x2l,
    letterSpacing: -0.5,
    height: 1,
  );

  // Top bar subtitle: 400 11sp
  TextStyle get topBarSubtitle => TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w400,
    fontSize: sm,
    letterSpacing: 0.2,
    fontFeatures: _interFeatures,
  );

  // Display headings
  TextStyle get display => TextStyle(
    fontFamily: fontFamily,
    fontVariations: const [FontVariation('wght', 600)],
    fontSize: hero,
    height: 1.1,
  );

  // Settings group title: 600 13sp
  TextStyle get sgrpTitle => TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w600,
    fontSize: md,
    fontFeatures: _interFeatures,
  );

  // Body text: 400 13sp
  TextStyle get body => TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w400,
    fontSize: bodySize,
    height: 1.3,
    fontFeatures: _interFeatures,
  );

  // Body medium weight
  TextStyle get bodyMedium => TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w500,
    fontSize: bodySize,
    height: 1.3,
    fontFeatures: _interFeatures,
  );

  // Section label: 600 15sp
  TextStyle get section => TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w600,
    fontSize: sectionSize,
    fontFeatures: _interFeatures,
  );

  // Row label: 400 11sp
  TextStyle get label => TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w400,
    fontSize: labelSize,
    fontFeatures: _interFeatures,
  );

  // Tag / pill: 600 9sp ls 0.2
  TextStyle get tag => TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w600,
    fontSize: tagSize,
    letterSpacing: 0.2,
    fontFeatures: _interFeatures,
  );

  // Large numbers (stat cards): 700 23sp — uses the numbers font.
  TextStyle get number => TextStyle(
    fontFamily: numberFontFamily,
    fontVariations: const [FontVariation('wght', 700)],
    fontSize: numberSize,
    height: 1,
    fontFeatures: const [FontFeature.tabularFigures()],
  );

  // Quadrant count badge: 700 19sp — uses the numbers font.
  TextStyle get quadrantCount => TextStyle(
    fontFamily: numberFontFamily,
    fontVariations: const [FontVariation('wght', 700)],
    fontSize: xl,
    height: 1,
  );

  // Pomodoro timer: 750 46sp tabular — uses the numbers font.
  TextStyle get pomodoroTimer => TextStyle(
    fontFamily: numberFontFamily,
    fontVariations: const [FontVariation('wght', 750)],
    fontSize: 46,
    fontFeatures: const [FontFeature.tabularFigures()],
  );
}
