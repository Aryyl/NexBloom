import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'focus_session_model.g.dart';

@HiveType(typeId: 22)
class FocusSession extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String? subjectId; // Optional subject association

  @HiveField(2)
  final String? subjectName;

  @HiveField(3)
  final DateTime startTime;

  @HiveField(4)
  final int durationMinutes;

  @HiveField(5)
  final bool isCompleted;

  FocusSession({
    String? id,
    this.subjectId,
    this.subjectName,
    required this.startTime,
    required this.durationMinutes,
    this.isCompleted = false,
  }) : id = id ?? const Uuid().v4();
}
