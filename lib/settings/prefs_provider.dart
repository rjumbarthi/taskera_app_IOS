import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Injected at startup in main.dart via ProviderScope.overrides.
/// Reading this before injection throws UnimplementedError by design.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (_) => throw UnimplementedError('SharedPreferences not injected'),
);
