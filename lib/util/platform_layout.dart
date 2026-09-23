import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

enum TaskEraPlatform { mobile, desktop, web }

TaskEraPlatform currentPlatform() {
  if (kIsWeb) return TaskEraPlatform.web;
  if (Platform.isAndroid || Platform.isIOS) return TaskEraPlatform.mobile;
  if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) return TaskEraPlatform.desktop;
  return TaskEraPlatform.mobile;
}

bool get isDesktop => currentPlatform() == TaskEraPlatform.desktop;
bool get isMobile  => currentPlatform() == TaskEraPlatform.mobile;
bool get isWeb     => kIsWeb;

/// True when the app should render as a centered phone-width column over the
/// wallpaper (desktop windows and web browsers) rather than edge-to-edge as on
/// a real phone. On a narrow browser the width cap is a no-op, so it stays
/// full-width on mobile-sized viewports.
bool get isCenteredLayout => isDesktop || isWeb;
