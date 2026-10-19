import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import '../../l10n/app_l10n.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/database.dart' show Task, TasksDao, Subtask, SubtasksCompanion, TasksCompanion;
import '../../data/providers/database_provider.dart';
import '../../data/providers/tasks_provider.dart';
import '../../theme/taskera_colors.dart';
import '../../theme/taskera_theme.dart';
import '../../widgets/add_back_button.dart';
import '../focus/focus_session_modal.dart';

String _dueLabelFor(DateTime d) {
  final now   = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final day   = DateTime(d.year, d.month, d.day);
  if (day == today) return 'Today';
  if (day == today.add(const Duration(days: 1))) return 'Tomorrow';
  return '${d.month}/${d.day}/${d.year}';
}

String _fmtClock(DateTime d) {
  final m = d.minute.toString().padLeft(2, '0');
  final period = d.hour >= 12 ? 'PM' : 'AM';
  final hr = d.hour % 12 == 0 ? 12 : d.hour % 12;
  return '$hr:$m $period';
}

String _fmtAlloc(int min) {
  if (min < 60) return '${min}m';
  final h = min ~/ 60;
  final m = min % 60;
  return m > 0 ? '${h}h ${m}m' : '${h}h';
}

// ── Helpers ───────────────────────────────────────────────────────────────────

const _kQuadNames  = {1: 'Q1 · Do Now', 2: 'Q2 · Schedule', 3: 'Q3 · Delegate', 4: 'Q4 · Eliminate'};
const _kQuadColors = {1: TaskEraColors.q1, 2: TaskEraColors.q2, 3: TaskEraColors.q3, 4: TaskEraColors.q4};

String _quadName(int q)  => _kQuadNames[q]  ?? 'Q1 · Do Now';
Color  _quadColor(int q) => _kQuadColors[q] ?? TaskEraColors.q1;

Color _quadBg(int q) => switch (q) {
  1 => const Color(0x12F25022),
  2 => const Color(0x127FBA00),
  3 => const Color(0x12FF9500),
  _ => const Color(0x12636366),
};
Color _quadBorder(int q) => switch (q) {
  1 => const Color(0x40F25022),
  2 => const Color(0x407FBA00),
  3 => const Color(0x40FF9500),
  _ => const Color(0x40636366),
};

Color _prioColor(String? p) => switch (p) {
  'P1' => const Color(0xFFFF6B6B),
  'P2' => const Color(0xFFFF9500),
  'P3' => TaskEraColors.acc2,
  _    => const Color(0xFF8E8E93),
};
Color _prioBg(String? p) => switch (p) {
  'P1' => const Color(0x24FF453A),
  'P2' => const Color(0x24FF9500),
  'P3' => TaskEraColors.accBg,
  _    => const Color(0x248E8E93),
};
String _prioLabel(String? p) => switch (p) {
  'P1' => 'Urgent',
  'P2' => 'High',
  'P3' => 'Medium',
  _    => 'Low',
};

// ── Screen ────────────────────────────────────────────────────────────────────

class TaskDetailScreen extends ConsumerStatefulWidget {
  final String taskId;
  const TaskDetailScreen({super.key, required this.taskId});

  @override
  ConsumerState<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends ConsumerState<TaskDetailScreen> {
  final _noteCtrl     = TextEditingController();
  final _subtaskCtrl  = TextEditingController();
  final _subtaskFocus = FocusNode();
  bool  _noteInit     = false;

  int?   _timeAllocMin;

  late final TasksDao _tasksDao;

  int get _id => int.tryParse(widget.taskId) ?? 0;

  @override
  void initState() {
    super.initState();
    _tasksDao = ref.read(appDatabaseProvider).tasksDao;
  }

  @override
  void dispose() {
    final notes = _noteCtrl.text;
    _tasksDao.updateTask(_id, TasksCompanion(notes: Value(notes.isEmpty ? null : notes)));
    _noteCtrl.dispose();
    _subtaskCtrl.dispose();
    _subtaskFocus.dispose();
    super.dispose();
  }

  Future<void> _changeDueDate(Task task) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: task.dueDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked == null || !mounted) return;
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: task.dueDate != null
          ? TimeOfDay.fromDateTime(task.dueDate!)
          : TimeOfDay.now(),
    );
    if (!mounted) return;
    final combined = pickedTime != null
        ? DateTime(picked.year, picked.month, picked.day, pickedTime.hour, pickedTime.minute)
        : DateTime(picked.year, picked.month, picked.day);
    await _tasksDao.updateTask(
      task.id,
      TasksCompanion(
        dueDate:   Value(combined),
        dueLabel:  Value(_dueLabelFor(combined)),
        isOverdue: Value(combined.isBefore(DateTime.now())),
      ),
    );
  }

  Future<void> _editTimeAlloc() async {
    final ctrl = TextEditingController(text: _timeAllocMin?.toString() ?? '');
    final result = await showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text(
          'Time Allocated',
          style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white),
        ),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          autofocus: true,
          style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 14, color: Colors.white),
          decoration: InputDecoration(
            hintText: AppL10n.of(context).minutesHint,
            hintStyle: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 13, color: Color(0xFF8E8E93)),
            suffixText: 'min',
            suffixStyle: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 13, color: Color(0xFF8E8E93)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(width: 0.5, color: Color(0x40FFFFFF)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(width: 0.5, color: TaskEraColors.acc),
            ),
            isDense: true,
            contentPadding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, color: Color(0xFF8E8E93))),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, int.tryParse(ctrl.text.trim())),
            // Fixed-dark dialog — never colors.textOrPlain here.
            child: Text('Save', style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontWeight: FontWeight.w700,
                color: TaskEraTheme.of(context).colors.plainText ? Colors.white : TaskEraColors.acc2)),
          ),
        ],
      ),
    );
    ctrl.dispose();
    if (!mounted) return;
    if (result != null) {
      final v = result > 0 ? result : null;
      setState(() => _timeAllocMin = v);
      await _tasksDao.updateTask(_id, TasksCompanion(timeAllocatedMin: Value(v)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors    = TaskEraTheme.of(context).colors;
    final taskAsync = ref.watch(singleTaskProvider(_id));
    final subsAsync = ref.watch(subtasksProvider(_id));

    return taskAsync.when(
      loading: () => Center(child: CircularProgressIndicator()),
      error:   (e, _) => Center(child: Text('Error: $e', style: TextStyle(color: Colors.white))),
      data: (task) {
        if (task == null) {
          return Center(child: Text('Task not found', style: TextStyle(color: colors.ink3)));
        }
        if (!_noteInit) {
          _noteCtrl.text = task.notes ?? '';
          _noteInit = true;
          _timeAllocMin = task.timeAllocatedMin;
        }
        return _Body(
          task:            task,
          subs:            subsAsync.value ?? [],
          noteCtrl:        _noteCtrl,
          subtaskCtrl:     _subtaskCtrl,
          subtaskFocus:    _subtaskFocus,
          colors:          colors,
          attentionScore:  task.urgencyScore ?? 0.0,
          timeAllocMin:    _timeAllocMin,
          onToggleSub:     (s) => _tasksDao.toggleSubtaskDone(s.id, !s.isDone),
          onAddSub: (text) async {
            await _tasksDao.insertSubtask(
              SubtasksCompanion(taskId: Value(task.id), title: Value(text)),
            );
            if (!mounted) return;
            _subtaskCtrl.clear();
          },
          onDone: () {
            final nav = Navigator.of(context);
            _tasksDao.toggleDone(task.id, true).then((_) {
              if (mounted) nav.pop();
            });
          },
          onChangeDue:     () => _changeDueDate(task),
          onEditTimeAlloc: _editTimeAlloc,
        );
      },
    );
  }
}

// ── Body widget ───────────────────────────────────────────────────────────────

class _Body extends StatelessWidget {
  final Task task;
  final List<Subtask> subs;
  final TextEditingController noteCtrl;
  final TextEditingController subtaskCtrl;
  final FocusNode subtaskFocus;
  final TaskEraColors colors;
  final void Function(Subtask) onToggleSub;
  final Future<void> Function(String) onAddSub;
  final VoidCallback onDone;
  final VoidCallback? onChangeDue;
  final double attentionScore;
  final int? timeAllocMin;
  final VoidCallback onEditTimeAlloc;

  const _Body({
    required this.task,
    required this.subs,
    required this.noteCtrl,
    required this.subtaskCtrl,
    required this.subtaskFocus,
    required this.colors,
    required this.onToggleSub,
    required this.onAddSub,
    required this.onDone,
    this.onChangeDue,
    required this.attentionScore,
    required this.timeAllocMin,
    required this.onEditTimeAlloc,
  });

  @override
  Widget build(BuildContext context) {
    final q         = task.quadrant;
    final qName     = _quadName(q);
    final qCol      = _quadColor(q);
    final qBg       = _quadBg(q);
    final qBdr      = _quadBorder(q);
    final prio      = task.priority;
    final doneCount = subs.where((s) => s.isDone).length;
    final fraction  = subs.isEmpty ? 0.0 : doneCount / subs.length;

    final d        = task.dueDate;
    final hasTime  = d != null && (d.hour != 0 || d.minute != 0);
    final dateStr  = d != null ? _dueLabelFor(d) : 'Set date';
    final timeStr  = (d != null && (d.hour != 0 || d.minute != 0)) ? _fmtClock(d) : 'Set time';
    final allotStr = timeAllocMin != null ? _fmtAlloc(timeAllocMin!) : 'Set';

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Sub-bar
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AddBackButton(strokeColor: qCol, onTap: () => context.pop()),
              SizedBox(width: 8),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontFamily: TaskEraTheme.of(context).fontFamily, fontVariations: [FontVariation('wght', 600)], fontSize: 19,
                      letterSpacing: -0.5, height: 1.3,
                    ),
                    children: [
                      TextSpan(text: '$qName · ', style: TextStyle(color: qCol)),
                      TextSpan(text: task.title, style: TextStyle(color: colors.ink)),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 8),
              GestureDetector(
                onTap: () => context.push('/tasks/edittask/${task.id}'),
                child: Container(
                  width: 30, height: 30,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(width: 0.5, color: colors.bdr),
                  ),
                  child: Icon(Icons.edit_outlined, size: 13, color: colors.ink3),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),

          // Hero card
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: qBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(width: 0.5, color: qBdr),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            task.title,
                            style: TextStyle(
                              fontFamily: TaskEraTheme.of(context).type.numberFontFamily,
                              fontVariations: const [FontVariation('wght', 600)],
                              fontSize: 15,
                              color: colors.ink,
                              height: 1.2,
                            ),
                          ),
                          SizedBox(height: 4),
                          Wrap(
                            spacing: 5,
                            runSpacing: 5,
                            children: [
                              _Badge(label: '${prio ?? 'P4'} · ${_prioLabel(prio)}', bg: _prioBg(prio), fg: _prioColor(prio)),
                              _Badge(label: qName, bg: qBg, fg: qCol),
                              if (attentionScore > 0)
                                _Badge(label: 'Score ${attentionScore.toStringAsFixed(1)}', bg: TaskEraColors.accBg, fg: TaskEraColors.acc2),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => showFocusSession(context, taskId: task.id),
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(12, 7, 12, 7),
                        decoration: BoxDecoration(color: TaskEraColors.acc, borderRadius: BorderRadius.circular(9)),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.play_arrow_rounded, color: Colors.white, size: 10),
                            SizedBox(width: 5),
                            Text('Start', style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                // Stats row: Date | Time | Allotted
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: onChangeDue,
                        child: _StatCell(
                          label: 'Date  ✎',
                          value: dateStr,
                          valueColor: task.isOverdue
                              ? const Color(0xFFFF6B6B)
                              : (d == null ? TaskEraColors.acc2 : colors.ink2),
                          colors: colors,
                          natural: true,
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: GestureDetector(
                        onTap: onChangeDue,
                        child: _StatCell(
                          label: 'Time  ✎',
                          value: timeStr,
                          valueColor: hasTime ? colors.ink2 : TaskEraColors.acc2,
                          colors: colors,
                          natural: true,
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: GestureDetector(
                        onTap: onEditTimeAlloc,
                        child: _StatCell(
                          label: 'Allotted  ✎',
                          value: allotStr,
                          valueColor: timeAllocMin != null ? colors.ink2 : TaskEraColors.acc2,
                          colors: colors,
                          natural: true,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 8),

          // Subtasks card
          Container(
            padding: const EdgeInsets.fromLTRB(11, 10, 11, 10),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(11),
              border: Border.all(width: 0.5, color: colors.bdr),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('Subtasks · $doneCount/${subs.length}',
                        style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 11, fontWeight: FontWeight.w600, color: colors.ink)),
                    const Spacer(),
                    Text('$doneCount / ${subs.length} done',
                        style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 9, color: colors.ink3)),
                    SizedBox(width: 6),
                    GestureDetector(
                      onTap: () => subtaskFocus.requestFocus(),
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: EdgeInsets.all(4),
                        child: Text('+', style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 19, color: colors.textOrPlain(TaskEraColors.acc), height: 1)),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 7),
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: SizedBox(
                    height: 3,
                    child: LinearProgressIndicator(
                      value: fraction,
                      backgroundColor: colors.surf3,
                      valueColor: AlwaysStoppedAnimation<Color>(qCol),
                    ),
                  ),
                ),
                SizedBox(height: 8),
                ...subs.map((s) => Padding(
                  padding: const EdgeInsets.only(bottom: 5),
                  child: _SubtaskRow(sub: s, qCol: qCol, colors: colors, onToggle: () => onToggleSub(s)),
                )),
                SizedBox(height: 4),
                _AddSubtaskRow(ctrl: subtaskCtrl, focus: subtaskFocus, colors: colors, onSubmit: onAddSub),
              ],
            ),
          ),
          SizedBox(height: 8),

          // Notes card
          Container(
            padding: const EdgeInsets.fromLTRB(11, 10, 11, 10),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(11),
              border: Border.all(width: 0.5, color: colors.bdr),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Notes', style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 11, fontWeight: FontWeight.w600, color: colors.ink)),
                SizedBox(height: 8),
                TextField(
                  controller: noteCtrl,
                  maxLines: null,
                  style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 13, color: colors.ink, height: 1.6),
                  decoration: InputDecoration(
                    hintText: AppL10n.of(context).addNoteHint,
                    hintStyle: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 13, color: colors.ink3, height: 1.6),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 8),

          // Mark as Done
          GestureDetector(
            onTap: onDone,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.fromLTRB(10, 12, 10, 12),
              decoration: BoxDecoration(
                color: task.isDone ? qCol : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(width: 0.5, color: qCol.withAlpha(0x60)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    task.isDone ? 'Completed' : 'Mark task as Done',
                    style: TextStyle(
                      fontFamily: TaskEraTheme.of(context).fontFamily,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: task.isDone ? Colors.white : qCol,
                    ),
                  ),
                  SizedBox(width: 8),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 20, height: 20,
                    decoration: BoxDecoration(
                      color: task.isDone ? Colors.white.withAlpha(0x33) : qCol.withAlpha(0x1A),
                      shape: BoxShape.circle,
                      border: Border.all(width: 0.5, color: task.isDone ? Colors.white.withAlpha(0x80) : qCol.withAlpha(0x99)),
                    ),
                    child: Center(
                      child: Icon(Icons.check_rounded, size: 11,
                          color: task.isDone ? Colors.white : qCol.withAlpha(0x80)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Small widgets ─────────────────────────────────────────────────────────────

class _Badge extends StatelessWidget {
  final String label;
  final Color bg, fg;
  const _Badge({required this.label, required this.bg, required this.fg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(9, 4, 9, 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(5)),
      child: Text(label, style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 12, fontWeight: FontWeight.w700, color: fg, height: 1)),
    );
  }
}

// natural=true → returns inner container as-is (for use inside GestureDetector)
// natural=false (default) → wraps in Expanded
class _StatCell extends StatelessWidget {
  final String label, value;
  final Color valueColor;
  final TaskEraColors colors;
  final bool natural;
  const _StatCell({required this.label, required this.value, required this.valueColor, required this.colors, this.natural = false});

  @override
  Widget build(BuildContext context) {
    final inner = Container(
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(width: 0.5, color: colors.bdr),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 9, color: colors.ink3, height: 1.2)),
          SizedBox(height: 1),
          Text(value, style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 11, fontWeight: FontWeight.w500, color: valueColor, height: 1.2)),
        ],
      ),
    );
    return natural ? inner : Expanded(child: inner);
  }
}

class _SubtaskRow extends StatelessWidget {
  final Subtask sub;
  final Color qCol;
  final TaskEraColors colors;
  final VoidCallback onToggle;
  const _SubtaskRow({required this.sub, required this.qCol, required this.colors, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    if (!sub.isDone) {
      return Container(
        padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(7),
          border: Border.all(width: 0.5, color: qCol.withAlpha(0x30)),
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: onToggle,
              child: Container(width: 15, height: 15,
                  decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(width: 1.5, color: qCol))),
            ),
            SizedBox(width: 8),
            Expanded(child: Text(sub.title,
                style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 13, fontWeight: FontWeight.w600, color: colors.ink))),
          ],
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          GestureDetector(
            onTap: onToggle,
            child: Container(
              width: 15, height: 15,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: qCol.withAlpha(0x33),
                border: Border.all(width: 1.5, color: qCol),
              ),
              child: Center(child: Icon(Icons.check, size: 8, color: qCol)),
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(sub.title,
              style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 13, color: colors.ink3,
                  decoration: TextDecoration.lineThrough, decorationColor: colors.ink3)),
          ),
        ],
      ),
    );
  }
}

class _AddSubtaskRow extends StatelessWidget {
  final TextEditingController ctrl;
  final FocusNode focus;
  final TaskEraColors colors;
  final Future<void> Function(String) onSubmit;
  const _AddSubtaskRow({required this.ctrl, required this.focus, required this.colors, required this.onSubmit});

  void _submit() {
    final val = ctrl.text.trim();
    if (val.isNotEmpty) onSubmit(val);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 15, height: 15,
            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(width: 1.2, color: colors.bdr2))),
        SizedBox(width: 8),
        Expanded(
          child: TextField(
            controller: ctrl,
            focusNode: focus,
            style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 13, color: colors.ink),
            decoration: InputDecoration(
              hintText: AppL10n.of(context).addSubtaskHint,
              hintStyle: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 13, color: colors.ink3),
              border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.zero,
            ),
            textInputAction: TextInputAction.done,
            onSubmitted: (val) { if (val.trim().isNotEmpty) onSubmit(val.trim()); },
          ),
        ),
        GestureDetector(
          onTap: _submit,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 4, 0, 4),
            child: Icon(Icons.add_circle_rounded, size: 22, color: TaskEraColors.acc),
          ),
        ),
      ],
    );
  }
}
