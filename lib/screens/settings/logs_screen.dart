import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../services/activity_log_service.dart';
import '../../theme/taskera_colors.dart';
import '../../theme/taskera_theme.dart';
import '../../widgets/add_back_button.dart';
import '../../widgets/wallpaper_background.dart';
import '../../l10n/app_l10n.dart';
import '../../settings/taskera_settings.dart';

class LogsScreen extends ConsumerWidget {
  final bool standalone;
  const LogsScreen({super.key, this.standalone = true});

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors    = TaskEraTheme.of(context).colors;
    final logsAsync = ref.watch(activityLogProvider);

    Widget logList = logsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator(color: TaskEraColors.acc)),
      error: (_, _) => Center(
        child: Text('Could not load logs', style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: colors.ink3)),
      ),
      data: (logs) => logs.isEmpty
          ? _EmptyState(colors: colors)
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 32),
              itemCount: logs.length,
              itemBuilder: (_, i) => _LogRow(
                log: logs[i],
                colors: colors,
                showDate: i == 0 || !_sameDay(logs[i].timestamp, logs[i - 1].timestamp),
              ),
            ),
    );

    // Branch sub-screen: no own shell — AppShell provides background + top bar
    if (!standalone) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            child: Row(
              children: [
                AddBackButton(onTap: () => context.pop()),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(AppL10n.of(context).activityLog,
                      style: TextStyle(fontFamily: 'Fraunces', fontVariations: [FontVariation('wght', 600)], fontSize: 19, letterSpacing: -0.5,
                          color: colors.ink, height: 1.1)),
                ),
                GestureDetector(
                  onTap: () => ref.read(activityLogProvider.notifier).clear(),
                  child: Text(AppL10n.of(context).clearAll, style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: colors.ink3)),
                ),
              ],
            ),
          ),
          Expanded(child: logList),
        ],
      );
    }

    // Standalone: own WallpaperBackground + Scaffold + sub-header
    final safeTop   = MediaQuery.of(context).padding.top;
    final wallpaper = ref.watch(taskeraSettingsProvider).wallpaper;
    return Stack(
      children: [
        Positioned.fill(child: WallpaperBackground(wallpaper: wallpaper)),
        Scaffold(
          backgroundColor: Colors.transparent,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(8, safeTop > 0 ? safeTop : 12, 12, 6),
                child: Row(children: [
                  AddBackButton(onTap: () => context.pop()),
                  const SizedBox(width: 8),
                  Expanded(child: Text(AppL10n.of(context).activityLog,
                      style: TextStyle(fontFamily: 'Fraunces', fontVariations: [FontVariation('wght', 600)], fontSize: 19, letterSpacing: -0.5,
                          color: colors.ink, height: 1.1))),
                  GestureDetector(
                    onTap: () => ref.read(activityLogProvider.notifier).clear(),
                    child: Text(AppL10n.of(context).clearAll,
                        style: TextStyle(fontFamily: 'Inter', fontSize: 12,
                            color: colors.ink3, height: 1)),
                  ),
                ]),
              ),
              Expanded(child: logList),
            ],
          ),
        ),
      ],
    );
  }
}


// ── Log row ───────────────────────────────────────────────────────────────────

class _LogRow extends StatelessWidget {
  final ActivityLog log;
  final TaskEraColors colors;
  final bool showDate;
  const _LogRow({required this.log, required this.colors, required this.showDate});

  static const _typeIcon = {
    'task':      '✓',
    'checklist': '📋',
    'goal':      '🎯',
    'note':      '📝',
    'habit':     '🔥',
    'calendar':  '📅',
  };

  static const _typeColor = {
    'task':      TaskEraColors.acc,
    'checklist': Color(0xFF00BCD4),
    'goal':      Color(0xFF7FBA00),
    'note':      Color(0xFFBF5AF2),
    'habit':     TaskEraColors.q4,
    'calendar':  Color(0xFFFF6B00),
  };

  @override
  Widget build(BuildContext context) {
    final icon  = _typeIcon[log.type] ?? '·';
    final color = _typeColor[log.type] ?? TaskEraColors.acc;
    final time  = _fmtTime(log.timestamp);
    final date  = _fmtDate(log.timestamp);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showDate)
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 12, 0, 6),
            child: Text(date.toUpperCase(),
                style: TextStyle(fontFamily: 'Inter', fontSize: 9,
                    fontWeight: FontWeight.w700, color: colors.ink3,
                    letterSpacing: 0.5, height: 1)),
          ),
        Container(
          margin: const EdgeInsets.only(bottom: 4),
          padding: const EdgeInsets.fromLTRB(10, 9, 12, 9),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(width: 0.5,
                color: color.withValues(alpha: 0.2)),
          ),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Padding(
              padding: const EdgeInsets.only(top: 1),
              child: Text(icon,
                  style: TextStyle(fontSize: 13, color: color, height: 1)),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(log.message,
                  style: TextStyle(fontFamily: 'Inter', fontSize: 13,
                      color: colors.ink, height: 1.4)),
            ),
            const SizedBox(width: 8),
            Text(time,
                style: TextStyle(fontFamily: 'Inter', fontSize: 10,
                    color: colors.ink3, height: 1)),
          ]),
        ),
      ],
    );
  }

  static String _fmtTime(DateTime dt) {
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    final p = dt.hour >= 12 ? 'pm' : 'am';
    return '$h:$m $p';
  }

  static String _fmtDate(DateTime dt) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun',
                    'Jul','Aug','Sep','Oct','Nov','Dec'];
    final now = DateTime.now();
    if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
      return 'Today';
    }
    final yesterday = now.subtract(const Duration(days: 1));
    if (dt.year == yesterday.year && dt.month == yesterday.month &&
        dt.day == yesterday.day) {
      return 'Yesterday';
    }
    return '${months[dt.month - 1]} ${dt.day}';
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
        Text('📋', style: const TextStyle(fontSize: 40)),
        const SizedBox(height: 12),
        Text(AppL10n.of(context).noActivityYet,
            style: TextStyle(fontFamily: 'Inter', fontSize: 15,
                fontWeight: FontWeight.w600, color: colors.ink)),
        const SizedBox(height: 4),
        Text('Actions like completing tasks, adding items,\nor deleting goals will appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(fontFamily: 'Inter', fontSize: 12,
                color: colors.ink3, height: 1.5)),
      ]),
    );
  }
}
