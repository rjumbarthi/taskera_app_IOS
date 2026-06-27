import 'dart:ui' show ImageFilter;

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart' show Task, TasksCompanion;
import '../../data/providers/database_provider.dart';
import '../../data/providers/tasks_provider.dart';
import '../../data/providers/time_tracker_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Apple-restrained, web-only "Today" surface. A ranked List (default) and a
// 2x2 Grid (toggle) over the same Today data. The Eisenhower matrix is the
// engine, not the surface: the List never shows Q1/Q2/Q3 labels or scores — the
// only matrix trace is the 3px flag colour.
//
// System font (no Inter/Fraunces here). Light-primary with a dark variant that
// follows the app theme. Quadrant + accent colours are pulled from
// kaal_pkg/tokens.json core_colors (see _Tok); everything else is Apple-HIG
// spacing/typography per the spec.
// ─────────────────────────────────────────────────────────────────────────────

/// Token colours (kaal_pkg/tokens.json → core_colors). Quadrant flags + accent.
class _Tok {
  static const q1 = Color(0xFFF25022); // core_colors.q1  — Do Now
  static const q2 = Color(0xFF7FBA00); // core_colors.q2  — Schedule
  static const q3 = Color(0xFF00A4EF); // core_colors.q3  — Delegate
  static const q4 = Color(0xFFFFB900); // core_colors.q4  — Eliminate
  static const acc = Color(0xFF0A84FF); // core_colors.acc — accent blue
  static const warn = Color(0xFFFF6B6B); // core_colors.warn — overdue red

  static Color quad(int q) => switch (q) {
        1 => q1,
        2 => q2,
        3 => q3,
        _ => q4,
      };
}

/// Apple system surface palette, light or dark.
class _Palette {
  final bool dark;
  const _Palette(this.dark);

  Color get bg          => dark ? const Color(0xFF000000) : const Color(0xFFF2F2F7);
  Color get card        => dark ? const Color(0xFF1C1C1E) : const Color(0xFFFFFFFF);
  Color get cardAlt     => dark ? const Color(0xFF2C2C2E) : const Color(0xFFFFFFFF);
  Color get label       => dark ? const Color(0xFFFFFFFF) : const Color(0xFF000000);
  Color get secondary   => dark ? const Color(0x99EBEBF5) : const Color(0x993C3C43);
  Color get tertiary    => dark ? const Color(0x4DEBEBF5) : const Color(0x4D3C3C43);
  Color get separator   => dark ? const Color(0x2E545458) : const Color(0x2E3C3C43);
  Color get fill        => dark ? const Color(0x1FEBEBF5) : const Color(0x0F3C3C43);
}

const _kRadiusCard = 16.0; // tokens radii_used: 16 (containers)
const _kRadiusRow = 14.0;  // tokens radii_used: 14 (stat card)

class TodayWebView extends ConsumerStatefulWidget {
  const TodayWebView({super.key});

  @override
  ConsumerState<TodayWebView> createState() => _TodayWebViewState();
}

class _TodayWebViewState extends ConsumerState<TodayWebView> {
  bool _grid = false;

  // ── Ranking engine (Eisenhower → plain priority) ───────────────────────────
  static const _sectionLabels = ['Now', 'Later today', 'Can wait'];

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  bool _overdue(Task t) {
    final d = t.dueDate;
    if (d == null) return false;
    final now = DateTime.now();
    return DateTime(d.year, d.month, d.day)
        .isBefore(DateTime(now.year, now.month, now.day));
  }

  int _section(Task t) {
    final now = DateTime.now();
    final dueToday = t.dueDate != null && _sameDay(t.dueDate!, now);
    if (_overdue(t) || t.quadrant == 1) return 0; // Now
    if (dueToday || t.quadrant == 2) return 1; // Later today
    return 2; // Can wait
  }

  // Lower sorts first within a section.
  double _rank(Task t) {
    var k = 0.0;
    if (_overdue(t)) k -= 1000;
    k -= (t.urgencyScore ?? 0) * 10;
    k += t.quadrant.toDouble();
    if (t.dueDate != null) k -= 1; // having a due time edges ahead
    return k;
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final p = _Palette(dark);

    final all = (ref.watch(allTasksProvider).value ?? const <Task>[])
        .where((t) => !t.isDone)
        .toList();

    return Container(
      color: p.bg,
      child: Stack(
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(28, 28, 28, 48),
                children: [
                  _header(p, all),
                  const SizedBox(height: 22),
                  if (_grid) _gridView(p, all) else _listView(p, all),
                ],
              ),
            ),
          ),
          // Floating focus-session pill (Dynamic-Island style). Isolated in its
          // own Consumer so the per-second tick doesn't rebuild the list.
          Positioned(
            top: 18,
            left: 0,
            right: 0,
            child: Consumer(
              builder: (context, ref, _) {
                final tr = ref.watch(timeTrackerProvider);
                if (tr.taskTitle == null) return const SizedBox.shrink();
                final task = all.where((t) => t.id == tr.taskId).cast<Task?>().firstWhere(
                      (t) => true,
                      orElse: () => null,
                    );
                final targetSec = (task?.timeAllocatedMin ?? 25) * 60;
                return Align(
                  alignment: Alignment.topCenter,
                  child: _FocusPill(
                    state: tr,
                    targetSeconds: targetSec,
                    onToggle: () {
                      final n = ref.read(timeTrackerProvider.notifier);
                      tr.running ? n.pause() : n.resume();
                    },
                    onStop: () => ref.read(timeTrackerProvider.notifier).stop(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ── Header ───────────────────────────────────────────────────────────────
  Widget _header(_Palette p, List<Task> all) {
    final now = DateTime.now();
    const wd = ['MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY', 'SATURDAY', 'SUNDAY'];
    const mo = ['', 'January', 'February', 'March', 'April', 'May', 'June', 'July',
                'August', 'September', 'October', 'November', 'December'];
    final eyebrow = '${wd[now.weekday - 1]} · ${mo[now.month]} ${now.day}';

    final nowCount = all.where((t) => _section(t) == 0).length;
    final glance = all.isEmpty
        ? 'Nothing on your plate — a clear day.'
        : nowCount > 0
            ? '${all.length} task${all.length == 1 ? '' : 's'}, $nowCount need${nowCount == 1 ? 's' : ''} you now.'
            : '${all.length} task${all.length == 1 ? '' : 's'}, nothing urgent — work at your pace.';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(eyebrow,
            style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.8, color: p.secondary)),
        const SizedBox(height: 6),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text('Today',
                  style: TextStyle(
                      fontSize: 34, fontWeight: FontWeight.w700, letterSpacing: -1.0, color: p.label, height: 1.05)),
            ),
            _SegToggle(grid: _grid, palette: p, onChanged: (g) => setState(() => _grid = g)),
          ],
        ),
        const SizedBox(height: 6),
        Text(glance, style: TextStyle(fontSize: 15, color: p.secondary, height: 1.4)),
      ],
    );
  }

  // ── List view (default) ────────────────────────────────────────────────────
  Widget _listView(_Palette p, List<Task> all) {
    final sorted = [...all]..sort((a, b) {
        final s = _section(a).compareTo(_section(b));
        return s != 0 ? s : _rank(a).compareTo(_rank(b));
      });
    final buckets = <int, List<Task>>{0: [], 1: [], 2: []};
    for (final t in sorted) {
      buckets[_section(t)]!.add(t);
    }

    final movedUp = all.where(_overdue).length;

    final children = <Widget>[];
    // One gentle AI surface — the sort already happened quietly.
    if (movedUp > 0) {
      children.add(_aiCard(p, movedUp));
      children.add(const SizedBox(height: 18));
    }
    for (var s = 0; s < 3; s++) {
      final items = buckets[s]!;
      if (items.isEmpty) continue;
      children.add(Opacity(
        opacity: s == 2 ? 0.62 : 1.0, // "Can wait" recedes
        child: _section3(p, _sectionLabels[s], items),
      ));
      children.add(const SizedBox(height: 22));
    }
    if (all.isEmpty) {
      children.add(_empty(p));
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children);
  }

  Widget _section3(_Palette p, String label, List<Task> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 9),
          child: Text(label,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: p.secondary)),
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(_kRadiusRow),
          child: Container(
            color: p.card,
            child: Column(
              children: [
                for (var i = 0; i < items.length; i++) ...[
                  if (i > 0)
                    Padding(
                      padding: const EdgeInsets.only(left: 46),
                      child: Divider(height: 0.5, thickness: 0.5, color: p.separator),
                    ),
                  _TaskRow(task: items[i], palette: p, ref: ref),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _aiCard(_Palette p, int n) {
    return Container(
      padding: const EdgeInsets.fromLTRB(15, 13, 15, 13),
      decoration: BoxDecoration(
        color: dark(p) ? const Color(0x140A84FF) : const Color(0x0F0A84FF),
        borderRadius: BorderRadius.circular(_kRadiusCard),
        border: Border.all(width: 0.5, color: const Color(0x330A84FF)),
      ),
      child: Row(
        children: [
          Container(
            width: 6, height: 6,
            decoration: const BoxDecoration(shape: BoxShape.circle, color: _Tok.acc),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Text(
              'I moved $n task${n == 1 ? '' : 's'} up — ${n == 1 ? "it's" : "they're"} due sooner than ${n == 1 ? 'it' : 'they'} looked.',
              style: TextStyle(fontSize: 13.5, color: p.label.withValues(alpha: 0.85), height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  bool dark(_Palette p) => p.dark;

  Widget _empty(_Palette p) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(
        children: [
          Text('✦', style: TextStyle(fontSize: 30, color: p.tertiary)),
          const SizedBox(height: 12),
          Text('All clear', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: p.label)),
          const SizedBox(height: 4),
          Text('No open tasks for today.', style: TextStyle(fontSize: 14, color: p.secondary)),
        ],
      ),
    );
  }

  // ── Grid view (2x2, draggable) ─────────────────────────────────────────────
  Widget _gridView(_Palette p, List<Task> all) {
    final byQuad = <int, List<Task>>{1: [], 2: [], 3: [], 4: []};
    for (final t in all) {
      final q = (t.quadrant >= 1 && t.quadrant <= 4) ? t.quadrant : 4;
      byQuad[q]!.add(t);
    }
    const meta = {
      1: ('Do Now', 'Urgent & important'),
      2: ('Schedule', 'Important, not urgent'),
      3: ('Delegate', 'Urgent, not important'),
      4: ('Eliminate', 'Neither'),
    };
    Widget cell(int q) => _QuadCell(
          quadrant: q,
          title: meta[q]!.$1,
          subtitle: meta[q]!.$2,
          tasks: byQuad[q]!,
          palette: p,
          onDropTask: (taskId) => ref
              .read(appDatabaseProvider)
              .tasksDao
              .updateTask(taskId, TasksCompanion(quadrant: Value(q))),
        );
    return Column(
      children: [
        IntrinsicHeight(
          child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Expanded(child: cell(1)),
            const SizedBox(width: 14),
            Expanded(child: cell(2)),
          ]),
        ),
        const SizedBox(height: 14),
        IntrinsicHeight(
          child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Expanded(child: cell(3)),
            const SizedBox(width: 14),
            Expanded(child: cell(4)),
          ]),
        ),
      ],
    );
  }
}

// ── Segmented List/Grid toggle ────────────────────────────────────────────────

class _SegToggle extends StatelessWidget {
  final bool grid;
  final _Palette palette;
  final ValueChanged<bool> onChanged;
  const _SegToggle({required this.grid, required this.palette, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    Widget seg(String label, IconData icon, bool isGrid) {
      final active = grid == isGrid;
      return GestureDetector(
        onTap: () => onChanged(isGrid),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 6),
          decoration: BoxDecoration(
            color: active ? palette.card : Colors.transparent,
            borderRadius: BorderRadius.circular(7),
            boxShadow: active
                ? [BoxShadow(color: Colors.black.withValues(alpha: palette.dark ? 0.3 : 0.08), blurRadius: 4, offset: const Offset(0, 1))]
                : null,
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, size: 14, color: active ? palette.label : palette.secondary),
            const SizedBox(width: 5),
            Text(label,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: active ? palette.label : palette.secondary)),
          ]),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(color: palette.fill, borderRadius: BorderRadius.circular(9)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        seg('List', Icons.view_agenda_outlined, false),
        seg('Grid', Icons.grid_view_outlined, true),
      ]),
    );
  }
}

// ── Task row ──────────────────────────────────────────────────────────────────

class _TaskRow extends StatefulWidget {
  final Task task;
  final _Palette palette;
  final WidgetRef ref;
  const _TaskRow({required this.task, required this.palette, required this.ref});

  @override
  State<_TaskRow> createState() => _TaskRowState();
}

class _TaskRowState extends State<_TaskRow> {
  bool _hover = false;

  bool get _overdue {
    final d = widget.task.dueDate;
    if (d == null) return false;
    final now = DateTime.now();
    return DateTime(d.year, d.month, d.day)
        .isBefore(DateTime(now.year, now.month, now.day));
  }

  String _meta() {
    final t = widget.task;
    if (t.dueLabel != null && t.dueLabel!.isNotEmpty) return t.dueLabel!;
    final d = t.dueDate;
    if (d == null) return '';
    final now = DateTime.now();
    final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final ampm = d.hour < 12 ? 'AM' : 'PM';
    final time = (d.hour != 0 || d.minute != 0)
        ? ' · $h:${d.minute.toString().padLeft(2, '0')} $ampm'
        : '';
    if (_overdue) return 'Overdue$time';
    if (d.year == now.year && d.month == now.month && d.day == now.day) return 'Today$time';
    const mo = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${mo[d.month]} ${d.day}$time';
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.palette;
    final t = widget.task;
    final flag = _Tok.quad(t.quadrant);
    final meta = _meta();

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        // Tapping a task starts a focus session (shown as the floating pill).
        onTap: () => widget.ref
            .read(timeTrackerProvider.notifier)
            .startNew(t.title, taskId: t.id, quadrant: t.quadrant),
        behavior: HitTestBehavior.opaque,
        child: Container(
          color: _hover ? p.fill : Colors.transparent,
          padding: const EdgeInsets.fromLTRB(14, 12, 16, 12),
          child: Row(
            children: [
              // 3px flag — the only Eisenhower trace
              Container(width: 3, height: 30, decoration: BoxDecoration(color: flag, borderRadius: BorderRadius.circular(2))),
              const SizedBox(width: 13),
              // circular tick
              GestureDetector(
                onTap: () => widget.ref
                    .read(appDatabaseProvider)
                    .tasksDao
                    .toggleDone(t.id, true),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: 21, height: 21,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(width: 1.6, color: p.tertiary),
                  ),
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(t.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 15.5, color: p.label, height: 1.25)),
                    if (meta.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(meta,
                          style: TextStyle(
                              fontSize: 12.5,
                              color: _overdue ? _Tok.warn : p.secondary,
                              height: 1.2)),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Quadrant cell (grid) ──────────────────────────────────────────────────────

class _QuadCell extends StatefulWidget {
  final int quadrant;
  final String title, subtitle;
  final List<Task> tasks;
  final _Palette palette;
  final void Function(int taskId) onDropTask;
  const _QuadCell({
    required this.quadrant,
    required this.title,
    required this.subtitle,
    required this.tasks,
    required this.palette,
    required this.onDropTask,
  });

  @override
  State<_QuadCell> createState() => _QuadCellState();
}

class _QuadCellState extends State<_QuadCell> {
  bool _over = false;

  @override
  Widget build(BuildContext context) {
    final p = widget.palette;
    final color = _Tok.quad(widget.quadrant);
    return DragTarget<int>(
      onWillAcceptWithDetails: (d) {
        setState(() => _over = true);
        return true;
      },
      onLeave: (_) => setState(() => _over = false),
      onAcceptWithDetails: (d) {
        setState(() => _over = false);
        widget.onDropTask(d.data);
      },
      builder: (context, cand, rej) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          padding: const EdgeInsets.fromLTRB(15, 14, 15, 14),
          decoration: BoxDecoration(
            color: _over ? color.withValues(alpha: 0.12) : p.card,
            borderRadius: BorderRadius.circular(_kRadiusCard),
            border: Border.all(width: _over ? 1.0 : 0.5, color: _over ? color : p.separator),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(widget.title,
                        style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600, color: p.label)),
                  ),
                  Text('${widget.tasks.length}',
                      style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600, color: p.tertiary)),
                ],
              ),
              const SizedBox(height: 1),
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Text(widget.subtitle, style: TextStyle(fontSize: 11.5, color: p.secondary)),
              ),
              const SizedBox(height: 11),
              for (final t in widget.tasks) _DraggableChip(task: t, color: color, palette: p),
              if (widget.tasks.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text('Drop a task here', style: TextStyle(fontSize: 12, color: p.tertiary)),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _DraggableChip extends StatelessWidget {
  final Task task;
  final Color color;
  final _Palette palette;
  const _DraggableChip({required this.task, required this.color, required this.palette});

  @override
  Widget build(BuildContext context) {
    final p = palette;
    final chip = Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.fromLTRB(11, 8, 11, 8),
      decoration: BoxDecoration(
        color: p.fill,
        borderRadius: BorderRadius.circular(9),
        border: Border(left: BorderSide(width: 3, color: color)),
      ),
      child: Text(task.title,
          maxLines: 1, overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 13, color: p.label)),
    );
    return Draggable<int>(
      data: task.id,
      feedback: Material(
        color: Colors.transparent,
        child: Opacity(
          opacity: 0.92,
          child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 260), child: chip),
        ),
      ),
      childWhenDragging: Opacity(opacity: 0.35, child: chip),
      child: MouseRegion(cursor: SystemMouseCursors.grab, child: chip),
    );
  }
}

// ── Floating focus-session pill (Dynamic-Island style) ────────────────────────

class _FocusPill extends StatelessWidget {
  final TimeTrackerState state;
  final int targetSeconds;
  final VoidCallback onToggle;
  final VoidCallback onStop;
  const _FocusPill({
    required this.state,
    required this.targetSeconds,
    required this.onToggle,
    required this.onStop,
  });

  @override
  Widget build(BuildContext context) {
    final progress =
        targetSeconds > 0 ? (state.elapsedSeconds / targetSeconds).clamp(0.0, 1.0) : 0.0;
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          padding: const EdgeInsets.fromLTRB(10, 8, 8, 8),
          decoration: BoxDecoration(
            color: const Color(0xD9101012),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(width: 0.5, color: const Color(0x1FFFFFFF)),
            boxShadow: const [
              BoxShadow(color: Color(0x40000000), blurRadius: 20, offset: Offset(0, 6)),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 30,
                height: 30,
                child: Stack(alignment: Alignment.center, children: [
                  SizedBox(
                    width: 30,
                    height: 30,
                    child: CircularProgressIndicator(
                      value: progress.toDouble(),
                      strokeWidth: 2.5,
                      backgroundColor: const Color(0x33FFFFFF),
                      valueColor: const AlwaysStoppedAnimation(_Tok.acc),
                    ),
                  ),
                  Icon(state.running ? Icons.bolt : Icons.pause,
                      size: 13, color: Colors.white),
                ]),
              ),
              const SizedBox(width: 11),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 200),
                    child: Text(state.taskTitle ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white, height: 1.1)),
                  ),
                  const SizedBox(height: 2),
                  Text(state.displayTime,
                      style: const TextStyle(
                          fontSize: 11.5,
                          color: Color(0x99FFFFFF),
                          height: 1,
                          fontFeatures: [FontFeature.tabularFigures()])),
                ],
              ),
              const SizedBox(width: 14),
              _PillBtn(icon: state.running ? Icons.pause_rounded : Icons.play_arrow_rounded, onTap: onToggle),
              const SizedBox(width: 4),
              _PillBtn(icon: Icons.close_rounded, onTap: onStop),
            ],
          ),
        ),
      ),
    );
  }
}

class _PillBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _PillBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: 30,
          height: 30,
          alignment: Alignment.center,
          decoration: const BoxDecoration(color: Color(0x1FFFFFFF), shape: BoxShape.circle),
          child: Icon(icon, size: 17, color: Colors.white),
        ),
      ),
    );
  }
}
