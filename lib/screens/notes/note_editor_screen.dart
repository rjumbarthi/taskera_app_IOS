import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/database.dart' show NotesCompanion, Task, Goal;
import '../../data/models/note_block.dart';
import '../../data/providers/database_provider.dart';
import '../../data/providers/goals_provider.dart';
import '../../util/input_limits.dart';
import '../../widgets/block_editor/block_editor.dart';
import '../../data/providers/tasks_provider.dart';
import '../../l10n/app_l10n.dart';
import '../../util/taskera_dialogs.dart';
import '../../theme/taskera_colors.dart';
import '../../theme/taskera_theme.dart';
import '../../services/activity_log_service.dart';
import '../../services/ai_service.dart';
import '../../data/providers/ai_access_provider.dart';
import '../../routing/routes.dart';
import '../../widgets/add_back_button.dart';
import '../../widgets/goal_link_pickers.dart';

class NoteEditorScreen extends ConsumerStatefulWidget {
  final String? noteId;
  const NoteEditorScreen({super.key, this.noteId});

  @override
  ConsumerState<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends ConsumerState<NoteEditorScreen> {
  final _titleCtrl = TextEditingController();

  // Block-document state. `_seed` is the immutable document the BlockEditor is
  // built from (keyed on its identity); `_doc` holds the latest edited content
  // for saving. They diverge after the first keystroke.
  BlockDocument? _seed;
  BlockDocument _doc = BlockDocument.empty();

  // Ids of tasks linked to this note (source of truth while editing).
  final Set<int> _linkedTaskIds = {};

  bool get _isEdit => widget.noteId != null;
  int? get _parsedId => widget.noteId != null ? int.tryParse(widget.noteId!) : null;

  @override
  void initState() {
    super.initState();
    if (_parsedId != null) {
      _loadNote();
    } else {
      _seed = _doc; // fresh note: editor ready immediately
    }
  }

  Future<void> _loadNote() async {
    final dao  = ref.read(appDatabaseProvider).notesDao;
    final note = await dao.getNote(_parsedId!);
    final links = await dao.getTaskLinks(_parsedId!);
    if (note != null && mounted) {
      _titleCtrl.text = note.title;
      final loaded = BlockDocument.decode(note.body);
      setState(() {
        _seed = loaded;
        _doc = loaded;
        _pinned = note.isPinned;
        _linkedTaskIds
          ..clear()
          ..addAll(links.map((l) => l.taskId));
      });
    }
  }

  Future<void> _aiScan() async {
    final body = _doc.plainText.trim();
    final messenger = ScaffoldMessenger.of(context);
    if (body.isEmpty) {
      messenger.showSnackBar(
          SnackBar(content: Text('Write a note first to scan it')));
      return;
    }
    if (!(await ref.read(aiUnlockedProvider.future))) {
      messenger.showSnackBar(SnackBar(
        content: Text(
            'AI is a TaskEra Pro feature — upgrade, or add your own key in Settings',
            style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 13, color: Colors.white)),
        backgroundColor: const Color(0xFF1C1C1E),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Upgrade',
          // Fixed-dark snackbar — never colors.textOrPlain here.
          textColor: TaskEraTheme.of(context).colors.plainText ? Colors.white : TaskEraColors.acc2,
          onPressed: () => context.push(TaskEraRoutes.paywall),
        ),
      ));
      return;
    }
    messenger.showSnackBar(SnackBar(content: Text('✦ Scanning note…')));
    try {
      final summary = await ref.read(aiServiceProvider).summarizeNote(body);
      if (!mounted) return;
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(SnackBar(
        content: Text((summary == null || summary.isEmpty)
            ? 'AI returned no summary. Try again.'
            : summary),
        duration: const Duration(seconds: 6),
      ));
    } catch (e) {
      if (!mounted) return;
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))));
    }
  }

  void _openTaskPicker(TaskEraColors colors) {
    final all = ref.read(allTasksProvider).value ?? const <Task>[];
    showTaskLinkPicker(
      context: context,
      tasks: all,
      initial: _linkedTaskIds,
      colors: colors,
      title: 'Link tasks to this note',
      onSave: (selected) => setState(() {
        _linkedTaskIds
          ..clear()
          ..addAll(selected);
      }),
    );
  }

  Future<void> _save() async {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) return;
    final dao = ref.read(appDatabaseProvider).notesDao;
    if (_isEdit && _parsedId != null) {
      await dao.updateNote(
        _parsedId!,
        NotesCompanion(
          title: Value(title),
          body: Value(_doc.encode()),
          isPinned: Value(_pinned),
          timeLabel: const Value('Just now'),
        ),
      );
      await dao.setTaskLinks(_parsedId!, _linkedTaskIds);
      ref.logActivity('Note "$title" updated', type: 'note');
    } else {
      final newId = await dao.insertNote(
        NotesCompanion(
          title: Value(title),
          body: Value(_doc.encode()),
          isPinned: Value(_pinned),
          timeLabel: const Value('Just now'),
        ),
      );
      await dao.setTaskLinks(newId, _linkedTaskIds);
      ref.logActivity('Note "$title" created', type: 'note');
    }
    if (mounted) context.pop();
  }

  int        _quadIdx   = 1; // Q2
  int        _goalIdx   = 9999; // defaults to "None" (the last chip)
  bool       _pinned    = false;
  final Set<int> _selLabels  = {0}; // #idea

  static const _quads  = ['Q1 · Do Now', 'Q2 · Schedule', 'Q3 · Delegate', 'Q4 · Eliminate', 'None'];
  static const _quadColors = [TaskEraColors.q1, TaskEraColors.q2, TaskEraColors.q3, TaskEraColors.q4, Color(0xFF8E8E93)];
  static const _labels = ['#idea', '#meeting', '#research', '#journal', '#braindump', '+ New'];

  @override
  void dispose() {
    _titleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = TaskEraTheme.of(context).colors;
    final allTasks    = ref.watch(allTasksProvider).value ?? const <Task>[];
    // Real goals from the DB + a trailing "None" chip (selection is display-only
    // for now — note→goal linking persistence is a separate feature).
    final goalChips = <String>[
      ...(ref.watch(goalsProvider).value ?? const <Goal>[]).map((g) => g.title),
      'None',
    ];
    final goalSel = (_goalIdx >= 0 && _goalIdx < goalChips.length)
        ? _goalIdx
        : goalChips.length - 1;
    final linkedTasks = allTasks.where((t) => _linkedTaskIds.contains(t.id)).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Sub-bar
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 12, 6),
          child: Row(
            children: [
              AddBackButton(onTap: () => context.pop()),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  _isEdit ? 'Edit note' : 'New note',
                  style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontVariations: [FontVariation('wght', 600)], fontSize: 19, letterSpacing: -0.5, color: colors.ink, height: 1.1),
                ),
              ),
              GestureDetector(
                onTap: _save,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(14, 6, 14, 6),
                  decoration: BoxDecoration(color: TaskEraColors.acc, borderRadius: BorderRadius.circular(8)),
                  child: Text(AppL10n.of(context).save, style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white, height: 1)),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
            children: [
              // Title + camera/mic
              _FormRow(
                label: 'Title',
                colors: colors,
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _titleCtrl,
                        inputFormatters: maxLen(kMaxTitle),
                        style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 15, color: colors.ink, height: 1.3),
                        decoration: InputDecoration(
                          hintText: '"Product Roadmap thoughts"',
                          hintStyle: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 15, color: colors.ink3),
                          filled: false,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(width: 0.5, color: colors.bdr)),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(width: 0.5, color: colors.bdr)),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(width: 0.5, color: TaskEraColors.acc)),
                          contentPadding: const EdgeInsets.fromLTRB(10, 9, 10, 9),
                          isDense: true,
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    // Camera btn
                    GestureDetector(
                      onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Photo capture coming soon'))),
                      child: Container(
                        width: 30, height: 30,
                        decoration: BoxDecoration(
                          color: const Color(0x1F7FBA00),
                          shape: BoxShape.circle,
                          border: Border.all(width: 0.5, color: const Color(0x407FBA00)),
                        ),
                        child: Icon(Icons.camera_alt_rounded, size: 14, color: colors.successFg),
                      ),
                    ),
                    SizedBox(width: 6),
                    // Mic btn
                    GestureDetector(
                      onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Voice notes coming soon'))),
                      child: Container(
                        width: 30, height: 30,
                        decoration: const BoxDecoration(
                          color: Color(0x1AFF453A),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.mic_rounded, size: 14, color: Color(0xFFFF6B6B)),
                      ),
                    ),
                  ],
                ),
              ),
              // Quadrant
              _FormRow(
                label: 'Quadrant',
                colors: colors,
                child: Wrap(
                  spacing: 5, runSpacing: 5,
                  children: [
                    for (int i = 0; i < _quads.length; i++)
                      _ColorChip(
                        label: _quads[i],
                        selected: _quadIdx == i,
                        activeColor: _quadColors[i],
                        colors: colors,
                        onTap: () => setState(() => _quadIdx = i),
                      ),
                  ],
                ),
              ),
              // Linked goal
              _FormRow(
                label: 'Linked goal · optional',
                colors: colors,
                child: Wrap(
                  spacing: 5, runSpacing: 5,
                  children: [
                    for (int i = 0; i < goalChips.length; i++)
                      _Chip(
                        label: goalChips[i],
                        selected: goalSel == i,
                        colors: colors,
                        onTap: () => setState(() => _goalIdx = i),
                      ),
                  ],
                ),
              ),
              // Labels
              _FormRow(
                label: 'Labels',
                colors: colors,
                child: Wrap(
                  spacing: 5, runSpacing: 5,
                  children: [
                    for (int i = 0; i < _labels.length; i++)
                      _Chip(
                        label: _labels[i],
                        selected: _selLabels.contains(i),
                        colors: colors,
                        onTap: () => setState(() {
                          if (i == _labels.length - 1) return;
                          if (_selLabels.contains(i)) {
                            _selLabels.remove(i);
                          } else {
                            _selLabels.add(i);
                          }
                        }),
                      ),
                  ],
                ),
              ),
              // Note body — Notion-style block editor
              _FormRow(
                label: 'Note body',
                colors: colors,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Toolbar (AI scan only — formatting is inline via blocks)
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            "Type '/' for blocks · '#', '-', '[]' shortcuts",
                            style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 11, color: colors.ink3),
                          ),
                        ),
                        SizedBox(width: 8),
                        GestureDetector(
                          onTap: _aiScan,
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(8, 3, 8, 3),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(width: 0.5, color: const Color(0x4D0A84FF)),
                            ),
                            child: Text('✦ AI scan', style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 12, color: colors.textOrPlain(TaskEraColors.acc2))),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 6),
                    Container(
                      constraints: const BoxConstraints(minHeight: 160),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(width: 0.5, color: colors.bdr2),
                      ),
                      padding: const EdgeInsets.fromLTRB(6, 8, 6, 8),
                      child: _seed == null
                          ? Padding(
                              padding: EdgeInsets.symmetric(vertical: 40),
                              child: Center(child: SizedBox(
                                  width: 18, height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2))),
                            )
                          : BlockEditor(
                              key: ValueKey(_seed),
                              document: _seed!,
                              colors: colors,
                              onChanged: (d) => _doc = d,
                            ),
                    ),
                  ],
                ),
              ),
              // Linked tasks
              _FormRow(
                label: 'Linked tasks · optional',
                colors: colors,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (linkedTasks.isNotEmpty) ...[
                      Wrap(
                        spacing: 5, runSpacing: 5,
                        children: [
                          for (final t in linkedTasks)
                            _LinkedTaskChip(
                              label: t.title,
                              quadrant: t.quadrant,
                              colors: colors,
                              onRemove: () => setState(() => _linkedTaskIds.remove(t.id)),
                            ),
                        ],
                      ),
                      SizedBox(height: 7),
                    ],
                    GestureDetector(
                      onTap: () => _openTaskPicker(colors),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 9),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: colors.surf2,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(width: 0.5, color: colors.bdr),
                        ),
                        child: Text(
                          linkedTasks.isEmpty ? '+ Link tasks' : '+ Edit linked tasks',
                          style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 12,
                              fontWeight: FontWeight.w600, color: colors.textOrPlain(TaskEraColors.acc2), height: 1),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Pin to top
              _FormRow(
                label: AppL10n.of(context).pinToTop,
                colors: colors,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(AppL10n.of(context).pinToTop, style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 13, color: colors.ink2)),
                    _Toggle(value: _pinned, onChanged: (v) => setState(() => _pinned = v)),
                  ],
                ),
              ),
              if (_isEdit) ...[
                SizedBox(height: 16),
                GestureDetector(
                  onTap: () async {
                    final confirmed = await taskeraConfirmDelete(context);
                    if (confirmed && context.mounted) {
                      await ref.read(appDatabaseProvider).notesDao.deleteNote(_parsedId!);
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
                    child: Text(AppL10n.of(context).deleteNote, style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFFFF453A), height: 1)),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

// ── Local widgets ─────────────────────────────────────────────────────────────

class _FormRow extends StatelessWidget {
  final String label;
  final Widget child;
  final TaskEraColors colors;
  const _FormRow({required this.label, required this.child, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(width: 0.5, color: colors.bdr))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(label.toUpperCase(), style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 11, fontWeight: FontWeight.w600, color: colors.ink3, letterSpacing: 0.4, height: 1)),
          SizedBox(height: 7),
          child,
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final TaskEraColors colors;
  const _Chip({required this.label, required this.selected, required this.onTap, required this.colors});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(9, 5, 9, 5),
        decoration: BoxDecoration(
          color: selected ? TaskEraColors.acc : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(width: 0.5, color: selected ? TaskEraColors.acc : colors.bdr),
        ),
        child: Text(label, style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 12, fontWeight: FontWeight.w500,
          color: selected ? Colors.white : colors.ink2, height: 1)),
      ),
    );
  }
}

class _LinkedTaskChip extends StatelessWidget {
  final String label;
  final int quadrant;
  final VoidCallback onRemove;
  final TaskEraColors colors;
  const _LinkedTaskChip({required this.label, required this.quadrant, required this.onRemove, required this.colors});

  @override
  Widget build(BuildContext context) {
    final qColor = quadrant >= 1 && quadrant <= 4
        ? [TaskEraColors.q1, TaskEraColors.q2, TaskEraColors.q3, TaskEraColors.q4][quadrant - 1]
        : const Color(0xFF8E8E93);
    return Container(
      padding: const EdgeInsets.fromLTRB(9, 5, 6, 5),
      decoration: BoxDecoration(
        color: qColor.withAlpha(0x1F),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(width: 0.5, color: qColor.withAlpha(0x80)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis,
                style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 12, fontWeight: FontWeight.w500,
                    color: colors.ink, height: 1)),
          ),
          SizedBox(width: 6),
          GestureDetector(
            onTap: onRemove,
            behavior: HitTestBehavior.opaque,
            child: Icon(Icons.close_rounded, size: 13, color: colors.ink3),
          ),
        ],
      ),
    );
  }
}

class _ColorChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color activeColor;
  final VoidCallback onTap;
  final TaskEraColors colors;
  const _ColorChip({required this.label, required this.selected, required this.activeColor, required this.onTap, required this.colors});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(9, 5, 9, 5),
        decoration: BoxDecoration(
          color: selected ? activeColor.withAlpha(0x1F) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(width: 0.5, color: selected ? activeColor.withAlpha(0x80) : colors.bdr),
        ),
        child: Text(label, style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 12, fontWeight: FontWeight.w500,
          color: selected ? activeColor : colors.ink2, height: 1)),
      ),
    );
  }
}

class _Toggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  const _Toggle({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 36, height: 21,
        decoration: BoxDecoration(
          color: value ? TaskEraColors.acc : const Color(0x33FFFFFF),
          borderRadius: BorderRadius.circular(11),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2.5),
            child: Container(width: 16, height: 16, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
          ),
        ),
      ),
    );
  }
}
