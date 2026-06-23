import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database.dart';
import 'database_provider.dart';

final listsProvider = StreamProvider<List<CustomList>>((ref) {
  return ref.watch(appDatabaseProvider).listsDao.watchAll();
});

final listItemsProvider =
    StreamProvider.family<List<CustomListItem>, int>((ref, listId) {
  return ref.watch(appDatabaseProvider).listsDao.watchItems(listId);
});
