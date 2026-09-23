import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../config/app_config.dart';
import '../../settings/prefs_provider.dart';
import '../models/announcement.dart';

// SUPABASE SETUP (run once in the SQL editor — see MESSAGES_SETUP.md):
//   create table public.announcements (
//     id bigint generated always as identity primary key,
//     title text not null, body text not null,
//     kind text not null default 'update',
//     created_at timestamptz not null default now(),
//     published boolean not null default true);
//   alter table public.announcements enable row level security;
//   create policy "read published" on public.announcements
//     for select using (published = true);
// The developer INSERTs rows (dashboard). No insert policy = users can't post.

const _kLastSeenKey = 'taskera.msgs.lastSeenId';

bool get _backendConfigured =>
    !AppConfig.supabaseUrl.contains('YOUR_PROJECT_REF') &&
    !AppConfig.supabaseAnonKey.contains('YOUR_SUPABASE');

/// All published announcements, newest first. Returns an empty list when the
/// backend isn't configured or the fetch fails (offline) — never throws.
final announcementsProvider = FutureProvider<List<Announcement>>((ref) async {
  if (!_backendConfigured) return const [];
  try {
    final rows = await Supabase.instance.client
        .from('announcements')
        .select()
        .order('created_at', ascending: false)
        .limit(100);
    return (rows as List)
        .whereType<Map<String, dynamic>>()
        .map(Announcement.fromJson)
        .toList();
  } catch (_) {
    return const [];
  }
});

/// The highest announcement id the user has seen. Backed by SharedPreferences,
/// but held in a StateProvider so the unread badge updates instantly when the
/// user opens the Messages screen.
final msgLastSeenProvider = StateProvider<int>(
  (ref) => ref.watch(sharedPreferencesProvider).getInt(_kLastSeenKey) ?? 0,
);

/// Number of unread announcements (id greater than the last-seen id).
final unreadAnnouncementCountProvider = Provider<int>((ref) {
  final list = ref.watch(announcementsProvider).valueOrNull ?? const [];
  final lastSeen = ref.watch(msgLastSeenProvider);
  return list.where((a) => a.id > lastSeen).length;
});

/// Mark every currently-loaded announcement as read (persist + update badge).
Future<void> markAnnouncementsRead(WidgetRef ref) async {
  final list = ref.read(announcementsProvider).valueOrNull ?? const [];
  if (list.isEmpty) return;
  final maxId = list.map((a) => a.id).reduce((a, b) => a > b ? a : b);
  if (maxId <= ref.read(msgLastSeenProvider)) return;
  ref.read(msgLastSeenProvider.notifier).state = maxId;
  await ref.read(sharedPreferencesProvider).setInt(_kLastSeenKey, maxId);
}
