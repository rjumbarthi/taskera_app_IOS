import 'package:flutter/material.dart';

class KaalColors {
  final Color bg;
  final Color appBg;
  final Color surf;
  final Color surf2;
  final Color surf3;
  final Color ink;
  final Color ink2;
  final Color ink3;
  final Color ink4;
  final Color bdr;
  final Color bdr2;

  // Theme-aware semantic colors. On light theme these are darkened so green
  // values and muted captions stay legible on white surfaces.
  final Color successFg;   // positive/green values & icons (text-safe)
  final Color labelMuted;  // small muted captions/labels (text-safe)

  // Dynamic accent — defaults to blue; overridden via KaalThemeData.fromMode
  final Color accent;
  final Color accent2;
  final Color accentBg;

  // Static accent/semantic — used as fallbacks and in const contexts
  static const Color acc     = Color(0xFF0A84FF);
  static const Color acc2    = Color(0xFF409CFF);
  static const Color accBg   = Color(0x1F0A84FF);
  static const Color q1      = Color(0xFFF25022);
  static const Color q2      = Color(0xFF7FBA00);
  static const Color q3      = Color(0xFF00A4EF);
  static const Color q4      = Color(0xFFFFB900);
  static const Color warn    = Color(0xFFFF6B6B);
  static const Color success = Color(0xFF9FCD44);

  const KaalColors({
    required this.bg,
    required this.appBg,
    required this.surf,
    required this.surf2,
    required this.surf3,
    required this.ink,
    required this.ink2,
    required this.ink3,
    required this.ink4,
    required this.bdr,
    required this.bdr2,
    this.successFg  = const Color(0xFF9FCD44),
    this.labelMuted = const Color(0x80FFFFFF),
    this.accent     = const Color(0xFF0A84FF),
    this.accent2    = const Color(0xFF409CFF),
    this.accentBg   = const Color(0x1F0A84FF),
  });

  // Glass theme — wallpaper shows through translucent surfaces
  static const glass = KaalColors(
    bg:    Colors.transparent,
    appBg: Color(0xFF0D0D14),
    surf:  Color(0x17FFFFFF), // rgba(255,255,255,.09)
    surf2: Color(0x1FFFFFFF), // rgba(255,255,255,.12)
    surf3: Color(0x2EFFFFFF), // rgba(255,255,255,.18)
    ink:   Color(0xFFF2F2F7),
    ink2:  Color(0xFFC8C8D0),
    ink3:  Color(0xFF7A7A86),
    ink4:  Color(0xFF4A4A56),
    bdr:   Color(0x24FFFFFF), // rgba(255,255,255,.14)
    bdr2:  Color(0x38FFFFFF), // rgba(255,255,255,.22)
  );

  // Dark theme — wallpaper shows through a strong dark scrim. Surfaces are
  // glass-like (translucent white) so the wallpaper colour bleeds through cards,
  // giving the same depth as glass but a darker, moodier mood.
  static const dark = KaalColors(
    bg:    Colors.transparent, // wallpaper + dark scrim shows through
    appBg: Color(0xFF0A0A0C),  // fallback when wallpaper is off
    surf:  Color(0x17FFFFFF), // rgba(255,255,255,.09)
    surf2: Color(0x1FFFFFFF), // rgba(255,255,255,.12)
    surf3: Color(0x2EFFFFFF), // rgba(255,255,255,.18)
    ink:   Color(0xFFF2F2F7),
    ink2:  Color(0xFFC8C8D0),
    ink3:  Color(0xFF8A8A94),
    ink4:  Color(0xFF55555E),
    bdr:   Color(0x24FFFFFF), // rgba(255,255,255,.14)
    bdr2:  Color(0x38FFFFFF), // rgba(255,255,255,.22)
  );

  // Light theme — wallpaper shows through a soft white wash. Surfaces are
  // translucent white (bright but layered) with dark ink, so cards stay airy
  // and legible while picking up a hint of wallpaper colour, matching glass depth.
  static const light = KaalColors(
    bg:    Colors.transparent, // wallpaper + white wash shows through
    appBg: Color(0xFFF2F2F7),  // fallback when wallpaper is off
    surf:  Color(0xE6FFFFFF), // rgba(255,255,255,.90)
    surf2: Color(0xCCFFFFFF), // rgba(255,255,255,.80)
    surf3: Color(0xB8FFFFFF), // rgba(255,255,255,.72)
    ink:   Color(0xFF111113),
    ink2:  Color(0xFF2C2C2E),
    ink3:  Color(0xFF5A5A5E),
    ink4:  Color(0xFF8A8A90),
    bdr:   Color(0x24000000), // rgba(0,0,0,.14)
    bdr2:  Color(0x3B000000), // rgba(0,0,0,.23)
    // Darkened so they remain legible on the bright translucent surfaces.
    successFg:  Color(0xFF3F7A00), // readable green on white
    labelMuted: Color(0xFF5C5C61), // solid grey (not translucent white)
  );
}
