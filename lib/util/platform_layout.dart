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
