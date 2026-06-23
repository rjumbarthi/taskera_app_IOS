import 'package:flutter/widgets.dart';
import 'app_strings.dart';

class AppL10n extends InheritedWidget {
  final AppStrings strings;

  const AppL10n({super.key, required this.strings, required super.child});

  static AppStrings of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppL10n>()!.strings;

  @override
  bool updateShouldNotify(AppL10n old) => strings.langIdx != old.strings.langIdx;
}
