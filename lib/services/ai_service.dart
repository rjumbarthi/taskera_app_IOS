import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// All AI calls are proxied through the Supabase Edge Function `ai-proxy`.
/// The function holds the Anthropic / OpenAI API keys as secrets — they never
/// touch the client.  Claude is tried first; OpenAI is the fallback.
class AiService {
  AiService(this._client);
  final SupabaseClient _client;

  // ── Low-level invoke ───────────────────────────────────────────────────────

  Future<String?> _invoke(String action, String content) async {
    final res = await _client.functions.invoke(
      'ai-proxy',
      body: {'action': action, 'content': content},
    );
    final data = res.data is String ? jsonDecode(res.data) : res.data;
    return (data as Map<String, dynamic>?)?['result'] as String?;
  }

  // ── Public helpers ─────────────────────────────────────────────────────────

  /// Returns a 1-2 sentence summary of a note body.
  Future<String?> summarizeNote(String noteBody) =>
      _invoke('summarize_note', noteBody);

  /// Returns `{'urgency': N, 'importance': N, 'quadrant': N, 'reason': '...'}`.
  Future<Map<String, dynamic>?> scoreTask(String taskTitle) async {
    final raw = await _invoke('score_task', taskTitle);
    if (raw == null) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  /// Returns `{'q1': [...], 'q2': [...], 'q3': [...], 'q4': [...], 'summary': '...'}`.
  Future<Map<String, dynamic>?> processBrainDump(String text) async {
    final raw = await _invoke('brain_dump', text);
    if (raw == null) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  /// Returns `{'context':'...','tasks':[{'title':'...','quadrant':N}],'checklist':[...],'goals':[...]}`.
  Future<Map<String, dynamic>?> suggestContext(String text) async {
    final raw = await _invoke('suggest_context', text);
    if (raw == null) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  /// Returns a list of `{'title': '...', 'detail': '...'}` insight objects.
  Future<List<Map<String, String>>> getInsights(String context) async {
    final raw = await _invoke('insights', context);
    if (raw == null) return [];
    try {
      final data = jsonDecode(raw) as Map<String, dynamic>;
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
  (ref) => AiService(Supabase.instance.client),
);
