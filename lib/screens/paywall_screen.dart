import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../l10n/app_l10n.dart';

import '../settings/app_launch_prefs.dart';
import '../settings/kaal_settings.dart';
import '../settings/prefs_provider.dart';
import '../theme/kaal_colors.dart';
import '../theme/kaal_theme.dart';
import '../widgets/add_back_button.dart';
import '../widgets/kaal_top_bar.dart';
import '../widgets/wallpaper_background.dart';
import '../routing/routes.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/app_config.dart';
import '../data/providers/ai_access_provider.dart';
import '../services/purchase_service.dart';
import '../util/platform_layout.dart';

class PaywallScreen extends ConsumerStatefulWidget {
  // `from == 'onboard'` marks the post-onboarding upsell. Combined with the
  // skipAuth flag it becomes the mandatory gate for local-storage users.
  final String? from;
  const PaywallScreen({super.key, this.from});

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

enum _LoadState { loading, ok, notFound, storeUnavailable, unsupported, error }

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  bool _annual = true;
  _LoadState _loadState = _LoadState.loading;
  List<ProductDetails> _products = const [];
  String? _loadErrorMessage;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() => _loadState = _LoadState.loading);
    final result = await ref.read(purchaseServiceProvider).queryProducts();
    if (!mounted) return;
    switch (result) {
      case ProductQueryOk(:final products):
        setState(() {
          _products = products;
          _loadState = _LoadState.ok;
        });
      case ProductQueryNotFound():
        setState(() => _loadState = _LoadState.notFound);
      case ProductQueryStoreUnavailable():
        setState(() => _loadState = _LoadState.storeUnavailable);
      case ProductQueryUnsupported():
        setState(() => _loadState = _LoadState.unsupported);
      case ProductQueryError(:final message):
        setState(() {
          _loadState = _LoadState.error;
          _loadErrorMessage = message;
        });
    }
  }

  ProductDetails? get _selectedProduct {
    final id = _annual ? AppConfig.proAnnualProductId : AppConfig.proMonthlyProductId;
    for (final p in _products) {
      if (p.id == id) return p;
    }
    return null;
  }

  Future<void> _subscribe() async {
    final svc = ref.read(purchaseServiceProvider);
    if (!await svc.isStoreAvailable) {
      if (mounted) {
        _toast(context, isDesktop ? 'Subscribe from the mobile app' : 'Store unavailable — try again shortly');
      }
      return;
    }
    final product = _selectedProduct;
    if (product == null) {
      if (mounted) _toast(context, 'This plan isn’t available right now — pull to retry below');
      await _loadProducts();
      return;
    }
    await svc.buy(product);
  }

  // UPI via an external Razorpay link — Android only. On iOS, Kaal Pro digital
  // functionality must go through the App Store; an external payment link for
  // it would violate Guideline 3.1.1.
  Future<void> _payWithUpi() async {
    if (AppConfig.razorpayUpiLink.isEmpty) {
      _toast(context, 'UPI checkout not set up yet');
      return;
    }
    final ok = await launchUrl(Uri.parse(AppConfig.razorpayUpiLink),
        mode: LaunchMode.externalApplication);
    if (!ok && mounted) _toast(context, 'Could not open UPI checkout');
  }

  Future<void> _restore() async {
    await ref.read(purchaseServiceProvider).restore();
  }

  @override
  Widget build(BuildContext context) {
    final colors    = KaalTheme.of(context).colors;
    final safeBot   = MediaQuery.of(context).padding.bottom;
    final wallpaper = ref.watch(kaalSettingsProvider).wallpaper;

    // Mode: optional upsell after sign-up (from==onboard, has account) vs the
    // mandatory gate for skip-auth/local-storage users vs normal (Settings).
    final postOnboard = widget.from == 'onboard';
    final skipAuth = AppLaunchPrefs.skipAuth(ref.read(sharedPreferencesProvider));
    final mandatory = postOnboard && skipAuth;

    void leave() {
      ref.read(purchaseUiStateProvider.notifier).state = PurchaseUiState.idle;
      if (mandatory) {
        // No free pass for local-only — steer them to a (free) account instead,
        // and drop the skipAuth flag so they don't loop back into this gate.
        AppLaunchPrefs.clearSkipAuth(ref.read(sharedPreferencesProvider));
        context.go(KaalRoutes.signup);
      } else if (postOnboard) {
        context.go(KaalRoutes.focus);
      } else {
        context.pop();
      }
    }

    // A successful purchase flips isPro (via server validation) → leave.
    ref.listen(isProProvider, (_, isPro) {
      if (isPro) leave();
    });

    // Purchase-flow feedback that isn't "isPro flipped" — surfaced as toasts
    // rather than swallowed, per real purchase/restore/error states.
    ref.listen(purchaseUiStateProvider, (_, state) {
      switch (state.status) {
        case PurchaseUiStatus.error:
          _toast(context, state.message ?? 'Purchase failed. Please try again.');
        case PurchaseUiStatus.cancelled:
          break; // user-initiated cancel — no need to nag
        case PurchaseUiStatus.alreadyOwned:
          _toast(context, 'You already own this — try Restore Purchases below.');
        case PurchaseUiStatus.restored:
          _toast(context, 'Purchase restored.');
        default:
          break;
      }
    });

    final purchaseStatus = ref.watch(purchaseUiStateProvider).status;
    final busy = purchaseStatus == PurchaseUiStatus.purchasing ||
        purchaseStatus == PurchaseUiStatus.pending ||
        purchaseStatus == PurchaseUiStatus.verifying;

    return Stack(children: [
      Positioned.fill(child: WallpaperBackground(wallpaper: wallpaper)),
      Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(children: [
          KaalTopBar(
            title: 'Kaal Pro',
            leading: mandatory ? null : AddBackButton(onTap: leave),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(16, 8, 16, safeBot + 16),
              children: [
                _HeroSection(colors: colors),
                const SizedBox(height: 20),
                _FeaturesList(colors: colors),
                const SizedBox(height: 14),
                _PlanToggle(annual: _annual, colors: colors,
                    onChanged: (v) => setState(() => _annual = v)),
                const SizedBox(height: 14),
                _PriceHero(
                  colors: colors,
                  loadState: _loadState,
                  annual: _annual,
                  product: _selectedProduct,
                  onRetry: _loadProducts,
                  errorMessage: _loadErrorMessage,
                ),
                const SizedBox(height: 14),
                _SubscribeButton(
                  onTap: (_loadState == _LoadState.ok && !busy) ? _subscribe : null,
                  busy: busy,
                ),
                // UPI is Android-only — Play Billing already offers UPI to
                // Indian users inside its own checkout. On iOS this must not
                // exist: Kaal Pro digital content is App Store IAP only.
                if (defaultTargetPlatform == TargetPlatform.android) ...[
                  const SizedBox(height: 8),
                  _UpiButton(colors: colors, onTap: _payWithUpi),
                ],
                const SizedBox(height: 10),
                Text(
                  'Auto-renewing subscription. Payment is charged to your '
                  '${defaultTargetPlatform == TargetPlatform.iOS ? "Apple ID" : "Google Play"} '
                  'account at confirmation of purchase. It renews automatically unless '
                  'auto-renew is turned off at least 24 hours before the end of the '
                  'current period. Manage or cancel anytime in your '
                  '${defaultTargetPlatform == TargetPlatform.iOS ? "App Store" : "Play Store"} account settings.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontFamily: 'Inter', fontSize: 11,
                      color: colors.ink3, height: 1.5),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: leave,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Center(child: Text(
                        mandatory
                            ? 'Create a free account instead'
                            : (postOnboard
                                ? 'Continue with free plan'
                                : AppL10n.of(context).maybeLater),
                        style: TextStyle(fontFamily: 'Inter', fontSize: 13,
                            color: mandatory ? KaalColors.acc2 : colors.ink3, height: 1))),
                  ),
                ),
                GestureDetector(
                  onTap: _restore,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Center(child: Text(AppL10n.of(context).restorePurchase,
                        style: TextStyle(fontFamily: 'Inter', fontSize: 11,
                            color: colors.ink3, height: 1))),
                  ),
                ),
                const SizedBox(height: 4),
                _LegalLinksRow(colors: colors),
                const SizedBox(height: 10),
                _ReferralNudge(colors: colors),
              ],
            ),
          ),
        ]),
      ),
    ]);
  }
}

void _toast(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message,
          style: const TextStyle(fontFamily: 'Inter', fontSize: 13, color: Colors.white)),
      backgroundColor: const Color(0xFF1C1C1E),
      duration: const Duration(seconds: 3),
      behavior: SnackBarBehavior.floating,
    ),
  );
}

// ── Hero section ──────────────────────────────────────────────────────────────

class _HeroSection extends StatelessWidget {
  final KaalColors colors;
  const _HeroSection({required this.colors});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text('✦',
          style: TextStyle(fontFamily: 'Inter', fontSize: 28,
              color: colors.ink, height: 1.2)),
      const SizedBox(height: 8),
      Text('Kaal Pro',
          style: TextStyle(fontFamily: 'Fraunces', fontSize: 24,
              fontVariations: const [FontVariation('wght', 700)],
              color: colors.ink, height: 1.2)),
      const SizedBox(height: 4),
      Text('Unlock unlimited AI + all premium features',
          textAlign: TextAlign.center,
          style: TextStyle(fontFamily: 'Inter', fontSize: 13,
              color: colors.ink3, height: 1.5)),
    ]);
  }
}

// ── Features list ─────────────────────────────────────────────────────────────

class _FeaturesList extends StatelessWidget {
  final KaalColors colors;
  const _FeaturesList({required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: colors.surf,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(width: 0.5, color: colors.bdr2),
      ),
      child: Column(children: [
        _FeatureRow(
          iconBg: const LinearGradient(colors: [Color(0xFF5856D6), KaalColors.acc],
              begin: Alignment.topLeft, end: Alignment.bottomRight),
          iconSvgPath: Icons.star_rounded,
          iconColor: Colors.white,
          title: 'Unlimited AI features',
          sub: 'Brain Dump, auto-schedule, AI scoring',
          trailLabel: '∞',
          trailColor: KaalColors.q2,
        ),
        const SizedBox(height: 9),
        _FeatureRow(
          iconBg: const LinearGradient(colors: [Color(0x240A84FF), Color(0x240A84FF)]),
          iconSvgPath: Icons.grid_view_rounded,
          iconColor: KaalColors.acc2,
          title: 'Home screen widget',
          sub: 'Q1 tasks at a glance, streak counter',
          trailLabel: '✓',
          trailColor: KaalColors.q2,
        ),
        const SizedBox(height: 9),
        _FeatureRow(
          iconBg: const LinearGradient(colors: [Color(0x1F7FBA00), Color(0x1F7FBA00)]),
          iconSvgPath: Icons.upload_rounded,
          iconColor: KaalColors.q2,
          title: 'Export & share',
          sub: 'Task lists, weekly review, EOD report',
          trailLabel: '✓',
          trailColor: KaalColors.q2,
        ),
        const SizedBox(height: 9),
        _FeatureRow(
          iconBg: const LinearGradient(colors: [Color(0x1FFFB900), Color(0x1FFFB900)]),
          iconSvgPath: Icons.email_rounded,
          iconColor: KaalColors.q4,
          title: 'Gmail & Cal deep sync',
          sub: 'Unlimited accounts, real-time AI triage',
          trailLabel: '✓',
          trailColor: KaalColors.q2,
        ),
        const SizedBox(height: 9),
        _FeatureRow(
          iconBg: const LinearGradient(colors: [Color(0x1FBF5AF2), Color(0x1FBF5AF2)]),
          iconSvgPath: Icons.star_outline_rounded,
          iconColor: const Color(0xFFBF5AF2),
          title: 'Pro badge + identity',
          sub: 'Custom themes, priority support',
          trailLabel: '✓',
          trailColor: KaalColors.q2,
        ),
      ]),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final Gradient iconBg;
  final IconData iconSvgPath;
  final Color iconColor;
  final String title;
  final String sub;
  final String trailLabel;
  final Color trailColor;
  const _FeatureRow({required this.iconBg, required this.iconSvgPath,
      required this.iconColor, required this.title, required this.sub,
      required this.trailLabel, required this.trailColor});

  @override
  Widget build(BuildContext context) {
    final colors = KaalTheme.of(context).colors;
    return Row(children: [
      Container(
        width: 26, height: 26,
        decoration: BoxDecoration(
          gradient: iconBg,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(iconSvgPath, color: iconColor, size: 12),
      ),
      const SizedBox(width: 9),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style: TextStyle(fontFamily: 'Inter', fontSize: 13,
                  fontWeight: FontWeight.w600, color: colors.ink, height: 1.2)),
          Text(sub,
              style: TextStyle(fontFamily: 'Inter', fontSize: 11,
                  color: colors.ink3, height: 1.3)),
        ]),
      ),
      Text(trailLabel,
          style: TextStyle(fontFamily: 'Inter', fontSize: 14,
              fontWeight: FontWeight.w700, color: trailColor, height: 1)),
    ]);
  }
}

// ── Plan toggle (Monthly / Annual — no pricing here, just plan selection) ─────

class _PlanToggle extends StatelessWidget {
  final bool annual;
  final KaalColors colors;
  final ValueChanged<bool> onChanged;
  const _PlanToggle({required this.annual, required this.colors, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colors.surf2,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(children: [
        _PlanTab(label: 'Annual', selected: annual, onTap: () => onChanged(true)),
        _PlanTab(label: 'Monthly', selected: !annual, onTap: () => onChanged(false)),
      ]),
    );
  }
}

class _PlanTab extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _PlanTab({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = KaalTheme.of(context).colors;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: selected ? KaalColors.acc : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(label,
              style: TextStyle(fontFamily: 'Inter', fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: selected ? Colors.white : colors.ink2, height: 1.2)),
        ),
      ),
    );
  }
}

// ── Price hero — the real, store-reported billed amount. This is the single
// most prominent pricing element on the screen, per App Store Guideline
// 3.1.2(c): the billed amount must never be subordinate to a trial or to a
// calculated monthly-equivalent. ─────────────────────────────────────────────

class _PriceHero extends StatelessWidget {
  final KaalColors colors;
  final _LoadState loadState;
  final bool annual;
  final ProductDetails? product;
  final Future<void> Function() onRetry;
  final String? errorMessage;
  const _PriceHero({
    required this.colors, required this.loadState, required this.annual,
    required this.product, required this.onRetry, required this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    if (loadState == _LoadState.loading) {
      return _Card(colors: colors, child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(width: 16, height: 16,
              child: CircularProgressIndicator(strokeWidth: 2, color: colors.ink3)),
          const SizedBox(width: 10),
          Text('Loading price…',
              style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: colors.ink3)),
        ],
      ));
    }

    if (loadState != _LoadState.ok || product == null) {
      final message = switch (loadState) {
        _LoadState.notFound => 'This plan isn’t available in your store region right now.',
        _LoadState.storeUnavailable => 'The App Store / Play Store isn’t reachable right now.',
        _LoadState.unsupported => 'Subscribe from the Kaal mobile app to see pricing.',
        _LoadState.error => errorMessage ?? 'Couldn’t load pricing.',
        _ => 'Couldn’t load pricing.',
      };
      return _Card(colors: colors, child: Column(children: [
        Text(message, textAlign: TextAlign.center,
            style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: colors.ink2, height: 1.4)),
        if (loadState != _LoadState.unsupported) ...[
          const SizedBox(height: 8),
          GestureDetector(
            onTap: onRetry,
            child: Text('Retry',
                style: TextStyle(fontFamily: 'Inter', fontSize: 13,
                    fontWeight: FontWeight.w600, color: KaalColors.acc2)),
          ),
        ],
      ]));
    }

    final intro = _introOfferFor(product!);
    final billed = _billedPrice(product!);
    final periodLabel = annual ? 'year' : 'month';
    final billedLabel = annual ? 'Billed annually' : 'Billed monthly';

    return _Card(colors: colors, child: Column(children: [
      Text(annual ? 'ANNUAL' : 'MONTHLY',
          style: TextStyle(fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w700,
              letterSpacing: 1.2, color: colors.ink3)),
      const SizedBox(height: 6),
      RichText(textAlign: TextAlign.center, text: TextSpan(children: [
        TextSpan(text: billed.label,
            style: TextStyle(fontFamily: 'Inter', fontSize: 30, fontWeight: FontWeight.w800,
                color: colors.ink, height: 1)),
        TextSpan(text: ' / $periodLabel',
            style: TextStyle(fontFamily: 'Inter', fontSize: 15, fontWeight: FontWeight.w600,
                color: colors.ink3, height: 1)),
      ])),
      const SizedBox(height: 4),
      Text(billedLabel,
          style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: colors.ink3, height: 1.3)),
      if (annual) ...[
        const SizedBox(height: 6),
        // Subordinate to the billed amount above — smaller, muted, computed
        // only from the real store price (never a hardcoded conversion).
        Text('Equivalent to ${billed.currencySymbol}${(billed.raw / 12).toStringAsFixed(2)}/month',
            style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: colors.ink3, height: 1.3)),
      ],
      if (intro != null) ...[
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: colors.surf2,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
              '${intro.priceLabel} for ${intro.periodLabel}, then ${billed.label}/$periodLabel',
              style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: colors.ink2, height: 1.3)),
        ),
      ],
    ]));
  }
}

class _Card extends StatelessWidget {
  final KaalColors colors;
  final Widget child;
  const _Card({required this.colors, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: colors.surf,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(width: 0.5, color: colors.bdr2),
      ),
      child: child,
    );
  }
}

/// A genuine introductory offer as reported by StoreKit / Play Billing for
/// the currently-loaded product — never shown unless the store actually
/// configures one for this user.
class _IntroOffer {
  final String priceLabel;
  final String periodLabel;
  const _IntroOffer(this.priceLabel, this.periodLabel);
}

_IntroOffer? _introOfferFor(ProductDetails p) {
  if (p is AppStoreProductDetails) {
    final discount = p.skProduct.introductoryPrice;
    if (discount == null) return null;
    final isFree = discount.paymentMode == SKProductDiscountPaymentMode.freeTrail;
    final priceLabel = isFree ? 'Free' : (p.currencySymbol + discount.price);
    final totalUnits = discount.subscriptionPeriod.numberOfUnits * discount.numberOfPeriods;
    return _IntroOffer(priceLabel, _unitLabel(discount.subscriptionPeriod.unit, totalUnits));
  }
  if (p is GooglePlayProductDetails) {
    final idx = p.subscriptionIndex;
    final offers = p.productDetails.subscriptionOfferDetails;
    if (idx == null || offers == null) return null;
    final phases = offers[idx].pricingPhases;
    if (phases.length < 2) return null; // only the base recurring phase — no intro
    final introPhase = phases.first;
    final isFree = introPhase.priceAmountMicros == 0;
    final periodLabel = _isoPeriodLabel(introPhase.billingPeriod);
    if (periodLabel == null) return null;
    return _IntroOffer(isFree ? 'Free' : introPhase.formattedPrice, periodLabel);
  }
  return null;
}

String _unitLabel(SKSubscriptionPeriodUnit unit, int count) {
  final noun = switch (unit) {
    SKSubscriptionPeriodUnit.day => 'day',
    SKSubscriptionPeriodUnit.week => 'week',
    SKSubscriptionPeriodUnit.month => 'month',
    SKSubscriptionPeriodUnit.year => 'year',
  };
  return '$count $noun${count == 1 ? '' : 's'}';
}

/// Parses a subset of ISO-8601 durations as used by Play Billing pricing
/// phases (e.g. "P7D", "P1W", "P1M", "P3M", "P1Y").
String? _isoPeriodLabel(String iso) {
  final m = RegExp(r'^P(\d+)([DWMY])$').firstMatch(iso);
  if (m == null) return null;
  final count = int.parse(m.group(1)!);
  final noun = switch (m.group(2)) {
    'D' => 'day',
    'W' => 'week',
    'M' => 'month',
    'Y' => 'year',
    _ => null,
  };
  if (noun == null) return null;
  return '$count $noun${count == 1 ? '' : 's'}';
}

/// The actual recurring billed price for a product, as a formatted label plus
/// its raw numeric amount (for deriving e.g. the monthly-equivalent).
///
/// On Android, `ProductDetails.price`/`.rawPrice` are built from the *first*
/// pricing phase of the matched offer (see `GooglePlayProductDetails._fromSubscription`
/// in the `in_app_purchase_android` plugin) — which is the introductory phase
/// when one exists, not the recurring one. Recompute from the *last* phase
/// (the one that repeats indefinitely) so the "billed amount" we show as the
/// primary price is never actually an introductory price in disguise.
class _BilledPrice {
  final String label;
  final double raw;
  final String currencySymbol;
  const _BilledPrice(this.label, this.raw, this.currencySymbol);
}

_BilledPrice _billedPrice(ProductDetails p) {
  if (p is GooglePlayProductDetails) {
    final idx = p.subscriptionIndex;
    final offers = p.productDetails.subscriptionOfferDetails;
    if (idx != null && offers != null) {
      final phases = offers[idx].pricingPhases;
      if (phases.length > 1) {
        final recurring = phases.last;
        return _BilledPrice(
            recurring.formattedPrice, recurring.priceAmountMicros / 1000000.0, p.currencySymbol);
      }
    }
  }
  return _BilledPrice(p.price, p.rawPrice, p.currencySymbol);
}

// ── Subscribe button ──────────────────────────────────────────────────────────

class _SubscribeButton extends StatelessWidget {
  final VoidCallback? onTap;
  final bool busy;
  const _SubscribeButton({required this.onTap, required this.busy});
  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: enabled
                ? const [Color(0xFF5856D6), KaalColors.acc]
                : [KaalColors.acc.withValues(alpha: 0.35), KaalColors.acc.withValues(alpha: 0.35)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(13),
          boxShadow: enabled
              ? const [BoxShadow(color: Color(0x665856D6), blurRadius: 18, offset: Offset(0, 4))]
              : null,
        ),
        alignment: Alignment.center,
        child: busy
            ? const SizedBox(width: 18, height: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : const Text('Subscribe',
                style: TextStyle(fontFamily: 'Inter', fontSize: 15,
                    fontWeight: FontWeight.w700, color: Colors.white, height: 1)),
      ),
    );
  }
}

// ── UPI button (Android only) ─────────────────────────────────────────────────

class _UpiButton extends StatelessWidget {
  final KaalColors colors;
  final VoidCallback onTap;
  const _UpiButton({required this.colors, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          color: colors.surf2,
          borderRadius: BorderRadius.circular(11),
          border: Border.all(width: 0.5, color: colors.bdr2),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
            width: 18, height: 18,
            decoration: BoxDecoration(
              color: const Color(0xFF097939),
              borderRadius: BorderRadius.circular(4),
            ),
            alignment: Alignment.center,
            child: const Text('UPI',
                style: TextStyle(fontFamily: 'Inter', fontSize: 7,
                    fontWeight: FontWeight.w700, color: Colors.white, height: 1)),
          ),
          const SizedBox(width: 8),
          Text('Pay with UPI (India)',
              style: TextStyle(fontFamily: 'Inter', fontSize: 14,
                  fontWeight: FontWeight.w600, color: colors.ink, height: 1)),
        ]),
      ),
    );
  }
}

// ── Legal links ────────────────────────────────────────────────────────────────

class _LegalLinksRow extends StatelessWidget {
  final KaalColors colors;
  const _LegalLinksRow({required this.colors});

  @override
  Widget build(BuildContext context) {
    Widget link(String label, VoidCallback onTap) => GestureDetector(
          onTap: onTap,
          child: Text(label,
              style: TextStyle(fontFamily: 'Inter', fontSize: 11,
                  color: colors.ink3, decoration: TextDecoration.underline,
                  decorationColor: colors.ink3, height: 1)),
        );
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      link('Terms of Use', () => context.push(KaalRoutes.legal)),
      Padding(padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text('·', style: TextStyle(color: colors.ink3, fontSize: 11))),
      link('Privacy Policy', () => context.push('${KaalRoutes.legal}?tab=privacy')),
    ]);
  }
}

// ── Referral nudge ────────────────────────────────────────────────────────────

class _ReferralNudge extends StatelessWidget {
  final KaalColors colors;
  const _ReferralNudge({required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: BoxDecoration(
        color: colors.surf,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(width: 0.5, color: colors.bdr),
      ),
      child: Column(children: [
        Text("Know someone who'd love Kaal?",
            textAlign: TextAlign.center,
            style: TextStyle(fontFamily: 'Inter', fontSize: 12,
                color: colors.ink3, height: 1.4)),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: () => context.push(KaalRoutes.referral),
          child: Container(
            padding: const EdgeInsets.fromLTRB(14, 6, 14, 6),
            decoration: BoxDecoration(
              color: colors.surf2,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text('🎁 Invite → both get 1 month free',
                style: TextStyle(fontFamily: 'Inter', fontSize: 12,
                    fontWeight: FontWeight.w600, color: KaalColors.acc2, height: 1)),
          ),
        ),
      ]),
    );
  }
}
