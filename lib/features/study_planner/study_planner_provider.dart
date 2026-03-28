import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/providers/providers.dart';
import '../../data/models/study_plan_model.dart';
import '../../data/models/assignment.dart';
import 'study_planner_repository.dart';
import 'study_planner_logic.dart';

// Repository provider
final studyPlannerRepositoryProvider = Provider<StudyPlannerRepository>((ref) {
  final hiveService = ref.watch(hiveServiceProvider);
  return StudyPlannerRepository(hiveService);
});

// Main state notifier
class StudyPlannerNotifier extends AsyncNotifier<List<StudyPlan>> {
  StudyPlannerRepository get _repository =>
      ref.read(studyPlannerRepositoryProvider);

  @override
  Future<List<StudyPlan>> build() async {
    return _repository.getAllPlans();
  }

  Future<void> _reload() async {
    try {
      state = AsyncValue.data(_repository.getAllPlans());
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addPlan(StudyPlan plan) async {
    await _repository.addPlan(plan);
    await _reload();
  }

  Future<void> updatePlan(StudyPlan plan) async {
    await _repository.updatePlan(plan);
    await _reload();
  }

  Future<void> deletePlan(String id) async {
    await _repository.deletePlan(id);
    await _reload();
  }

  Future<void> toggleDayComplete(String planId, int dayIndex) async {
    final plan = _repository.getPlan(planId);
    if (plan == null) return;

    final updatedDays = List<StudyDay>.from(plan.studyDays);
    updatedDays[dayIndex] = updatedDays[dayIndex].copyWith(
      completed: !updatedDays[dayIndex].completed,
    );

    final allComplete = updatedDays.every((d) => d.completed);

    final updatedPlan = plan.copyWith(
      studyDays: updatedDays,
      isCompleted: allComplete,
    );

    await _repository.updatePlan(updatedPlan);
    await _reload();
  }

  Future<void> toggleTopicComplete(
    String planId,
    int dayIndex,
    int topicIndex,
  ) async {
    final plan = _repository.getPlan(planId);
    if (plan == null) return;

    final updatedDays = List<StudyDay>.from(plan.studyDays);
    final day = updatedDays[dayIndex];

    // Ensure topic arrays match length to handle legacy models from Hive
    List<bool> updatedTopics = List<bool>.from(day.topicCompleted);
    if (updatedTopics.length < day.topics.length) {
      final padded = List.filled(day.topics.length, false);
      for (int i = 0; i < updatedTopics.length; i++) {
        padded[i] = updatedTopics[i];
      }
      updatedTopics = padded;
    }

    // Toggle specific topic
    updatedTopics[topicIndex] = !updatedTopics[topicIndex];

    // If all topics are completed, complete the day automatically
    final dayIsNowComplete =
        updatedTopics.where((c) => c).length == day.topics.length;

    updatedDays[dayIndex] = day.copyWith(
      topicCompleted: updatedTopics,
      completed: dayIsNowComplete,
    );

    final allComplete = updatedDays.every((d) => d.completed);

    final updatedPlan = plan.copyWith(
      studyDays: updatedDays,
      isCompleted: allComplete,
    );

    await _repository.updatePlan(updatedPlan);
    await _reload();
  }

  /// Convert study days into Assignment tasks
  Future<int> convertToTasks(String planId) async {
    final plan = _repository.getPlan(planId);
    if (plan == null) return 0;

    final assignmentRepo = ref.read(assignmentRepositoryProvider);
    final existingAssignments = assignmentRepo.getAllAssignments();
    int created = 0;

    for (final day in plan.studyDays) {
      final title = 'Study ${plan.subject}: ${day.topics.join(", ")}';

      // Check for duplicates (same title + same deadline date)
      final isDuplicate = existingAssignments.any((a) {
        final sameTitle = a.title == title;
        final sameDate =
            a.deadline.year == day.date.year &&
            a.deadline.month == day.date.month &&
            a.deadline.day == day.date.day;
        return sameTitle && sameDate;
      });

      if (!isDuplicate) {
        final assignment = Assignment(
          id: '${planId}_${day.date.millisecondsSinceEpoch}',
          subjectId: plan.subjectId ?? '',
          title: title,
          description: day.isRevision
              ? 'Revision day'
              : 'Study session from planner',
          deadline: day.date,
          priority: day.isRevision ? 'Low' : 'Medium',
        );
        await assignmentRepo.addAssignment(assignment);
        created++;
      }
    }

    return created;
  }

  /// Regenerate an existing plan with updated parameters
  Future<StudyPlanResult> regeneratePlan(String planId) async {
    final plan = _repository.getPlan(planId);
    if (plan == null) {
      throw Exception('Plan not found');
    }

    final result = StudyPlannerLogic.generatePlan(
      subject: plan.subject,
      examDate: plan.examDate,
      chapters: plan.chapters,
      hoursPerChapter: plan.hoursPerChapter,
      dailyStudyHours: plan.dailyStudyHours,
      subjectId: plan.subjectId,
    );

    // Keep the same ID
    final updatedPlan = result.plan.copyWith();
    final samePlan = StudyPlan(
      id: planId,
      subject: updatedPlan.subject,
      examDate: updatedPlan.examDate,
      dailyStudyHours: updatedPlan.dailyStudyHours,
      hoursPerChapter: updatedPlan.hoursPerChapter,
      chapters: updatedPlan.chapters,
      studyDays: updatedPlan.studyDays,
      subjectId: updatedPlan.subjectId,
    );

    await _repository.updatePlan(samePlan);
    await _reload();
    return result;
  }
}

final studyPlannerProvider =
    AsyncNotifierProvider<StudyPlannerNotifier, List<StudyPlan>>(() {
      return StudyPlannerNotifier();
    });

// Provider for today's study topic
final todayStudyDayProvider = Provider<StudyDay?>((ref) {
  final hiveService = ref.watch(hiveServiceProvider);
  final repo = StudyPlannerRepository(hiveService);
  // Watch the planner provider to reactively update
  ref.watch(studyPlannerProvider);
  return repo.getTodayStudyDay();
});

final todayStudyPlanProvider = Provider<StudyPlan?>((ref) {
  final hiveService = ref.watch(hiveServiceProvider);
  final repo = StudyPlannerRepository(hiveService);
  ref.watch(studyPlannerProvider);
  return repo.getTodayPlan();
});
