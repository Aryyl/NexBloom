import 'package:hive/hive.dart';

part 'assignment.g.dart';

@HiveType(typeId: 2)
class Assignment {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String subjectId;

  @HiveField(2)
  final String title;

  @HiveField(3)
  final String description;

  @HiveField(4)
  final DateTime deadline;

  @HiveField(5)
  final bool isCompleted;

  @HiveField(6)
  final String priority; // "Low", "Medium", "High"

  Assignment({
    required this.id,
    required this.subjectId,
    required this.title,
    required this.description,
    required this.deadline,
    this.isCompleted = false,
    this.priority = 'Medium',
  });
}

@HiveType(typeId: 3)
class Exam {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String subjectId;

  @HiveField(2)
  final String title;

  @HiveField(3)
  final DateTime date;

  @HiveField(4)
  final String location;

  Exam({
    required this.id,
    required this.subjectId,
    required this.title,
    required this.date,
    required this.location,
  });
}
