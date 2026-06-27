import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

enum KaalPlatform { mobile, desktop, web }

KaalPlatform currentPlatform() {
  if (kIsWeb) return KaalPlatform.web;
  if (Platform.isAndroid || Platform.isIOS) return KaalPlatform.mobile;
  if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) return KaalPlatform.desktop;
  return KaalPlatform.mobile;
}

bool get isDesktop => currentPlatform() == KaalPlatform.desktop;
bool get isMobile  => currentPlatform() == KaalPlatform.mobile;
bool get isWeb     => kIsWeb;

/// True when the app should render as a centered phone-width column over the
/// wallpaper (desktop windows and web browsers) rather than edge-to-edge as on
/// a real phone. On a narrow browser the width cap is a no-op, so it stays
/// full-width on mobile-sized viewports.
bool get isCenteredLayout => isDesktop || isWeb;
