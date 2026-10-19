import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/database.dart' show TasksCompanion, SubtasksCompanion;
import '../../data/providers/database_provider.dart';
import '../../l10n/app_l10n.dart';
import '../../settings/taskera_settings.dart';
import '../../util/taskera_dialogs.dart';
import '../../theme/taskera_colors.dart';
import '../../theme/taskera_theme.dart';
import '../../widgets/add_back_button.dart';
import '../../widgets/reminders_section.dart';

// ── Data ──────────────────────────────────────────────────────────────────────

class _EditSubtask {
  String text;
  bool done;
  _EditSubtask({required this.text}) : done = false;
}

class _QChip {
  final int value;
  final String label;
  final Color color;
  const _QChip(this.value, this.label, this.color);
}

class _PChip {
  final String value, label;
  final Color color;
  const _PChip(this.value, this.label, this.color);
}

const _quads = [
  _QChip(1, 'Q1 · Do Now',    TaskEraColors.q1),
  _QChip(2, 'Q2 · Schedule',  TaskEraColors.q2),
  _QChip(3, 'Q3 · Delegate',  TaskEraColors.q3),
  _QChip(4, 'Q4 · Eliminate', TaskEraColors.q4),
];

const _priorities = [
  _PChip('P1', 'P1 Urgent', Color(0xFFFF6B6B)),
  _PChip('P2', 'P2 High',   Color(0xFFFF9500)),
  _PChip('P3', 'P3 Medium', TaskEraColors.acc2),
  _PChip('P4', 'P4 Low',    Color(0xFF8E8E93)),
];

const _allLabels = ['work', 'personal', 'health', 'finance', 'learning'];

// ── Title normalizer ──────────────────────────────────────────────────────────
// Applied at save-time only (not during live typing — _parseTitle needs raw text).
String _normalizeTitle(String raw) {
  var t = raw.trim().replaceAll(RegExp(r'\s+'), ' ');
  if (t.isEmpty) return t;
  t = t[0].toUpperCase() + t.substring(1);
  return t.replaceAllMapped(RegExp(r'\bi\b'), (_) => 'I');
}

// ── Screen ────────────────────────────────────────────────────────────────────

class EditTaskScreen extends ConsumerStatefulWidget {
  final String? taskId;
  final int? initialQuad;
  const EditTaskScreen({super.key, this.taskId, this.initialQuad});

  @override
  ConsumerState<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends ConsumerState<EditTaskScreen> {
  int      _quad     = 1;
  String   _priority = 'P3';
  final Set<String> _labels = {};
  String   _parseResult = '';
  DateTime?  _selectedDueDate;
  TimeOfDay? _selectedTime;
  bool _loading = false;

  final _titleCtrl     = TextEditingController();
  final _reminderCtrl  = TextEditingController();
  final _notesCtrl     = TextEditingController();
  final _subtaskCtrl   = TextEditingController();
  final _timeAllocCtrl = TextEditingController();

  late List<_EditSubtask> _subtasks;

  bool get _isNew => widget.taskId == null;
  int? get _taskId => int.tryParse(widget.taskId ?? '');

  String get _quadLabel => _quads.firstWhere((q) => q.value == _quad, orElse: () => _quads.first).label;
  Color  get _quadColor => _quads.firstWhere((q) => q.value == _quad, orElse: () => _quads.first).color;

  @override
  void initState() {
    super.initState();
    _subtasks = [];
    if (widget.initialQuad != null) _quad = widget.initialQuad!;
    if (!_isNew) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadTask());
    }
  }

  Future<void> _loadTask() async {
    final id = _taskId;
    if (id == null) return;
    final task = await ref.read(appDatabaseProvider).tasksDao.getTask(id);
    if (task != null && mounted) {
      setState(() {
        _titleCtrl.text = task.title;
        _quad           = task.quadrant;
        _priority       = task.priority ?? 'P3';
        _notesCtrl.text = task.notes ?? '';
        _labels
          ..clear()
          ..addAll((task.labels ?? '')
              .split(',')
              .map((s) => s.trim())
              .where((s) => s.isNotEmpty));
        if (task.timeAllocatedMin != null) {
          _timeAllocCtrl.text = task.timeAllocatedMin!.toString();
        }
        final d = task.dueDate;
        if (d != null) {
          _selectedDueDate = DateTime(d.year, d.month, d.day);
          if (d.hour != 0 || d.minute != 0) {
            _selectedTime = TimeOfDay(hour: d.hour, minute: d.minute);
            _reminderCtrl.text = _formatTime(_selectedTime!);
          }
        }
      });
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _reminderCtrl.dispose();
    _notesCtrl.dispose();
    _subtaskCtrl.dispose();
    _timeAllocCtrl.dispose();
    super.dispose();
  }

  static const _months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
  static const _days   = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];

  static String _formatTime(TimeOfDay t) {
    final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final m = t.minute.toString().padLeft(2, '0');
    final p = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '$h:$m $p';
  }

  String _formatDate(DateTime d) {
    final now    = DateTime.now();
    final today  = DateTime(now.year, now.month, now.day);
    final target = DateTime(d.year, d.month, d.day);
    final diff   = target.difference(today).inDays;
    if (diff == 0)  return 'Today';
    if (diff == 1)  return 'Tomorrow';
    if (diff == -1) return 'Yesterday · Overdue';
    if (diff < 0)   return '${_months[d.month - 1]} ${d.day} · Overdue';
    if (diff <= 6)  return _days[(d.weekday - 1) % 7];
    return '${_months[d.month - 1]} ${d.day}, ${d.year}';
  }

  void _parseTitle(String text) {
    final lower = text.toLowerCase();
    final parts = <String>[];
    int    newQuad = _quad;
    String newPrio = _priority;
    DateTime? newDate = _selectedDueDate;

    // Quadrant detection
    if (RegExp(r'\bq1\b|urgent|asap|critical').hasMatch(lower)) {
      newQuad = 1; parts.add('Q1 Do Now');
    } else if (RegExp(r'\bq2\b|schedule|plan|learn|review|study|prepare').hasMatch(lower)) {
      newQuad = 2; parts.add('Q2 Schedule');
    } else if (RegExp(r'\bq3\b|delegate|forward|send|reply|ask').hasMatch(lower)) {
      newQuad = 3; parts.add('Q3 Delegate');
    } else if (RegExp(r'\bq4\b|someday|later|eventually|maybe').hasMatch(lower)) {
      newQuad = 4; parts.add('Q4 Eliminate');
    }

    // Priority detection
    if (RegExp(r'\bp1\b|critical|deadline').hasMatch(lower)) {
      newPrio = 'P1'; parts.add('P1 Urgent');
    } else if (RegExp(r'\bp2\b|\bhigh\b').hasMatch(lower)) {
      newPrio = 'P2'; parts.add('P2 High');
    } else if (RegExp(r'\bp3\b|\bmedium\b').hasMatch(lower)) {
      newPrio = 'P3'; parts.add('P3 Medium');
    }

    // Date detection
    final now = DateTime.now();
    if (lower.contains('today')) {
      newDate = DateTime(now.year, now.month, now.day);
      parts.add('📅 Today');
    } else if (lower.contains('tomorrow')) {
      newDate = DateTime(now.year, now.month, now.day + 1);
      parts.add('📅 Tomorrow');
    } else if (RegExp(r'\bnext week\b').hasMatch(lower)) {
      newDate = now.add(const Duration(days: 7));
      parts.add('📅 Next week');
    } else if (RegExp(r'\bin (\d+) days?\b').hasMatch(lower)) {
      final m = RegExp(r'\bin (\d+) days?\b').firstMatch(lower);
      if (m != null) {
        final n = int.tryParse(m.group(1)!);
        if (n != null) { newDate = now.add(Duration(days: n)); parts.add('📅 In $n days'); }
      }
    } else if (RegExp(r'\bfri(day)?\b').hasMatch(lower)) {
      final daysUntilFri = (5 - now.weekday + 7) % 7;
      newDate = now.add(Duration(days: daysUntilFri == 0 ? 7 : daysUntilFri));
      parts.add('📅 Friday');
    } else if (RegExp(r'\bmon(day)?\b').hasMatch(lower)) {
      final daysUntil = (1 - now.weekday + 7) % 7;
      newDate = now.add(Duration(days: daysUntil == 0 ? 7 : daysUntil));
      parts.add('📅 Monday');
    } else if (RegExp(r'\bwed(nesday)?\b').hasMatch(lower)) {
      final daysUntil = (3 - now.weekday + 7) % 7;
      newDate = now.add(Duration(days: daysUntil == 0 ? 7 : daysUntil));
      parts.add('📅 Wednesday');
    } else if (RegExp(r'\b\d{1,2}(am|pm)\b').hasMatch(lower)) {
      parts.add('⏰ Time detected');
    }

    // Label detection (#tag)
    final knownLabels = {..._allLabels, ...ref.read(taskeraSettingsProvider).customLabels};
    final tagMatches = RegExp(r'#(\w+)').allMatches(lower);
    for (final m in tagMatches) {
      final tag = m.group(1)!;
      if (knownLabels.contains(tag)) { _labels.add(tag); parts.add('#$tag'); }
    }

    final newResult = parts.isEmpty ? '' : parts.join(' · ');
    if (newQuad != _quad || newPrio != _priority || newResult != _parseResult || newDate != _selectedDueDate) {
      setState(() {
        _quad         = newQuad;
        _priority     = newPrio;
        _parseResult  = newResult;
        _selectedDueDate = newDate;
      });
    }
  }

  Future<void> _pickDate() async {
    final now  = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? now,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365 * 2)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: TaskEraColors.acc,
            onPrimary: Colors.white,
            surface: Color(0xFF1C1C1E),
            onSurface: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (date != null && mounted) {
      setState(() => _selectedDueDate = date);
    }
  }

  static String _formatTimeAlloc(int min) {
    if (min < 60) return '${min}m';
    final h = min ~/ 60;
    final m = min % 60;
    return m > 0 ? '${h}h ${m}m' : '${h}h';
  }

  Future<void> _pickTimeAlloc() async {
    const presets = [15, 25, 30, 45, 60, 90, 120];
    final colors = TaskEraTheme.of(context).colors;
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: const Color(0x8C000000),
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 28),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xDD1C1C1E),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(width: 0.5, color: colors.bdr),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                child: Text('Time Allocated',
                    style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 13,
                        fontWeight: FontWeight.w700, color: colors.ink)),
              ),
              Divider(height: 1, thickness: 0.5, color: colors.bdr),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ...presets.map((m) {
                      final label = _formatTimeAlloc(m);
                      final current = int.tryParse(_timeAllocCtrl.text);
                      final selected = current == m;
                      return GestureDetector(
                        onTap: () {
                          setState(() => _timeAllocCtrl.text = m.toString());
                          Navigator.pop(ctx);
                        },
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
                          decoration: BoxDecoration(
                            color: selected ? TaskEraColors.acc.withAlpha(0x22) : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              width: 0.5,
                              color: selected ? TaskEraColors.acc : colors.bdr,
                            ),
                          ),
                          child: Text(label,
                              style: TextStyle(
                                fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 13,
                                fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                                color: selected ? TaskEraColors.acc2 : colors.ink2,
                              )),
                        ),
                      );
                    }),
                    GestureDetector(
                      onTap: () async {
                        Navigator.pop(ctx);
                        await _customTimeAlloc();
                      },
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(width: 0.5, color: colors.bdr),
                        ),
                        child: Text('Custom…',
                            style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 13, color: colors.ink3)),
                      ),
                    ),
                  ],
                ),
              ),
              if (_timeAllocCtrl.text.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                  child: GestureDetector(
                    onTap: () {
                      setState(() => _timeAllocCtrl.clear());
                      Navigator.pop(ctx);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      decoration: BoxDecoration(
                        border: Border.all(width: 0.5, color: colors.bdr),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Text('Clear', style: TextStyle(
                          fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 13, color: colors.ink3)),
                    ),
                  ),
                ),
              SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _customTimeAlloc() async {
    final ctrl = TextEditingController(text: _timeAllocCtrl.text);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text('Custom duration',
            style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 15,
                fontWeight: FontWeight.w700, color: Colors.white)),
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
            onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
            // Fixed-dark dialog — never colors.textOrPlain (resolves to ink).
            child: Text('Set', style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily,
                fontWeight: FontWeight.w700,
                color: TaskEraTheme.of(context).colors.plainText ? Colors.white : TaskEraColors.acc2)),
          ),
        ],
      ),
    );
    ctrl.dispose();
    if (!mounted || result == null) return;
    final parsed = int.tryParse(result);
    if (parsed != null && parsed > 0) {
      setState(() => _timeAllocCtrl.text = result);
    }
  }

  Future<void> _addCustomLabel() async {
    final ctrl = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text('New label',
            style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 15,
                fontWeight: FontWeight.w700, color: Colors.white)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          textCapitalization: TextCapitalization.none,
          style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 14, color: Colors.white),
          decoration: InputDecoration(
            hintText: 'e.g. travel',
            hintStyle: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 13, color: Color(0xFF8E8E93)),
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
          onSubmitted: (v) => Navigator.pop(ctx, v.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, color: Color(0xFF8E8E93))),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
            child: Text('Add', style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily,
                fontWeight: FontWeight.w700,
                color: TaskEraTheme.of(context).colors.plainText ? Colors.white : TaskEraColors.acc2)),
          ),
        ],
      ),
    );
    ctrl.dispose();
    if (!mounted || result == null) return;
    final name = result.trim().toLowerCase();
    if (name.isEmpty) return;
    ref.read(taskeraSettingsProvider.notifier).addCustomLabel(name);
    setState(() => _labels.add(name));
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: TaskEraColors.acc,
            onPrimary: Colors.white,
            surface: Color(0xFF1C1C1E),
            onSurface: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (t != null && mounted) {
      setState(() {
        _selectedTime = t;
        _reminderCtrl.text = _formatTime(t);
      });
    }
  }

  Future<void> _save() async {
    final title = _normalizeTitle(_titleCtrl.text);
    if (title.isEmpty) return;

    setState(() => _loading = true);
    try {
      // Combine date + time into a single DateTime for storage
      DateTime? combinedDate = _selectedDueDate;
      if (combinedDate != null && _selectedTime != null) {
        combinedDate = DateTime(
          combinedDate.year, combinedDate.month, combinedDate.day,
          _selectedTime!.hour, _selectedTime!.minute,
        );
      }

      String? dueLabel;
      if (_selectedDueDate != null) {
        final base = _formatDate(_selectedDueDate!);
        dueLabel = _selectedTime != null ? '$base · ${_formatTime(_selectedTime!)}' : base;
      }

      final isOverdue = _selectedDueDate != null &&
          _selectedDueDate!.isBefore(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day));

      final allocMin = int.tryParse(_timeAllocCtrl.text.trim());

      final companion = TasksCompanion(
        title:            Value(title),
        quadrant:         Value(_quad),
        priority:         Value(_priority),
        notes:            Value(_notesCtrl.text.trim().isNotEmpty ? _notesCtrl.text.trim() : null),
        dueDate:          Value(combinedDate),
        dueLabel:         Value(dueLabel),
        isOverdue:        Value(isOverdue),
        timeAllocatedMin: Value(allocMin != null && allocMin > 0 ? allocMin : null),
        labels:           Value(_labels.isEmpty ? null : _labels.join(',')),
      );

      if (_isNew) {
        final newId = await ref.read(appDatabaseProvider).tasksDao.insertTask(companion);
        for (int i = 0; i < _subtasks.length; i++) {
          await ref.read(appDatabaseProvider).tasksDao.insertSubtask(SubtasksCompanion(
            taskId: Value(newId),
            title: Value(_subtasks[i].text),
            isDone: Value(_subtasks[i].done),
            sortOrder: Value(i),
          ));
        }
      } else {
        final id = _taskId!;
        await ref.read(appDatabaseProvider).tasksDao.updateTask(id, companion);
      }
      if (mounted) context.pop();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = TaskEraTheme.of(context).colors;
    final dueText = _selectedDueDate != null ? _formatDate(_selectedDueDate!) : '';
    final allLabels = {..._allLabels, ...ref.watch(taskeraSettingsProvider).customLabels}.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Top bar
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
          child: Row(
            children: [
              AddBackButton(onTap: () => context.pop()),
              SizedBox(width: 8),
              Expanded(
                child: _isNew
                    ? Text(AppL10n.of(context).addTask, style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontVariations: [FontVariation('wght', 600)], fontSize: 19, letterSpacing: -0.5, color: colors.ink))
                    : RichText(
                        text: TextSpan(
                          style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontVariations: [FontVariation('wght', 600)], fontSize: 19, letterSpacing: -0.5, height: 1.1),
                          children: [
                            TextSpan(text: _quadLabel, style: TextStyle(color: _quadColor)),
                            TextSpan(text: ' · ${AppL10n.of(context).edit}', style: TextStyle(color: colors.ink)),
                          ],
                        ),
                      ),
              ),
              GestureDetector(
                onTap: _loading ? null : _save,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(14, 5, 14, 5),
                  decoration: BoxDecoration(
                    color: _loading ? colors.surf2 : TaskEraColors.acc,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: _loading
                      ? SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text(AppL10n.of(context).save, style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),

        // Form body
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(12, 2, 12, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [

                // TITLE + AI PARSER
                _FormRow(
                  label: 'TITLE',
                  colors: colors,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(width: 0.5, color: colors.bdr2),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _titleCtrl,
                                onChanged: _parseTitle,
                                style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 13, fontWeight: FontWeight.w600, color: colors.ink),
                                decoration: InputDecoration(
                                  hintText: "e.g. 'Call dentist Friday 3pm Q2'",
                                  hintStyle: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 11, color: colors.ink3),
                                  isDense: true,
                                  contentPadding: const EdgeInsets.fromLTRB(10, 10, 10, 6),
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Icon(Icons.mic_none, size: 18, color: colors.ink3),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.fromLTRB(10, 6, 10, 8),
                          decoration: BoxDecoration(border: Border(top: BorderSide(width: 0.5, color: colors.bdr))),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.fromLTRB(5, 1.5, 5, 1.5),
                                decoration: BoxDecoration(color: TaskEraColors.accBg, borderRadius: BorderRadius.circular(3)),
                                child: Text('AI PARSER', style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 8, fontWeight: FontWeight.w700, color: colors.textOrPlain(TaskEraColors.acc2))),
                              ),
                              SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  _parseResult.isEmpty ? 'Type to detect quad, priority, date…' : '✦ $_parseResult',
                                  style: TextStyle(
                                    fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 9,
                                    color: _parseResult.isEmpty ? colors.ink3 : TaskEraColors.acc2,
                                    fontWeight: _parseResult.isEmpty ? FontWeight.w400 : FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 7),

                // QUADRANT
                _FormRow(
                  label: 'QUADRANT',
                  colors: colors,
                  child: Wrap(
                    spacing: 4, runSpacing: 4,
                    children: _quads.map((q) => GestureDetector(
                      onTap: () => setState(() => _quad = q.value),
                      child: _HfChip(label: q.label, on: _quad == q.value, onColor: q.color),
                    )).toList(),
                  ),
                ),
                SizedBox(height: 7),

                // PRIORITY
                _FormRow(
                  label: 'PRIORITY',
                  colors: colors,
                  child: Wrap(
                    spacing: 4, runSpacing: 4,
                    children: _priorities.map((p) => GestureDetector(
                      onTap: () => setState(() => _priority = p.value),
                      child: _HfChip(label: p.label, on: _priority == p.value, onColor: p.color),
                    )).toList(),
                  ),
                ),
                SizedBox(height: 7),

                // LABELS
                _FormRow(
                  label: 'LABELS',
                  colors: colors,
                  child: Wrap(
                    spacing: 4, runSpacing: 4,
                    children: [
                      ...allLabels.map((l) {
                        final on = _labels.contains(l);
                        return GestureDetector(
                          onTap: () => setState(() => on ? _labels.remove(l) : _labels.add(l)),
                          child: _HfChip(label: '#$l', on: on),
                        );
                      }),
                      GestureDetector(
                        onTap: _addCustomLabel,
                        child: _HfChip(label: '+ New', on: false, overrideColor: TaskEraColors.acc2),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 7),

                // DUE
                _FormRow(
                  label: 'DUE',
                  colors: colors,
                  child: GestureDetector(
                    onTap: _pickDate,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(width: 0.5, color: colors.bdr2),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                              child: Text(
                                dueText.isEmpty ? 'Tap to pick date' : dueText,
                                style: TextStyle(
                                  fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 13,
                                  color: dueText.isEmpty ? colors.ink3 : colors.ink,
                                ),
                              ),
                            ),
                          ),
                          if (_selectedDueDate != null)
                            GestureDetector(
                              onTap: () => setState(() => _selectedDueDate = null),
                              child: Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: Icon(Icons.close, size: 14, color: colors.ink3),
                              ),
                            ),
                          Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: Icon(Icons.calendar_today_outlined, size: 14, color: colors.ink3),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 7),

                // REMINDER
                _FormRow(
                  label: 'REMINDER',
                  colors: colors,
                  child: GestureDetector(
                    onTap: _pickTime,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(width: 0.5, color: colors.bdr2),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                              child: Text(
                                _selectedTime != null ? _reminderCtrl.text : '+ Add reminder',
                                style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 13,
                                    color: _selectedTime != null ? colors.ink : colors.ink3),
                              ),
                            ),
                          ),
                          if (_selectedTime != null)
                            GestureDetector(
                              onTap: () => setState(() { _selectedTime = null; _reminderCtrl.clear(); }),
                              child: Padding(padding: const EdgeInsets.only(right: 8), child: Icon(Icons.close, size: 14, color: colors.ink3)),
                            ),
                          Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: Icon(Icons.notifications_none, size: 14, color: colors.ink3),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 7),

                // REMIND ME — schedules a real reminder/alarm that fires
                _FormRow(
                  label: 'REMIND ME',
                  colors: colors,
                  child: GestureDetector(
                    onTap: () => showAddReminderSheet(context, ref,
                        initialLabel: _normalizeTitle(_titleCtrl.text)),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(width: 0.5, color: colors.bdr2),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                              child: Text('+ Set reminder or alarm',
                                  style: TextStyle(
                                      fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 13, color: colors.ink3)),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: Icon(Icons.alarm, size: 14, color: colors.ink3),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 7),

                // TIME ALLOCATED
                _FormRow(
                  label: 'TIME ALLOCATED',
                  colors: colors,
                  child: GestureDetector(
                    onTap: _pickTimeAlloc,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(width: 0.5, color: colors.bdr2),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                              child: Text(
                                _timeAllocCtrl.text.isNotEmpty
                                    ? _formatTimeAlloc(int.parse(_timeAllocCtrl.text))
                                    : 'Tap to set duration',
                                style: TextStyle(
                                  fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 13,
                                  color: _timeAllocCtrl.text.isNotEmpty ? colors.ink : colors.ink3,
                                ),
                              ),
                            ),
                          ),
                          if (_timeAllocCtrl.text.isNotEmpty)
                            GestureDetector(
                              onTap: () => setState(() => _timeAllocCtrl.clear()),
                              child: Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: Icon(Icons.close, size: 14, color: colors.ink3),
                              ),
                            ),
                          Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: Icon(Icons.timer_outlined, size: 14, color: colors.ink3),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 7),

                // SUBTASKS
                _FormRow(
                  label: 'SUBTASKS',
                  colors: colors,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (int i = 0; i < _subtasks.length; i++)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: _SubtaskEditRow(
                            sub: _subtasks[i],
                            colors: colors,
                            onToggle: () => setState(() => _subtasks[i].done = !_subtasks[i].done),
                            onDelete: () => setState(() => _subtasks.removeAt(i)),
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Row(
                          children: [
                            Container(
                              width: 15, height: 15,
                              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(width: 1.2, color: colors.bdr2)),
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: _subtaskCtrl,
                                style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 13, color: colors.ink),
                                decoration: InputDecoration(
                                  hintText: AppL10n.of(context).addSubtaskPlus,
                                  hintStyle: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 13, color: colors.ink3),
                                  border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.zero,
                                ),
                                textInputAction: TextInputAction.done,
                                onSubmitted: (val) {
                                  if (val.trim().isNotEmpty) {
                                    setState(() { _subtasks.add(_EditSubtask(text: val.trim())); _subtaskCtrl.clear(); });
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 7),

                // NOTES
                _FormRow(
                  label: 'NOTES',
                  colors: colors,
                  child: _notesField(_notesCtrl, 'Add notes…', colors),
                ),
                if (!_isNew) ...[
                  SizedBox(height: 16),
                  GestureDetector(
                    onTap: () async {
                      final confirmed = await taskeraConfirmDelete(context);
                      if (confirmed && context.mounted) {
                        await ref.read(appDatabaseProvider).tasksDao.deleteTask(_taskId!);
                        if (context.mounted) context.pop();
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0x12FF453A),
                        borderRadius: BorderRadius.circular(11),
                        border: Border.all(width: 0.5, color: const Color(0x33FF453A)),
                      ),
                      alignment: Alignment.center,
                      child: Text('Delete Task', style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFFFF453A), height: 1)),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }


  Widget _notesField(TextEditingController ctrl, String hint, TaskEraColors colors) {
    return TextField(
      controller: ctrl,
      minLines: 4,
      maxLines: null,
      style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 13, color: colors.ink),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 13, color: colors.ink3),
        isDense: true,
        contentPadding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
        filled: true,
        fillColor: Colors.transparent,
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(width: 0.5, color: colors.bdr2)),
        focusedBorder:  OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(width: 0.5, color: colors.bdr2)),
      ),
    );
  }
}

// ── Subtask edit row ──────────────────────────────────────────────────────────

class _SubtaskEditRow extends StatelessWidget {
  final _EditSubtask sub;
  final TaskEraColors colors;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  const _SubtaskEditRow({required this.sub, required this.colors, required this.onToggle, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(width: 0.5, color: colors.bdr2),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onToggle,
            child: Container(
              width: 15, height: 15,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: sub.done ? const Color(0x337FBA00) : Colors.transparent,
                border: Border.all(width: 1.5, color: sub.done ? TaskEraColors.q2 : colors.bdr2),
              ),
              child: sub.done ? Center(child: Icon(Icons.check, size: 8, color: TaskEraColors.q2)) : null,
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              sub.text,
              style: TextStyle(
                fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 13,
                color: sub.done ? colors.ink3 : colors.ink,
                decoration: sub.done ? TextDecoration.lineThrough : null,
                decorationColor: colors.ink3,
              ),
            ),
          ),
          GestureDetector(
            onTap: onDelete,
            child: Icon(Icons.close, size: 14, color: colors.ink3),
          ),
        ],
      ),
    );
  }
}

// ── Form section ──────────────────────────────────────────────────────────────

class _FormRow extends StatelessWidget {
  final String label;
  final Widget child;
  final TaskEraColors colors;
  const _FormRow({required this.label, required this.child, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.5, color: colors.ink3, height: 1)),
        SizedBox(height: 4),
        child,
      ],
    );
  }
}

// ── Selection chip ────────────────────────────────────────────────────────────

class _HfChip extends StatelessWidget {
  final String label;
  final bool on;
  final Color? onColor;
  final Color? overrideColor;
  const _HfChip({required this.label, required this.on, this.onColor, this.overrideColor});

  @override
  Widget build(BuildContext context) {
    final colors    = TaskEraTheme.of(context).colors;
    final textColor = overrideColor ?? (on ? (onColor ?? TaskEraColors.acc2) : colors.ink3);
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 4, 10, 4),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(width: 0.5, color: on ? const Color(0x660A84FF) : colors.bdr),
      ),
      child: Text(label, style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 11, fontWeight: on ? FontWeight.w700 : FontWeight.w400, color: textColor, height: 1)),
    );
  }
}
