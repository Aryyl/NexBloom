import 'package:hive_flutter/hive_flutter.dart';
import '../../core/services/hive_service.dart';
import '../../data/models/note_model.dart';

class NoteRepository {
  final HiveService _hiveService;

  NoteRepository(this._hiveService);

  Box<Note> get _box => _hiveService.noteBox;

  List<Note> getAllNotes() {
    return _box.values.toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  Future<void> addNote(Note note) async {
    await _box.put(note.id, note);
  }

  Future<void> updateNote(Note note) async {
    note.updatedAt = DateTime.now();
    await _box.put(note.id, note);
  }

  Future<void> deleteNote(String id) async {
    await _box.delete(id);
  }

  Future<void> clearAll() async {
    await _box.clear();
  }

  List<Note> getNotesBySubject(String subjectId) {
    return _box.values.where((n) => n.subjectId == subjectId).toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }
}
