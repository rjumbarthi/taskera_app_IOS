import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/app_config.dart';
import '../data/providers/ai_access_provider.dart';
import '../util/platform_layout.dart';

/// UI-facing purchase state — the paywall renders off this instead of
/// independently guessing whether a purchase "worked". `purchasing`/`pending`
/// covers the async gap while the store or our own receipt validation is
/// still running; `verified` only fires once the server has confirmed the
/// entitlement (never on a bare client-side purchase event).
enum PurchaseUiStatus { idle, purchasing, pending, verifying, verified, restored, alreadyOwned, cancelled, error }

class PurchaseUiState {
  const PurchaseUiState(this.status, {this.message});
  final PurchaseUiStatus status;
  final String? message;
  static const idle = PurchaseUiState(PurchaseUiStatus.idle);
}

final purchaseUiStateProvider = StateProvider<PurchaseUiState>((ref) => PurchaseUiState.idle);

/// Play Store / App Store subscriptions via `in_app_purchase`. On Android,
/// UPI/cards/wallets are additionally offered inside Google Play's own
/// checkout in India — there's no separate in-app UPI SDK for that (a
/// standalone one would breach store policy for digital goods on either
/// platform). On iOS, Kaal Pro must be purchased through the App Store only.
///
/// A successful purchase does NOT grant Pro by itself — it triggers server
/// receipt validation, and only that (or the realtime `pro_entitlements`
/// stream it feeds) flips `isProProvider`. The plugin only supports
/// Android/iOS, so on Windows desktop every method is a guarded no-op.
class PurchaseService {
  PurchaseService(this._ref);

  final Ref _ref;

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
    _sub = _iap.purchaseStream.listen(_onPurchases, onError: (Object e) {
      _setStatus(PurchaseUiStatus.error, e.toString());
    });
  }

  void dispose() => _sub?.cancel();

  Future<bool> get isStoreAvailable async => supported && await _iap.isAvailable();

  /// The configured subscription products (empty until they exist in the
  /// store, or on any query failure). Callers must distinguish "empty because
  /// the store call failed" from "empty because not configured yet" via
  /// [queryProducts] instead of silently collapsing both into one UI state.
  Future<List<ProductDetails>> products() async {
    if (!await isStoreAvailable) return const [];
    final resp = await _iap.queryProductDetails(productIds);
    return resp.productDetails;
  }

  /// Full product-loading result, so the paywall can tell "store unavailable"
  /// apart from "products not found" apart from "network/store error" instead
  /// of collapsing everything into a generic "Plan not available" dead end.
  Future<ProductQueryResult> queryProducts() async {
    if (!supported) return const ProductQueryResult.unsupported();
    if (!await _iap.isAvailable()) return const ProductQueryResult.storeUnavailable();
    try {
      final resp = await _iap.queryProductDetails(productIds);
      if (resp.error != null) {
        return ProductQueryResult.error(resp.error!.message);
      }
      if (resp.productDetails.isEmpty) {
        return ProductQueryResult.notFound(resp.notFoundIDs);
      }
      return ProductQueryResult.ok(resp.productDetails);
    } catch (e) {
      return ProductQueryResult.error(e.toString());
    }
  }

  Future<void> buy(ProductDetails product) async {
    if (!supported) return;
    _setStatus(PurchaseUiStatus.purchasing);
    await _iap.buyNonConsumable(
      purchaseParam: PurchaseParam(productDetails: product),
    );
  }

  Future<void> restore() async {
    if (!supported) return;
    _setStatus(PurchaseUiStatus.pending, 'Checking previous purchases…');
    await _iap.restorePurchases();
  }

  void _setStatus(PurchaseUiStatus status, [String? message]) {
    _ref.read(purchaseUiStateProvider.notifier).state = PurchaseUiState(status, message: message);
  }

  Future<void> _onPurchases(List<PurchaseDetails> purchases) async {
    for (final p in purchases) {
      switch (p.status) {
        case PurchaseStatus.pending:
          _setStatus(PurchaseUiStatus.pending);
          break;
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          _setStatus(PurchaseUiStatus.verifying);
          final ok = await _validateWithServer(p);
          if (ok) {
            await refreshProEntitlementFromRef(_ref);
            _setStatus(p.status == PurchaseStatus.restored
                ? PurchaseUiStatus.restored
                : PurchaseUiStatus.verified);
          } else {
            // Do NOT fall back to an optimistic local grant — an unverifiable
            // receipt must not silently become permanent Pro access. Surface
            // the failure so the user can retry (e.g. once back online); the
            // realtime pro_entitlements stream will still unlock Pro
            // automatically if validation actually succeeded server-side but
            // the response just didn't make it back to this device.
            _setStatus(PurchaseUiStatus.error,
                'Could not verify this purchase. Check your connection and try Restore Purchases.');
          }
          break;
        case PurchaseStatus.error:
          final code = p.error?.code.toLowerCase() ?? '';
          final msg = p.error?.message.toLowerCase() ?? '';
          if (code.contains('already') || msg.contains('already own')) {
            _setStatus(PurchaseUiStatus.alreadyOwned, p.error?.message);
          } else {
            _setStatus(PurchaseUiStatus.error, p.error?.message);
          }
          break;
        case PurchaseStatus.canceled:
          _setStatus(PurchaseUiStatus.cancelled);
          break;
      }
      if (p.pendingCompletePurchase) {
        await _iap.completePurchase(p);
      }
    }
  }

  Future<bool> _validateWithServer(PurchaseDetails p) async {
    try {
      final res = await Supabase.instance.client.functions.invoke(
        'validate-purchase',
        body: {
          'platform': Platform.isIOS ? 'ios' : 'android',
          'productId': p.productID,
          'token': p.verificationData.serverVerificationData,
        },
      );
      final data = res.data;
      return data is Map && data['is_pro'] == true;
    } catch (_) {
      return false;
    }
  }
}

/// Result of a product-details query, distinguishing every failure mode the
/// paywall needs to react to differently (never collapsed into one generic
/// "not available" message).
sealed class ProductQueryResult {
  const ProductQueryResult();
  const factory ProductQueryResult.ok(List<ProductDetails> products) = ProductQueryOk;
  const factory ProductQueryResult.notFound(List<String> missingIds) = ProductQueryNotFound;
  const factory ProductQueryResult.storeUnavailable() = ProductQueryStoreUnavailable;
  const factory ProductQueryResult.unsupported() = ProductQueryUnsupported;
  const factory ProductQueryResult.error(String message) = ProductQueryError;
}

class ProductQueryOk extends ProductQueryResult {
  const ProductQueryOk(this.products);
  final List<ProductDetails> products;
}

class ProductQueryNotFound extends ProductQueryResult {
  const ProductQueryNotFound(this.missingIds);
  final List<String> missingIds;
}

class ProductQueryStoreUnavailable extends ProductQueryResult {
  const ProductQueryStoreUnavailable();
}

class ProductQueryUnsupported extends ProductQueryResult {
  const ProductQueryUnsupported();
}

class ProductQueryError extends ProductQueryResult {
  const ProductQueryError(this.message);
  final String message;
}

final purchaseServiceProvider = Provider<PurchaseService>((ref) {
  final service = PurchaseService(ref);
  service.init();
  ref.onDispose(service.dispose);
  return service;
});
