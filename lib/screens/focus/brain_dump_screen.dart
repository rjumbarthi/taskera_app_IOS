import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import '../../l10n/app_l10n.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/database.dart'
    show TasksCompanion, GoalsCompanion, CustomListsCompanion, CustomListItemsCompanion;
import '../../data/providers/database_provider.dart';
import '../../services/ai_service.dart';
import '../../settings/prefs_provider.dart';
import '../../theme/kaal_colors.dart';
import '../../theme/kaal_theme.dart';
import '../../widgets/add_back_button.dart';

class BrainDumpScreen extends ConsumerStatefulWidget {
  const BrainDumpScreen({super.key});

  @override
  ConsumerState<BrainDumpScreen> createState() => _BrainDumpScreenState();
}

class _BrainDumpScreenState extends ConsumerState<BrainDumpScreen> {
  static const _kPrefKey = 'kaal.brainDump';

  final _controller = TextEditingController();
  bool _loading = false;
  String? _error;
  Map<String, dynamic>? _result;
  Map<String, dynamic>? _suggestions;

  // Track which suggestions have been added
  final _taskAdded   = <int>{};
  final _goalAdded   = <int>{};
  bool  _listCreated = false;

  @override
  void initState() {
    super.initState();
    final prefs = ref.read(sharedPreferencesProvider);
    final saved = prefs.getString(_kPrefKey) ?? '';
    if (saved.isNotEmpty) _controller.text = saved;
    _controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    ref.read(sharedPreferencesProvider).setString(_kPrefKey, _controller.text);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    super.dispose();
  }

  Future<void> _process() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _loading      = true;
      _error        = null;
      _result       = null;
      _suggestions  = null;
      _taskAdded.clear();
      _goalAdded.clear();
      _listCreated  = false;
    });

    try {
      final results = await Future.wait<Map<String, dynamic>?>([
        ref.read(aiServiceProvider).processBrainDump(text),
        ref.read(aiServiceProvider).suggestContext(text),
      ]);
      if (mounted) {
        setState(() {
          _loading     = false;
          _result      = results[0];
          _suggestions = results[1];
          if (_result == null && _suggestions == null) {
            _error = 'AI returned no results. Check your connection and try again.';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error   = e.toString().replaceFirst('Exception: ', '');
        });
      }
    }
  }

  // ── DB write helpers ────────────────────────────────────────────────────────

  Future<void> _addTask(int idx, String title, int quadrant) async {
    await ref.read(appDatabaseProvider).tasksDao.insertTask(
      TasksCompanion(title: Value(title), quadrant: Value(quadrant)),
    );
    if (mounted) setState(() => _taskAdded.add(idx));
  }

  Future<void> _createChecklist(String contextLabel, List<String> items) async {
    final db = ref.read(appDatabaseProvider);
    final id = await db.listsDao.createList(CustomListsCompanion(
      title: Value('$contextLabel checklist'),
      emoji: const Value('✅'),
    ));
    for (final item in items) {
      await db.listsDao.addItem(CustomListItemsCompanion(
        listId: Value(id),
        content: Value(item),
      ));
    }
    if (mounted) setState(() => _listCreated = true);
  }

  Future<void> _addGoal(int idx, String title) async {
    const accent = Color(0xFF0A84FF);
    await ref.read(appDatabaseProvider).goalsDao.insertGoal(GoalsCompanion(
      emoji:            const Value('🎯'),
      emojiBg:          const Value('0x1F0A84FF'),
      title:            Value(title),
      subtitle:         const Value(''),
      accentColorValue: Value(accent.toARGB32()),
      barColorValue:    Value(accent.withAlpha(0xE5).toARGB32()),
      borderColorValue: Value(accent.withAlpha(0x33).toARGB32()),
      linkedLabel:      const Value('LINKED TASKS · 0/0'),
      dotColorValue:    Value(accent.toARGB32()),
    ));
    if (mounted) setState(() => _goalAdded.add(idx));
  }

  @override
  Widget build(BuildContext context) {
    final colors = KaalTheme.of(context).colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _SubHeader(),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // AI notice card
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                  decoration: BoxDecoration(
                    color: const Color(0x12BF5AF2),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(width: 0.5, color: const Color(0x33BF5AF2)),
                  ),
                  child: const Text(
                    '✦ Type anything on your mind. Kaal AI will sort each item into the right quadrant — and suggest tasks, checklists & goals if it detects a plan.',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      color: Color(0xFFBF5AF2),
                      height: 1.55,
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // Text input
                Container(
                  constraints: const BoxConstraints(minHeight: 200),
                  decoration: BoxDecoration(
                    color: const Color(0x12BF5AF2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(width: 0.5, color: const Color(0x33BF5AF2)),
                  ),
                  child: TextField(
                    controller: _controller,
                    maxLines: null,
                    minLines: 8,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      color: colors.ink,
                      height: 1.6,
                    ),
                    decoration: InputDecoration(
                      hintText: AppL10n.of(context).brainDumpHint,
                      hintStyle: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        color: colors.ink3,
                        height: 1.6,
                      ),
                      contentPadding: const EdgeInsets.all(12),
                      border: InputBorder.none,
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // Process button
                GestureDetector(
                  onTap: _loading ? null : _process,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    decoration: BoxDecoration(
                      color: _loading ? const Color(0xFF8E5BBE) : const Color(0xFFBF5AF2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: _loading
                        ? const SizedBox(
                            width: 18, height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text(
                            '✦ Process with AI',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),

                // Error state
                if (_error != null) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0x1FFF453A),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(width: 0.5, color: const Color(0x66FF453A)),
                    ),
                    child: Row(
                      children: [
                        const Text('⚠', style: TextStyle(fontSize: 14)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _error!,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 13,
                              color: Color(0xFFFF453A),
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Quadrant sort results
                if (_result != null) ...[
                  const SizedBox(height: 16),
                  _ResultsSection(result: _result!, colors: colors),
                ],

                // Smart suggestions panel
                if (_suggestions != null) ...[
                  const SizedBox(height: 12),
                  _SuggestionsPanel(
                    suggestions: _suggestions!,
                    colors: colors,
                    taskAdded: _taskAdded,
                    goalAdded: _goalAdded,
                    listCreated: _listCreated,
                    onAddTask: _addTask,
                    onCreateList: _createChecklist,
                    onAddGoal: _addGoal,
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Smart suggestions panel ───────────────────────────────────────────────────

class _SuggestionsPanel extends StatelessWidget {
  final Map<String, dynamic> suggestions;
  final KaalColors colors;
  final Set<int> taskAdded;
  final Set<int> goalAdded;
  final bool listCreated;
  final Future<void> Function(int, String, int) onAddTask;
  final Future<void> Function(String, List<String>) onCreateList;
  final Future<void> Function(int, String) onAddGoal;

  const _SuggestionsPanel({
    required this.suggestions,
    required this.colors,
    required this.taskAdded,
    required this.goalAdded,
    required this.listCreated,
    required this.onAddTask,
    required this.onCreateList,
    required this.onAddGoal,
  });

  @override
  Widget build(BuildContext context) {
    final ctx      = suggestions['context'] as String? ?? 'Your plan';
    final tasks    = (suggestions['tasks']     as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
    final checklist= (suggestions['checklist'] as List<dynamic>? ?? []).cast<String>();
    final goals    = (suggestions['goals']     as List<dynamic>? ?? []).cast<String>();

    if (tasks.isEmpty && checklist.isEmpty && goals.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Context header
        Container(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          decoration: BoxDecoration(
            color: const Color(0x12BF5AF2),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(width: 0.5, color: const Color(0x33BF5AF2)),
          ),
          child: Row(children: [
            const Text('✦ ', style: TextStyle(color: Color(0xFFBF5AF2), fontSize: 13)),
            Expanded(
              child: Text('Kaal detected: $ctx',
                  style: const TextStyle(
                      fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w600,
                      color: Color(0xFFBF5AF2), height: 1.3)),
            ),
          ]),
        ),

        // Tasks
        if (tasks.isNotEmpty) ...[
          const SizedBox(height: 10),
          _SugLabel(label: 'SUGGESTED TASKS', colors: colors),
          const SizedBox(height: 6),
          Container(
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(width: 0.5, color: colors.bdr),
            ),
            child: Column(
              children: [
                for (int i = 0; i < tasks.length; i++) ...[
                  if (i > 0) Divider(height: 0.5, thickness: 0.5, color: colors.bdr),
                  _TaskSugRow(
                    index: i,
                    title: tasks[i]['title'] as String? ?? '',
                    quadrant: (tasks[i]['quadrant'] as num?)?.toInt() ?? 2,
                    added: taskAdded.contains(i),
                    colors: colors,
                    onAdd: (title, q) => onAddTask(i, title, q),
                  ),
                ],
              ],
            ),
          ),
        ],

        // Checklist
        if (checklist.isNotEmpty) ...[
          const SizedBox(height: 10),
          _SugLabel(label: 'SUGGESTED CHECKLIST', colors: colors),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(width: 0.5, color: colors.bdr),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Wrap(
                  spacing: 5, runSpacing: 5,
                  children: checklist.map((item) => Container(
                    padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
                    decoration: BoxDecoration(
                      color: listCreated ? const Color(0x1430D158) : colors.surf2,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        width: 0.5,
                        color: listCreated ? const Color(0x4030D158) : colors.bdr,
                      ),
                    ),
                    child: Text(item,
                        style: TextStyle(
                            fontFamily: 'Inter', fontSize: 12,
                            color: listCreated ? const Color(0xFF30D158) : colors.ink,
                            height: 1)),
                  )).toList(),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: listCreated ? null : () {
                    final ctx2 = suggestions['context'] as String? ?? 'My list';
                    onCreateList(ctx2, checklist);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    decoration: BoxDecoration(
                      color: listCreated ? const Color(0x1430D158) : colors.surf2,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        width: 0.5,
                        color: listCreated ? const Color(0x4030D158) : colors.bdr,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      listCreated
                          ? '✓ Checklist created'
                          : '＋ Create checklist with all ${checklist.length} items',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: listCreated ? const Color(0xFF30D158) : KaalColors.acc2,
                        height: 1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],

        // Goals
        if (goals.isNotEmpty) ...[
          const SizedBox(height: 10),
          _SugLabel(label: 'SUGGESTED GOALS', colors: colors),
          const SizedBox(height: 6),
          Container(
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(width: 0.5, color: colors.bdr),
            ),
            child: Column(
              children: [
                for (int i = 0; i < goals.length; i++) ...[
                  if (i > 0) Divider(height: 0.5, thickness: 0.5, color: colors.bdr),
                  _GoalSugRow(
                    index: i,
                    title: goals[i],
                    added: goalAdded.contains(i),
                    colors: colors,
                    onAdd: (title) => onAddGoal(i, title),
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _SugLabel extends StatelessWidget {
  final String label;
  final KaalColors colors;
  const _SugLabel({required this.label, required this.colors});

  @override
  Widget build(BuildContext context) => Text(label,
      style: TextStyle(
          fontFamily: 'Inter', fontSize: 9, fontWeight: FontWeight.w700,
          color: colors.ink3, letterSpacing: 0.5, height: 1));
}

class _TaskSugRow extends StatefulWidget {
  final int index;
  final String title;
  final int quadrant;
  final bool added;
  final KaalColors colors;
  final Future<void> Function(String, int) onAdd;

  const _TaskSugRow({
    required this.index,
    required this.title,
    required this.quadrant,
    required this.added,
    required this.colors,
    required this.onAdd,
  });

  @override
  State<_TaskSugRow> createState() => _TaskSugRowState();
}

class _TaskSugRowState extends State<_TaskSugRow> {
  bool _busy = false;

  static const _qColor = {
    1: Color(0xFFFF453A), 2: Color(0xFF0A84FF),
    3: Color(0xFFFF9F0A), 4: Color(0xFF8E8E93),
  };
  static const _qLabel = {
    1: 'Q1', 2: 'Q2', 3: 'Q3', 4: 'Q4',
  };

  @override
  Widget build(BuildContext context) {
    final qc  = _qColor[widget.quadrant] ?? const Color(0xFF0A84FF);
    final ql  = _qLabel[widget.quadrant] ?? 'Q2';
    final done = widget.added;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 9, 10, 9),
      child: Row(children: [
        Container(
          width: 5, height: 5,
          decoration: BoxDecoration(color: qc, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(widget.title,
              style: TextStyle(
                  fontFamily: 'Inter', fontSize: 13,
                  color: done ? widget.colors.ink3 : widget.colors.ink,
                  decoration: done ? TextDecoration.lineThrough : null,
                  decorationColor: widget.colors.ink3,
                  height: 1.3)),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.fromLTRB(5, 2, 5, 2),
          decoration: BoxDecoration(
            color: qc.withAlpha(0x1A),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(width: 0.5, color: qc.withAlpha(0x66)),
          ),
          child: Text(ql,
              style: TextStyle(fontFamily: 'Inter', fontSize: 9,
                  fontWeight: FontWeight.w700, color: qc, height: 1)),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: done || _busy ? null : () async {
            setState(() => _busy = true);
            await widget.onAdd(widget.title, widget.quadrant);
            if (mounted) setState(() => _busy = false);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 28, height: 28,
            decoration: BoxDecoration(
              color: done ? const Color(0x1430D158) : KaalColors.accBg,
              borderRadius: BorderRadius.circular(7),
              border: Border.all(
                width: 0.5,
                color: done ? const Color(0x4030D158) : const Color(0x330A84FF),
              ),
            ),
            alignment: Alignment.center,
            child: _busy
                ? const SizedBox(width: 12, height: 12,
                    child: CircularProgressIndicator(strokeWidth: 1.5, color: KaalColors.acc2))
                : Icon(
                    done ? Icons.check_rounded : Icons.add_rounded,
                    size: 16,
                    color: done ? const Color(0xFF30D158) : KaalColors.acc2,
                  ),
          ),
        ),
      ]),
    );
  }
}

class _GoalSugRow extends StatefulWidget {
  final int index;
  final String title;
  final bool added;
  final KaalColors colors;
  final Future<void> Function(String) onAdd;

  const _GoalSugRow({
    required this.index,
    required this.title,
    required this.added,
    required this.colors,
    required this.onAdd,
  });

  @override
  State<_GoalSugRow> createState() => _GoalSugRowState();
}

class _GoalSugRowState extends State<_GoalSugRow> {
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final done = widget.added;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 9, 10, 9),
      child: Row(children: [
        const Text('🎯', style: TextStyle(fontSize: 14)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(widget.title,
              style: TextStyle(
                  fontFamily: 'Inter', fontSize: 13,
                  color: done ? widget.colors.ink3 : widget.colors.ink,
                  decoration: done ? TextDecoration.lineThrough : null,
                  decorationColor: widget.colors.ink3,
                  height: 1.3)),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: done || _busy ? null : () async {
            setState(() => _busy = true);
            await widget.onAdd(widget.title);
            if (mounted) setState(() => _busy = false);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 28, height: 28,
            decoration: BoxDecoration(
              color: done ? const Color(0x1430D158) : KaalColors.accBg,
              borderRadius: BorderRadius.circular(7),
              border: Border.all(
                width: 0.5,
                color: done ? const Color(0x4030D158) : const Color(0x330A84FF),
              ),
            ),
            alignment: Alignment.center,
            child: _busy
                ? const SizedBox(width: 12, height: 12,
                    child: CircularProgressIndicator(strokeWidth: 1.5, color: KaalColors.acc2))
                : Icon(
                    done ? Icons.check_rounded : Icons.add_rounded,
                    size: 16,
                    color: done ? const Color(0xFF30D158) : KaalColors.acc2,
                  ),
          ),
        ),
      ]),
    );
  }
}

// ── Quadrant sort results (existing) ─────────────────────────────────────────

class _ResultsSection extends StatelessWidget {
  final Map<String, dynamic> result;
  final KaalColors colors;
  const _ResultsSection({required this.result, required this.colors});

  @override
  Widget build(BuildContext context) {
    final summary = result['summary'] as String?;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (summary != null) ...[
          Container(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            decoration: BoxDecoration(
              color: const Color(0x12BF5AF2),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(width: 0.5, color: const Color(0x33BF5AF2)),
            ),
            child: Text(
              '✦ $summary',
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                color: Color(0xFFBF5AF2),
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
        for (final key in const ['q1', 'q2', 'q3', 'q4']) ...[
          _QuadCard(
            quadKey: key,
            items: (result[key] as List<dynamic>? ?? []).cast<String>(),
            colors: colors,
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}

class _QuadCard extends StatelessWidget {
  final String quadKey;
  final List<String> items;
  final KaalColors colors;
  const _QuadCard({required this.quadKey, required this.items, required this.colors});

  static const _meta = {
    'q1': ('Do Now',    Color(0xFFFF453A), Color(0x1FFF453A), Color(0x40FF453A)),
    'q2': ('Schedule',  Color(0xFF0A84FF), Color(0x1F0A84FF), Color(0x400A84FF)),
    'q3': ('Delegate',  Color(0xFFFF9F0A), Color(0x1FFF9F0A), Color(0x40FF9F0A)),
    'q4': ('Eliminate', Color(0xFF8E8E93), Color(0x1F8E8E93), Color(0x408E8E93)),
  };

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    final m = _meta[quadKey]!;

    return Container(
      decoration: BoxDecoration(
        color: m.$3,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(width: 0.5, color: m.$4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 9, 12, 7),
            child: Text(
              '${quadKey.toUpperCase()} — ${m.$1}',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.4,
                color: m.$2,
                height: 1,
              ),
            ),
          ),
          for (int i = 0; i < items.length; i++) ...[
            Divider(height: 0.5, thickness: 0.5, color: m.$4),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
              child: Row(
                children: [
                  Container(width: 5, height: 5,
                      decoration: BoxDecoration(color: m.$2, shape: BoxShape.circle)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(items[i],
                        style: TextStyle(fontFamily: 'Inter', fontSize: 13,
                            color: colors.ink, height: 1.4)),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Sub-header ────────────────────────────────────────────────────────────────

class _SubHeader extends StatelessWidget {
  const _SubHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AddBackButton(onTap: () => context.pop()),
          const SizedBox(width: 2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Brain Dump',
                      style: TextStyle(
                        fontFamily: 'Fraunces',
                        fontVariations: [FontVariation('wght', 600)],
                        fontSize: 19,
                        letterSpacing: -0.5,
                        color: Color(0xFFF2F2F7),
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0x245856D6),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: const Text(
                        '3/5 free',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF8B8BFF),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 1),
                const Text(
                  'Get everything out of your head',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: Color(0xFF8E8E93),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
