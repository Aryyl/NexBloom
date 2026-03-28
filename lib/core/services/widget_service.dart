import 'package:home_widget/home_widget.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import '../../data/models/assignment.dart';
import '../../data/models/attendance_record.dart';
import '../../data/models/subject.dart';

/// Service responsible for pushing summary data to the Android home screen widget.
/// Call [updateWidget] after any data change (attendance, tasks, schedule).
class WidgetService {
  static const String _qualifiedAndroidName =
      'com.example.studentcompanionapp.StudentWidget';

  static Future<void> init() async {
    // No Android-specific init needed for home_widget
  }

  /// Toggle widget theme between 'light' and 'dark'.
  static Future<void> setWidgetTheme(String theme) async {
    await HomeWidget.saveWidgetData<String>('widget_theme', theme);
    await HomeWidget.updateWidget(qualifiedAndroidName: _qualifiedAndroidName);
  }

  /// Get current widget theme.
  static Future<String> getWidgetTheme() async {
    return await HomeWidget.getWidgetData<String>(
          'widget_theme',
          defaultValue: 'light',
        ) ??
        'light';
  }

  /// Reads current Hive data and pushes everything to the widget.
  static Future<void> updateWidget() async {
    try {
      // ── Attendance ─────────────────────────────────────────────
      final attendanceBox = Hive.box<AttendanceRecord>('attendance');
      int totalClasses = 0;
      int attendedClasses = 0;
      for (final record in attendanceBox.values) {
        if (record.status != AttendanceStatus.holiday) {
          totalClasses++;
          if (record.status == AttendanceStatus.present) {
            attendedClasses++;
          }
        }
      }
      final double attendancePct = totalClasses > 0
          ? (attendedClasses / totalClasses) * 100
          : 0.0;
      final int attendanceInt = attendancePct.round().clamp(0, 100);

      // ── Pending Tasks (top 3) ───────────────────────────────────
      final assignmentBox = Hive.box<Assignment>('assignments');
      final now = DateTime.now();
      final pendingAssignments =
          assignmentBox.values.where((a) => !a.isCompleted).toList()
            ..sort((a, b) => a.deadline.compareTo(b.deadline));

      final int pendingCount = pendingAssignments.length;
      final String task1 = pendingCount > 0 ? pendingAssignments[0].title : '';
      final String task2 = pendingCount > 1 ? pendingAssignments[1].title : '';
      final String task3 = pendingCount > 2 ? pendingAssignments[2].title : '';

      // Task 1 high priority = due today or overdue
      final bool task1High =
          pendingCount > 0 &&
          pendingAssignments[0].deadline.isBefore(
            now.add(const Duration(days: 1)),
          );

      // ── Today's Schedule (next 2 upcoming classes today) ────────
      final subjectBox = Hive.box<Subject>('subjects');
      final sessionBox = Hive.box<ClassSession>('class_sessions');

      final int todayWeekday = now.weekday; // 1=Mon, 7=Sun
      final todaySessions =
          sessionBox.values.where((s) => s.dayOfWeek == todayWeekday).toList()
            ..sort((a, b) => a.startTime.compareTo(b.startTime));

      // Filter to sessions that haven't ended yet
      final upcomingSessions = todaySessions.where((s) {
        final parts = s.endTime.split(':');
        if (parts.length < 2) return true;
        final end = DateTime(
          now.year,
          now.month,
          now.day,
          int.parse(parts[0]),
          int.parse(parts[1]),
        );
        return end.isAfter(now);
      }).toList();

      String class1Name = '', class1Room = '', class1Time = '', class1Eta = '';
      String class2Name = '', class2Room = '', class2Time = '';

      if (upcomingSessions.isNotEmpty) {
        final s1 = upcomingSessions[0];
        final subject1 = subjectBox.values.firstWhere(
          (s) => s.id == s1.subjectId,
          orElse: () => Subject(
            id: '',
            name: 'Unknown',
            professorName: '',
            roomNumber: '',
            colorValue: 0,
          ),
        );
        class1Name = subject1.name;
        class1Room = subject1.roomNumber.isNotEmpty
            ? 'Room ${subject1.roomNumber}'
            : '';
        class1Time = _formatTime(s1.startTime);

        // ETA calculation
        final startParts = s1.startTime.split(':');
        if (startParts.length >= 2) {
          final startDt = DateTime(
            now.year,
            now.month,
            now.day,
            int.parse(startParts[0]),
            int.parse(startParts[1]),
          );
          if (startDt.isAfter(now)) {
            final mins = startDt.difference(now).inMinutes;
            class1Eta = mins <= 60 ? 'In $mins mins' : '';
          } else {
            class1Eta = 'Ongoing';
          }
        }

        if (upcomingSessions.length > 1) {
          final s2 = upcomingSessions[1];
          final subject2 = subjectBox.values.firstWhere(
            (s) => s.id == s2.subjectId,
            orElse: () => Subject(
              id: '',
              name: 'Unknown',
              professorName: '',
              roomNumber: '',
              colorValue: 0,
            ),
          );
          class2Name = subject2.name;
          class2Room = subject2.roomNumber.isNotEmpty
              ? 'Room ${subject2.roomNumber}'
              : '';
          class2Time = _formatTime(s2.startTime);
        }
      }

      // ── Save all data to HomeWidget SharedPreferences ───────────
      await Future.wait([
        HomeWidget.saveWidgetData<int>('attendance_int', attendanceInt),
        HomeWidget.saveWidgetData<String>('attendance_pct', '$attendanceInt%'),
        HomeWidget.saveWidgetData<int>('pending_tasks_count', pendingCount),
        HomeWidget.saveWidgetData<String>('task_1_title', task1),
        HomeWidget.saveWidgetData<String>('task_2_title', task2),
        HomeWidget.saveWidgetData<String>('task_3_title', task3),
        HomeWidget.saveWidgetData<bool>('task_1_high_priority', task1High),
        HomeWidget.saveWidgetData<String>('class_1_name', class1Name),
        HomeWidget.saveWidgetData<String>('class_1_room', class1Room),
        HomeWidget.saveWidgetData<String>('class_1_time', class1Time),
        HomeWidget.saveWidgetData<String>('class_1_eta', class1Eta),
        HomeWidget.saveWidgetData<String>('class_2_name', class2Name),
        HomeWidget.saveWidgetData<String>('class_2_room', class2Room),
        HomeWidget.saveWidgetData<String>('class_2_time', class2Time),
      ]);

      // ── Trigger widget redraw ───────────────────────────────────
      await HomeWidget.updateWidget(
        qualifiedAndroidName: _qualifiedAndroidName,
      );
    } catch (_) {
      // Widget update should never crash the app
    }
  }

  static String _formatTime(String hhmm) {
    try {
      final parts = hhmm.split(':');
      final dt = DateTime(0, 0, 0, int.parse(parts[0]), int.parse(parts[1]));
      return DateFormat('hh:mm a').format(dt);
    } catch (_) {
      return hhmm;
    }
  }
}
