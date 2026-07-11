import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'secure_store.dart';
import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import 'oauth_helper.dart';

class JiraService {
  JiraService(this._s);
  final FlutterSecureStorage _s;

  static const _keyAccess  = 'jira_access_token';
  static const _keyRefresh = 'jira_refresh_token';
  static const _redirect   = 'jira-auth';
  static const _scopes     =
      'read:jira-user read:jira-work write:jira-work offline_access';

  Future<bool> get isConnected async =>
      await _s.read(key: _keyAccess) != null;

  Future<bool> connect() async {
    final verifier  = OAuthHelper.codeVerifier();
    final challenge = OAuthHelper.codeChallenge(verifier);
    final st        = OAuthHelper.state();

    final uri = Uri.parse('https://auth.atlassian.com/authorize').replace(
      queryParameters: {
        'audience'             : 'api.atlassian.com',
        'client_id'            : AppConfig.jiraClientId,
        'scope'                : _scopes,
        'redirect_uri'         : OAuthHelper.redirect(_redirect),
        'state'                : st,
        'response_type'        : 'code',
        'prompt'               : 'consent',
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
        Uri.parse('https://auth.atlassian.com/oauth/token'),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: jsonEncode({
          'grant_type'   : 'authorization_code',
          'client_id'    : AppConfig.jiraClientId,
          'code'         : code,
          'redirect_uri' : OAuthHelper.redirect(_redirect),
          'code_verifier': verifier,
        }),
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

final jiraServiceProvider = Provider<JiraService>(
    (ref) => JiraService(kSecureStorage));
