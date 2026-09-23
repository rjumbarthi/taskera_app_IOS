import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'openai_service.dart';

/// All AI calls are proxied through the Supabase Edge Function `ai-proxy`.
/// The function holds the Anthropic / OpenAI API keys as secrets — they never
/// touch the client.  Claude is tried first; OpenAI is the fallback.
class AiService {
  AiService(this._client, [this._getUserCreds]);
  final SupabaseClient _client;
  // When the user has connected their own AI provider (Settings → Integrations →
  // OpenAI or Claude), their (provider, key) is sent to the proxy so ALL AI
  // features run on the provider they chose.
  final Future<({String provider, String key})?> Function()? _getUserCreds;

  // ── Low-level invoke ───────────────────────────────────────────────────────

  Future<String?> _invoke(String action, String content) async {
    final creds = await _getUserCreds?.call();
    final res = await _client.functions.invoke(
      'ai-proxy',
      body: {
        'action': action,
        'content': content,
        if (creds != null) 'provider': creds.provider,
        if (creds != null) 'apiKey': creds.key,
      },
    );
    final data = res.data is String ? jsonDecode(res.data) : res.data;
    final map = data as Map<String, dynamic>?;
    // Surface server-side failures (missing API key, upstream error, etc.)
    // instead of silently returning null → "AI returned no results".
    final err = map?['error'];
    if (err != null) throw Exception(err.toString());
    return map?['result'] as String?;
  }

  /// Models often wrap JSON in ```json … ``` fences or add prose despite being
  /// told "JSON only". Strip fences and fall back to the outermost `{…}` block
  /// so a valid response is never dropped on a parse error.
  static Map<String, dynamic>? _decodeObject(String? raw) {
    if (raw == null) return null;
    var t = raw.trim();
    if (t.startsWith('```')) {
      t = t.replaceFirst(RegExp(r'^```[a-zA-Z]*\s*'), '');
      if (t.endsWith('```')) t = t.substring(0, t.length - 3);
      t = t.trim();
    }
    try {
      return jsonDecode(t) as Map<String, dynamic>;
    } catch (_) {
      final start = t.indexOf('{');
      final end = t.lastIndexOf('}');
      if (start >= 0 && end > start) {
        try {
          return jsonDecode(t.substring(start, end + 1)) as Map<String, dynamic>;
        } catch (_) {}
      }
      return null;
    }
  }

  // ── Public helpers ─────────────────────────────────────────────────────────

  /// Returns a 1-2 sentence summary of a note body.
  Future<String?> summarizeNote(String noteBody) =>
      _invoke('summarize_note', noteBody);

  /// Returns `{'urgency': N, 'importance': N, 'quadrant': N, 'reason': '...'}`.
  Future<Map<String, dynamic>?> scoreTask(String taskTitle) async {
    final raw = await _invoke('score_task', taskTitle);
    return _decodeObject(raw);
  }

  /// Returns `{'q1': [...], 'q2': [...], 'q3': [...], 'q4': [...], 'summary': '...'}`.
  Future<Map<String, dynamic>?> processBrainDump(String text) async {
    final raw = await _invoke('brain_dump', text);
    return _decodeObject(raw);
  }

  /// Returns `{'context':'...','tasks':[{'title':'...','quadrant':N}],'checklist':[...],'goals':[...]}`.
  Future<Map<String, dynamic>?> suggestContext(String text) async {
    final raw = await _invoke('suggest_context', text);
    return _decodeObject(raw);
  }

  /// Returns a list of `{'title': '...', 'detail': '...'}` insight objects.
  Future<List<Map<String, String>>> getInsights(String context) async {
    final raw = await _invoke('insights', context);
    final data = _decodeObject(raw);
    if (data == null) return [];
    try {
      final list = (data['insights'] as List<dynamic>? ?? []);
      return list.cast<Map<String, dynamic>>().map((e) => {
        'title' : (e['title']  as String?) ?? '',
        'detail': (e['detail'] as String?) ?? '',
      }).toList();
    } catch (_) {
      return [];
    }
  }
}

final aiServiceProvider = Provider<AiService>(
  (ref) => AiService(
    Supabase.instance.client,
    () async {
      // Use whichever provider the user connected; Claude wins if both are set,
      // otherwise fall back to TaskEra's managed keys.
      final anth = await ref.read(anthropicServiceProvider).getKey();
      if (anth != null && anth.isNotEmpty) return (provider: 'anthropic', key: anth);
      final oai = await ref.read(openAiServiceProvider).getKey();
      if (oai != null && oai.isNotEmpty) return (provider: 'openai', key: oai);
      return null;
    },
  ),
);
