# iOS "Do The Next" widget — Xcode setup (Phase 4)

The Dart side (`lib/services/dtn_widget_bridge.dart`) already writes the current
DTN task into the shared App Group via the `home_widget` plugin. To surface it
on iOS you must add a Widget Extension target **in Xcode** (this can't be done
from the Flutter CLI / non-macOS):

1. Open `ios/Runner.xcworkspace` in Xcode.
2. **File → New → Target… → Widget Extension**. Name it **`DtnWidget`**
   (uncheck "Include Configuration Intent"). This creates a target + group.
3. Replace the generated `DtnWidget.swift` with this folder's `DtnWidget.swift`
   (or add this file to the new target and delete the generated one).
4. **App Groups** — Signing & Capabilities → + Capability → App Groups, add
   `group.com.taskera.taskera_app` to **both** the `Runner` target **and** the
   `DtnWidget` target. (Must match `_appGroupId` in `dtn_widget_bridge.dart`
   and `appGroupId` in `DtnWidget.swift`.)
5. Deep link: `Runner/Info.plist` already needs URL scheme `taskeraapp` (used by
   `widgetURL(URL(string: "taskeraapp://focus"))`) — already present for OAuth.
6. Build the `DtnWidget` scheme once, then run the app; long-press the home
   screen / lock screen to add the **Do The Next** widget.

No Dart changes are required after this — `HomeWidget.updateWidget(iOSName: 'DtnWidget')`
already targets this kind.
