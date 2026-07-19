import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../config/app_config.dart';

// Remote feature flags, controlled from a Supabase table so features can be
// turned on/off without shipping a new app build.
//
// SUPABASE SETUP (run once — see FEATURE_FLAGS_SETUP.md):
//   create table public.app_flags (
//     key text primary key,
//     enabled boolean not null default false
//   );
//   alter table public.app_flags enable row level security;
//   create policy "read flags" on public.app_flags for select using (true);
//   insert into public.app_flags (key, enabled) values
//     ('gmail', false), ('calendar', false);
// Flip a feature by setting its `enabled` value in the table.

bool get _backendConfigured =>
    !AppConfig.supabaseUrl.contains('YOUR_PROJECT_REF') &&
    !AppConfig.supabaseAnonKey.contains('YOUR_SUPABASE');

/// All remote flags as a key→enabled map. Empty (⇒ everything off) when the
/// backend isn't configured or the fetch fails — features fail *closed*, which
/// is the safe default for un-verified OAuth scopes.
final remoteFlagsProvider = FutureProvider<Map<String, bool>>((ref) async {
  if (!_backendConfigured) return const {};
  try {
    final rows = await Supabase.instance.client
        .from('app_flags')
        .select('key,enabled');
    final map = <String, bool>{};
    for (final r in (rows as List)) {
      if (r is Map) {
        final k = r['key'] as String?;
        final v = r['enabled'] as bool?;
        if (k != null && v != null) map[k] = v;
      }
    }
    return map;
  } catch (_) {
    return const {};
  }
});

bool _flag(Ref ref, String key) =>
    ref.watch(remoteFlagsProvider).valueOrNull?[key] ?? false;

/// Generic remote flag by key — `ref.watch(featureEnabledProvider('microsoft'))`.
/// Any gated feature can read this; add its key to the `app_flags` table to
/// turn it on without a rebuild. Unknown/absent keys read `false` (fail-closed).
final featureEnabledProvider =
    Provider.family<bool, String>((ref, key) => _flag(ref, key));

/// Gmail inbox feature (`gmail.readonly`, restricted scope). Off until Google
/// OAuth verification + CASA clear, then set `gmail = true` in `app_flags`.
final gmailEnabledProvider = Provider<bool>((ref) => _flag(ref, 'gmail'));

/// Google Calendar feature (`calendar.events.readonly`, sensitive scope).
final calendarEnabledProvider = Provider<bool>((ref) => _flag(ref, 'calendar'));

/// Microsoft sign-in (Azure OAuth via Supabase). Implemented; flip on once the
/// Azure provider + client id are configured.
final microsoftSignInEnabledProvider =
    Provider<bool>((ref) => _flag(ref, 'microsoft'));
