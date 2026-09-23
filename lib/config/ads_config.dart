import 'dart:io' show Platform;

/// AdMob configuration for Kaal's free-plan ads.
///
/// Ads are shown to free users only (Pro is ad-free) and only on Android/iOS —
/// google_mobile_ads has no desktop/web support, so the ad layer no-ops there.
///
/// While [useTestAds] is true the official Google **test** unit IDs are used, so
/// you can develop without risking your AdMob account. Before release:
///   1. Create an AdMob app + ad units (console.admob.com).
///   2. Paste the real IDs into the `_prod*` constants below.
///   3. Set [useTestAds] = false.
///   4. Put the real **app ID** in AndroidManifest.xml (and iOS Info.plist).
abstract final class AdsConfig {
  /// Master switch — flip to false to disable all ads app-wide.
  static const bool enabled = true;

  /// Use Google's sample ad units (safe for development). Set false for release.
  static const bool useTestAds = false;

  // ── Test IDs (Google-provided, always safe to load) ─────────────────────────
  static const _testInterstitialAndroid = 'ca-app-pub-3940256099942544/1033173712';
  static const _testInterstitialIos     = 'ca-app-pub-3940256099942544/4411468910';
  static const _testRewardedAndroid     = 'ca-app-pub-3940256099942544/5224354917';
  static const _testRewardedIos         = 'ca-app-pub-3940256099942544/1712485313';

  // ── Production IDs — REPLACE before going live ──────────────────────────────
  static const _prodInterstitialAndroid = 'ca-app-pub-9013964076288950/1324943461'; // kaal_ad_Interstitial
  static const _prodInterstitialIos     = 'ca-app-pub-9013964076288950/7049993571'; // kaal_ad_Interstitial
  static const _prodRewardedAndroid     = 'ca-app-pub-9013964076288950/3839426160'; // kaal_ad_rewarded
  static const _prodRewardedIos         = 'ca-app-pub-9013964076288950/5899643566'; // kaal_ad_rewarded

  static bool get _ios => Platform.isIOS;

  // A production ID that is still the XXXX placeholder falls back to Google's
  // test unit, so an unfilled slot loads a test ad instead of failing outright.
  static String _pick(String prod, String test) =>
      useTestAds || prod.contains('XXXX') ? test : prod;

  static String get interstitialUnitId => _ios
      ? _pick(_prodInterstitialIos, _testInterstitialIos)
      : _pick(_prodInterstitialAndroid, _testInterstitialAndroid);

  static String get rewardedUnitId => _ios
      ? _pick(_prodRewardedIos, _testRewardedIos)
      : _pick(_prodRewardedAndroid, _testRewardedAndroid);

  /// Minimum gap between interstitials, so we never spam the user. A free user
  /// sees at most one interstitial every 2 hours (and only on a tab-switch).
  static const Duration interstitialMinGap = Duration(hours: 2);
}
