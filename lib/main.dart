import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/constants/theme.dart';
import 'presentation/navigation/app_router.dart';
import 'domain/providers/providers.dart';
import 'domain/providers/theme_provider.dart';

import 'core/services/hive_service.dart';
import 'core/services/notification_service.dart';
import 'data/models/subject.dart';
import 'data/models/assignment.dart';
import 'data/models/attendance_record.dart';
import 'data/models/settings.dart';
import 'data/models/note_model.dart';
import 'data/models/study_plan_model.dart';
import 'core/services/widget_service.dart';
import 'core/services/background_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Register Adapters
  Hive.registerAdapter(SubjectAdapter());
  Hive.registerAdapter(ClassSessionAdapter());
  Hive.registerAdapter(AssignmentAdapter());
  Hive.registerAdapter(ExamAdapter());
  Hive.registerAdapter(AttendanceStatusAdapter());
  Hive.registerAdapter(AttendanceRecordAdapter());
  Hive.registerAdapter(AppSettingsAdapter());
  Hive.registerAdapter(NoteAdapter());
  Hive.registerAdapter(ChecklistItemAdapter());
  Hive.registerAdapter(StudyPlanAdapter());
  Hive.registerAdapter(StudyDayAdapter());

  // Initialize Hive Service (Open Boxes)
  final hiveService = HiveService();
  await hiveService.init();

  // Initialize Notification Service
  final notificationService = NotificationService();
  await notificationService.init();

  // Initialize Settings and Theme
  await SettingsController.init();
  await ThemeController.init();

  // Initialize and update home screen widget
  await WidgetService.init();
  WidgetService.updateWidget(); // fire-and-forget, non-blocking

  // Register background periodic sync (updates widget when app is closed)
  await BackgroundService.init();

  runApp(
    ProviderScope(
      overrides: [
        hiveServiceProvider.overrideWithValue(hiveService),
        notificationServiceProvider.overrideWithValue(notificationService),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final primaryColor = ref.watch(primaryColorProvider);

    // Rebuild themes when primary color changes
    AppTheme.applyPrimaryColor(primaryColor);

    return MaterialApp.router(
      title: 'NexBloom',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: appRouter,
    );
  }
}
