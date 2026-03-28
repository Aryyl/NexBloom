import '../../core/services/hive_service.dart';
import '../../core/services/notification_service.dart';
import '../../core/services/widget_service.dart';
import '../models/subject.dart';

// Wait, where is ClassSession defined?
// In lib/data/models/subject.dart I defined both Subject and ClassSession?
// Let me check subject.dart content.
// Yes, Step 57 shows I put both in subject.dart but ClassSession usage implies separate type.
// Actually Step 62 confirmed I created `subject.dart` with both class definitions.

class ClassSessionRepository {
  final HiveService _hiveService;
  final NotificationService _notificationService;

  ClassSessionRepository(this._hiveService, this._notificationService);

  List<ClassSession> getAllSessions() {
    return _hiveService.classSessionBox.values.toList();
  }

  List<ClassSession> getSessionsForDay(int dayOfWeek) {
    return _hiveService.classSessionBox.values
        .where((s) => s.dayOfWeek == dayOfWeek)
        .toList();
  }

  Future<void> addSession(ClassSession session) async {
    await _hiveService.classSessionBox.put(session.id, session);

    // Schedule notification
    final subject = _hiveService.subjectBox.get(session.subjectId);
    final subjectName = subject?.name ?? 'Class';
    await _notificationService.scheduleClassReminder(session, subjectName);
    WidgetService.updateWidget();
  }

  Future<void> deleteSession(String id) async {
    await _notificationService.cancelNotification(id.hashCode);
    await _hiveService.classSessionBox.delete(id);
    WidgetService.updateWidget();
  }

  Future<void> deleteBySubject(String subjectId) async {
    final sessions = _hiveService.classSessionBox.values
        .where((s) => s.subjectId == subjectId)
        .toList();
    for (var s in sessions) {
      await deleteSession(s.id);
    }
  }

  Future<void> clearAll() async {
    await _hiveService.classSessionBox.clear();
    WidgetService.updateWidget();
  }
}
