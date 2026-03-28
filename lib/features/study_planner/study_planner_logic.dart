/// Pure-Dart study plan distribution engine.
/// No Flutter dependencies — testable in isolation.
library;

import '../../data/models/study_plan_model.dart';

enum RiskLevel { none, tight, high, critical }

class StudyPlanResult {
  final StudyPlan plan;
  final RiskLevel riskLevel;
  final String riskMessage;
  final int daysLeft;
  final int totalRequiredHours;
  final int totalAvailableHours;

  const StudyPlanResult({
    required this.plan,
    required this.riskLevel,
    required this.riskMessage,
    required this.daysLeft,
    required this.totalRequiredHours,
    required this.totalAvailableHours,
  });
}

class StudyPlannerLogic {
  /// Generate a structured study plan from user inputs.
  ///
  /// Distribution Rules:
  ///   A – Reserve last 2 days strictly for revision
  ///   B – Distribute chapters evenly across earlier days
  ///   C – If chapters exceed available days, stack multiple chapters/day
  ///   D – If slack hours exist, add revision blocks earlier
  ///   E – Never exceed [dailyStudyHours] per day
  static StudyPlanResult generatePlan({
    required String subject,
    required DateTime examDate,
    required List<String> chapters,
    required int hoursPerChapter,
    required int dailyStudyHours,
    String? subjectId,
  }) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final examDay = DateTime(examDate.year, examDate.month, examDate.day);
    final int daysLeft = examDay.difference(today).inDays;

    final int totalRequired = chapters.length * hoursPerChapter;
    final int totalAvailable = daysLeft * dailyStudyHours;

    // ── Risk assessment ──────────────────────────────────────────────
    RiskLevel riskLevel;
    String riskMessage;

    if (daysLeft <= 0) {
      riskLevel = RiskLevel.critical;
      riskMessage = 'Exam date has already passed or is today!';
    } else if (totalAvailable < totalRequired) {
      riskLevel = RiskLevel.critical;
      riskMessage =
          'Not enough time! Need $totalRequired hrs but only $totalAvailable hrs available. '
          'Increase daily study hours or reduce chapters.';
    } else if (daysLeft < chapters.length) {
      riskLevel = RiskLevel.high;
      riskMessage =
          'High risk: fewer days ($daysLeft) than chapters (${chapters.length}). '
          'Multiple chapters per day required.';
    } else if (totalAvailable < totalRequired * 1.3) {
      riskLevel = RiskLevel.tight;
      riskMessage =
          'Tight schedule — very little buffer for revision. '
          'Consider adding more daily hours.';
    } else {
      riskLevel = RiskLevel.none;
      riskMessage = 'Schedule looks good! Enough time for study and revision.';
    }

    // ── If exam is today/past, return empty plan ─────────────────────
    if (daysLeft <= 0) {
      return StudyPlanResult(
        plan: StudyPlan(
          subject: subject,
          examDate: examDate,
          dailyStudyHours: dailyStudyHours,
          hoursPerChapter: hoursPerChapter,
          chapters: chapters,
          studyDays: [],
          subjectId: subjectId,
        ),
        riskLevel: riskLevel,
        riskMessage: riskMessage,
        daysLeft: daysLeft,
        totalRequiredHours: totalRequired,
        totalAvailableHours: totalAvailable,
      );
    }

    // ── Rule A: Reserve last 2 days for revision ─────────────────────
    final int revisionDays = daysLeft >= 4 ? 2 : (daysLeft >= 2 ? 1 : 0);
    final int studyDaysCount = daysLeft - revisionDays;

    // ── Rule B & C: Distribute chapters across study days ────────────
    final List<StudyDay> days = [];

    if (studyDaysCount > 0 && chapters.isNotEmpty) {
      // How many chapters can fit per day based on hours?
      final int maxChaptersPerDay =
          dailyStudyHours ~/ hoursPerChapter.clamp(1, dailyStudyHours);

      // Distribute chapters evenly
      final int chaptersPerDay = chapters.length <= studyDaysCount
          ? 1
          : (chapters.length / studyDaysCount).ceil();

      // Clamp to what daily hours allow
      final int effectivePerDay = chaptersPerDay.clamp(
        1,
        maxChaptersPerDay.clamp(1, chapters.length),
      );

      int chapterIndex = 0;
      for (
        int d = 0;
        d < studyDaysCount && chapterIndex < chapters.length;
        d++
      ) {
        final dayDate = today.add(Duration(days: d + 1));
        final List<String> dayTopics = [];

        for (
          int c = 0;
          c < effectivePerDay && chapterIndex < chapters.length;
          c++
        ) {
          dayTopics.add(chapters[chapterIndex]);
          chapterIndex++;
        }

        days.add(StudyDay(date: dayDate, topics: dayTopics, isRevision: false));
      }

      // If there are remaining chapters (edge case: effective clamping),
      // distribute them into existing days without exceeding maxChaptersPerDay
      while (chapterIndex < chapters.length) {
        for (
          int d = 0;
          d < days.length && chapterIndex < chapters.length;
          d++
        ) {
          if (days[d].topics.length <
              maxChaptersPerDay.clamp(1, chapters.length)) {
            final updatedTopics = List<String>.from(days[d].topics)
              ..add(chapters[chapterIndex]);
            days[d] = days[d].copyWith(topics: updatedTopics);
            chapterIndex++;
          }
        }
        // Safety break — if we can't fit more, just add extra day
        if (chapterIndex < chapters.length) {
          final dayDate = days.isNotEmpty
              ? days.last.date.add(const Duration(days: 1))
              : today.add(const Duration(days: 1));
          days.add(
            StudyDay(
              date: dayDate,
              topics: [chapters[chapterIndex]],
              isRevision: false,
            ),
          );
          chapterIndex++;
        }
      }
    }

    // ── Rule D: If slack time exists, add revision blocks earlier ─────
    final int totalStudyHoursUsed = days.fold<int>(
      0,
      (sum, d) => sum + d.topics.length * hoursPerChapter,
    );
    final int totalStudyHoursAvailable = studyDaysCount * dailyStudyHours;
    final int slackHours = totalStudyHoursAvailable - totalStudyHoursUsed;

    if (slackHours > hoursPerChapter && days.length > 2) {
      // Add mid-plan revision: mark days with spare capacity
      int revisionBudget = slackHours ~/ hoursPerChapter;
      // Insert revision topics every ~3rd day
      for (int d = 2; d < days.length && revisionBudget > 0; d += 3) {
        final currentLoad = days[d].topics.length * hoursPerChapter;
        if (currentLoad + hoursPerChapter <= dailyStudyHours) {
          final updatedTopics = List<String>.from(days[d].topics)
            ..add('📖 Revision: ${days[d].topics.join(", ")}');
          days[d] = days[d].copyWith(topics: updatedTopics);
          revisionBudget--;
        }
      }
    }

    // ── Rule A continued: Add revision days at the end ───────────────
    for (int r = 0; r < revisionDays; r++) {
      final revisionDate = examDay.subtract(Duration(days: revisionDays - r));
      // Revision covers all chapters
      final int chunkSize = (chapters.length / revisionDays.clamp(1, 999))
          .ceil();
      final int startIdx = r * chunkSize;
      final int endIdx = (startIdx + chunkSize).clamp(0, chapters.length);
      final revisionTopics = startIdx < chapters.length
          ? chapters
                .sublist(startIdx, endIdx)
                .map((c) => '📝 Revise: $c')
                .toList()
          : ['📝 Full revision'];

      days.add(
        StudyDay(date: revisionDate, topics: revisionTopics, isRevision: true),
      );
    }

    // Sort days by date
    days.sort((a, b) => a.date.compareTo(b.date));

    final plan = StudyPlan(
      subject: subject,
      examDate: examDate,
      dailyStudyHours: dailyStudyHours,
      hoursPerChapter: hoursPerChapter,
      chapters: chapters,
      studyDays: days,
      subjectId: subjectId,
    );

    return StudyPlanResult(
      plan: plan,
      riskLevel: riskLevel,
      riskMessage: riskMessage,
      daysLeft: daysLeft,
      totalRequiredHours: totalRequired,
      totalAvailableHours: totalAvailable,
    );
  }
}
