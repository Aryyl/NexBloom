import 'package:hive/hive.dart';

part 'settings.g.dart';

@HiveType(typeId: 10)
class AppSettings extends HiveObject {
  @HiveField(0, defaultValue: 'system')
  String themeMode; // 'light', 'dark', 'system'

  @HiveField(1, defaultValue: true)
  bool notificationsEnabled;

  @HiveField(2, defaultValue: 60)
  int defaultReminderMinutes;

  @HiveField(3, defaultValue: 75)
  int attendanceTarget;

  @HiveField(4, defaultValue: null)
  DateTime? semesterStart;

  @HiveField(5, defaultValue: null)
  DateTime? semesterEnd;

  @HiveField(6, defaultValue: 'Student')
  String userName;

  @HiveField(7, defaultValue: '')
  String currentSemester;

  @HiveField(8, defaultValue: null)
  int? primaryColorValue; // stores Color.value int

  AppSettings({
    this.themeMode = 'system',
    this.notificationsEnabled = true,
    this.defaultReminderMinutes = 60,
    this.attendanceTarget = 75,
    this.semesterStart,
    this.semesterEnd,
    this.userName = 'Student',
    this.currentSemester = '',
    this.primaryColorValue,
  });

  // Factory for default settings
  factory AppSettings.defaultSettings() {
    return AppSettings(
      themeMode: 'system',
      notificationsEnabled: true,
      defaultReminderMinutes: 60,
      attendanceTarget: 75,
      userName: 'Student',
      currentSemester: '',
      primaryColorValue: null,
    );
  }

  // Copy with method for updates
  AppSettings copyWith({
    String? themeMode,
    bool? notificationsEnabled,
    int? defaultReminderMinutes,
    int? attendanceTarget,
    DateTime? semesterStart,
    DateTime? semesterEnd,
    String? userName,
    String? currentSemester,
    int? primaryColorValue,
    bool clearPrimaryColor = false,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      defaultReminderMinutes:
          defaultReminderMinutes ?? this.defaultReminderMinutes,
      attendanceTarget: attendanceTarget ?? this.attendanceTarget,
      semesterStart: semesterStart ?? this.semesterStart,
      semesterEnd: semesterEnd ?? this.semesterEnd,
      userName: userName ?? this.userName,
      currentSemester: currentSemester ?? this.currentSemester,
      primaryColorValue: clearPrimaryColor
          ? null
          : (primaryColorValue ?? this.primaryColorValue),
    );
  }
}
