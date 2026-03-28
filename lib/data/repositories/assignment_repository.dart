import '../../core/services/hive_service.dart';
import '../../core/services/notification_service.dart';
import '../../core/services/widget_service.dart';
import '../models/assignment.dart';

class AssignmentRepository {
  final HiveService _hiveService;
  final NotificationService _notificationService;

  AssignmentRepository(this._hiveService, this._notificationService);

  List<Assignment> getAllAssignments() {
    return _hiveService.assignmentBox.values.toList();
  }

  List<Assignment> getPendingAssignments() {
    return _hiveService.assignmentBox.values
        .where((a) => !a.isCompleted)
        .toList();
  }

  Future<void> addAssignment(Assignment assignment) async {
    await _hiveService.assignmentBox.put(assignment.id, assignment);
    await _notificationService.scheduleAssignmentReminder(assignment);
    WidgetService.updateWidget();
  }

  Future<void> updateAssignment(Assignment assignment) async {
    await _hiveService.assignmentBox.put(assignment.id, assignment);
    if (!assignment.isCompleted) {
      await _notificationService.scheduleAssignmentReminder(assignment);
    } else {
      await _notificationService.cancelNotification(assignment.id.hashCode);
    }
  }

  Future<void> deleteAssignment(String id) async {
    await _notificationService.cancelNotification(id.hashCode);
    await _hiveService.assignmentBox.delete(id);
    WidgetService.updateWidget();
  }

  Future<void> deleteBySubject(String subjectId) async {
    final assignments = _hiveService.assignmentBox.values
        .where((a) => a.subjectId == subjectId)
        .toList();
    for (var a in assignments) {
      await deleteAssignment(a.id);
    }
  }

  Future<void> toggleCompletion(String id) async {
    final assignment = _hiveService.assignmentBox.get(id);
    if (assignment != null) {
      final updated = Assignment(
        id: assignment.id,
        subjectId: assignment.subjectId,
        title: assignment.title,
        description: assignment.description,
        deadline: assignment.deadline,
        isCompleted: !assignment.isCompleted,
        priority: assignment.priority,
      );
      await updateAssignment(updated);
      WidgetService.updateWidget();
    }
  }

  Future<void> clearAll() async {
    await _hiveService.assignmentBox.clear();
  }
}
