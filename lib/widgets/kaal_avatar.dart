import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../data/providers/auth_provider.dart';

// Shared avatar colour palette — mirrors the picker in edit_profile_screen.dart.
const kKaalAvatarColors = <Color>[
  Color(0xFF0A84FF), Color(0xFF5856D6), Color(0xFF7FBA00), Color(0xFFFF6B00),
  Color(0xFFBF5AF2), Color(0xFFFF2D55), Color(0xFF00BCD4), Color(0xFF6264A7),
];

// Logo emoji list — indexes 0-1 are asset/SVG (handled separately), 2-7 are emoji.
const kKaalLogoEmojis = <String>['', '', '🎯', '🔥', '⚡', '🚀', '✦', '🌊'];

// Stateless renderer used by both KaalAvatar (provider-driven) and the Edit
// Profile preview (local-state-driven with an XFile path).
Widget buildKaalAvatarFace({
  required String? imagePath,
  required int colorIdx,
  required int? logoIdx,
  required String initials,
  required double size,
}) {
  final bgColor = kKaalAvatarColors[colorIdx.clamp(0, kKaalAvatarColors.length - 1)];
  // dart:io File is unavailable on web (image upload is gated off there too),
  // so only attempt a file-backed avatar on native platforms.
  final hasImage = !kIsWeb && imagePath != null && File(imagePath).existsSync();

  if (hasImage) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
      clipBehavior: Clip.antiAlias,
      child: Image.file(File(imagePath), width: size, height: size, fit: BoxFit.cover),
    );
  }

  // PNG logo — fill the full circle so the circular artwork covers it completely.
  if (logoIdx == 0) {
    return Container(
      width: size, height: size,
      decoration: const BoxDecoration(shape: BoxShape.circle),
      clipBehavior: Clip.antiAlias,
      child: Image.asset('assets/logo/kaal_logo.png',
          width: size, height: size, fit: BoxFit.cover),
    );
  }

  Widget inner;
  if (logoIdx != null && logoIdx >= 1 && logoIdx < 8) {
    if (logoIdx == 1) {
      inner = SvgPicture.asset('assets/icons/focus_nav.svg',
          width: size * 0.65, height: size * 0.65,
          colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn));
    } else {
      inner = Text(kKaalLogoEmojis[logoIdx],
          style: TextStyle(fontSize: size * 0.50, height: 1));
    }
  } else {
    inner = Text(initials.isEmpty ? '?' : initials,
        style: TextStyle(fontFamily: 'Inter', fontSize: size * 0.38,
            fontWeight: FontWeight.w700, color: Colors.white, height: 1));
  }

  return Container(
    width: size, height: size,
    decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
    clipBehavior: Clip.antiAlias,
    alignment: Alignment.center,
    child: inner,
  );
}

// Drop-in avatar widget: reads all profile providers and renders the correct
// face (photo > logo > colour+initials). Used in the tab bar and profile screen.
class KaalAvatar extends ConsumerWidget {
  final double size;
  const KaalAvatar({super.key, this.size = 24});

  static String _initials(String? name) {
    if (name == null || name.isEmpty) return '?';
    final parts = name.trim().split(RegExp(r'\s+')).where((s) => s.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imagePath = ref.watch(profileImagePathProvider);
    final colorIdx  = ref.watch(profileAvatarColorProvider);
    final logoIdx   = ref.watch(profileAvatarLogoProvider);
    final name      = ref.watch(displayNameProvider);
    return buildKaalAvatarFace(
      imagePath: imagePath,
      colorIdx:  colorIdx,
      logoIdx:   logoIdx,
      initials:  _initials(name),
      size:      size,
    );
  }
}
