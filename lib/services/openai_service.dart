import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class OpenAiService {
  OpenAiService(this._s);
  final FlutterSecureStorage _s;

  static const _key = 'openai_api_key';

  Future<bool> get isConnected async => await _s.read(key: _key) != null;

  /// Validates [apiKey] against OpenAI's /models endpoint, stores on success.
  Future<bool> setKey(String apiKey) async {
    try {
      final res = await http.get(
        Uri.parse('https://api.openai.com/v1/models'),
        headers: {'Authorization': 'Bearer $apiKey'},
      );
      if (res.statusCode != 200) return false;
      // Confirm it's a real models list
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      if (body['object'] != 'list') return false;
      await _s.write(key: _key, value: apiKey);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<String?> getKey() => _s.read(key: _key);

  Future<void> disconnect() => _s.delete(key: _key);
}

final openAiServiceProvider = Provider<OpenAiService>(
    (ref) => OpenAiService(const FlutterSecureStorage()));
