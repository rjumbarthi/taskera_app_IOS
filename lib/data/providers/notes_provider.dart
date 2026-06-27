import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database.dart';
import 'database_provider.dart';

/// Stream of all notes (pinned first, then most recently updated).
final notesProvider = StreamProvider<List<Note>>((ref) {
  return ref.watch(appDatabaseProvider).notesDao.watchAll();
});

/// Stream of tags for a given note id.
final noteTagsProvider =
    StreamProvider.family<List<NoteTag>, int>((ref, noteId) {
  return ref.watch(appDatabaseProvider).notesDao.watchTags(noteId);
});

/// Stream of Task rows linked to a given note id.
final noteLinkedTasksProvider =
    StreamProvider.family<List<Task>, int>((ref, noteId) {
  return ref.watch(appDatabaseProvider).watchNoteLinkedTasks(noteId);
});
