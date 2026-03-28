class MonthlyAttendanceSummary {
  final int presentCount;
  final int absentCount;
  final int holidayCount;
  final double percentage;
  final double trend; // change from previous month

  MonthlyAttendanceSummary({
    required this.presentCount,
    required this.absentCount,
    required this.holidayCount,
    required this.percentage,
    this.trend = 0.0,
  });

  int get totalClasses => presentCount + absentCount;
}
