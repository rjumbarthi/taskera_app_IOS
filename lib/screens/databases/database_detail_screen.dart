import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/database.dart';
import '../../data/models/db_models.dart';
import '../../data/providers/database_provider.dart';
import '../../data/providers/databases_provider.dart';
import '../../theme/taskera_colors.dart';
import '../../theme/taskera_theme.dart';
import '../../widgets/add_back_button.dart';
import 'db_editors.dart';

class DatabaseDetailScreen extends ConsumerStatefulWidget {
  final int databaseId;
  const DatabaseDetailScreen({super.key, required this.databaseId});

  @override
  ConsumerState<DatabaseDetailScreen> createState() => _DatabaseDetailScreenState();
}

class _DatabaseDetailScreenState extends ConsumerState<DatabaseDetailScreen> {
  String? _view; // null until first read from db.defaultView

  int get _id => widget.databaseId;
  DatabasesDao get _dao => ref.read(appDatabaseProvider).databasesDao;

  // ── Actions ────────────────────────────────────────────────────────────────

  Future<void> _addRow({String? groupProp, String? groupValue}) async {
    final rows = ref.read(dbRowsProvider(_id)).value ?? const <DbRow>[];
    final cells = <String, dynamic>{};
    if (groupProp != null && groupValue != null) cells[groupProp] = groupValue;
    await _dao.upsertRow(DbRowsCompanion(
      id: Value(genDbId('r')),
      databaseId: Value(_id),
      cells: Value(encodeCells(cells)),
      sortOrder: Value(rows.length),
    ));
  }

  Future<void> _addProperty() async {
    final props = ref.read(dbPropertiesProvider(_id)).value ?? const <DbProperty>[];
    await _dao.upsertProperty(DbPropertiesCompanion(
      id: Value(genDbId('p')),
      databaseId: Value(_id),
      name: Value('Property ${props.length + 1}'),
      type: Value(DbPropType.text.id),
      sortOrder: Value(props.length),
    ));
  }

  Future<void> _renameDatabase(TaskEraDatabase db) async {
    final colors = TaskEraTheme.of(context).colors;
    final ctrl = TextEditingController(text: db.name);
    final v = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.surf,
        title: Text('Rename database', style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 16, color: colors.ink)),
        content: TextField(
          controller: ctrl, autofocus: true,
          style: TextStyle(color: colors.ink),
          onSubmitted: (x) => Navigator.pop(ctx, x),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel', style: TextStyle(color: colors.ink3))),
          TextButton(onPressed: () => Navigator.pop(ctx, ctrl.text), child: Text('Save', style: TextStyle(color: colors.textOrPlain(TaskEraColors.acc2)))),
        ],
      ),
    );
    if (v != null && v.trim().isNotEmpty) {
      _dao.updateDatabase(_id, TaskEraDatabasesCompanion(name: Value(v.trim())));
    }
  }

  Future<void> _propertyMenu(DbProperty prop, int propCount) async {
    final colors = TaskEraTheme.of(context).colors;
    final action = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: colors.surf,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(18))),
      builder: (ctx) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          SizedBox(height: 12),
          _menuRow(ctx, colors, Icons.edit_rounded, 'Rename', 'rename'),
          _menuRow(ctx, colors, Icons.swap_horiz_rounded, 'Change type (now: ${propTypeOf(prop).label})', 'type'),
          if (propCount > 1)
            _menuRow(ctx, colors, Icons.delete_outline_rounded, 'Delete property', 'delete', danger: true),
          SizedBox(height: 8),
        ]),
      ),
    );
    if (!mounted) return;
    switch (action) {
      case 'rename':
        await _renameProperty(prop);
        break;
      case 'type':
        await _changeType(prop);
        break;
      case 'delete':
        _dao.deleteProperty(prop.id);
        break;
    }
  }

  Future<void> _renameProperty(DbProperty prop) async {
    final colors = TaskEraTheme.of(context).colors;
    final ctrl = TextEditingController(text: prop.name);
    final v = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.surf,
        title: Text('Property name', style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 16, color: colors.ink)),
        content: TextField(controller: ctrl, autofocus: true, style: TextStyle(color: colors.ink), onSubmitted: (x) => Navigator.pop(ctx, x)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel', style: TextStyle(color: colors.ink3))),
          TextButton(onPressed: () => Navigator.pop(ctx, ctrl.text), child: Text('Save', style: TextStyle(color: colors.textOrPlain(TaskEraColors.acc2)))),
        ],
      ),
    );
    if (v != null && v.trim().isNotEmpty) {
      _dao.upsertProperty(DbPropertiesCompanion(
        id: Value(prop.id), databaseId: Value(prop.databaseId), name: Value(v.trim()),
        type: Value(prop.type), sortOrder: Value(prop.sortOrder), config: Value(prop.config),
      ));
    }
  }

  Future<void> _changeType(DbProperty prop) async {
    final colors = TaskEraTheme.of(context).colors;
    final type = await showModalBottomSheet<DbPropType>(
      context: context,
      backgroundColor: colors.surf,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(18))),
      builder: (ctx) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          SizedBox(height: 12),
          for (final t in DbPropType.values)
            InkWell(
              onTap: () => Navigator.pop(ctx, t),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
                child: Row(children: [
                  Icon(t.icon, size: 18, color: colors.ink2),
                  SizedBox(width: 14),
                  Text(t.label, style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 15, color: colors.ink)),
                  const Spacer(),
                  if (t == propTypeOf(prop)) Icon(Icons.check_rounded, size: 18, color: TaskEraColors.acc),
                ]),
              ),
            ),
          SizedBox(height: 8),
        ]),
      ),
    );
    if (type != null) {
      _dao.upsertProperty(DbPropertiesCompanion(
        id: Value(prop.id), databaseId: Value(prop.databaseId), name: Value(prop.name),
        type: Value(type.id), sortOrder: Value(prop.sortOrder),
        config: Value(type.isSelectLike ? prop.config : '{}'),
      ));
    }
  }

  Widget _menuRow(BuildContext ctx, TaskEraColors colors, IconData icon, String label, String value, {bool danger = false}) {
    final color = danger ? const Color(0xFFFF453A) : colors.ink;
    return InkWell(
      onTap: () => Navigator.pop(ctx, value),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(children: [
          Icon(icon, size: 19, color: color),
          SizedBox(width: 14),
          Expanded(child: Text(label, style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 15, color: color))),
        ]),
      ),
    );
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final colors = TaskEraTheme.of(context).colors;
    final dbAsync = ref.watch(databaseProvider(_id));
    final props = ref.watch(dbPropertiesProvider(_id)).value ?? const <DbProperty>[];
    final rows = ref.watch(dbRowsProvider(_id)).value ?? const <DbRow>[];

    return dbAsync.when(
      loading: () => Center(child: CircularProgressIndicator(strokeWidth: 2)),
      error: (e, _) => Center(child: Text('$e', style: TextStyle(color: colors.ink3))),
      data: (db) {
        if (db == null) {
          return Center(child: Text('Database not found', style: TextStyle(color: colors.ink3)));
        }
        final view = _view ?? db.defaultView;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _topBar(colors, db),
            _viewSwitcher(colors, view, db),
            Expanded(
              child: switch (view) {
                'board' => _boardView(colors, db, props, rows),
                'list' => _listView(colors, props, rows),
                _ => _tableView(colors, props, rows),
              },
            ),
          ],
        );
      },
    );
  }

  Widget _topBar(TaskEraColors colors, TaskEraDatabase db) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 12, 4),
      child: Row(children: [
        AddBackButton(onTap: () => context.pop()),
        SizedBox(width: 4),
        Text(db.icon, style: TextStyle(fontSize: 20)),
        SizedBox(width: 8),
        Expanded(
          child: GestureDetector(
            onTap: () => _renameDatabase(db),
            child: Text(db.name.isEmpty ? 'Untitled' : db.name,
                maxLines: 1, overflow: TextOverflow.ellipsis,
                style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontVariations: const [FontVariation('wght', 600)], fontSize: 19, letterSpacing: -0.5, color: colors.ink)),
          ),
        ),
        GestureDetector(
          onTap: () => _addRow(),
          child: Container(
            padding: const EdgeInsets.fromLTRB(11, 6, 13, 6),
            decoration: BoxDecoration(color: TaskEraColors.acc, borderRadius: BorderRadius.circular(8)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.add_rounded, size: 15, color: Colors.white),
              SizedBox(width: 2),
              Text('Row', style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
            ]),
          ),
        ),
      ]),
    );
  }

  Widget _viewSwitcher(TaskEraColors colors, String view, TaskEraDatabase db) {
    Widget seg(String id, IconData icon, String label) {
      final active = view == id;
      return GestureDetector(
        onTap: () {
          setState(() => _view = id);
          _dao.updateDatabase(_id, TaskEraDatabasesCompanion(defaultView: Value(id)));
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: active ? const Color(0x120A84FF) : Colors.transparent,
            borderRadius: BorderRadius.circular(7),
            border: Border.all(width: 0.5, color: active ? const Color(0x330A84FF) : Colors.transparent),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, size: 14, color: active ? TaskEraColors.acc2 : colors.ink3),
            SizedBox(width: 5),
            Text(label, style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 12.5, fontWeight: FontWeight.w600, color: active ? colors.textOrPlain(TaskEraColors.acc2) : colors.ink3)),
          ]),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 2, 12, 6),
      child: Row(children: [
        seg('table', Icons.grid_on_rounded, 'Table'),
        SizedBox(width: 6),
        seg('board', Icons.view_kanban_rounded, 'Board'),
        SizedBox(width: 6),
        seg('list', Icons.view_agenda_rounded, 'List'),
      ]),
    );
  }

  // ── Table view ─────────────────────────────────────────────────────────────

  Widget _tableView(TaskEraColors colors, List<DbProperty> props, List<DbRow> rows) {
    if (props.isEmpty) return _needProperty(colors);
    double widthFor(int i) => i == 0 ? 180 : 150;

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(children: [
              for (var i = 0; i < props.length; i++)
                GestureDetector(
                  onTap: () => _propertyMenu(props[i], props.length),
                  child: Container(
                    width: widthFor(i),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
                    decoration: BoxDecoration(border: Border(bottom: BorderSide(width: 0.5, color: colors.bdr))),
                    child: Row(children: [
                      Icon(propTypeOf(props[i]).icon, size: 13, color: colors.ink3),
                      SizedBox(width: 5),
                      Flexible(child: Text(props[i].name, maxLines: 1, overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 12, fontWeight: FontWeight.w600, color: colors.ink2))),
                    ]),
                  ),
                ),
              GestureDetector(
                onTap: _addProperty,
                child: Container(
                  width: 44, padding: const EdgeInsets.symmetric(vertical: 9),
                  decoration: BoxDecoration(border: Border(bottom: BorderSide(width: 0.5, color: colors.bdr))),
                  child: Icon(Icons.add_rounded, size: 16, color: colors.ink3),
                ),
              ),
            ]),
            // Rows
            for (final row in rows)
              Row(children: [
                for (var i = 0; i < props.length; i++)
                  _tableCell(colors, props[i], row, widthFor(i), isTitle: i == 0),
                SizedBox(width: 44),
              ]),
            // Add row
            GestureDetector(
              onTap: () => _addRow(),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Row(children: [
                  Icon(Icons.add_rounded, size: 15, color: colors.ink3),
                  SizedBox(width: 5),
                  Text('New row', style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 12.5, color: colors.ink3)),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tableCell(TaskEraColors colors, DbProperty prop, DbRow row, double width, {bool isTitle = false}) {
    final type = propTypeOf(prop);
    final value = decodeCells(row)[prop.id];
    return GestureDetector(
      onTap: () {
        if (isTitle) {
          openRowEditor(context, _id, row.id);
        } else {
          editCell(context, ref, colors, _id, prop, row.id);
        }
      },
      child: Container(
        width: width,
        constraints: const BoxConstraints(minHeight: 38),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(border: Border(bottom: BorderSide(width: 0.5, color: colors.bdr))),
        alignment: Alignment.centerLeft,
        child: _cellContent(colors, prop, type, value, isTitle: isTitle),
      ),
    );
  }

  Widget _cellContent(TaskEraColors colors, DbProperty prop, DbPropType type, dynamic value, {bool isTitle = false}) {
    if (type == DbPropType.checkbox) {
      return Icon(value == true ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
          size: 18, color: value == true ? TaskEraColors.acc : colors.ink3);
    }
    if (type == DbPropType.select && value is String && value.isNotEmpty) {
      final cfg = PropConfig.parse(prop);
      return OptionChip(option: cfg.options.firstWhere((o) => o.name == value, orElse: () => SelectOption(value, 0)));
    }
    if (type == DbPropType.multiSelect && value is List && value.isNotEmpty) {
      final cfg = PropConfig.parse(prop);
      return Wrap(spacing: 4, runSpacing: 4, children: [
        for (final v in value.take(3))
          OptionChip(option: cfg.options.firstWhere((o) => o.name == v, orElse: () => SelectOption('$v', 0))),
      ]);
    }
    final disp = cellDisplay(value, type);
    if (disp.isEmpty) {
      return Text(isTitle ? 'Untitled' : '', style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 13, color: colors.ink3));
    }
    return Text(disp, maxLines: 2, overflow: TextOverflow.ellipsis,
        style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 13,
            fontWeight: isTitle ? FontWeight.w600 : FontWeight.w400,
            color: type == DbPropType.url ? colors.textOrPlain(TaskEraColors.acc2) : colors.ink));
  }

  // ── Board view ───────────────────────────────────────────────────────────

  Widget _boardView(TaskEraColors colors, TaskEraDatabase db, List<DbProperty> props, List<DbRow> rows) {
    if (props.isEmpty) return _needProperty(colors);
    // Choose the grouping property: configured, else first select-like prop.
    DbProperty? group;
    for (final p in props) {
      if (p.id == db.boardGroupProp) group = p;
    }
    group ??= props.firstWhere((p) => propTypeOf(p).isSelectLike,
        orElse: () => props.first);

    final cfg = PropConfig.parse(group);
    final titleProp = props.first;
    // Columns: each option + an "Empty" bucket.
    final columns = <({String? value, String label, Color color})>[
      for (final o in cfg.options) (value: o.name, label: o.name, color: o.color),
      (value: null, label: 'No ${group.name}', color: const Color(0xFF8E8E93)),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final col in columns)
            _boardColumn(colors, group, titleProp, props, rows, col),
        ],
      ),
    );
  }

  Widget _boardColumn(TaskEraColors colors, DbProperty group, DbProperty titleProp,
      List<DbProperty> props,
      List<DbRow> rows,
      ({String? value, String label, Color color}) col) {
    final colRows = rows.where((r) {
      final v = decodeCells(r)[group.id];
      if (col.value == null) return v == null || (v is String && v.isEmpty);
      return v == col.value;
    }).toList();

    return Container(
      width: 230,
      margin: const EdgeInsets.only(right: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
            child: Row(children: [
              Container(width: 8, height: 8, decoration: BoxDecoration(color: col.color, shape: BoxShape.circle)),
              SizedBox(width: 7),
              Text(col.label, style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 13, fontWeight: FontWeight.w600, color: colors.ink)),
              SizedBox(width: 6),
              Text('${colRows.length}', style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 12, color: colors.ink3)),
            ]),
          ),
          for (final row in colRows)
            _boardCard(colors, titleProp, props, group, row),
          GestureDetector(
            onTap: () => _addRow(groupProp: group.id, groupValue: col.value),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 9),
              margin: const EdgeInsets.only(top: 2),
              child: Row(children: [
                Icon(Icons.add_rounded, size: 15, color: colors.ink3),
                SizedBox(width: 5),
                Text('New', style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 12.5, color: colors.ink3)),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _boardCard(TaskEraColors colors, DbProperty titleProp, List<DbProperty> props, DbProperty group, DbRow row) {
    final cells = decodeCells(row);
    final title = cellDisplay(cells[titleProp.id], propTypeOf(titleProp));
    final chips = <Widget>[];
    for (final p in props) {
      if (p.id == titleProp.id || p.id == group.id) continue;
      final v = cells[p.id];
      if (v == null || (v is String && v.isEmpty) || (v is List && v.isEmpty)) continue;
      chips.add(_miniChip(colors, p, v));
    }

    return GestureDetector(
      onTap: () => openRowEditor(context, _id, row.id),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(
          color: colors.surf2,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(width: 0.5, color: colors.bdr),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title.isEmpty ? 'Untitled' : title,
                style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 13.5, fontWeight: FontWeight.w600, color: title.isEmpty ? colors.ink3 : colors.ink)),
            if (chips.isNotEmpty) ...[
              SizedBox(height: 7),
              Wrap(spacing: 5, runSpacing: 5, children: chips),
            ],
          ],
        ),
      ),
    );
  }

  Widget _miniChip(TaskEraColors colors, DbProperty p, dynamic value) {
    final type = propTypeOf(p);
    if (type == DbPropType.select && value is String) {
      final cfg = PropConfig.parse(p);
      return OptionChip(option: cfg.options.firstWhere((o) => o.name == value, orElse: () => SelectOption(value, 0)));
    }
    if (type == DbPropType.multiSelect && value is List) {
      final cfg = PropConfig.parse(p);
      return Wrap(spacing: 4, runSpacing: 4, children: [
        for (final v in value)
          OptionChip(option: cfg.options.firstWhere((o) => o.name == v, orElse: () => SelectOption('$v', 0))),
      ]);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(color: colors.surf, borderRadius: BorderRadius.circular(5), border: Border.all(width: 0.5, color: colors.bdr)),
      child: Text(cellDisplay(value, type), style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 11, color: colors.ink2)),
    );
  }

  // ── List view ────────────────────────────────────────────────────────────

  Widget _listView(TaskEraColors colors, List<DbProperty> props, List<DbRow> rows) {
    if (props.isEmpty) return _needProperty(colors);
    if (rows.isEmpty) return _emptyRows(colors);
    final titleProp = props.first;
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 24),
      itemCount: rows.length,
      separatorBuilder: (_, _) => SizedBox(height: 8),
      itemBuilder: (context, i) {
        final row = rows[i];
        final cells = decodeCells(row);
        final title = cellDisplay(cells[titleProp.id], propTypeOf(titleProp));
        final chips = <Widget>[];
        for (final p in props) {
          if (p.id == titleProp.id) continue;
          final v = cells[p.id];
          if (v == null || (v is String && v.isEmpty) || (v is List && v.isEmpty)) continue;
          chips.add(_miniChip(colors, p, v));
        }
        return GestureDetector(
          onTap: () => openRowEditor(context, _id, row.id),
          child: Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: colors.surf2,
              borderRadius: BorderRadius.circular(11),
              border: Border.all(width: 0.5, color: colors.bdr),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title.isEmpty ? 'Untitled' : title,
                    style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 14.5, fontWeight: FontWeight.w600, color: title.isEmpty ? colors.ink3 : colors.ink)),
                if (chips.isNotEmpty) ...[
                  SizedBox(height: 8),
                  Wrap(spacing: 5, runSpacing: 5, children: chips),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Empty / helper states ──────────────────────────────────────────────────

  Widget _needProperty(TaskEraColors colors) => Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('No properties', style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 14, color: colors.ink2)),
          SizedBox(height: 10),
          GestureDetector(
            onTap: _addProperty,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
              decoration: BoxDecoration(color: const Color(0x120A84FF), borderRadius: BorderRadius.circular(9), border: Border.all(width: 0.5, color: const Color(0x330A84FF))),
              child: Text('+ Add property', style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 13, fontWeight: FontWeight.w600, color: colors.textOrPlain(TaskEraColors.acc2))),
            ),
          ),
        ]),
      );

  Widget _emptyRows(TaskEraColors colors) => Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('No rows yet', style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 14, color: colors.ink2)),
          SizedBox(height: 10),
          GestureDetector(
            onTap: () => _addRow(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
              decoration: BoxDecoration(color: const Color(0x120A84FF), borderRadius: BorderRadius.circular(9), border: Border.all(width: 0.5, color: const Color(0x330A84FF))),
              child: Text('+ New row', style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 13, fontWeight: FontWeight.w600, color: colors.textOrPlain(TaskEraColors.acc2))),
            ),
          ),
        ]),
      );
}
