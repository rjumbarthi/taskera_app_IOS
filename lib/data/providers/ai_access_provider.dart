import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/openai_service.dart';
import '../../settings/prefs_provider.dart';
import 'integrations_provider.dart';

/// Whether the user has Kaal Pro. There's no IAP wired yet, so this is a
/// pref-backed placeholder (`kaal.isPro`, default false) — flip it from a real
/// purchase flow when that exists.
final isProProvider = Provider<bool>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return prefs.getBool('kaal.isPro') ?? false;
});

/// Whether AI features/recommendations are unlocked for this user: true when
/// they're Pro OR have connected their own OpenAI/Claude key (which pays for
/// itself). Free users with no key get an upgrade prompt instead of AI.
final aiUnlockedProvider = FutureProvider<bool>((ref) async {
  if (ref.watch(isProProvider)) return true;
  // Re-evaluate whenever a key is connected/disconnected.
  ref.watch(integrationsProvider);
  if (await ref.read(openAiServiceProvider).isConnected) return true;
  return ref.read(anthropicServiceProvider).isConnected;
});
