import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_config.dart';
import '../data/providers/ai_access_provider.dart';
import '../settings/prefs_provider.dart';
import '../util/platform_layout.dart';

/// Play Store / App Store subscriptions via `in_app_purchase`. UPI, cards and
/// wallets are offered inside Google Play's own checkout in India — there's no
/// separate in-app UPI SDK (that would breach store policy for digital goods).
///
/// On a successful (or restored) purchase this flips the `kaal.isPro` flag,
/// which unlocks AI etc. The plugin only supports Android/iOS, so on Windows
/// desktop every method is a guarded no-op.
class PurchaseService {
  PurchaseService(this._prefs, {this.onProChanged});

  final SharedPreferences _prefs;
  final void Function()? onProChanged;

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _sub;

  static const Set<String> productIds = {
    AppConfig.proMonthlyProductId,
    AppConfig.proAnnualProductId,
  };

  bool get supported => isMobile; // in_app_purchase: Android/iOS only

  /// Begin listening for purchase updates. Call once at startup.
  void init() {
    if (!supported) return;
    _sub = _iap.purchaseStream.listen(_onPurchases, onError: (_) {});
  }

  void dispose() => _sub?.cancel();

  Future<bool> get isStoreAvailable async => supported && await _iap.isAvailable();

  /// The configured subscription products (empty until they exist in the store).
  Future<List<ProductDetails>> products() async {
    if (!await isStoreAvailable) return const [];
    final resp = await _iap.queryProductDetails(productIds);
    return resp.productDetails;
  }

  Future<void> buy(ProductDetails product) async {
    if (!supported) return;
    await _iap.buyNonConsumable(
      purchaseParam: PurchaseParam(productDetails: product),
    );
  }

  Future<void> restore() async {
    if (!supported) return;
    await _iap.restorePurchases();
  }

  Future<void> _onPurchases(List<PurchaseDetails> purchases) async {
    for (final p in purchases) {
      if (p.status == PurchaseStatus.purchased ||
          p.status == PurchaseStatus.restored) {
        // NOTE: for production, validate p.verificationData server-side
        // (e.g. a Supabase edge function) before granting entitlement.
        await _grantPro();
      }
      if (p.pendingCompletePurchase) {
        await _iap.completePurchase(p);
      }
    }
  }

  Future<void> _grantPro() async {
    await _prefs.setBool('kaal.isPro', true);
    onProChanged?.call();
  }
}

final purchaseServiceProvider = Provider<PurchaseService>((ref) {
  final service = PurchaseService(
    ref.read(sharedPreferencesProvider),
    onProChanged: () {
      // Refresh the entitlement-driven providers so the UI unlocks immediately.
      ref.invalidate(isProProvider);
      ref.invalidate(aiUnlockedProvider);
    },
  );
  service.init();
  ref.onDispose(service.dispose);
  return service;
});
