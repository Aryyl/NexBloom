import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:studentcompanionapp/data/models/settings.dart';

// Settings box name constant
const String settingsBoxName = 'settings';
const String settingsKey = 'app_settings';

// Global instances to trigger rebuilds
final _themeNotifier = ValueNotifier<ThemeMode>(ThemeMode.system);
final _settingsNotifier = ValueNotifier<AppSettings>(
  AppSettings.defaultSettings(),
);

// Theme controller class
class ThemeController {
  static ThemeMode get themeMode => _themeNotifier.value;
  static Box<AppSettings>? _settingsBox;

  static Future<void> init() async {
    try {
      _settingsBox = await Hive.openBox<AppSettings>(settingsBoxName);
      final settings = _settingsBox?.get(settingsKey);

      if (settings != null) {
        _themeNotifier.value = _themeModeFromString(settings.themeMode);
      }
    } catch (e) {
      debugPrint('Error loading theme: $e');
    }
  }

  static Future<void> setThemeMode(ThemeMode mode) async {
    _themeNotifier.value = mode;
    await _saveTheme(mode);
  }

  static Future<void> _saveTheme(ThemeMode mode) async {
    try {
      _settingsBox ??= await Hive.openBox<AppSettings>(settingsBoxName);

      var settings = _settingsBox?.get(settingsKey);
      settings ??= AppSettings.defaultSettings();

      settings.themeMode = _themeModeToString(mode);
      await _settingsBox?.put(settingsKey, settings);
    } catch (e) {
      debugPrint('Error saving theme: $e');
    }
  }

  static ThemeMode _themeModeFromString(String mode) {
    switch (mode.toLowerCase()) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  static String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }
}

// Theme mode provider
final themeModeProvider = Provider<ThemeMode>((ref) {
  void listener() {
    if (ref.mounted) ref.invalidateSelf();
  }

  _themeNotifier.addListener(listener);
  ref.onDispose(() => _themeNotifier.removeListener(listener));
  return _themeNotifier.value;
});

// Settings controller class
class SettingsController {
  static AppSettings get settings => _settingsNotifier.value;
  static Box<AppSettings>? _settingsBox;

  static Future<void> init() async {
    try {
      _settingsBox = await Hive.openBox<AppSettings>(settingsBoxName);
      final loadedSettings = _settingsBox?.get(settingsKey);

      if (loadedSettings != null) {
        _settingsNotifier.value = loadedSettings;
      }
    } catch (e) {
      debugPrint('Error loading settings: $e');
    }
  }

  static Future<void> updateSettings(AppSettings newSettings) async {
    _settingsNotifier.value = newSettings;
    await _saveSettings(newSettings);
  }

  static Future<void> _saveSettings(AppSettings settings) async {
    try {
      _settingsBox ??= await Hive.openBox<AppSettings>(settingsBoxName);
      await _settingsBox?.put(settingsKey, settings);
    } catch (e) {
      debugPrint('Error saving settings: $e');
    }
  }

  static Future<void> updateNotifications(bool enabled) async {
    final updated = settings.copyWith(notificationsEnabled: enabled);
    await updateSettings(updated);
  }

  static Future<void> updateReminderTime(int minutes) async {
    final updated = settings.copyWith(defaultReminderMinutes: minutes);
    await updateSettings(updated);
  }

  static Future<void> updateAttendanceTarget(int target) async {
    final updated = settings.copyWith(attendanceTarget: target);
    await updateSettings(updated);
  }

  static Future<void> updateSemesterDates(
    DateTime? start,
    DateTime? end,
  ) async {
    final updated = settings.copyWith(semesterStart: start, semesterEnd: end);
    await updateSettings(updated);
  }

  static Future<void> updateUserName(String name) async {
    final updated = settings.copyWith(userName: name);
    await updateSettings(updated);
  }

  static Future<void> updateSemester(String semester) async {
    final updated = settings.copyWith(currentSemester: semester);
    await updateSettings(updated);
  }

  static Future<void> updatePrimaryColor(int? colorValue) async {
    if (colorValue == null) {
      final updated = settings.copyWith(clearPrimaryColor: true);
      await updateSettings(updated);
    } else {
      final updated = settings.copyWith(primaryColorValue: colorValue);
      await updateSettings(updated);
    }
  }

  static Future<void> resetToDefaults() async {
    await updateSettings(AppSettings.defaultSettings());
  }
}

// Settings provider
final settingsProvider = Provider<AppSettings>((ref) {
  void listener() {
    if (ref.mounted) ref.invalidateSelf();
  }

  _settingsNotifier.addListener(listener);
  ref.onDispose(() => _settingsNotifier.removeListener(listener));
  return _settingsNotifier.value;
});

// Primary color provider
final primaryColorProvider = Provider<Color?>((ref) {
  final settings = ref.watch(settingsProvider);
  if (settings.primaryColorValue != null) {
    return Color(settings.primaryColorValue!);
  }
  return null;
});
