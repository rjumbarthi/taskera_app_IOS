import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../services/openai_service.dart';
import '../../settings/prefs_provider.dart';
import 'integrations_provider.dart';

/// Whether the user has Kaal Pro. Two independent sources, OR'd:
///  • `kaal.isPro`     — a device store purchase (set by PurchaseService)
///  • `kaal.proServer` — a server entitlement from `pro_entitlements`
///                        (Razorpay webhook etc.), synced by [refreshProEntitlement]
final isProProvider = Provider<bool>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return (prefs.getBool('kaal.isPro') ?? false) ||
      (prefs.getBool('kaal.proServer') ?? false);
});

/// Whether AI features/recommendations are unlocked: Pro OR a connected own key
/// (OpenAI/Claude, which pays for itself). Free users with no key get an upgrade
/// prompt instead of AI.
final aiUnlockedProvider = FutureProvider<bool>((ref) async {
  if (ref.watch(isProProvider)) return true;
  // Re-evaluate whenever a key is connected/disconnected.
  ref.watch(integrationsProvider);
  if (await ref.read(openAiServiceProvider).isConnected) return true;
  return ref.read(anthropicServiceProvider).isConnected;
});

/// Pull the server-authoritative entitlement (set by the `razorpay-webhook` /
/// future store validators) into the local `kaal.proServer` flag, then refresh
/// the entitlement providers. Call on launch and on sign-in / sign-out.
Future<void> refreshProEntitlement(WidgetRef ref) async {
  final prefs = ref.read(sharedPreferencesProvider);
  final uid = Supabase.instance.client.auth.currentUser?.id;

  if (uid == null) {
    // Signed out → the account-bound server entitlement no longer applies.
    await prefs.setBool('kaal.proServer', false);
    ref.invalidate(isProProvider);
    ref.invalidate(aiUnlockedProvider);
    return;
  }

  try {
    final row = await Supabase.instance.client
        .from('pro_entitlements')
        .select('is_pro')
        .eq('user_id', uid)
        .maybeSingle();
    await prefs.setBool('kaal.proServer', (row?['is_pro'] as bool?) ?? false);
    ref.invalidate(isProProvider);
    ref.invalidate(aiUnlockedProvider);
  } catch (_) {
    // Offline, or the table isn't created yet — keep the existing flag.
  }
}
