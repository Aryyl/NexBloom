import 'package:hive/hive.dart';

part 'subject.g.dart';

@HiveType(typeId: 0)
class Subject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String professorName;

  @HiveField(3)
  final String roomNumber;

  @HiveField(4)
  final int colorValue; // Store int value of color

  Subject({
    required this.id,
    required this.name,
    required this.professorName,
    required this.roomNumber,
    required this.colorValue,
  });
}

@HiveType(typeId: 1)
class ClassSession {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String subjectId;

  @HiveField(2)
  final int dayOfWeek; // 1 = Monday, 7 = Sunday

  @HiveField(3)
  final String startTime; // "HH:mm"

  @HiveField(4)
  final String endTime; // "HH:mm"

  ClassSession({
    required this.id,
    required this.subjectId,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
  });
}
