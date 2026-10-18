import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../data/models/db_models.dart';
import '../../data/providers/database_provider.dart';
import '../../data/providers/databases_provider.dart';
import '../../theme/taskera_colors.dart';
import '../../theme/taskera_theme.dart';
import '../../util/input_limits.dart';

// ── Persistence helpers ──────────────────────────────────────────────────────

DbRow? _latestRow(WidgetRef ref, int dbId, String rowId) {
  final rows = ref.read(dbRowsProvider(dbId)).value ?? const <DbRow>[];
  for (final r in rows) {
    if (r.id == rowId) return r;
  }
  return null;
}

void _persist(WidgetRef ref, int dbId, String rowId, String propId, dynamic value) {
  final row = _latestRow(ref, dbId, rowId);
  if (row == null) return;
  final cells = decodeCells(row);
  final empty = value == null ||
      (value is String && value.isEmpty) ||
      (value is List && value.isEmpty) ||
      value == false;
  if (empty) {
    cells.remove(propId);
  } else {
    cells[propId] = value;
  }
  ref.read(appDatabaseProvider).databasesDao.updateRowCells(row.id, encodeCells(cells));
}

Future<void> _addOptionToProperty(
    WidgetRef ref, DbProperty prop, SelectOption option) async {
  final cfg = PropConfig.parse(prop);
  final next = PropConfig([...cfg.options, option]);
  await ref.read(appDatabaseProvider).databasesDao.upsertProperty(
        DbPropertiesCompanion(
          id: Value(prop.id),
          databaseId: Value(prop.databaseId),
          name: Value(prop.name),
          type: Value(prop.type),
          sortOrder: Value(prop.sortOrder),
          config: Value(next.encode()),
        ),
      );
}

// ── Cell editing ─────────────────────────────────────────────────────────────

/// Edits a single cell in-place, persisting immediately. Checkbox toggles
/// directly; everything else opens a type-appropriate editor.
Future<void> editCell(BuildContext context, WidgetRef ref, TaskEraColors colors,
    int dbId, DbProperty prop, String rowId) async {
  final type = propTypeOf(prop);
  final row = _latestRow(ref, dbId, rowId);
  if (row == null) return;
  final current = decodeCells(row)[prop.id];

  switch (type) {
    case DbPropType.checkbox:
      _persist(ref, dbId, rowId, prop.id, !(current == true));
      break;
    case DbPropType.text:
    case DbPropType.url:
    case DbPropType.number:
      final v = await _editTextValue(context, colors, prop, current?.toString() ?? '',
          number: type == DbPropType.number);
      if (v != null) {
        _persist(ref, dbId, rowId, prop.id,
            type == DbPropType.number ? num.tryParse(v) : v);
      }
      break;
    case DbPropType.date:
      final init = DateTime.tryParse(current?.toString() ?? '') ?? DateTime.now();
      final picked = await showDatePicker(
        context: context,
        initialDate: init,
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
      );
      if (picked != null) {
        _persist(ref, dbId, rowId, prop.id, picked.toIso8601String());
      }
      break;
    case DbPropType.select:
      await _pickSelect(context, ref, colors, dbId, prop, rowId, current);
      break;
    case DbPropType.multiSelect:
      await _pickMultiSelect(context, ref, colors, dbId, prop, rowId, current);
      break;
  }
}

Future<String?> _editTextValue(
    BuildContext context, TaskEraColors colors, DbProperty prop, String current,
    {bool number = false}) {
  final ctrl = TextEditingController(text: current);
  return showDialog<String>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: colors.surf,
      title: Text(prop.name, style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 16, color: colors.ink)),
      content: TextField(
        controller: ctrl,
        autofocus: true,
        inputFormatters: maxLen(kMaxCell),
        keyboardType: number ? const TextInputType.numberWithOptions(decimal: true) : null,
        style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, color: colors.ink),
        decoration: InputDecoration(
          hintText: 'Enter ${prop.name.toLowerCase()}…',
          hintStyle: TextStyle(color: colors.ink3),
          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: colors.bdr)),
          focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: TaskEraColors.acc)),
        ),
        onSubmitted: (v) => Navigator.pop(ctx, v),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel', style: TextStyle(color: colors.ink3))),
        TextButton(onPressed: () => Navigator.pop(ctx, ctrl.text), child: const Text('Save', style: TextStyle(color: TaskEraColors.acc2))),
      ],
    ),
  );
}

Future<void> _pickSelect(BuildContext context, WidgetRef ref, TaskEraColors colors,
    int dbId, DbProperty prop, String rowId, dynamic current) async {
  await showModalBottomSheet(
    context: context,
    backgroundColor: colors.surf,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(18))),
    builder: (ctx) {
      final cfg = PropConfig.parse(prop);
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _sheetTitle(ctx, colors, prop.name),
            ...cfg.options.map((o) => _OptionRow(
                  option: o, colors: colors,
                  selected: current == o.name,
                  onTap: () {
                    _persist(ref, dbId, rowId, prop.id, current == o.name ? null : o.name);
                    Navigator.pop(ctx);
                  },
                )),
            _addOptionRow(ctx, ref, colors, prop, (name) {
              _addOptionToProperty(ref, prop, SelectOption(name, cfg.options.length % kOptionColors.length));
              _persist(ref, dbId, rowId, prop.id, name);
            }),
            const SizedBox(height: 8),
          ],
        ),
      );
    },
  );
}

Future<void> _pickMultiSelect(BuildContext context, WidgetRef ref, TaskEraColors colors,
    int dbId, DbProperty prop, String rowId, dynamic current) async {
  await showModalBottomSheet(
    context: context,
    backgroundColor: colors.surf,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(18))),
    builder: (ctx) => StatefulBuilder(builder: (ctx, setSheet) {
      final row = _latestRow(ref, dbId, rowId);
      final cfg = PropConfig.parse(prop);
      final selected = <String>{
        ...((row == null ? null : decodeCells(row)[prop.id]) as List?)?.cast<String>() ?? const []
      };
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _sheetTitle(ctx, colors, prop.name),
            ...cfg.options.map((o) => _OptionRow(
                  option: o, colors: colors,
                  selected: selected.contains(o.name),
                  onTap: () {
                    if (selected.contains(o.name)) {
                      selected.remove(o.name);
                    } else {
                      selected.add(o.name);
                    }
                    _persist(ref, dbId, rowId, prop.id, selected.toList());
                    setSheet(() {});
                  },
                )),
            _addOptionRow(ctx, ref, colors, prop, (name) {
              _addOptionToProperty(ref, prop, SelectOption(name, cfg.options.length % kOptionColors.length));
              selected.add(name);
              _persist(ref, dbId, rowId, prop.id, selected.toList());
              setSheet(() {});
            }),
            const SizedBox(height: 8),
          ],
        ),
      );
    }),
  );
}

Widget _sheetTitle(BuildContext context, TaskEraColors colors, String title) => Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
      child: Row(children: [
        Text(title, style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 13, fontWeight: FontWeight.w600, color: colors.ink3)),
      ]),
    );

Widget _addOptionRow(BuildContext context, WidgetRef ref, TaskEraColors colors,
    DbProperty prop, ValueChanged<String> onAdd) {
  return InkWell(
    onTap: () async {
      final name = await _editTextValue(context, colors, prop, '');
      if (name != null && name.trim().isNotEmpty) onAdd(name.trim());
    },
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
      child: Row(children: [
        Icon(Icons.add_rounded, size: 18, color: colors.ink3),
        const SizedBox(width: 12),
        Text('Add option', style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 14, color: colors.ink2)),
      ]),
    ),
  );
}

class _OptionRow extends StatelessWidget {
  final SelectOption option;
  final bool selected;
  final TaskEraColors colors;
  final VoidCallback onTap;
  const _OptionRow({required this.option, required this.selected, required this.colors, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(children: [
          OptionChip(option: option),
          const Spacer(),
          if (selected) const Icon(Icons.check_rounded, size: 18, color: TaskEraColors.acc),
        ]),
      ),
    );
  }
}

/// A select-option pill (tinted with the option's colour).
class OptionChip extends StatelessWidget {
  final SelectOption option;
  const OptionChip({super.key, required this.option});

  @override
  Widget build(BuildContext context) {
    final c = option.color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: c.withAlpha(0x24),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(width: 0.5, color: c.withAlpha(0x66)),
      ),
      child: Text(option.name,
          style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 12, fontWeight: FontWeight.w500, color: c)),
    );
  }
}

// ── Row editor sheet ─────────────────────────────────────────────────────────

Future<void> openRowEditor(
    BuildContext context, int dbId, String rowId) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _RowEditorSheet(dbId: dbId, rowId: rowId),
  );
}

class _RowEditorSheet extends ConsumerWidget {
  final int dbId;
  final String rowId;
  const _RowEditorSheet({required this.dbId, required this.rowId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = TaskEraTheme.of(context).colors;
    final props = ref.watch(dbPropertiesProvider(dbId)).value ?? const <DbProperty>[];
    final rows = ref.watch(dbRowsProvider(dbId)).value ?? const <DbRow>[];
    DbRow? row;
    for (final r in rows) {
      if (r.id == rowId) row = r;
    }
    final cells = row == null ? <String, dynamic>{} : decodeCells(row);

    return DraggableScrollableSheet(
      initialChildSize: 0.62,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      expand: false,
      builder: (context, scroll) => Container(
        decoration: BoxDecoration(
          color: colors.surf,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          border: Border.all(width: 0.5, color: colors.bdr),
        ),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(width: 38, height: 4, decoration: BoxDecoration(color: colors.bdr, borderRadius: BorderRadius.circular(2))),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 6),
              child: Row(children: [
                Text('Edit row', style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 15, fontWeight: FontWeight.w700, color: colors.ink)),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    ref.read(appDatabaseProvider).databasesDao.deleteRow(rowId);
                    Navigator.pop(context);
                  },
                  child: const Icon(Icons.delete_outline_rounded, size: 20, color: Color(0xFFFF453A)),
                ),
              ]),
            ),
            Expanded(
              child: ListView(
                controller: scroll,
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                children: [
                  for (final p in props)
                    _fieldRow(context, ref, colors, p, cells[p.id]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fieldRow(BuildContext context, WidgetRef ref, TaskEraColors colors,
      DbProperty p, dynamic value) {
    final type = propTypeOf(p);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(type.icon, size: 14, color: colors.ink3),
            const SizedBox(width: 6),
            Text(p.name.toUpperCase(),
                style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 11, fontWeight: FontWeight.w600, color: colors.ink3, letterSpacing: 0.4)),
          ]),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: () => editCell(context, ref, colors, dbId, p, rowId),
            child: Container(
              width: double.infinity,
              constraints: const BoxConstraints(minHeight: 40),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: BoxDecoration(
                color: colors.surf2,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(width: 0.5, color: colors.bdr),
              ),
              child: _valuePreview(context, colors, p, type, value),
            ),
          ),
        ],
      ),
    );
  }

  Widget _valuePreview(BuildContext context, TaskEraColors colors, DbProperty p, DbPropType type, dynamic value) {
    if (type == DbPropType.checkbox) {
      return Row(children: [
        Icon(value == true ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
            size: 20, color: value == true ? TaskEraColors.acc : colors.ink3),
        const SizedBox(width: 8),
        Text(value == true ? 'Checked' : 'Unchecked', style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 13, color: colors.ink2)),
      ]);
    }
    if (type == DbPropType.select && value is String && value.isNotEmpty) {
      final cfg = PropConfig.parse(p);
      final opt = cfg.options.firstWhere((o) => o.name == value, orElse: () => SelectOption(value, 0));
      return Align(alignment: Alignment.centerLeft, child: OptionChip(option: opt));
    }
    if (type == DbPropType.multiSelect && value is List && value.isNotEmpty) {
      final cfg = PropConfig.parse(p);
      return Wrap(spacing: 5, runSpacing: 5, children: [
        for (final v in value)
          OptionChip(option: cfg.options.firstWhere((o) => o.name == v, orElse: () => SelectOption('$v', 0))),
      ]);
    }
    final disp = cellDisplay(value, type);
    return Text(disp.isEmpty ? 'Empty' : disp,
        style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 13, color: disp.isEmpty ? colors.ink3 : colors.ink));
  }
}
