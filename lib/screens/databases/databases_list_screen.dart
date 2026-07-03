import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/database.dart';
import '../../data/models/db_models.dart';
import '../../data/providers/database_provider.dart';
import '../../data/providers/databases_provider.dart';
import '../../routing/routes.dart';
import '../../theme/kaal_colors.dart';
import '../../theme/kaal_theme.dart';
import '../../util/kaal_dialogs.dart';
import '../../widgets/add_back_button.dart';

/// Creates a fresh database with a sensible starter schema and one empty row,
/// returning its id (ready to navigate into).
Future<int> createStarterDatabase(AppDatabase db, {String name = 'Untitled'}) async {
  final dao = db.databasesDao;
  final statusProp = genDbId('p');
  final dateProp = genDbId('p');
  final nameProp = genDbId('p');

  final id = await dao.createDatabase(KaalDatabasesCompanion(
    name: Value(name),
    defaultView: const Value('table'),
    boardGroupProp: Value(statusProp),
  ));

  await dao.upsertProperty(DbPropertiesCompanion(
    id: Value(nameProp), databaseId: Value(id), name: const Value('Name'),
    type: Value(DbPropType.text.id), sortOrder: const Value(0),
  ));
  await dao.upsertProperty(DbPropertiesCompanion(
    id: Value(statusProp), databaseId: Value(id), name: const Value('Status'),
    type: Value(DbPropType.select.id), sortOrder: const Value(1),
    config: Value(const PropConfig([
      SelectOption('To do', 0),
      SelectOption('In progress', 1),
      SelectOption('Done', 2),
    ]).encode()),
  ));
  await dao.upsertProperty(DbPropertiesCompanion(
    id: Value(dateProp), databaseId: Value(id), name: const Value('Date'),
    type: Value(DbPropType.date.id), sortOrder: const Value(2),
  ));

  await dao.upsertRow(DbRowsCompanion(
    id: Value(genDbId('r')), databaseId: Value(id),
    cells: Value(encodeCells({nameProp: ''})), sortOrder: const Value(0),
  ));
  return id;
}

class DatabasesListScreen extends ConsumerWidget {
  const DatabasesListScreen({super.key});

  Future<void> _create(BuildContext context, WidgetRef ref) async {
    final db = ref.read(appDatabaseProvider);
    final id = await createStarterDatabase(db);
    if (context.mounted) context.push('${KaalRoutes.databases}/$id');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = KaalTheme.of(context).colors;
    final dbs = ref.watch(databasesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 12, 6),
          child: Row(
            children: [
              AddBackButton(onTap: () => context.pop()),
              const SizedBox(width: 8),
              Expanded(
                child: Text('Databases',
                    style: TextStyle(fontFamily: 'Fraunces', fontVariations: const [FontVariation('wght', 600)], fontSize: 19, letterSpacing: -0.5, color: colors.ink)),
              ),
              GestureDetector(
                onTap: () => _create(context, ref),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(12, 6, 14, 6),
                  decoration: BoxDecoration(color: KaalColors.acc, borderRadius: BorderRadius.circular(8)),
                  child: const Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.add_rounded, size: 16, color: Colors.white),
                    SizedBox(width: 3),
                    Text('New', style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
                  ]),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: dbs.when(
            loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
            error: (e, _) => Center(child: Text('$e', style: TextStyle(color: colors.ink3))),
            data: (list) {
              if (list.isEmpty) return _empty(context, ref, colors);
              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 20),
                itemCount: list.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, i) => _DbCard(
                  db: list[i], colors: colors,
                  onTap: () => context.push('${KaalRoutes.databases}/${list[i].id}'),
                  onDelete: () async {
                    final ok = await kaalConfirmDelete(context);
                    if (ok) ref.read(appDatabaseProvider).databasesDao.deleteDatabase(list[i].id);
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _empty(BuildContext context, WidgetRef ref, KaalColors colors) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('🗂️', style: const TextStyle(fontSize: 44)),
          const SizedBox(height: 12),
          Text('No databases yet',
              style: TextStyle(fontFamily: 'Inter', fontSize: 15, fontWeight: FontWeight.w600, color: colors.ink)),
          const SizedBox(height: 4),
          Text('Tables, boards & lists for anything.',
              style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: colors.ink3)),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => _create(context, ref),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0x120A84FF),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(width: 0.5, color: const Color(0x330A84FF)),
              ),
              child: const Text('+ New database',
                  style: TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w600, color: KaalColors.acc2)),
            ),
          ),
        ],
      ),
    );
  }
}

class _DbCard extends ConsumerWidget {
  final KaalDatabase db;
  final KaalColors colors;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  const _DbCard({required this.db, required this.colors, required this.onTap, required this.onDelete});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rows = ref.watch(dbRowsProvider(db.id)).value ?? const <DbRow>[];
    return GestureDetector(
      onTap: onTap,
      onLongPress: onDelete,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0x120A84FF),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(width: 0.5, color: const Color(0x330A84FF)),
        ),
        child: Row(
          children: [
            Text(db.icon, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(db.name.isEmpty ? 'Untitled' : db.name,
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontFamily: 'Inter', fontSize: 15, fontWeight: FontWeight.w600, color: colors.ink)),
                  const SizedBox(height: 2),
                  Text('${rows.length} ${rows.length == 1 ? 'row' : 'rows'}',
                      style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: colors.ink3)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, size: 20, color: colors.ink3),
          ],
        ),
      ),
    );
  }
}
