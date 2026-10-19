import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/announcement.dart';
import '../../data/providers/announcements_provider.dart';
import '../../theme/taskera_colors.dart';
import '../../theme/taskera_theme.dart';
import '../../widgets/add_back_button.dart';

/// Settings → Messages: broadcast announcements from the developer
/// ("Fixed the bug you reported ✓", "New feature shipped"). Opening the screen
/// marks everything read, clearing the unread badge.
class MessagesScreen extends ConsumerStatefulWidget {
  const MessagesScreen({super.key});

  @override
  ConsumerState<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends ConsumerState<MessagesScreen> {
  bool _marked = false;

  static String _ago(DateTime t) {
    final d = DateTime.now().difference(t);
    if (d.inMinutes < 1) return 'just now';
    if (d.inMinutes < 60) return '${d.inMinutes}m ago';
    if (d.inHours < 24) return '${d.inHours}h ago';
    if (d.inDays < 7) return '${d.inDays}d ago';
    return '${t.year}-${t.month.toString().padLeft(2, '0')}-${t.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final colors = TaskEraTheme.of(context).colors;
    final async = ref.watch(announcementsProvider);

    // Mark all read the first time data is available.
    if (async.hasValue && !_marked) {
      _marked = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) markAnnouncementsRead(ref);
      });
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 12, 6),
          child: Row(
            children: [
              AddBackButton(onTap: () => context.pop()),
              const SizedBox(width: 8),
              Expanded(
                child: Text('Message from Founder',
                    style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontVariations: const [FontVariation('wght', 600)], fontSize: 19, letterSpacing: -0.5, color: colors.ink)),
              ),
              GestureDetector(
                onTap: () => ref.invalidate(announcementsProvider),
                child: Icon(Icons.refresh_rounded, size: 20, color: colors.ink3),
              ),
            ],
          ),
        ),
        Expanded(
          child: async.when(
            loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
            error: (_, _) => _empty(colors, 'Couldn\'t load messages', 'Check your connection and pull to refresh.'),
            data: (list) {
              if (list.isEmpty) {
                return _empty(colors, 'No messages yet', 'Updates, fixes and new features will show up here.');
              }
              return RefreshIndicator(
                onRefresh: () async => ref.invalidate(announcementsProvider),
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 24),
                  itemCount: list.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, i) => _card(colors, list[i]),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _card(TaskEraColors colors, Announcement a) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surf2,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(width: 0.5, color: colors.bdr0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(a.emoji, style: TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0x120A84FF),
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(width: 0.5, color: const Color(0x330A84FF)),
                ),
                child: Text(a.kindLabel,
                    style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 10, fontWeight: FontWeight.w700, color: colors.textOrPlain(TaskEraColors.acc2))),
              ),
              const Spacer(),
              Text(_ago(a.createdAt),
                  style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 11, color: colors.ink3)),
            ],
          ),
          if (a.title.isNotEmpty) ...[
            const SizedBox(height: 9),
            Text(a.title,
                style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 14.5, fontWeight: FontWeight.w700, color: colors.ink, height: 1.25)),
          ],
          if (a.body.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(a.body,
                style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 13, color: colors.ink2, height: 1.5)),
          ],
        ],
      ),
    );
  }

  Widget _empty(TaskEraColors colors, String title, String sub) {
    return ListView(
      // ListView so pull-to-refresh still works in the empty state.
      children: [
        const SizedBox(height: 100),
        Center(
          child: Column(
            children: [
              const Text('📭', style: TextStyle(fontSize: 42)),
              const SizedBox(height: 12),
              Text(title, style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 15, fontWeight: FontWeight.w600, color: colors.ink)),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(sub, textAlign: TextAlign.center,
                    style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 13, color: colors.ink3, height: 1.4)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
