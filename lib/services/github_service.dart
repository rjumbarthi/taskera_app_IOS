import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import 'oauth_helper.dart';

class GitHubService {
  GitHubService(this._s);
  final FlutterSecureStorage _s;

  static const _key      = 'github_access_token';
  static const _redirect = 'github-auth';
  static const _scopes   = 'repo,user';

  Future<bool> get isConnected async => await _s.read(key: _key) != null;

  Future<bool> connect() async {
    final st  = OAuthHelper.state();
    final uri = Uri.parse('https://github.com/login/oauth/authorize').replace(
      queryParameters: {
        'client_id'   : AppConfig.githubClientId,
        'redirect_uri': OAuthHelper.redirect(_redirect),
        'scope'       : _scopes,
        'state'       : st,
      },
    );
    final result = await OAuthHelper.launch(uri.toString());
    if (result == null) return false;
    final params = Uri.parse(result).queryParameters;
    if (params['state'] != st) return false;
    final code = params['code'];
    if (code == null) return false;

    try {
      final res = await http.post(
        Uri.parse('https://github.com/login/oauth/access_token'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded',
                  'Accept': 'application/json'},
        body: {
          'client_id'    : AppConfig.githubClientId,
          'client_secret': AppConfig.githubClientSecret,
          'code'         : code,
          'redirect_uri' : OAuthHelper.redirect(_redirect),
        },
      );
      if (res.statusCode != 200) return false;
      final token =
          (jsonDecode(res.body) as Map<String, dynamic>)['access_token']
              as String?;
      return OAuthHelper.store(_s, key: _key, token: token);
    } catch (_) {
      return false;
    }
  }

  Future<void> disconnect() => _s.delete(key: _key);
}

final githubServiceProvider = Provider<GitHubService>(
    (ref) => GitHubService(const FlutterSecureStorage()));
