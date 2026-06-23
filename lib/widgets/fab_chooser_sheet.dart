import 'package:flutter/material.dart';

/// FAB chooser sheet — solid dim scrim (rgba 0,0,0,0.55), no blur.
Future<T?> showFabChooserSheet<T>({
  required BuildContext context,
  required Widget child,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: const Color(0x8C000000),
    builder: (ctx) => child,
  );
}
