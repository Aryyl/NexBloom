import 'package:hive_flutter/hive_flutter.dart';
import 'package:workmanager/workmanager.dart';

import '../../data/models/assignment.dart';
import '../../data/models/attendance_record.dart';
import '../../data/models/settings.dart';
import '../../data/models/subject.dart';
import '../../data/models/note_model.dart';
import 'widget_service.dart';

/// Unique task name used by WorkManager to identify the periodic sync.
const _widgetSyncTask = 'widget_sync_task';

/// Top-level (not a class method) callback executed by WorkManager in a
/// separate isolate. MUST be annotated with @pragma so the AOT compiler
/// keeps it.
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    try {
      // 1. Re-initialise Hive in the background isolate
      await Hive.initFlutter();

      // Register every adapter that WidgetService needs
      if (!Hive.isAdapterRegistered(SubjectAdapter().typeId)) {
        Hive.registerAdapter(SubjectAdapter());
      }
      if (!Hive.isAdapterRegistered(ClassSessionAdapter().typeId)) {
        Hive.registerAdapter(ClassSessionAdapter());
      }
      if (!Hive.isAdapterRegistered(AssignmentAdapter().typeId)) {
        Hive.registerAdapter(AssignmentAdapter());
      }
      if (!Hive.isAdapterRegistered(ExamAdapter().typeId)) {
        Hive.registerAdapter(ExamAdapter());
      }
      if (!Hive.isAdapterRegistered(AttendanceRecordAdapter().typeId)) {
        Hive.registerAdapter(AttendanceStatusAdapter());
        Hive.registerAdapter(AttendanceRecordAdapter());
      }
      if (!Hive.isAdapterRegistered(AppSettingsAdapter().typeId)) {
        Hive.registerAdapter(AppSettingsAdapter());
      }
      if (!Hive.isAdapterRegistered(NoteAdapter().typeId)) {
        Hive.registerAdapter(NoteAdapter());
      }
      if (!Hive.isAdapterRegistered(ChecklistItemAdapter().typeId)) {
        Hive.registerAdapter(ChecklistItemAdapter());
      }

      if (!Hive.isBoxOpen('attendance')) {
        try {
          final box = await Hive.openBox<AttendanceRecord>('attendance');
          box.values.toList();
        } catch (e) {
          await Hive.deleteBoxFromDisk('attendance');
          await Hive.openBox<AttendanceRecord>('attendance');
        }
      }
      if (!Hive.isBoxOpen('assignments')) {
        await Hive.openBox<Assignment>('assignments');
      }
      if (!Hive.isBoxOpen('class_sessions')) {
        await Hive.openBox<ClassSession>('class_sessions');
      }
      if (!Hive.isBoxOpen('subjects')) {
        await Hive.openBox<Subject>('subjects');
      }

      // 3. Push fresh data to the widget
      await WidgetService.updateWidget();
    } catch (_) {
      // Swallow errors so WorkManager doesn't retry infinitely
    }
    return Future.value(true);
  });
}

/// Service that bootstraps WorkManager for automatic background widget syncs.
class BackgroundService {
  /// Call once from [main] after Workmanager is available.
  static Future<void> init() async {
    await Workmanager().initialize(callbackDispatcher);

    // Register a periodic task. Android enforces a minimum of 15 minutes.
    // The OS may delay or batch tasks, so expect some slack.
    await Workmanager().registerPeriodicTask(
      _widgetSyncTask,
      _widgetSyncTask,
      frequency: const Duration(minutes: 15),
    );
  }
}
