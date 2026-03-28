import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'study_plan_model.g.dart';

@HiveType(typeId: 20)
class StudyPlan extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String subject;

  @HiveField(2)
  final DateTime examDate;

  @HiveField(3)
  final int dailyStudyHours;

  @HiveField(4)
  final int hoursPerChapter;

  @HiveField(5)
  final List<String> chapters;

  @HiveField(6)
  final List<StudyDay> studyDays;

  @HiveField(7)
  final bool isCompleted;

  @HiveField(8)
  final DateTime createdAt;

  @HiveField(9)
  final String? subjectId;

  StudyPlan({
    String? id,
    required this.subject,
    required this.examDate,
    required this.dailyStudyHours,
    required this.hoursPerChapter,
    required this.chapters,
    required this.studyDays,
    this.isCompleted = false,
    DateTime? createdAt,
    this.subjectId,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now();

  StudyPlan copyWith({
    String? subject,
    DateTime? examDate,
    int? dailyStudyHours,
    int? hoursPerChapter,
    List<String>? chapters,
    List<StudyDay>? studyDays,
    bool? isCompleted,
    String? subjectId,
  }) {
    return StudyPlan(
      id: id,
      subject: subject ?? this.subject,
      examDate: examDate ?? this.examDate,
      dailyStudyHours: dailyStudyHours ?? this.dailyStudyHours,
      hoursPerChapter: hoursPerChapter ?? this.hoursPerChapter,
      chapters: chapters ?? this.chapters,
      studyDays: studyDays ?? this.studyDays,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt,
      subjectId: subjectId ?? this.subjectId,
    );
  }

  int get daysLeft => examDate.difference(DateTime.now()).inDays;
  int get totalRequiredHours => chapters.length * hoursPerChapter;

  int get totalTopics {
    int count = 0;
    for (final day in studyDays) {
      if (!day.isRevision) {
        count += day.topics.length;
      }
    }
    return count;
  }

  int get completedTopics {
    int count = 0;
    for (final day in studyDays) {
      if (!day.isRevision) {
        count += day.completedTopicsCount;
      }
    }
    return count;
  }

  int get completedDays => studyDays.where((d) => d.completed).length;

  double get progress {
    if (studyDays.isEmpty) return 0.0;
    if (totalTopics == 0) return completedDays / studyDays.length;
    return completedTopics / totalTopics;
  }
}

@HiveType(typeId: 21)
class StudyDay {
  @HiveField(0)
  final DateTime date;

  @HiveField(1)
  final List<String> topics;

  @HiveField(2)
  final bool completed;

  @HiveField(3)
  final bool isRevision;

  @HiveField(4, defaultValue: [])
  final List<bool> topicCompleted;

  StudyDay({
    required this.date,
    required this.topics,
    this.completed = false,
    this.isRevision = false,
    List<bool>? topicCompleted,
  }) : topicCompleted = topicCompleted ?? List.filled(topics.length, false);

  StudyDay copyWith({
    DateTime? date,
    List<String>? topics,
    bool? completed,
    bool? isRevision,
    List<bool>? topicCompleted,
  }) {
    return StudyDay(
      date: date ?? this.date,
      topics: topics ?? this.topics,
      completed: completed ?? this.completed,
      isRevision: isRevision ?? this.isRevision,
      topicCompleted: topicCompleted ?? this.topicCompleted,
    );
  }

  int get completedTopicsCount => topicCompleted.where((c) => c).length;
  bool get allTopicsCompleted =>
      topics.isNotEmpty && completedTopicsCount == topics.length;
}
