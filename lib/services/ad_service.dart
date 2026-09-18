import 'dart:io' show Platform;

import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../config/ads_config.dart';
import '../util/platform_layout.dart';

/// Thin wrapper around AdMob interstitial + rewarded ads.
///
/// - No-ops on desktop/web (google_mobile_ads is Android/iOS only).
/// - Caller decides *who* sees ads (free users only); this just loads/shows.
/// - Each ad is preloaded once and reloaded after it's shown.
class AdService {
  AdService._();
  static final AdService instance = AdService._();

  bool _initialized = false;

  InterstitialAd? _interstitial;
  RewardedAd? _rewarded;
  DateTime? _lastInterstitialAt;

  bool get _supported => isMobile && AdsConfig.enabled;

  /// Initialize the SDK and warm up the first ads. Safe to call once at startup.
  ///
  /// On iOS this must request App Tracking Transparency *before* the ad SDK
  /// initializes — Info.plist declares NSUserTrackingUsageDescription, and
  /// Apple requires the actual system prompt to back that up (Guideline 5.1.1).
  Future<void> init() async {
    if (_initialized || !_supported) return;
    _initialized = true;
    if (Platform.isIOS) {
      final status = await AppTrackingTransparency.trackingAuthorizationStatus;
      if (status == TrackingStatus.notDetermined) {
        await AppTrackingTransparency.requestTrackingAuthorization();
      }
    }
    await MobileAds.instance.initialize();
    _loadInterstitial();
    _loadRewarded();
  }

  // ── Interstitial ────────────────────────────────────────────────────────────

  void _loadInterstitial() {
    if (!_supported) return;
    InterstitialAd.load(
      adUnitId: AdsConfig.interstitialUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) => _interstitial = ad,
        onAdFailedToLoad: (_) => _interstitial = null,
      ),
    );
  }

  /// Show an interstitial if one is ready and the min-gap has elapsed. Returns
  /// true if an ad was shown. Call this only for free users, at natural breaks.
  Future<bool> maybeShowInterstitial() async {
    if (!_supported || _interstitial == null) return false;
    final now = DateTime.now();
    if (_lastInterstitialAt != null &&
        now.difference(_lastInterstitialAt!) < AdsConfig.interstitialMinGap) {
      return false;
    }
    final ad = _interstitial!;
    _interstitial = null;
    _lastInterstitialAt = now;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _loadInterstitial();
      },
      onAdFailedToShowFullScreenContent: (ad, _) {
        ad.dispose();
        _loadInterstitial();
      },
    );
    await ad.show();
    return true;
  }

  // ── Rewarded ────────────────────────────────────────────────────────────────

  void _loadRewarded() {
    if (!_supported) return;
    RewardedAd.load(
      adUnitId: AdsConfig.rewardedUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) => _rewarded = ad,
        onAdFailedToLoad: (_) => _rewarded = null,
      ),
    );
  }

  /// True when a rewarded ad is loaded and ready to show.
  bool get rewardedReady => _supported && _rewarded != null;

  /// Show a rewarded ad. Resolves true only if the user earned the reward
  /// (watched far enough). Reloads the next ad afterward either way.
  Future<bool> showRewarded() async {
    if (!_supported || _rewarded == null) return false;
    final ad = _rewarded!;
    _rewarded = null;
    var earned = false;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _loadRewarded();
      },
      onAdFailedToShowFullScreenContent: (ad, _) {
        ad.dispose();
        _loadRewarded();
      },
    );
    await ad.show(onUserEarnedReward: (ad, reward) => earned = true);
    return earned;
  }
}

final adServiceProvider = Provider<AdService>((ref) => AdService.instance);
