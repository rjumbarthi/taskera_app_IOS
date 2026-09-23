import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/database.dart' show TasksCompanion;
import '../../data/providers/conflicts_provider.dart';
import '../../data/providers/database_provider.dart';
import '../../l10n/app_l10n.dart';
import '../../theme/taskera_colors.dart';
import '../../theme/taskera_theme.dart';
import '../../widgets/add_back_button.dart';

class ConflictsScreen extends ConsumerStatefulWidget {
  const ConflictsScreen({super.key});

  @override
  ConsumerState<ConflictsScreen> createState() => _ConflictsScreenState();
}

class _ConflictsScreenState extends ConsumerState<ConflictsScreen> {
  final _dismissed = <String>{};

  static String _dayLabel(DateTime d) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dd = DateTime(d.year, d.month, d.day);
    final diff = dd.difference(today).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Tomorrow';
    if (diff == -1) return 'Yesterday';
    const wd = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return wd[d.weekday - 1];
  }

  Future<void> _moveTask(int taskId, DateTime newStart) async {
    await ref.read(appDatabaseProvider).tasksDao.updateTask(
          taskId,
          TasksCompanion(dueDate: Value(newStart)),
        );
    // Streams rebuild → conflicts recompute automatically.
  }

  // ── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final colors = TaskEraTheme.of(context).colors;

    final all = ref.watch(conflictsProvider);
    final conflicts = all.where((c) => !_dismissed.contains(c.key)).toList();
    final scheduledCount = ref.watch(scheduledItemsProvider).length;
    final l = AppL10n.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Sub-bar
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 12, 6),
          child: Row(
            children: [
              AddBackButton(onTap: () => context.pop()),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(l.conflicts,
                        style: TextStyle(
                            fontFamily: 'Fraunces',
                            fontVariations: const [FontVariation('wght', 600)],
                            fontSize: 19,
                            letterSpacing: -0.5,
                            color: colors.ink,
                            height: 1.1)),
                    Text(
                      conflicts.isEmpty
                          ? 'No scheduling conflicts'
                          : '${conflicts.length} scheduling conflict${conflicts.length == 1 ? '' : 's'} detected',
                      style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          color: colors.ink3,
                          height: 1.2),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
            children: [
              if (conflicts.isEmpty)
                _AllClearCard(colors: colors, scheduledCount: scheduledCount)
              else ...[
                for (final c in conflicts) ...[
                  _ConflictCard(
                    colors: colors,
                    conflict: c,
                    onMove: (taskId, newStart) => _moveTask(taskId, newStart),
                    onDismiss: () => setState(() => _dismissed.add(c.key)),
                  ),
                  const SizedBox(height: 8),
                ],
                _AllClearCard(
                  colors: colors,
                  scheduledCount: scheduledCount,
                  footer: true,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

// ── Conflict card ─────────────────────────────────────────────────────────────

class _ConflictCard extends StatelessWidget {
  final TaskEraColors colors;
  final TaskConflict conflict;
  final void Function(int taskId, DateTime newStart) onMove;
  final VoidCallback onDismiss;

  const _ConflictCard({
    required this.colors,
    required this.conflict,
    required this.onMove,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final overlap = conflict.overlap;
    final accent = overlap ? const Color(0xFFFF6B6B) : const Color(0xFFFFB900);
    final bg = overlap ? const Color(0x12FF453A) : const Color(0x12FFB900);
    final bdr = overlap ? const Color(0x4DFF453A) : const Color(0x4DFFB900);
    final a = conflict.a;
    final b = conflict.b;

    // Resolution: prefer moving the later item if it's a task, else the earlier.
    int? moveId;
    DateTime? newStart;
    String? moveLabel;
    if (overlap) {
      if (b.taskId != null) {
        moveId = b.taskId;
        newStart = a.end;
        moveLabel = 'Move to ${fmtTime(a.end)}';
      } else if (a.taskId != null) {
        moveId = a.taskId;
        newStart = b.end;
        moveLabel = 'Move to ${fmtTime(b.end)}';
      }
    } else {
      // back-to-back: add a 10-minute buffer before the later item.
      if (b.taskId != null) {
        moveId = b.taskId;
        newStart = b.start.add(const Duration(minutes: 10));
        moveLabel = 'Add 10m buffer';
      }
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(width: 0.5, color: bdr),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber_rounded, size: 14, color: accent),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  '${overlap ? 'Overlap' : 'Back-to-back'} — '
                  '${_ConflictsScreenState._dayLabel(a.start)} ${fmtTime(b.start)}',
                  style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: accent),
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          _ItemRow(colors: colors, sched: a),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Text(
              overlap
                  ? '⚡ Overlaps by ${conflict.minutes} min'
                  : conflict.minutes == 0
                      ? 'No buffer between them'
                      : 'Only ${conflict.minutes} min between them',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: accent),
            ),
          ),
          _ItemRow(colors: colors, sched: b),
          const SizedBox(height: 9),
          Row(
            children: [
              if (moveId != null && moveLabel != null) ...[
                Expanded(
                  child: _ActionBtn(
                    label: moveLabel,
                    filled: true,
                    accent: overlap ? TaskEraColors.acc : accent,
                    onTap: () => onMove(moveId!, newStart!),
                  ),
                ),
                const SizedBox(width: 5),
              ],
              Expanded(
                child: _ActionBtn(
                  label: moveId == null ? 'Dismiss' : 'Ignore',
                  filled: false,
                  accent: accent,
                  onTap: onDismiss,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ItemRow extends StatelessWidget {
  final TaskEraColors colors;
  final ScheduledItem sched;
  const _ItemRow({required this.colors, required this.sched});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border(left: BorderSide(width: 3, color: sched.color)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(sched.title,
              style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: colors.ink)),
          Text(sched.meta,
              style: TextStyle(
                  fontFamily: 'Inter', fontSize: 11, color: colors.ink3)),
        ],
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final String label;
  final bool filled;
  final Color accent;
  final VoidCallback onTap;
  const _ActionBtn({
    required this.label,
    required this.filled,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: filled ? accent : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: filled
              ? null
              : Border.all(width: 0.5, color: accent.withAlpha(0x66)),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: filled ? Colors.white : accent,
          ),
        ),
      ),
    );
  }
}

// ── All-clear / empty state ───────────────────────────────────────────────────

class _AllClearCard extends StatelessWidget {
  final TaskEraColors colors;
  final int scheduledCount;
  final bool footer;
  const _AllClearCard({
    required this.colors,
    required this.scheduledCount,
    this.footer = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(12, footer ? 10 : 18, 12, footer ? 10 : 18),
      decoration: BoxDecoration(
        color: const Color(0x0F7FBA00),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(width: 0.5, color: const Color(0x337FBA00)),
      ),
      child: Column(
        children: [
          Text(
            footer ? 'Rest of your schedule looks clear' : '✓ No conflicts',
            style: TextStyle(
                fontFamily: 'Inter',
                fontSize: footer ? 12 : 14,
                fontWeight: FontWeight.w700,
                color: colors.successFg),
          ),
          const SizedBox(height: 3),
          Text(
            scheduledCount == 0
                ? 'Schedule tasks with a time and duration to spot clashes here.'
                : footer
                    ? 'Your other $scheduledCount scheduled item${scheduledCount == 1 ? '' : 's'} don\'t clash.'
                    : 'Your $scheduledCount scheduled item${scheduledCount == 1 ? '' : 's'} don\'t clash.',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontFamily: 'Inter', fontSize: 11, color: colors.ink3, height: 1.4),
          ),
        ],
      ),
    );
  }
}
