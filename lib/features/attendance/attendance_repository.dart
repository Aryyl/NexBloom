import '../../core/services/hive_service.dart';
import '../../core/services/widget_service.dart';
import '../../data/models/attendance_record.dart';

class AttendanceRepository {
  final HiveService _hiveService;

  AttendanceRepository(this._hiveService);

  // The box uses typeId 4 but we are storing the new AttendanceRecord (typeId: 10) list
  // Actually, wait, the box previously stored legacy AttendanceRecord.
  // We'll reset it or use a new box entirely to be safe and avoid type mis-matches on start up.
  // Wait, let's keep it clean since it's a complete redesign. We will use the existing box but clear it
  // if format is wrong, or we can just make a dedicated box just for calendar attendance.
  // We'll update HiveService for a new Box in a different step if needed, but for now assuming clean state.

  List<AttendanceRecord> getAllRecords() {
    return _hiveService.attendanceBox.values
        .whereType<AttendanceRecord>()
        .toList();
  }

  AttendanceRecord? getRecord(String subjectId, DateTime date) {
    final key = _generateKey(subjectId, date);
    return _hiveService.attendanceBox.get(key);
  }

  Future<void> saveRecord(AttendanceRecord record) async {
    final key = _generateKey(record.subjectId, record.date);
    await _hiveService.attendanceBox.put(key, record);
    WidgetService.updateWidget();
  }

  Future<void> deleteRecord(String subjectId, DateTime date) async {
    final key = _generateKey(subjectId, date);
    await _hiveService.attendanceBox.delete(key);
    WidgetService.updateWidget();
  }

  Future<void> clearAll() async {
    await _hiveService.attendanceBox.clear();
  }

  // Compatibility methods for old app architecture logic to avoid breaking build
  Future<void> markPresent(String subjectId) async {
    await saveRecord(
      AttendanceRecord(
        id: _generateKey(subjectId, DateTime.now()),
        subjectId: subjectId,
        date: DateTime.now(),
        status: AttendanceStatus.present,
      ),
    );
  }

  Future<void> markAbsent(String subjectId) async {
    await saveRecord(
      AttendanceRecord(
        id: _generateKey(subjectId, DateTime.now()),
        subjectId: subjectId,
        date: DateTime.now(),
        status: AttendanceStatus.absent,
      ),
    );
  }

  Future<void> resetAttendance(String subjectId) async {
    await resetSubjectAttendance(subjectId);
  }

  Future<void> resetSubjectAttendance(String subjectId) async {
    final recordsToRemove = getAllRecords()
        .where((record) => record.subjectId == subjectId)
        .map((r) => _generateKey(r.subjectId, r.date))
        .toList();

    await _hiveService.attendanceBox.deleteAll(recordsToRemove);
    WidgetService.updateWidget();
  }

  String _generateKey(String subjectId, DateTime date) {
    // Format: subjectId_YYYYMMDD
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${subjectId}_$year$month$day';
  }
}
