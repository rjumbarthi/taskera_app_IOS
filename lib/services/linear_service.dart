import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'secure_store.dart';
import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import 'oauth_helper.dart';

class LinearService {
  LinearService(this._s);
  final FlutterSecureStorage _s;

  static const _keyAccess  = 'linear_access_token';
  static const _keyRefresh = 'linear_refresh_token';
  static const _redirect   = 'linear-auth';
  static const _scopes     = 'read,issues:create,comments:create';

  Future<bool> get isConnected async =>
      await _s.read(key: _keyAccess) != null;

  Future<bool> connect() async {
    final verifier  = OAuthHelper.codeVerifier();
    final challenge = OAuthHelper.codeChallenge(verifier);
    final st        = OAuthHelper.state();

    final uri = Uri.parse('https://linear.app/oauth/authorize').replace(
      queryParameters: {
        'client_id'            : AppConfig.linearClientId,
        'redirect_uri'         : OAuthHelper.redirect(_redirect),
        'response_type'        : 'code',
        'scope'                : _scopes,
        'state'                : st,
        'code_challenge'       : challenge,
        'code_challenge_method': 'S256',
      },
    );
    final result = await OAuthHelper.launch(uri.toString());
    if (result == null) return false;
    final params = Uri.parse(result).queryParameters;
    if (params['state'] != st) return false;
    final code = params['code'];
    if (code == null) return false;
    return _exchange(code, verifier);
  }

  Future<bool> _exchange(String code, String verifier) async {
    try {
      final res = await http.post(
        Uri.parse('https://api.linear.app/oauth/token'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded',
                  'Accept': 'application/json'},
        body: {
          'grant_type'   : 'authorization_code',
          'client_id'    : AppConfig.linearClientId,
          'redirect_uri' : OAuthHelper.redirect(_redirect),
          'code'         : code,
          'code_verifier': verifier,
        },
      );
      if (res.statusCode != 200) return false;
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      return OAuthHelper.store(_s,
          key: _keyAccess, token: data['access_token'] as String?,
          refreshKey: _keyRefresh, refresh: data['refresh_token'] as String?);
    } catch (_) {
      return false;
    }
  }

  Future<void> disconnect() async {
    await _s.delete(key: _keyAccess);
    await _s.delete(key: _keyRefresh);
  }
}

final linearServiceProvider = Provider<LinearService>(
    (ref) => LinearService(kSecureStorage));
