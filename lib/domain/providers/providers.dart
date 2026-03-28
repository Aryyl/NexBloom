import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/hive_service.dart';
import '../../core/services/notification_service.dart';
import '../../data/repositories/subject_repository.dart';
import '../../data/repositories/assignment_repository.dart';
import '../../features/attendance/attendance_repository.dart';
import '../../data/repositories/class_session_repository.dart';
import '../../data/models/subject.dart';
import '../../data/models/assignment.dart';

// Service Provider
final hiveServiceProvider = Provider<HiveService>((ref) {
  return HiveService();
});

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

// Repository Providers
final subjectRepositoryProvider = Provider<SubjectRepository>((ref) {
  final hiveService = ref.watch(hiveServiceProvider);
  return SubjectRepository(hiveService);
});

final assignmentRepositoryProvider = Provider<AssignmentRepository>((ref) {
  final hiveService = ref.watch(hiveServiceProvider);
  final notificationService = ref.watch(notificationServiceProvider);
  return AssignmentRepository(hiveService, notificationService);
});

final attendanceRepositoryProvider = Provider<AttendanceRepository>((ref) {
  final hiveService = ref.watch(hiveServiceProvider);
  return AttendanceRepository(hiveService);
});

final classSessionRepositoryProvider = Provider<ClassSessionRepository>((ref) {
  final hiveService = ref.watch(hiveServiceProvider);
  final notificationService = ref.watch(notificationServiceProvider);
  return ClassSessionRepository(hiveService, notificationService);
});

// Data Providers (Streams usually preferred for Hive, or ValueListenable)

final subjectsProvider = StreamProvider<List<Subject>>((ref) async* {
  final hiveService = ref.watch(hiveServiceProvider);
  // Yield initial value
  yield hiveService.subjectBox.values.toList();
  // Yield on change
  yield* hiveService.subjectBox.watch().map((event) {
    return hiveService.subjectBox.values.toList();
  });
});

final assignmentsProvider = StreamProvider<List<Assignment>>((ref) async* {
  final hiveService = ref.watch(hiveServiceProvider);
  yield hiveService.assignmentBox.values.toList();
  yield* hiveService.assignmentBox.watch().map((event) {
    return hiveService.assignmentBox.values.toList();
  });
});

final classSessionsProvider = StreamProvider<List<ClassSession>>((ref) async* {
  final hiveService = ref.watch(hiveServiceProvider);
  yield hiveService.classSessionBox.values.toList();
  yield* hiveService.classSessionBox.watch().map((event) {
    return hiveService.classSessionBox.values.toList();
  });
});

final examsProvider = StreamProvider<List<Exam>>((ref) async* {
  final hiveService = ref.watch(hiveServiceProvider);
  yield hiveService.examBox.values.toList();
  yield* hiveService.examBox.watch().map((event) {
    return hiveService.examBox.values.toList();
  });
});
