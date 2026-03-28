import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/attendance_record.dart';
import '../../data/models/monthly_attendance_summary.dart';
import '../../domain/providers/providers.dart';
import 'attendance_repository.dart';
import 'attendance_logic.dart';

final attendanceStateProvider =
    NotifierProvider<AttendanceNotifier, List<AttendanceRecord>>(() {
      return AttendanceNotifier();
    });

class AttendanceNotifier extends Notifier<List<AttendanceRecord>> {
  late final AttendanceRepository _repository;

  @override
  List<AttendanceRecord> build() {
    _repository = ref.watch(attendanceRepositoryProvider);
    return _repository.getAllRecords();
  }

  void _loadRecords() {
    state = _repository.getAllRecords();
  }

  Future<void> markAttendance(
    String subjectId,
    DateTime date,
    AttendanceStatus status,
  ) async {
    final record = AttendanceRecord(
      id: _generateKey(subjectId, date),
      subjectId: subjectId,
      date: date,
      status: status,
    );

    // Save optimally to Hive
    await _repository.saveRecord(record);

    // Update state to trigger UI rebuild
    _loadRecords();
  }

  Future<bool> undoLastAction() async {
    // Basic implementation for undo - removes the most recently added record.
    // Enhanced undo logic should target a specific subject if required,
    // but the unified repository method `undoLastAction` handles the DB.
    final lastRecord = _repository.getAllRecords().lastOrNull;
    if (lastRecord == null) return false;

    await _repository.deleteRecord(lastRecord.subjectId, lastRecord.date);
    _loadRecords();
    return true;
  }

  Future<void> undoAttendance(String subjectId, DateTime date) async {
    await _repository.deleteRecord(subjectId, date);
    _loadRecords();
  }

  Future<void> resetAttendance(String subjectId) async {
    await _repository.resetSubjectAttendance(subjectId);
    _loadRecords();
  }

  // Helper methodologies for UI derived state

  double getSubjectPercentage(String subjectId) {
    return AttendanceLogic.calculatePercentage(state, subjectId);
  }

  double getOverallPercentage() {
    return AttendanceLogic.calculateOverallPercentage(state);
  }

  MonthlyAttendanceSummary getMonthlySummary(
    DateTime month, {
    String? subjectId,
  }) {
    return AttendanceLogic.generateMonthlySummary(
      state,
      month,
      subjectId: subjectId,
    );
  }

  String? getLowestAttendanceSubject(List<String> subjectIds) {
    return AttendanceLogic.findLowestAttendanceSubject(state, subjectIds);
  }

  String _generateKey(String subjectId, DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${subjectId}_$year$month$day';
  }
}
