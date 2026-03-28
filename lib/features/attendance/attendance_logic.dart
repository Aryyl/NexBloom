import '../../data/models/attendance_record.dart';
import '../../data/models/monthly_attendance_summary.dart';

class AttendanceLogic {
  /// Calculates the overall attendance percentage for a specific subject
  static double calculatePercentage(
    List<AttendanceRecord> records,
    String subjectId,
  ) {
    final subjectRecords = records
        .where((r) => r.subjectId == subjectId)
        .toList();

    int presentCount = subjectRecords
        .where((r) => r.status == AttendanceStatus.present)
        .length;
    int absentCount = subjectRecords
        .where((r) => r.status == AttendanceStatus.absent)
        .length;
    // Holidays are ignored in total class count

    int totalValidClasses = presentCount + absentCount;
    if (totalValidClasses == 0) return 0.0;

    return (presentCount / totalValidClasses) * 100;
  }

  /// Calculates the overall attendance percentage across all subjects
  static double calculateOverallPercentage(List<AttendanceRecord> records) {
    if (records.isEmpty) return 0.0;

    int presentCount = records
        .where((r) => r.status == AttendanceStatus.present)
        .length;
    int absentCount = records
        .where((r) => r.status == AttendanceStatus.absent)
        .length;

    int totalValidClasses = presentCount + absentCount;
    if (totalValidClasses == 0) return 0.0;

    return (presentCount / totalValidClasses) * 100;
  }

  /// Generates a monthly summary for a specific subject or all subjects
  static MonthlyAttendanceSummary generateMonthlySummary(
    List<AttendanceRecord> records,
    DateTime month, {
    String? subjectId,
  }) {
    var filteredRecords = records.where(
      (r) => r.date.year == month.year && r.date.month == month.month,
    );

    if (subjectId != null) {
      filteredRecords = filteredRecords.where((r) => r.subjectId == subjectId);
    }

    final list = filteredRecords.toList();

    int presentCount = list
        .where((r) => r.status == AttendanceStatus.present)
        .length;
    int absentCount = list
        .where((r) => r.status == AttendanceStatus.absent)
        .length;
    int holidayCount = list
        .where((r) => r.status == AttendanceStatus.holiday)
        .length;

    int totalValidClasses = presentCount + absentCount;
    double percentage = totalValidClasses > 0
        ? (presentCount / totalValidClasses) * 100
        : 0.0;

    // Calculate trend from previous month
    final prevMonth = DateTime(month.year, month.month - 1, 1);
    var prevRecords = records.where(
      (r) => r.date.year == prevMonth.year && r.date.month == prevMonth.month,
    );
    if (subjectId != null) {
      prevRecords = prevRecords.where((r) => r.subjectId == subjectId);
    }

    final prevList = prevRecords.toList();
    int prevPresent = prevList
        .where((r) => r.status == AttendanceStatus.present)
        .length;
    int prevAbsent = prevList
        .where((r) => r.status == AttendanceStatus.absent)
        .length;
    double prevPercentage = (prevPresent + prevAbsent) > 0
        ? (prevPresent / (prevPresent + prevAbsent)) * 100
        : 0.0;

    double trend = percentage - prevPercentage;

    return MonthlyAttendanceSummary(
      presentCount: presentCount,
      absentCount: absentCount,
      holidayCount: holidayCount,
      percentage: percentage,
      trend: trend,
    );
  }

  /// Finds the subject ID with the lowest attendance percentage
  static String? findLowestAttendanceSubject(
    List<AttendanceRecord> records,
    List<String> subjectIds,
  ) {
    if (records.isEmpty || subjectIds.isEmpty) return null;

    String? lowestSubjectId;
    double? lowestPercentage;

    for (var subId in subjectIds) {
      final pct = calculatePercentage(records, subId);
      final subRecords = records.where((r) => r.subjectId == subId);
      final totalValid = subRecords
          .where(
            (r) =>
                r.status == AttendanceStatus.present ||
                r.status == AttendanceStatus.absent,
          )
          .length;

      // Only consider subjects that actually have classes marked
      if (totalValid > 0) {
        if (lowestPercentage == null || pct < lowestPercentage) {
          lowestPercentage = pct;
          lowestSubjectId = subId;
        }
      }
    }

    return lowestSubjectId;
  }
}
