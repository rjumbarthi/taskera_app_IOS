import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'secure_store.dart';
import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import 'oauth_helper.dart';

class TodoistService {
  TodoistService(this._s);
  final FlutterSecureStorage _s;

  static const _key = 'todoist_access_token';

  Future<bool> get isConnected async => await _s.read(key: _key) != null;

  Future<bool> connect() async {
    final st  = OAuthHelper.state();
    final uri = Uri.parse('https://todoist.com/oauth/authorize').replace(
      queryParameters: {
        'client_id': AppConfig.todoistClientId,
        'scope'    : 'data:read,data:delete,task:add',
        'state'    : st,
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
        Uri.parse('https://todoist.com/oauth/access_token'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded',
                  'Accept': 'application/json'},
        body: {
          'client_id'    : AppConfig.todoistClientId,
          'client_secret': AppConfig.todoistClientSecret,
          'code'         : code,
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

final todoistServiceProvider = Provider<TodoistService>(
    (ref) => TodoistService(kSecureStorage));
