import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/database.dart';
import '../data/models/note_block.dart';
import '../data/providers/database_provider.dart';
import '../routing/routes.dart';
import '../util/input_limits.dart';
import '../theme/taskera_colors.dart';
import '../theme/taskera_theme.dart';

/// Notion-style "capture anything" bar. Type a thought, choose Note or Task,
/// and it's filed instantly — the "Capture" half of Capture / Find / Execute.
class QuickCaptureBar extends ConsumerStatefulWidget {
  const QuickCaptureBar({super.key});

  @override
  ConsumerState<QuickCaptureBar> createState() => _QuickCaptureBarState();
}

class _QuickCaptureBarState extends ConsumerState<QuickCaptureBar> {
  final _ctrl = TextEditingController();
  bool _asTask = false; // Note by default

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _capture() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    final db = ref.read(appDatabaseProvider);
    final lines = text.split('\n');
    final title = lines.first.trim();
    final bodyLines = lines.skip(1).where((l) => l.trim().isNotEmpty).toList();

    String kind;
    String route;
    if (_asTask) {
      await db.tasksDao.insertTask(TasksCompanion(
        title: Value(title),
        quadrant: const Value(2), // Q2 · Schedule
        notes: Value(bodyLines.join('\n')),
      ));
      kind = 'Task';
      route = TaskEraRoutes.tasks; // opens Tasks tab (no per-task deep link)
    } else {
      final blocks = bodyLines.isEmpty
          ? [NoteBlock(id: newBlockId())]
          : bodyLines.map((l) => NoteBlock(id: newBlockId(), text: l)).toList();
      final id = await db.notesDao.insertNote(NotesCompanion(
        title: Value(title),
        body: Value(BlockDocument(blocks).encode()),
        timeLabel: const Value('Just now'),
      ));
      kind = 'Note';
      route = '${TaskEraRoutes.notesEditor}/$id';
    }

    _ctrl.clear();
    if (!mounted) return;
    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Captured as $kind ✓'),
      duration: const Duration(seconds: 3),
      behavior: SnackBarBehavior.floating,
      action: SnackBarAction(
        label: 'Open',
        textColor: TaskEraTheme.of(context).colors.textOrPlain(TaskEraColors.acc2),
        onPressed: () => context.push(route),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final colors = TaskEraTheme.of(context).colors;
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: const Color(0x120A84FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(width: 0.5, color: const Color(0x330A84FF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text('⚡', style: TextStyle(fontSize: 15)),
              SizedBox(width: 7),
              Text('Quick capture',
                  style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 12, fontWeight: FontWeight.w700, color: colors.ink2)),
            ],
          ),
          SizedBox(height: 8),
          TextField(
            controller: _ctrl,
            maxLines: null,
            minLines: 1,
            inputFormatters: maxLen(kMaxLongText),
            textInputAction: TextInputAction.newline,
            style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 14, color: colors.ink, height: 1.4),
            decoration: InputDecoration(
              hintText: 'Capture a thought, task, or idea…',
              hintStyle: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 14, color: colors.ink3),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 6),
              border: InputBorder.none,
            ),
          ),
          SizedBox(height: 6),
          Row(
            children: [
              _typeToggle(colors, 'Note', !_asTask, () => setState(() => _asTask = false)),
              SizedBox(width: 6),
              _typeToggle(colors, 'Task', _asTask, () => setState(() => _asTask = true)),
              const Spacer(),
              GestureDetector(
                onTap: _capture,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(14, 7, 14, 7),
                  decoration: BoxDecoration(color: TaskEraColors.acc, borderRadius: BorderRadius.circular(8)),
                  child: Text('Capture',
                      style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 12.5, fontWeight: FontWeight.w700, color: Colors.white, height: 1)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _typeToggle(TaskEraColors colors, String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
        decoration: BoxDecoration(
          color: active ? TaskEraColors.acc : Colors.transparent,
          borderRadius: BorderRadius.circular(7),
          border: Border.all(width: 0.5, color: active ? TaskEraColors.acc : colors.bdr),
        ),
        child: Text(label,
            style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 12, fontWeight: FontWeight.w600, color: active ? Colors.white : colors.ink2, height: 1)),
      ),
    );
  }
}
