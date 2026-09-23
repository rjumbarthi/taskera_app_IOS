import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/providers/conflicts_provider.dart';
import '../../data/providers/reminders_provider.dart';
import '../../data/providers/tasks_provider.dart';
import '../../l10n/app_l10n.dart';
import '../../routing/routes.dart';
import '../../services/activity_log_service.dart';
import '../../settings/taskera_settings.dart';
import '../../theme/taskera_colors.dart';
import '../../theme/taskera_theme.dart';
import '../../widgets/add_back_button.dart';
import '../../widgets/taskera_top_bar.dart';
import '../../widgets/wallpaper_background.dart';

// ── Model ─────────────────────────────────────────────────────────────────────

class _Notif {
  final String key;
  final String emoji;
  final Color iconBg;
  final String title;
  final String sub;
  final DateTime time;
  final String deepRoute;
  final bool alert; // true = red-bordered priority alert

  const _Notif({
    required this.key,
    required this.emoji,
    required this.iconBg,
    required this.title,
    required this.sub,
    required this.time,
    required this.deepRoute,
    this.alert = false,
  });
}

String _relTime(DateTime t) {
  final d = DateTime.now().difference(t);
  if (d.inMinutes < 1) return 'Just now';
  if (d.inMinutes < 60) return '${d.inMinutes}m ago';
  if (d.inHours < 24) return '${d.inHours}h ago';
  if (d.inDays == 1) return '1 day ago';
  return '${d.inDays} days ago';
}

(String, Color) _typeIcon(String type) => switch (type) {
      'habit' => ('🔁', const Color(0x1AFFB900)),
      'note' => ('📝', const Color(0x1ABF5AF2)),
      'goal' => ('🎯', const Color(0x1A7FBA00)),
      'calendar' => ('📅', TaskEraColors.accBg),
      'checklist' => ('☑', TaskEraColors.accBg),
      _ => ('📋', TaskEraColors.accBg),
    };

String _typeRoute(String type) => switch (type) {
      'habit' => TaskEraRoutes.habits,
      'note' => TaskEraRoutes.notes,
      'goal' => TaskEraRoutes.focus,
      'calendar' => TaskEraRoutes.cal,
      _ => TaskEraRoutes.tasks,
    };

// ── Screen ────────────────────────────────────────────────────────────────────

class NotificationCenterScreen extends ConsumerStatefulWidget {
  const NotificationCenterScreen({super.key});

  @override
  ConsumerState<NotificationCenterScreen> createState() =>
      _NotificationCenterScreenState();
}

class _NotificationCenterScreenState
    extends ConsumerState<NotificationCenterScreen> {
  final _dismissed = <String>{};

  /// Build the live notification feed: derived alerts (overdue tasks,
  /// conflicts, reminders due today) + the real activity log.
  List<_Notif> _buildFeed() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final out = <_Notif>[];

    // 1) Overdue tasks
    final tasks = ref.watch(allTasksProvider).value ?? [];
    final overdue = tasks
        .where((t) =>
            !t.isDone &&
            t.dueDate != null &&
            DateTime(t.dueDate!.year, t.dueDate!.month, t.dueDate!.day).isBefore(today))
        .toList();
    if (overdue.isNotEmpty) {
      final titles = overdue.take(3).map((t) => t.title).join(', ');
      final extra = overdue.length > 3 ? ' +${overdue.length - 3} more' : '';
      out.add(_Notif(
        key: 'overdue',
        emoji: '⚡',
        iconBg: const Color(0x1FF25022),
        title: '${overdue.length} task${overdue.length == 1 ? '' : 's'} overdue',
        sub: '$titles$extra',
        time: now,
        deepRoute: TaskEraRoutes.tasks,
        alert: true,
      ));
    }

    // 2) Scheduling conflicts
    final conflicts = ref.watch(conflictsProvider);
    if (conflicts.isNotEmpty) {
      final c = conflicts.first;
      out.add(_Notif(
        key: 'conflicts',
        emoji: '📅',
        iconBg: const Color(0x1FF25022),
        title: '${conflicts.length} scheduling conflict${conflicts.length == 1 ? '' : 's'}',
        sub: '${c.a.title} clashes with ${c.b.title}',
        time: now,
        deepRoute: TaskEraRoutes.calConflicts,
        alert: true,
      ));
    }

    // 3) Reminders due today
    final reminders = ref.watch(remindersProvider);
    for (final r in reminders) {
      final w = r.when;
      if (w.year == today.year && w.month == today.month && w.day == today.day) {
        final h = w.hour % 12 == 0 ? 12 : w.hour % 12;
        final ampm = w.hour < 12 ? 'AM' : 'PM';
        out.add(_Notif(
          key: 'rem:${r.id}',
          emoji: r.isAlarm ? '⏰' : '🔔',
          iconBg: r.isAlarm ? const Color(0x1AFF453A) : TaskEraColors.accBg,
          title: r.label.isEmpty ? (r.isAlarm ? 'Alarm' : 'Reminder') : r.label,
          sub: 'Today · $h:${w.minute.toString().padLeft(2, '0')} $ampm',
          time: w,
          deepRoute: TaskEraRoutes.cal,
        ));
      }
    }

    // 4) Activity log (real, timestamped)
    final logs = ref.watch(activityLogProvider).value ?? [];
    for (final l in logs) {
      final (emoji, bg) = _typeIcon(l.type);
      out.add(_Notif(
        key: 'log:${l.timestamp.millisecondsSinceEpoch}:${l.message.hashCode}',
        emoji: emoji,
        iconBg: bg,
        title: l.message,
        sub: '',
        time: l.timestamp,
        deepRoute: _typeRoute(l.type),
      ));
    }

    out.sort((a, b) => b.time.compareTo(a.time));
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final colors = TaskEraTheme.of(context).colors;
    final safeBot = MediaQuery.of(context).padding.bottom;
    final wallpaper = ref.watch(taskeraSettingsProvider).wallpaper;

    final feed = _buildFeed().where((n) => !_dismissed.contains(n.key)).toList();

    final now = DateTime.now();
    bool sameDay(DateTime t, int offset) {
      final ref = DateTime(now.year, now.month, now.day).subtract(Duration(days: offset));
      return t.year == ref.year && t.month == ref.month && t.day == ref.day;
    }

    final todayItems = feed.where((n) => sameDay(n.time, 0)).toList();
    final yesterdayItems = feed.where((n) => sameDay(n.time, 1)).toList();
    final earlierItems = feed
        .where((n) => !sameDay(n.time, 0) && !sameDay(n.time, 1))
        .toList();

    return Stack(children: [
      Positioned.fill(child: WallpaperBackground(wallpaper: wallpaper)),
      Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          TaskEraTopBar(
            title: AppL10n.of(context).notifications,
            leading: AddBackButton(onTap: () => context.pop()),
            actions: [
              if (feed.isNotEmpty)
                GestureDetector(
                  onTap: () => setState(() => _dismissed.addAll(feed.map((n) => n.key))),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    child: Text(AppL10n.of(context).clearAll,
                        style: TextStyle(
                            fontFamily: 'Inter', fontSize: 12, color: colors.ink3, height: 1)),
                  ),
                ),
            ],
          ),
          Expanded(
            child: feed.isEmpty
                ? _EmptyState(colors: colors)
                : ListView(
                    padding: EdgeInsets.fromLTRB(12, 6, 12, safeBot + 24),
                    children: [
                      if (todayItems.isNotEmpty) ...[
                        _GroupLabel('TODAY', colors),
                        for (final n in todayItems) _tile(n, colors),
                        const SizedBox(height: 4),
                      ],
                      if (yesterdayItems.isNotEmpty) ...[
                        _GroupLabel('YESTERDAY', colors),
                        for (final n in yesterdayItems) _tile(n, colors),
                        const SizedBox(height: 4),
                      ],
                      if (earlierItems.isNotEmpty) ...[
                        _GroupLabel('EARLIER', colors),
                        for (final n in earlierItems) _tile(n, colors),
                      ],
                    ],
                  ),
          ),
        ]),
      ),
    ]);
  }

  Widget _tile(_Notif n, TaskEraColors colors) => _NotifTile(
        notif: n,
        colors: colors,
        onTap: () => context.push(n.deepRoute),
        onDismiss: () => setState(() => _dismissed.add(n.key)),
      );
}

// ── Notification tile ─────────────────────────────────────────────────────────

class _NotifTile extends StatelessWidget {
  final _Notif notif;
  final TaskEraColors colors;
  final VoidCallback onTap;
  final VoidCallback onDismiss;
  const _NotifTile({
    required this.notif,
    required this.colors,
    required this.onTap,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 5),
        padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
        decoration: BoxDecoration(
          color: colors.surf2,
          borderRadius: BorderRadius.circular(11),
          border: Border.all(
              width: 0.5, color: notif.alert ? const Color(0x33F25022) : colors.bdr),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 28, height: 28,
            decoration: BoxDecoration(color: notif.iconBg, borderRadius: BorderRadius.circular(8)),
            alignment: Alignment.center,
            child: Text(notif.emoji, style: const TextStyle(fontSize: 13)),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(notif.title,
                  style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: colors.ink,
                      height: 1.2)),
              if (notif.sub.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(notif.sub,
                    style: TextStyle(
                        fontFamily: 'Inter', fontSize: 11, color: colors.ink3, height: 1.35)),
              ],
              const SizedBox(height: 3),
              Text(_relTime(notif.time),
                  style: TextStyle(
                      fontFamily: 'Inter', fontSize: 10, color: colors.ink3, height: 1)),
            ]),
          ),
          GestureDetector(
            onTap: onDismiss,
            child: Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                child: Text('✕',
                    style: TextStyle(
                        fontFamily: 'Inter', fontSize: 13, color: colors.ink3, height: 1))),
          ),
        ]),
      ),
    );
  }
}

// ── Group label ───────────────────────────────────────────────────────────────

class _GroupLabel extends StatelessWidget {
  final String text;
  final TaskEraColors colors;
  const _GroupLabel(this.text, this.colors);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 4, 0, 6),
      child: Text(text,
          style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
              color: colors.ink3,
              height: 1)),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final TaskEraColors colors;
  const _EmptyState({required this.colors});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('🔔', style: TextStyle(fontSize: 40)),
        const SizedBox(height: 12),
        Text(AppL10n.of(context).allCaughtUp,
            style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: colors.ink,
                height: 1.2)),
        const SizedBox(height: 4),
        Text(AppL10n.of(context).noNewNotifications,
            style: TextStyle(
                fontFamily: 'Inter', fontSize: 12, color: colors.ink3, height: 1.4)),
      ]),
    );
  }
}
