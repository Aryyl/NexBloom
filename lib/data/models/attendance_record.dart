import 'package:hive/hive.dart';

part 'attendance_record.g.dart';

@HiveType(typeId: 4) // Reusing typeId 4 from legacy attendance.dart
enum AttendanceStatus {
  @HiveField(0)
  present,
  @HiveField(1)
  absent,
  @HiveField(2)
  holiday,
}

@HiveType(typeId: 14) // New typeId for the redesigned attendance record
class AttendanceRecord {
  @HiveField(0)
  final String id; // Derived as: subjectId_YYYYMMDD

  @HiveField(1)
  final String subjectId;

  @HiveField(2)
  final DateTime date;

  @HiveField(3)
  final AttendanceStatus status;

  AttendanceRecord({
    required this.id,
    required this.subjectId,
    required this.date,
    required this.status,
  });

  AttendanceRecord copyWith({
    String? id,
    String? subjectId,
    DateTime? date,
    AttendanceStatus? status,
  }) {
    return AttendanceRecord(
      id: id ?? this.id,
      subjectId: subjectId ?? this.subjectId,
      date: date ?? this.date,
      status: status ?? this.status,
    );
  }
}
