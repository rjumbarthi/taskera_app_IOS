import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'secure_store.dart';
import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import 'oauth_helper.dart';

class SlackService {
  SlackService(this._s);
  final FlutterSecureStorage _s;

  static const _key      = 'slack_access_token';
  static const _redirect = 'slack-auth';
  static const _scopes   = 'channels:read,chat:write,im:read,users:read';

  Future<bool> get isConnected async => await _s.read(key: _key) != null;

  Future<bool> connect() async {
    final st  = OAuthHelper.state();
    final uri = Uri.parse('https://slack.com/oauth/v2/authorize').replace(
      queryParameters: {
        'client_id'   : AppConfig.slackClientId,
        'scope'       : _scopes,
        'redirect_uri': OAuthHelper.redirect(_redirect),
        'state'       : st,
      },
    );
    final result = await OAuthHelper.launch(uri.toString());
    if (result == null) return false;
    final params = Uri.parse(result).queryParameters;
    if (params['state'] != st) return false;
    final code = params['code'];
    if (code == null) return false;

    // Slack uses HTTP Basic auth for token exchange
    final creds = base64Encode(
        utf8.encode('${AppConfig.slackClientId}:${AppConfig.slackClientSecret}'));
    try {
      final res = await http.post(
        Uri.parse('https://slack.com/api/oauth.v2.access'),
        headers: {
          'Authorization': 'Basic $creds',
          'Content-Type' : 'application/x-www-form-urlencoded',
        },
        body: {
          'code'        : code,
          'redirect_uri': OAuthHelper.redirect(_redirect),
        },
      );
      if (res.statusCode != 200) return false;
      final body  = jsonDecode(res.body) as Map<String, dynamic>;
      if (body['ok'] != true) return false;
      final token = (body['access_token'] ??
          (body['authed_user'] as Map?)
              ?['access_token']) as String?;
      return OAuthHelper.store(_s, key: _key, token: token);
    } catch (_) {
      return false;
    }
  }

  Future<void> disconnect() => _s.delete(key: _key);
}

final slackServiceProvider = Provider<SlackService>(
    (ref) => SlackService(kSecureStorage));
