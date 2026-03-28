import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/providers/providers.dart';
import '../../data/models/note_model.dart';
import 'note_repository.dart';

final noteRepositoryProvider = Provider<NoteRepository>((ref) {
  final hiveService = ref.watch(hiveServiceProvider);
  return NoteRepository(hiveService);
});

// Using AsyncNotifier to manage the list of notes
class NotesNotifier extends AsyncNotifier<List<Note>> {
  NoteRepository get _repository => ref.read(noteRepositoryProvider);

  @override
  Future<List<Note>> build() async {
    return _repository.getAllNotes();
  }

  Future<void> _loadNotes() async {
    try {
      final notes = _repository.getAllNotes();
      state = AsyncValue.data(notes);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addNote(Note note) async {
    await _repository.addNote(note);
    await _loadNotes();
  }

  Future<void> updateNote(Note note) async {
    await _repository.updateNote(note);
    await _loadNotes();
  }

  Future<void> deleteNote(String noteId) async {
    await _repository.deleteNote(noteId);
    await _loadNotes();
  }

  Future<void> togglePin(Note note) async {
    final updatedNote = note.copyWith(isPinned: !note.isPinned);
    await updateNote(updatedNote);
  }

  Future<void> toggleArchive(Note note) async {
    final updatedNote = note.copyWith(isArchived: !note.isArchived);
    await updateNote(updatedNote);
  }
}

final notesProvider = AsyncNotifierProvider<NotesNotifier, List<Note>>(() {
  return NotesNotifier();
});

// A provider block for search/filtering
class NotesSearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void updateQuery(String query) {
    state = query;
  }
}

final notesSearchQueryProvider =
    NotifierProvider<NotesSearchQueryNotifier, String>(() {
      return NotesSearchQueryNotifier();
    });

final filteredNotesProvider = Provider<AsyncValue<List<Note>>>((ref) {
  final search = ref.watch(notesSearchQueryProvider).toLowerCase();
  final notesAsync = ref.watch(notesProvider);

  return notesAsync.whenData((notes) {
    if (search.isEmpty) return notes;

    return notes.where((note) {
      final matchesTitle = note.title.toLowerCase().contains(search);
      final matchesContent =
          note.content?.toLowerCase().contains(search) ?? false;
      final matchesChecklist =
          note.checklist?.any(
            (item) => item.text.toLowerCase().contains(search),
          ) ??
          false;

      return matchesTitle || matchesContent || matchesChecklist;
    }).toList();
  });
});
