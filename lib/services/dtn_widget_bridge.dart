import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';

import '../util/platform_layout.dart';

/// Pushes the current "Do The Next" task into the native home-screen widget
/// (Android AppWidget / iOS WidgetKit) via the home_widget shared store.
/// No-op on desktop/web where the plugin isn't available.
class DtnWidgetBridge {
  DtnWidgetBridge._();

  static const _appGroupId = 'group.com.port443.taskera'; // iOS App Group

  static Future<void> update({
    required String title,
    required String meta,
    String? focusToday,
  }) async {
    if (kIsWeb || isDesktop) return;
    try {
      await HomeWidget.setAppGroupId(_appGroupId);
      await HomeWidget.saveWidgetData<String>('dtn_title', title);
      await HomeWidget.saveWidgetData<String>('dtn_meta', meta);
      if (focusToday != null) {
        await HomeWidget.saveWidgetData<String>('dtn_focus_today', focusToday);
      }
      await HomeWidget.updateWidget(
        androidName: 'DtnWidgetProvider',
        iOSName: 'DtnWidget',
      );
    } catch (_) {
      // Widget bridge is best-effort; never break the app over it.
    }
  }

  static Future<void> clear() =>
      update(title: 'Nothing queued', meta: 'Do The Next');
}
