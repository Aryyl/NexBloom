import '../../core/services/hive_service.dart';
import '../../data/models/study_plan_model.dart';

class StudyPlannerRepository {
  final HiveService _hiveService;

  StudyPlannerRepository(this._hiveService);

  List<StudyPlan> getAllPlans() {
    return _hiveService.studyPlanBox.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  StudyPlan? getPlan(String id) {
    return _hiveService.studyPlanBox.get(id);
  }

  Future<void> addPlan(StudyPlan plan) async {
    await _hiveService.studyPlanBox.put(plan.id, plan);
  }

  Future<void> updatePlan(StudyPlan plan) async {
    await _hiveService.studyPlanBox.put(plan.id, plan);
  }

  Future<void> deletePlan(String id) async {
    await _hiveService.studyPlanBox.delete(id);
  }

  Future<void> clearAll() async {
    await _hiveService.studyPlanBox.clear();
  }

  /// Get plans for a specific subject
  List<StudyPlan> getPlansBySubject(String subjectId) {
    return _hiveService.studyPlanBox.values
        .where((p) => p.subjectId == subjectId)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Get the active study topic for today across all plans
  StudyDay? getTodayStudyDay() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    for (final plan in _hiveService.studyPlanBox.values) {
      if (plan.isCompleted) continue;
      for (final day in plan.studyDays) {
        final dayDate = DateTime(day.date.year, day.date.month, day.date.day);
        if (dayDate.isAtSameMomentAs(today) && !day.completed) {
          return day;
        }
      }
    }
    return null;
  }

  /// Get the plan that has today's study day
  StudyPlan? getTodayPlan() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    for (final plan in _hiveService.studyPlanBox.values) {
      if (plan.isCompleted) continue;
      for (final day in plan.studyDays) {
        final dayDate = DateTime(day.date.year, day.date.month, day.date.day);
        if (dayDate.isAtSameMomentAs(today)) {
          return plan;
        }
      }
    }
    return null;
  }
}
