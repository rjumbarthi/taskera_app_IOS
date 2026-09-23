import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../services/openai_service.dart';
import '../../settings/prefs_provider.dart';
import 'auth_provider.dart';
import 'integrations_provider.dart';

/// A subscription state as reported by the store/webhook-validated
/// `pro_entitlements` row. `cancelled` / `grace_period` / `billing_retry` all
/// still hold Pro access until [currentPeriodEnd] passes — only `expired` and
/// `revoked` (or a null/never-set row) do not.
enum ProStatus { active, cancelled, gracePeriod, billingRetry, expired, revoked, none }

ProStatus _statusFromString(String? s) => switch (s) {
      'active' => ProStatus.active,
      'cancelled' => ProStatus.cancelled,
      'grace_period' => ProStatus.gracePeriod,
      'billing_retry' => ProStatus.billingRetry,
      'expired' => ProStatus.expired,
      'revoked' => ProStatus.revoked,
      _ => ProStatus.none,
    };

class ProEntitlement {
  const ProEntitlement({
    required this.status,
    required this.currentPeriodEnd,
    required this.willRenew,
  });

  const ProEntitlement.none()
      : status = ProStatus.none,
        currentPeriodEnd = null,
        willRenew = false;

  final ProStatus status;
  final DateTime? currentPeriodEnd;
  final bool willRenew;

  /// The single source of truth for "does this grant Pro right now". A
  /// cancelled subscription keeps access until its paid period ends; an
  /// expired/revoked one (or the absence of any entitlement) does not.
  bool get isActive {
    const grantingStates = {
      ProStatus.active,
      ProStatus.cancelled,
      ProStatus.gracePeriod,
      ProStatus.billingRetry,
    };
    if (!grantingStates.contains(status)) return false;
    if (currentPeriodEnd == null) return true; // no known expiry (e.g. lifetime/manual grant)
    return currentPeriodEnd!.isAfter(DateTime.now());
  }

  Map<String, dynamic> toJson() => {
        'status': status.name,
        'currentPeriodEnd': currentPeriodEnd?.toIso8601String(),
        'willRenew': willRenew,
      };

  factory ProEntitlement.fromJson(Map<String, dynamic> j) => ProEntitlement(
        status: _statusFromString(j['status'] as String?),
        currentPeriodEnd: j['currentPeriodEnd'] != null
            ? DateTime.tryParse(j['currentPeriodEnd'] as String)
            : null,
        willRenew: j['willRenew'] as bool? ?? false,
      );

  factory ProEntitlement.fromRow(Map<String, dynamic> row) => ProEntitlement(
        status: (row['is_pro'] as bool?) == true
            ? _statusFromString(row['status'] as String?)
            : ProStatus.expired,
        currentPeriodEnd: row['current_period_end'] != null
            ? DateTime.tryParse(row['current_period_end'] as String)
            : null,
        willRenew: row['will_renew'] as bool? ?? false,
      );
}

const _kEntitlementPrefsKey = 'taskera.proEntitlement';

/// Whether the user has TaskEra Pro right now. Authoritative source: the
/// server-validated [proEntitlementProvider] (store receipt / Razorpay
/// webhook via `pro_entitlements`), cached locally so it survives offline
/// launches. This never grants Pro merely because a purchase transaction
/// once occurred — expiry is checked on every read.
final isProProvider = Provider<bool>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  final raw = prefs.getString(_kEntitlementPrefsKey);
  if (raw == null) return false;
  try {
    return ProEntitlement.fromJson(jsonDecode(raw) as Map<String, dynamic>).isActive;
  } catch (_) {
    return false;
  }
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

/// Live stream of the user's server entitlement row. Emits the current value
/// on subscribe and again on every change, so a just-paid user unlocks Pro
/// mid-session without relaunching. RLS limits the client to its own row.
/// Re-subscribes on sign-in / sign-out.
final serverProProvider = StreamProvider<ProEntitlement>((ref) {
  ref.watch(authStateProvider); // re-subscribe when the session changes
  final uid = Supabase.instance.client.auth.currentUser?.id;
  if (uid == null) return Stream<ProEntitlement>.value(const ProEntitlement.none());
  return Supabase.instance.client
      .from('pro_entitlements')
      .stream(primaryKey: ['user_id'])
      .eq('user_id', uid)
      .map((rows) => rows.isEmpty
          ? const ProEntitlement.none()
          : ProEntitlement.fromRow(rows.first));
});

/// Pull the server-authoritative entitlement into the local cache, then
/// refresh the entitlement providers. Call on launch and on sign-in / sign-out.
///
/// Two entry points because `WidgetRef` (used by widgets/ConsumerState, e.g.
/// main.dart) and `Ref` (used inside providers, e.g. PurchaseService) are
/// distinct types in riverpod with no common supertype — both only need
/// `read`/`invalidate`, so they share the same implementation underneath.
Future<void> refreshProEntitlement(WidgetRef ref) => _refreshProEntitlement(
      prefs: ref.read(sharedPreferencesProvider),
      onDone: () {
        ref.invalidate(isProProvider);
        ref.invalidate(aiUnlockedProvider);
      },
    );

Future<void> refreshProEntitlementFromRef(Ref ref) => _refreshProEntitlement(
      prefs: ref.read(sharedPreferencesProvider),
      onDone: () {
        ref.invalidate(isProProvider);
        ref.invalidate(aiUnlockedProvider);
      },
    );

Future<void> _refreshProEntitlement({
  required SharedPreferences prefs,
  required void Function() onDone,
}) async {
  final uid = Supabase.instance.client.auth.currentUser?.id;

  if (uid == null) {
    // Signed out → the account-bound server entitlement no longer applies.
    await prefs.remove(_kEntitlementPrefsKey);
    onDone();
    return;
  }

  try {
    final row = await Supabase.instance.client
        .from('pro_entitlements')
        .select('is_pro, status, current_period_end, will_renew')
        .eq('user_id', uid)
        .maybeSingle();
    final entitlement = row == null ? const ProEntitlement.none() : ProEntitlement.fromRow(row);
    await prefs.setString(_kEntitlementPrefsKey, jsonEncode(entitlement.toJson()));
  } catch (_) {
    // Offline, or the table isn't reachable — keep the existing cached entitlement.
  }
  onDone();
}
