import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/database.dart' show TasksCompanion, SubtasksCompanion;
import '../../data/providers/database_provider.dart';
import '../../l10n/app_l10n.dart';
import '../../theme/kaal_colors.dart';
import '../../theme/kaal_theme.dart';
import '../../widgets/add_back_button.dart';

// ── Screen ────────────────────────────────────────────────────────────────────

class QuickAddScreen extends ConsumerStatefulWidget {
  const QuickAddScreen({super.key});

  @override
  ConsumerState<QuickAddScreen> createState() => _QuickAddScreenState();
}

class _QuickAddScreenState extends ConsumerState<QuickAddScreen> {
  final _titleCtrl = TextEditingController();
  final _newSubCtrl = TextEditingController();
  String? _quad;
  String? _priority;
  String? _repeat;
  final Set<String> _labels = {};
  String _parseResult = '';
  DateTime? _dueDate;
  TimeOfDay? _reminderTime;
  bool _addingSubtask = false;

  int _quadrantInt() => switch (_quad) {
        'q1' => 1,
        'q2' => 2,
        'q3' => 3,
        'q4' => 4,
        _ => 1,
      };

  Future<void> _addTask() async {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) return;
    final db = ref.read(appDatabaseProvider);
    final newId = await db.tasksDao.insertTask(
      TasksCompanion(
        title: Value(title),
        quadrant: Value(_quadrantInt()),
        dueDate: Value(_dueDate),
        recurrenceLabel: Value(_repeat),
      ),
    );
    for (int i = 0; i < _subtasks.length; i++) {
      await db.tasksDao.insertSubtask(SubtasksCompanion(
        taskId: Value(newId),
        title: Value(_subtasks[i].text),
        isDone: Value(_subtasks[i].done),
        sortOrder: Value(i),
      ));
    }
    if (mounted) context.pop();
  }

  Future<void> _pickDue() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 3 * 365)),
      builder: (context, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: KaalColors.acc,
            onPrimary: Colors.white,
            surface: Color(0xFF1C1C1E),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  Future<void> _pickReminder() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime ?? TimeOfDay.now(),
      builder: (context, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: KaalColors.acc,
            onPrimary: Colors.white,
            surface: Color(0xFF1C1C1E),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _reminderTime = picked);
  }

  String _formatDue() {
    if (_dueDate == null) return '';
    final d = _dueDate!;
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$m/$day/${d.year}';
  }

  String _formatReminder() {
    if (_reminderTime == null) return '';
    final t = _reminderTime!;
    final hour = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final min = t.minute.toString().padLeft(2, '0');
    final period = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$min $period';
  }

  void _confirmSubtask() {
    final text = _newSubCtrl.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _subtasks.add(_Subtask(text: text, done: false));
      _addingSubtask = false;
      _newSubCtrl.clear();
    });
  }

  void _parseTitle(String text) {
    final lower = text.toLowerCase();
    final parts = <String>[];
    String? newQuad = _quad;
    String? newPriority = _priority;

    if (RegExp(r'\bq1\b|urgent|asap|critical').hasMatch(lower)) {
      newQuad = 'q1';
      parts.add('Q1 Do Now');
    } else if (RegExp(r'\bq2\b|schedule|plan|learn|review|study').hasMatch(lower)) {
      newQuad = 'q2';
      parts.add('Q2 Schedule');
    } else if (RegExp(r'\bq3\b|delegate|forward|send|reply').hasMatch(lower)) {
      newQuad = 'q3';
      parts.add('Q3 Delegate');
    } else if (RegExp(r'\bq4\b|someday|later|eventually').hasMatch(lower)) {
      newQuad = 'q4';
      parts.add('Q4 Eliminate');
    }

    if (RegExp(r'\bp1\b|critical|deadline').hasMatch(lower)) {
      newPriority = 'P1';
      parts.add('P1 Urgent');
    } else if (RegExp(r'\bp2\b|\bhigh\b').hasMatch(lower)) {
      newPriority = 'P2';
      parts.add('P2 High');
    } else if (RegExp(r'\bp3\b|\bmedium\b').hasMatch(lower)) {
      newPriority = 'P3';
      parts.add('P3 Medium');
    }

    if (lower.contains('today')) {
      parts.add('📅 Today');
    } else if (lower.contains('tomorrow')) {
      parts.add('📅 Tomorrow');
    } else if (RegExp(r'\bfri(day)?\b').hasMatch(lower)) {
      parts.add('📅 Friday');
    } else if (RegExp(r'\bmon(day)?\b').hasMatch(lower)) {
      parts.add('📅 Monday');
    } else if (RegExp(r'\b\d{1,2}(am|pm)\b').hasMatch(lower)) {
      parts.add('⏰ Time detected');
    }

    final newResult = parts.isEmpty ? '' : parts.join(' · ');
    if (newQuad != _quad || newPriority != _priority || newResult != _parseResult) {
      setState(() { _quad = newQuad; _priority = newPriority; _parseResult = newResult; });
    }
  }

  final List<_Subtask> _subtasks = [];

  static const _quads = [
    ('q1', 'Q1 Do Now',    KaalColors.q1),
    ('q2', 'Q2 Schedule',  KaalColors.q2),
    ('q3', 'Q3 Delegate',  KaalColors.q3),
    ('q4', 'Q4 Eliminate', KaalColors.q4),
  ];

  static const _priorities = [
    ('P1', 'P1 Urgent', Color(0xFFFF6B6B)),
    ('P2', 'P2 High',   Color(0xFFFF9500)),
    ('P3', 'P3 Medium', KaalColors.acc2),
    ('P4', 'P4 Low',    Color(0xFF8E8E93)),
  ];

  static const _allLabels = ['work', 'personal', 'health', 'finance', 'learning'];

  static const _repeats = [
    ('↻ Daily',    'Daily'),
    ('↻ Weekdays', 'Weekdays'),
    ('↻ Weekly',   'Weekly'),
    ('↻ Monthly',  'Monthly'),
  ];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _newSubCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = KaalTheme.of(context).colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Top bar
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
          child: Row(
            children: [
              AddBackButton(onTap: () => context.pop()),
              const SizedBox(width: 8),
              Expanded(
                child: Text(AppL10n.of(context).addTask, style: TextStyle(fontFamily: 'Fraunces', fontVariations: [FontVariation('wght', 600)], fontSize: 19, letterSpacing: -0.5, color: colors.ink)),
              ),
              GestureDetector(
                onTap: _addTask,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(14, 6, 14, 6),
                  decoration: BoxDecoration(color: KaalColors.acc, borderRadius: BorderRadius.circular(8)),
                  child: Text(AppL10n.of(context).save, style: const TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white, height: 1)),
                ),
              ),
            ],
          ),
        ),

        // Form body
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // TITLE with AI parser
                _SectionLabel(label: 'TITLE', colors: colors),
                const SizedBox(height: 4),
                Container(
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
                              style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: colors.ink),
                              decoration: InputDecoration(
                                hintText: "e.g. 'Call dentist Friday 3pm Q2 remind'",
                                hintStyle: TextStyle(fontFamily: 'Inter', fontSize: 11, color: colors.ink3),
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
                        decoration: BoxDecoration(
                          border: Border(top: BorderSide(width: 0.5, color: colors.bdr)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.fromLTRB(5, 1.5, 5, 1.5),
                              decoration: BoxDecoration(color: KaalColors.accBg, borderRadius: BorderRadius.circular(3)),
                              child: const Text('AI PARSER', style: TextStyle(fontFamily: 'Inter', fontSize: 8, fontWeight: FontWeight.w700, color: KaalColors.acc2)),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                _parseResult.isEmpty
                                    ? 'Type a task — AI extracts date, time, quad, score…'
                                    : '✦ $_parseResult',
                                style: TextStyle(
                                  fontFamily: 'Inter', fontSize: 9,
                                  color: _parseResult.isEmpty ? colors.ink3 : KaalColors.acc2,
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
                const SizedBox(height: 10),

                // QUADRANT
                _SectionLabel(label: 'QUADRANT', colors: colors),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 4, runSpacing: 4,
                  children: _quads.map((q) => GestureDetector(
                    onTap: () => setState(() => _quad = q.$1),
                    child: _HfChip(label: q.$2, on: _quad == q.$1, onColor: q.$3),
                  )).toList(),
                ),
                const SizedBox(height: 10),

                // PRIORITY
                _SectionLabel(label: 'PRIORITY', colors: colors),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 4, runSpacing: 4,
                  children: _priorities.map((p) => GestureDetector(
                    onTap: () => setState(() => _priority = p.$1),
                    child: _HfChip(label: p.$2, on: _priority == p.$1, onColor: p.$3),
                  )).toList(),
                ),
                const SizedBox(height: 10),

                // LABELS
                _SectionLabel(label: 'LABELS', colors: colors),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 4, runSpacing: 4,
                  children: [
                    ..._allLabels.map((l) {
                      final on = _labels.contains(l);
                      return GestureDetector(
                        onTap: () => setState(() => on ? _labels.remove(l) : _labels.add(l)),
                        child: _HfChip(label: '#$l', on: on),
                      );
                    }),
                    const _HfChip(label: '+ New', on: false, overrideColor: KaalColors.acc2),
                  ],
                ),
                const SizedBox(height: 10),

                // DUE
                _SectionLabel(label: 'DUE', colors: colors),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: _pickDue,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(width: 0.5, color: colors.bdr2),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _dueDate != null ? _formatDue() : 'mm/dd/yyyy',
                            style: TextStyle(fontFamily: 'Inter', fontSize: 13,
                                color: _dueDate != null ? colors.ink : colors.ink3),
                          ),
                        ),
                        if (_dueDate != null)
                          GestureDetector(
                            onTap: () => setState(() => _dueDate = null),
                            child: Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: Icon(Icons.close, size: 14, color: colors.ink3),
                            ),
                          ),
                        Icon(Icons.calendar_today_outlined, size: 14, color: colors.ink3),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // REMINDER
                _SectionLabel(label: 'REMINDER', colors: colors),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: _pickReminder,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(width: 0.5, color: colors.bdr2),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _reminderTime != null ? _formatReminder() : '--:-- --',
                            style: TextStyle(fontFamily: 'Inter', fontSize: 13,
                                color: _reminderTime != null ? colors.ink : colors.ink3),
                          ),
                        ),
                        if (_reminderTime != null)
                          GestureDetector(
                            onTap: () => setState(() => _reminderTime = null),
                            child: Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: Icon(Icons.close, size: 14, color: colors.ink3),
                            ),
                          ),
                        Icon(Icons.notifications_none, size: 14, color: colors.ink3),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // REPEAT
                _SectionLabel(label: 'REPEAT', colors: colors),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 4, runSpacing: 4,
                  children: _repeats.map((r) => GestureDetector(
                    onTap: () => setState(() => _repeat = _repeat == r.$1 ? null : r.$1),
                    child: _HfChip(label: r.$2, on: _repeat == r.$1, onColor: KaalColors.acc2),
                  )).toList(),
                ),
                const SizedBox(height: 10),

                // SUBTASKS
                _SectionLabel(label: 'SUBTASKS', colors: colors),
                const SizedBox(height: 4),
                for (final sub in _subtasks) ...[
                  _SubtaskRow(sub: sub, colors: colors, onToggle: () => setState(() => sub.done = !sub.done)),
                  const SizedBox(height: 4),
                ],
                if (_addingSubtask) ...[
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(width: 0.5, color: colors.bdr2),
                          ),
                          child: TextField(
                            controller: _newSubCtrl,
                            autofocus: true,
                            style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: colors.ink),
                            decoration: InputDecoration(
                              hintText: AppL10n.of(context).subtaskTitleHint,
                              hintStyle: TextStyle(fontFamily: 'Inter', fontSize: 13, color: colors.ink3),
                              isDense: true,
                              contentPadding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                              border: InputBorder.none,
                            ),
                            onSubmitted: (_) => _confirmSubtask(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: _confirmSubtask,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(color: KaalColors.acc, borderRadius: BorderRadius.circular(6)),
                          child: const Icon(Icons.check, size: 14, color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () => setState(() { _addingSubtask = false; _newSubCtrl.clear(); }),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(width: 0.5, color: colors.bdr),
                          ),
                          child: Icon(Icons.close, size: 14, color: colors.ink3),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                ] else
                  GestureDetector(
                    onTap: () => setState(() => _addingSubtask = true),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 4),
                      child: Text('＋ Add subtask', style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: KaalColors.acc)),
                    ),
                  ),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Helper widgets ────────────────────────────────────────────────────────────

class _Subtask {
  String text;
  bool done;
  _Subtask({required this.text, required this.done});
}

class _SubtaskRow extends StatelessWidget {
  final _Subtask sub;
  final KaalColors colors;
  final VoidCallback onToggle;
  const _SubtaskRow({required this.sub, required this.colors, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: onToggle,
          child: Container(
            width: 15, height: 15,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: sub.done ? const Color(0x337FBA00) : Colors.transparent,
              border: Border.all(width: 1.5, color: sub.done ? KaalColors.q2 : colors.bdr2),
            ),
            child: sub.done ? const Center(child: Icon(Icons.check, size: 8, color: KaalColors.q2)) : null,
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            sub.text,
            style: TextStyle(
              fontFamily: 'Inter', fontSize: 13, color: sub.done ? colors.ink3 : colors.ink,
              decoration: sub.done ? TextDecoration.lineThrough : null,
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  final KaalColors colors;
  const _SectionLabel({required this.label, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Text(label, style: TextStyle(fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.5, color: colors.ink3, height: 1));
  }
}

class _HfChip extends StatelessWidget {
  final String label;
  final bool on;
  final Color? onColor;
  final Color? overrideColor;
  const _HfChip({required this.label, required this.on, this.onColor, this.overrideColor});

  @override
  Widget build(BuildContext context) {
    final colors = KaalTheme.of(context).colors;
    final textColor = overrideColor ?? (on ? (onColor ?? KaalColors.acc2) : colors.ink3);
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 4, 10, 4),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(width: 0.5, color: on ? const Color(0x660A84FF) : colors.bdr),
      ),
      child: Text(label, style: TextStyle(fontFamily: 'Inter', fontSize: 11, fontWeight: on ? FontWeight.w700 : FontWeight.w400, color: textColor, height: 1)),
    );
  }
}
