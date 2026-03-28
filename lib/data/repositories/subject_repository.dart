import '../../core/services/hive_service.dart';
import '../models/subject.dart';

class SubjectRepository {
  final HiveService _hiveService;

  SubjectRepository(this._hiveService);

  List<Subject> getAllSubjects() {
    return _hiveService.subjectBox.values.toList();
  }

  Future<void> addSubject(Subject subject) async {
    await _hiveService.subjectBox.put(subject.id, subject);
  }

  Future<void> updateSubject(Subject subject) async {
    await _hiveService.subjectBox.put(subject.id, subject);
  }

  Future<void> deleteSubject(String id) async {
    await _hiveService.subjectBox.delete(id);
  }

  Future<void> clearAll() async {
    await _hiveService.subjectBox.clear();
  }
}
