import 'package:flutter/widgets.dart';
import '../widgets/kaal_bottom_nav.dart' show KaalTab;

// Exposes the active root tab to any descendant, including sub-screens pushed
// within a branch navigator. Placed at the _RouterShell level so it sits above
// all branch navigators and is visible through overlay entries.
class CurrentTab extends InheritedWidget {
  final KaalTab tab;

  const CurrentTab({super.key, required this.tab, required super.child});

  static KaalTab of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<CurrentTab>()?.tab ??
      KaalTab.focus;

  @override
  bool updateShouldNotify(CurrentTab old) => tab != old.tab;
}
