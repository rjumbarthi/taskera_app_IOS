import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import 'oauth_helper.dart';

class NotionService {
  NotionService(this._s);
  final FlutterSecureStorage _s;

  static const _key = 'notion_access_token';
  static const _redirect = 'notion-auth';

  Future<bool> get isConnected async => await _s.read(key: _key) != null;

  Future<bool> connect() async {
    final st  = OAuthHelper.state();
    final uri = Uri.parse('https://api.notion.com/v1/oauth/authorize').replace(
      queryParameters: {
        'client_id'    : AppConfig.notionClientId,
        'response_type': 'code',
        'owner'        : 'user',
        'redirect_uri' : OAuthHelper.redirect(_redirect),
        'state'        : st,
      },
    );
    final result = await OAuthHelper.launch(uri.toString());
    if (result == null) return false;
    final code = Uri.parse(result).queryParameters['code'];
    if (code == null) return false;
    return _exchange(code);
  }

  Future<bool> _exchange(String code) async {
    // Notion requires HTTP Basic auth (client_id:client_secret) + JSON body
    final creds = base64Encode(
        utf8.encode('${AppConfig.notionClientId}:${AppConfig.notionClientSecret}'));
    try {
      final res = await http.post(
        Uri.parse('https://api.notion.com/v1/oauth/token'),
        headers: {
          'Authorization': 'Basic $creds',
          'Content-Type' : 'application/json',
          'Accept'       : 'application/json',
        },
        body: jsonEncode({
          'grant_type'  : 'authorization_code',
          'code'        : code,
          'redirect_uri': OAuthHelper.redirect(_redirect),
        }),
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

final notionServiceProvider = Provider<NotionService>(
    (ref) => NotionService(const FlutterSecureStorage()));
