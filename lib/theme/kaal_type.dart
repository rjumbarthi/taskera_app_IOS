import 'package:flutter/material.dart';

class KaalType {
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

  // Top bar title: Fraunces 600 23sp, ls -0.5
  static const TextStyle topBarTitle = TextStyle(
    fontFamily: 'Fraunces',
    fontVariations: [FontVariation('wght', 600)],
    fontSize: x2l,
    letterSpacing: -0.5,
    height: 1,
  );

  // Top bar subtitle: Inter 400 11sp
  static const TextStyle topBarSubtitle = TextStyle(
    fontFamily: 'Inter',
    fontWeight: FontWeight.w400,
    fontSize: sm,
    letterSpacing: 0.2,
    fontFeatures: _interFeatures,
  );

  // Display headings (Fraunces)
  static const TextStyle display = TextStyle(
    fontFamily: 'Fraunces',
    fontVariations: [FontVariation('wght', 600)],
    fontSize: hero,
    height: 1.1,
  );

  // Settings group title: Inter 600 13sp
  static const TextStyle sgrpTitle = TextStyle(
    fontFamily: 'Inter',
    fontWeight: FontWeight.w600,
    fontSize: md,
    fontFeatures: _interFeatures,
  );

  // Body text: Inter 400 13sp
  static const TextStyle body = TextStyle(
    fontFamily: 'Inter',
    fontWeight: FontWeight.w400,
    fontSize: bodySize,
    height: 1.3,
    fontFeatures: _interFeatures,
  );

  // Body medium weight
  static const TextStyle bodyMedium = TextStyle(
    fontFamily: 'Inter',
    fontWeight: FontWeight.w500,
    fontSize: bodySize,
    height: 1.3,
    fontFeatures: _interFeatures,
  );

  // Section label: Inter 600 15sp
  static const TextStyle section = TextStyle(
    fontFamily: 'Inter',
    fontWeight: FontWeight.w600,
    fontSize: sectionSize,
    fontFeatures: _interFeatures,
  );

  // Row label: Inter 400 11sp
  static const TextStyle label = TextStyle(
    fontFamily: 'Inter',
    fontWeight: FontWeight.w400,
    fontSize: labelSize,
    fontFeatures: _interFeatures,
  );

  // Tag / pill: Inter 600 9sp ls 0.2
  static const TextStyle tag = TextStyle(
    fontFamily: 'Inter',
    fontWeight: FontWeight.w600,
    fontSize: tagSize,
    letterSpacing: 0.2,
    fontFeatures: _interFeatures,
  );

  // Large numbers (stat cards): Fraunces 700 23sp
  static const TextStyle number = TextStyle(
    fontFamily: 'Fraunces',
    fontVariations: [FontVariation('wght', 700)],
    fontSize: numberSize,
    height: 1,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  // Quadrant count badge: Fraunces 700 19sp
  static const TextStyle quadrantCount = TextStyle(
    fontFamily: 'Fraunces',
    fontVariations: [FontVariation('wght', 700)],
    fontSize: xl,
    height: 1,
  );

  // Pomodoro timer: Fraunces 750 46sp tabular
  static const TextStyle pomodoroTimer = TextStyle(
    fontFamily: 'Fraunces',
    fontVariations: [FontVariation('wght', 750)],
    fontSize: 46,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  const KaalType();
}
