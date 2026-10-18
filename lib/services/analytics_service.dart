import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_config.dart';

/// Lightweight, vendor-agnostic product analytics over PostHog's HTTP capture
/// API. Works on every target (Android / iOS / Windows) with no native SDK, so
/// there's no platform gap. It auto-captures screen views and back-navigation
/// (see [attachToRouter]) plus any explicit [capture] events; PostHog turns the
/// `$screen` stream into Paths / Funnels / drop-off.
///
/// Privacy: disabled when the user opts out (Settings → Privacy), and a no-op
/// until a real PostHog key is set in [AppConfig]. It never throws into the app
/// and never blocks the UI — every network failure is swallowed.
class AnalyticsService {
  AnalyticsService._();
  static final AnalyticsService instance = AnalyticsService._();

  static const _anonKey = 'taskera.analytics.anonId';

  final _client = http.Client();
  String _anonId = '';
  String _distinctId = '';
  bool _enabled = true;
  bool _initialised = false;
  bool _routerAttached = false;
  Timer? _settingsDebounce;

  bool get _configured =>
      AppConfig.posthogApiKey.isNotEmpty &&
      !AppConfig.posthogApiKey.startsWith('YOUR_');

  /// Loads (or mints) a stable anonymous id. Call once at startup.
  Future<void> init(SharedPreferences prefs) async {
    if (_initialised) return;
    _initialised = true;
    var anon = prefs.getString(_anonKey);
    if (anon == null || anon.isEmpty) {
      anon = _randomId();
      await prefs.setString(_anonKey, anon);
    }
    _anonId = anon;
    _distinctId = anon;
  }

  /// Honor the Settings → Privacy opt-out.
  void setEnabled(bool value) => _enabled = value;

  /// Tie subsequent events to the signed-in user.
  void identify(String userId) {
    if (userId.isNotEmpty) _distinctId = userId;
  }

  /// Revert to the anonymous id (call on sign-out).
  void resetIdentity() {
    if (_anonId.isNotEmpty) _distinctId = _anonId;
  }

  /// Fire an arbitrary product event. Fire-and-forget.
  Future<void> capture(String event, {Map<String, dynamic>? props}) async {
    if (!_enabled || !_configured || _distinctId.isEmpty) return;
    final payload = <String, dynamic>{
      'api_key': AppConfig.posthogApiKey,
      'event': event,
      'distinct_id': _distinctId,
      'timestamp': DateTime.now().toUtc().toIso8601String(),
      'properties': <String, dynamic>{
        '\$lib': 'taskera-flutter',
        'platform': defaultTargetPlatform.name,
        ...?props,
      },
    };
    try {
      await _client.post(
        Uri.parse('${AppConfig.posthogHost}/capture/'),
        headers: const {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );
    } catch (_) {
      // Analytics must never crash or block the app.
    }
  }

  /// Records the user's current settings as PostHog *person* properties (via
  /// `$set`), not just a one-off event — so later you can query "what % of
  /// users have quadColors on" / "least-picked accent" etc. across the whole
  /// user base to decide what to prune, rather than digging through a stream
  /// of change events. Call once per launch (immediate) via [captureSettingsSnapshot].
  Future<void> _setPersonProperties(Map<String, dynamic> props) =>
      capture('settings_snapshot', props: {r'$set': props});

  /// Same as above but fired on every settings change — debounced so a
  /// slider drag (wallpaper dim) or rapid toggling doesn't spam a request
  /// per tick; only the settled state after 2s of inactivity is sent.
  void captureSettingsSnapshot(Map<String, dynamic> props, {bool immediate = false}) {
    _settingsDebounce?.cancel();
    if (immediate) {
      _setPersonProperties(props);
      return;
    }
    _settingsDebounce = Timer(const Duration(seconds: 2), () => _setPersonProperties(props));
  }

  /// A screen / route view. [isBack] marks a pop (user navigated back).
  Future<void> screen(String route, {String? from, bool isBack = false}) =>
      capture('\$screen', props: {
        '\$screen_name': route,
        'route': route,
        'from': from,
        'direction': isBack ? 'back' : 'forward',
      });

  /// Listens to the router and emits a [screen] event on every navigation,
  /// inferring forward vs. back from a small location history. Idempotent.
  void attachToRouter(GoRouter router) {
    if (_routerAttached) return;
    _routerAttached = true;
    final history = <String>[];
    String? last;
    void onChange() {
      final loc = router.routerDelegate.currentConfiguration.uri.path;
      if (loc.isEmpty || loc == last) return;
      final isBack = history.length >= 2 && history[history.length - 2] == loc;
      screen(loc, from: last, isBack: isBack);
      if (isBack) {
        history.removeLast();
      } else {
        history.add(loc);
      }
      last = loc;
    }

    router.routerDelegate.addListener(onChange);
    onChange(); // capture the launch screen
  }

  String _randomId() {
    final r = Random.secure();
    final bytes = List<int>.generate(16, (_) => r.nextInt(256));
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }
}
