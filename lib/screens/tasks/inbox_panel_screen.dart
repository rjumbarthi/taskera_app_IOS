import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/database.dart' show Task, TasksCompanion;
import '../../data/providers/database_provider.dart';
import '../../l10n/app_l10n.dart';
import '../../data/providers/tasks_provider.dart';
import '../../theme/taskera_colors.dart';
import '../../theme/taskera_theme.dart';
import '../../widgets/add_back_button.dart';

// ── Screen ────────────────────────────────────────────────────────────────────

class InboxPanelScreen extends ConsumerStatefulWidget {
  const InboxPanelScreen({super.key});

  @override
  ConsumerState<InboxPanelScreen> createState() => _InboxPanelScreenState();
}

class _InboxPanelScreenState extends ConsumerState<InboxPanelScreen> {
  final _captureCtrl = TextEditingController();

  @override
  void dispose() {
    _captureCtrl.dispose();
    super.dispose();
  }

  Future<void> _capture() async {
    final text = _captureCtrl.text.trim();
    if (text.isEmpty) return;
    await ref.read(appDatabaseProvider).tasksDao.insertTask(
          TasksCompanion(title: Value(text), quadrant: const Value(0)),
        );
    _captureCtrl.clear();
  }

  Future<void> _assign(int taskId, int quad) async {
    await ref.read(appDatabaseProvider).tasksDao.updateTask(
          taskId,
          TasksCompanion(quadrant: Value(quad)),
        );
  }

  Future<void> _dismiss(int taskId) async {
    await ref.read(appDatabaseProvider).tasksDao.deleteTask(taskId);
  }

  @override
  Widget build(BuildContext context) {
    final colors = TaskEraTheme.of(context).colors;
    final items = ref.watch(inboxTasksProvider).valueOrNull ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Sub-bar
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
          child: Row(
            children: [
              AddBackButton(onTap: () => context.pop()),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(AppL10n.of(context).inbox, style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontVariations: [FontVariation('wght', 600)], fontSize: 19, letterSpacing: -0.5, color: colors.ink, height: 1.1)),
                    Text(AppL10n.of(context).unreviewedCaptures, style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 11, color: colors.ink3, height: 1.2)),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Capture input
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
          child: Container(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(width: 0.5, color: colors.bdr),
            ),
            child: Row(
              children: [
                Icon(Icons.add, size: 16, color: colors.ink3),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _captureCtrl,
                    style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 13, color: colors.ink),
                    decoration: InputDecoration(
                      hintText: AppL10n.of(context).captureThought,
                      hintStyle: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 13, color: colors.ink3),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onSubmitted: (_) => _capture(),
                    textInputAction: TextInputAction.done,
                  ),
                ),
                GestureDetector(
                  onTap: _capture,
                  child: Icon(Icons.send_rounded, size: 16, color: colors.ink3),
                ),
              ],
            ),
          ),
        ),

        // AI suggestion banner
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '✦ AI suggests quadrant — tap to confirm',
                  style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 11, color: colors.textOrPlain(TaskEraColors.acc2)),
                ),
              ),
              GestureDetector(
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('AI auto-sort coming soon'))),
                child: Text(AppL10n.of(context).sortAll, style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 11, color: colors.ink3)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // Capture items
        Expanded(
          child: items.isEmpty
              ? _EmptyInbox(colors: colors)
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 6),
                  itemBuilder: (context, i) => _CaptureRow(
                    task: items[i],
                    colors: colors,
                    onAssign: (q) => _assign(items[i].id, q),
                    onDismiss: () => _dismiss(items[i].id),
                  ),
                ),
        ),
      ],
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyInbox extends StatelessWidget {
  final TaskEraColors colors;
  const _EmptyInbox({required this.colors});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('📥', style: TextStyle(fontSize: 32)),
          const SizedBox(height: 8),
          Text(
            'Inbox is clear',
            style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 15, fontWeight: FontWeight.w600, color: colors.ink2),
          ),
          const SizedBox(height: 4),
          Text(
            'Capture a thought above to get started',
            style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 12, color: colors.ink3),
          ),
        ],
      ),
    );
  }
}

// ── Capture row ───────────────────────────────────────────────────────────────

class _CaptureRow extends StatelessWidget {
  final Task task;
  final TaskEraColors colors;
  final ValueChanged<int> onAssign;
  final VoidCallback onDismiss;

  const _CaptureRow({required this.task, required this.colors, required this.onAssign, required this.onDismiss});

  static const _qDots = [
    (1, 'Q1', TaskEraColors.q1),
    (2, 'Q2', TaskEraColors.q2),
    (3, 'Q3', TaskEraColors.q3),
    (4, 'Q4', TaskEraColors.q4),
  ];

  static String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    final when = 'Captured ${_timeAgo(task.createdAt)} · No quadrant';
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(width: 0.5, color: colors.bdr),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Circle
              Container(
                margin: const EdgeInsets.only(top: 2),
                width: 15, height: 15,
                decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(width: 1.5, color: colors.bdr2)),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(task.title, style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 13, fontWeight: FontWeight.w500, color: colors.ink)),
                    const SizedBox(height: 2),
                    Text(when, style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 9, color: colors.ink3)),
                  ],
                ),
              ),
              GestureDetector(
                onTap: onDismiss,
                child: Icon(Icons.close, size: 14, color: colors.ink3),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Quad selector chips
          Row(
            children: [
              for (final (val, lbl, clr) in _qDots) ...[
                GestureDetector(
                  onTap: () => onAssign(val),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(8, 3, 8, 3),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(width: 0.5, color: colors.bdr),
                    ),
                    child: Text(lbl, style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 9, fontWeight: FontWeight.w700, color: colors.textOrPlain(clr))),
                  ),
                ),
                const SizedBox(width: 4),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
