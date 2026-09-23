import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';

import '../util/platform_layout.dart';

abstract class OAuthHelper {
  static String codeVerifier() => _rnd(64);

  static String codeChallenge(String verifier) =>
      base64Url.encode(sha256.convert(utf8.encode(verifier)).bytes)
          .replaceAll('=', '');

  static String state([int n = 16]) => _rnd(n);

  static String _rnd(int n) {
    const c =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~';
    final r = Random.secure();
    return List.generate(n, (_) => c[r.nextInt(c.length)]).join();
  }

  static String get _scheme => isDesktop ? 'http' : 'taskeraapp';

  static String redirect(String path) =>
      isDesktop ? 'http://localhost' : 'taskeraapp://$path';

  /// Returns the callback URI on success, null if user cancelled, throws on error.
  static Future<String?> launch(String url) async {
    try {
      return await FlutterWebAuth2.authenticate(
          url: url, callbackUrlScheme: _scheme);
    } on PlatformException catch (e) {
      // User pressed back / closed the Custom Tab — not an error.
      if (e.code == 'CANCELED' || e.code == 'UserCancelled') return null;
      rethrow;
    }
  }

  static Future<bool> store(
    FlutterSecureStorage s, {
    required String key,
    required String? token,
    String? refreshKey,
    String? refresh,
  }) async {
    if (token == null) return false;
    await s.write(key: key, value: token);
    if (refreshKey != null && refresh != null) {
      await s.write(key: refreshKey, value: refresh);
    }
    return true;
  }
}
