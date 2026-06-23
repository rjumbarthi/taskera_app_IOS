import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_l10n.dart';
import '../../routing/routes.dart';
import '../../settings/kaal_settings.dart';
import '../../theme/kaal_colors.dart';
import '../../theme/kaal_theme.dart';
import '../../widgets/add_back_button.dart';
import '../../widgets/kaal_top_bar.dart';
import '../../widgets/wallpaper_background.dart';

// ── Data ──────────────────────────────────────────────────────────────────────

class _Notif {
  final int id;
  final String emoji;
  final Color iconBg;
  final String title;
  final String sub;
  final String time;
  final String deepRoute;
  final bool preRead;
  const _Notif(this.id, this.emoji, this.iconBg, this.title, this.sub, this.time,
      {required this.deepRoute, this.preRead = false});
}

const _today = [
  _Notif(0, '⚡', Color(0x1FF25022), '3 Q1 tasks overdue',
      'Assignment submission, Client call prep, Bug fix #204', '2h ago',
      deepRoute: KaalRoutes.tasks),
  _Notif(1, '🎯', Color(0x1A7FBA00), 'Q2 neglected for 3 days',
      'No important tasks completed since Tuesday', '5h ago',
      deepRoute: KaalRoutes.tasks),
  _Notif(2, '🔥', Color(0x1AFFB900), '14-day streak milestone!',
      'Tap to claim your badge', '8h ago',
      deepRoute: KaalRoutes.habits),
];

const _yesterday = [
  _Notif(3, '📋', KaalColors.accBg, 'Weekly review due',
      'Week 17 summary ready to generate', '1 day ago',
      deepRoute: KaalRoutes.focus, preRead: true),
  _Notif(4, '✦', Color(0x1ABF5AF2), 'Gmail sync complete',
      '4 new tasks extracted from inbox', '1 day ago',
      deepRoute: KaalRoutes.inbox, preRead: true),
];

// ── Screen ────────────────────────────────────────────────────────────────────

class NotificationCenterScreen extends ConsumerStatefulWidget {
  const NotificationCenterScreen({super.key});

  @override
  ConsumerState<NotificationCenterScreen> createState() =>
      _NotificationCenterScreenState();
}

class _NotificationCenterScreenState
    extends ConsumerState<NotificationCenterScreen> {
  final _dismissed = <int>{};

  bool get _allGone => _dismissed.containsAll([0, 1, 2]);

  @override
  Widget build(BuildContext context) {
    final colors    = KaalTheme.of(context).colors;
    final safeBot   = MediaQuery.of(context).padding.bottom;
    final wallpaper = ref.watch(kaalSettingsProvider).wallpaper;

    return Stack(children: [
      Positioned.fill(child: WallpaperBackground(wallpaper: wallpaper)),
      Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          KaalTopBar(
            title: AppL10n.of(context).notifications,
            leading: AddBackButton(onTap: () => context.pop()),
            actions: [
              GestureDetector(
                onTap: () => setState(() => _dismissed.addAll([0, 1, 2])),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: Text(AppL10n.of(context).clearAll,
                      style: TextStyle(fontFamily: 'Inter', fontSize: 12,
                          color: colors.ink3, height: 1)),
                ),
              ),
            ],
          ),
          Expanded(
            child: _allGone
                ? _EmptyState(colors: colors)
                : ListView(
                    padding: EdgeInsets.fromLTRB(12, 6, 12, safeBot + 24),
                    children: [
                      _GroupLabel('TODAY', colors),
                      for (final n in _today)
                        if (!_dismissed.contains(n.id))
                          _NotifTile(
                            notif: n, colors: colors,
                            onTap: () => context.push(n.deepRoute),
                            onDismiss: () => setState(() => _dismissed.add(n.id)),
                          ),
                      const SizedBox(height: 4),
                      _GroupLabel('YESTERDAY', colors),
                      for (final n in _yesterday)
                        _NotifTile(notif: n, colors: colors,
                            onTap: () => context.push(n.deepRoute), onDismiss: null),
                    ],
                  ),
          ),
        ]),
      ),
    ]);
  }
}

// ── Notification tile ─────────────────────────────────────────────────────────

class _NotifTile extends StatelessWidget {
  final _Notif notif;
  final KaalColors colors;
  final VoidCallback onTap;
  final VoidCallback? onDismiss;
  const _NotifTile({required this.notif, required this.colors,
      required this.onTap, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
      opacity: notif.preRead ? 0.6 : 1.0,
      child: Container(
        margin: const EdgeInsets.only(bottom: 5),
        padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
        decoration: BoxDecoration(
          color: const Color(0x0DFFFFFF),
          borderRadius: BorderRadius.circular(11),
          border: Border.all(width: 0.5,
              color: notif.id == 0 ? const Color(0x33F25022) : colors.bdr),
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
                  style: TextStyle(fontFamily: 'Inter', fontSize: 13,
                      fontWeight: FontWeight.w600, color: colors.ink, height: 1.2)),
              const SizedBox(height: 2),
              Text(notif.sub,
                  style: TextStyle(fontFamily: 'Inter', fontSize: 11,
                      color: colors.ink3, height: 1.35)),
              const SizedBox(height: 3),
              Text(notif.time,
                  style: TextStyle(fontFamily: 'Inter', fontSize: 10,
                      color: colors.ink3, height: 1)),
            ]),
          ),
          if (onDismiss != null)
            GestureDetector(
              onTap: onDismiss,
              child: Container(width: 28, height: 28, alignment: Alignment.center,
                  child: Text('✕', style: TextStyle(fontFamily: 'Inter', fontSize: 13,
                      color: colors.ink3, height: 1))),
            ),
        ]),
      ),
    ));
  }
}

// ── Group label ───────────────────────────────────────────────────────────────

class _GroupLabel extends StatelessWidget {
  final String text;
  final KaalColors colors;
  const _GroupLabel(this.text, this.colors);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 4, 0, 6),
      child: Text(text,
          style: TextStyle(fontFamily: 'Inter', fontSize: 9,
              fontWeight: FontWeight.w700, letterSpacing: 0.5,
              color: colors.ink3, height: 1)),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final KaalColors colors;
  const _EmptyState({required this.colors});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text('🔔', style: const TextStyle(fontSize: 40)),
        const SizedBox(height: 12),
        Text(AppL10n.of(context).allCaughtUp,
            style: TextStyle(fontFamily: 'Inter', fontSize: 15,
                fontWeight: FontWeight.w600, color: colors.ink, height: 1.2)),
        const SizedBox(height: 4),
        Text(AppL10n.of(context).noNewNotifications,
            style: TextStyle(fontFamily: 'Inter', fontSize: 12,
                color: colors.ink3, height: 1.4)),
      ]),
    );
  }
}
