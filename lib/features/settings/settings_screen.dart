import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:go_router/go_router.dart';
import 'package:studentcompanionapp/domain/providers/theme_provider.dart';
import 'package:studentcompanionapp/domain/providers/providers.dart';
import 'package:studentcompanionapp/core/constants/colors.dart';
import 'package:studentcompanionapp/core/services/widget_service.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  String _appVersion = '';
  String _widgetTheme = 'light';

  // Predefined accent colors for the color picker
  static const List<_AccentColorOption> _accentColors = [
    _AccentColorOption('Indigo', Color(0xFF6366F1), null), // default
    _AccentColorOption('Blue', Color(0xFF3B82F6), 0xFF3B82F6),
    _AccentColorOption('Sky', Color(0xFF0EA5E9), 0xFF0EA5E9),
    _AccentColorOption('Teal', Color(0xFF14B8A6), 0xFF14B8A6),
    _AccentColorOption('Emerald', Color(0xFF10B981), 0xFF10B981),
    _AccentColorOption('Green', Color(0xFF22C55E), 0xFF22C55E),
    _AccentColorOption('Amber', Color(0xFFF59E0B), 0xFFF59E0B),
    _AccentColorOption('Orange', Color(0xFFF97316), 0xFFF97316),
    _AccentColorOption('Rose', Color(0xFFF43F5E), 0xFFF43F5E),
    _AccentColorOption('Pink', Color(0xFFEC4899), 0xFFEC4899),
    _AccentColorOption('Purple', Color(0xFFA855F7), 0xFFA855F7),
    _AccentColorOption('Violet', Color(0xFF8B5CF6), 0xFF8B5CF6),
  ];

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
    _loadWidgetTheme();
  }

  Future<void> _loadAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = packageInfo.version;
    });
  }

  Future<void> _loadWidgetTheme() async {
    final theme = await WidgetService.getWidgetTheme();
    setState(() {
      _widgetTheme = theme;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: ListView(
        children: [
          // Profile Section
          _buildSectionHeader(context, 'Profile'),
          _buildUserNameTile(context, settings.userName),
          _buildSemesterTile(context, settings.currentSemester),
          const Divider(),

          // Theme Settings Section
          _buildSectionHeader(context, 'Appearance'),
          _buildThemeTile(context, themeMode),
          _buildAccentColorTile(context, settings.primaryColorValue),
          _buildWidgetThemeTile(context),
          const Divider(),

          // Notification Settings Section
          _buildSectionHeader(context, 'Notifications'),
          _buildNotificationToggle(context, settings.notificationsEnabled),
          _buildTestNotificationButton(context),
          _buildReminderTimeTile(context, settings.defaultReminderMinutes),
          const Divider(),

          // Academic Settings Section
          _buildSectionHeader(context, 'Academic'),
          _buildAttendanceTargetTile(context, settings.attendanceTarget),
          _buildSemesterDatesTile(
            context,
            settings.semesterStart,
            settings.semesterEnd,
          ),
          _buildResetAcademicDataButton(context),
          const Divider(),

          // Data Management Section
          _buildSectionHeader(context, 'Data'),
          _buildExportDataTile(context),
          _buildClearDataButton(context),
          _buildBackupRestorePlaceholder(context),
          const Divider(),

          // About Section
          _buildSectionHeader(context, 'About'),
          _buildAboutTiles(context),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  // ── Profile ────────────────────────────────────────────────────────────

  Widget _buildUserNameTile(BuildContext context, String currentName) {
    return ListTile(
      leading: const Icon(Icons.person_outline),
      title: const Text('Display Name'),
      subtitle: Text(currentName.isNotEmpty ? currentName : 'Not set'),
      onTap: () => _showNameEditDialog(context, currentName),
    );
  }

  void _showNameEditDialog(BuildContext context, String currentName) {
    final controller = TextEditingController(text: currentName);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Display Name'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            labelText: 'Your name',
            hintText: 'e.g. John Doe',
            border: OutlineInputBorder(),
          ),
          maxLength: 30,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                SettingsController.updateUserName(name);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Name updated to "$name"')),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildSemesterTile(BuildContext context, String currentSemester) {
    return ListTile(
      leading: const Icon(Icons.school_outlined),
      title: const Text('Current Semester'),
      subtitle: Text(currentSemester.isNotEmpty ? currentSemester : 'Not set'),
      onTap: () => _showSemesterEditDialog(context, currentSemester),
    );
  }

  void _showSemesterEditDialog(BuildContext context, String currentSemester) {
    final controller = TextEditingController(text: currentSemester);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set Current Semester'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Semester',
                hintText: 'e.g. Semester 4, Fall 2026',
                border: OutlineInputBorder(),
              ),
              maxLength: 40,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _semesterQuickChip(context, controller, 'Semester 1'),
                _semesterQuickChip(context, controller, 'Semester 2'),
                _semesterQuickChip(context, controller, 'Semester 3'),
                _semesterQuickChip(context, controller, 'Semester 4'),
                _semesterQuickChip(context, controller, 'Semester 5'),
                _semesterQuickChip(context, controller, 'Semester 6'),
                _semesterQuickChip(context, controller, 'Semester 7'),
                _semesterQuickChip(context, controller, 'Semester 8'),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final semester = controller.text.trim();
              SettingsController.updateSemester(semester);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    semester.isEmpty
                        ? 'Semester cleared'
                        : 'Semester set to "$semester"',
                  ),
                ),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _semesterQuickChip(
    BuildContext context,
    TextEditingController controller,
    String label,
  ) {
    return ActionChip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      onPressed: () {
        controller.text = label;
        controller.selection = TextSelection.fromPosition(
          TextPosition(offset: label.length),
        );
      },
    );
  }

  // ── Appearance ──────────────────────────────────────────────────────────

  Widget _buildThemeTile(BuildContext context, ThemeMode currentMode) {
    return ListTile(
      leading: const Icon(Icons.palette_outlined),
      title: const Text('App Theme'),
      subtitle: Text(_getThemeLabel(currentMode)),
      onTap: () => _showThemeDialog(context, currentMode),
    );
  }

  Widget _buildAccentColorTile(BuildContext context, int? currentColorValue) {
    final currentColor = currentColorValue != null
        ? Color(currentColorValue)
        : _accentColors.first.displayColor;

    return ListTile(
      leading: const Icon(Icons.color_lens_outlined),
      title: const Text('Accent Color'),
      subtitle: Text(
        _accentColors
            .firstWhere(
              (c) =>
                  (c.colorInt == null && currentColorValue == null) ||
                  (c.colorInt != null &&
                      currentColorValue != null &&
                      c.colorInt == currentColorValue),
              orElse: () => _accentColors.first,
            )
            .name,
      ),
      trailing: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: currentColor,
          shape: BoxShape.circle,
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
            width: 2,
          ),
        ),
      ),
      onTap: () => _showColorPickerDialog(context, currentColorValue),
    );
  }

  void _showColorPickerDialog(BuildContext context, int? currentColorValue) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Choose Accent Color'),
          content: SizedBox(
            width: 280,
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: _accentColors.map((option) {
                final isSelected =
                    (option.colorInt == null && currentColorValue == null) ||
                    (option.colorInt != null &&
                        currentColorValue != null &&
                        option.colorInt == currentColorValue);

                return GestureDetector(
                  onTap: () {
                    SettingsController.updatePrimaryColor(option.colorInt);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Accent color changed to ${option.name}'),
                      ),
                    );
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: option.displayColor,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? Theme.of(context).colorScheme.onSurface
                            : Colors.transparent,
                        width: 3,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: option.displayColor.withValues(
                                  alpha: 0.4,
                                ),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ]
                          : null,
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white, size: 24)
                        : null,
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildWidgetThemeTile(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.widgets_outlined),
      title: const Text('Widget Theme'),
      subtitle: Text(_widgetTheme == 'dark' ? 'Dark' : 'Light'),
      onTap: () => _showWidgetThemeDialog(context),
    );
  }

  void _showWidgetThemeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Widget Theme'),
        content: RadioGroup<String>(
          groupValue: _widgetTheme,
          onChanged: (val) {
            if (val != null) {
              setState(() => _widgetTheme = val);
              WidgetService.setWidgetTheme(val);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Widget theme updated to ${val == 'dark' ? 'Dark' : 'Light'}',
                  ),
                ),
              );
            }
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              RadioListTile<String>(
                title: Text('Light'),
                subtitle: Text('Clean white design'),
                value: 'light',
              ),
              RadioListTile<String>(
                title: Text('Dark'),
                subtitle: Text('Modern deep dark'),
                value: 'dark',
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getThemeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System default';
    }
  }

  void _showThemeDialog(BuildContext context, ThemeMode currentMode) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Theme'),
        content: RadioGroup<ThemeMode>(
          groupValue: currentMode,
          onChanged: (val) {
            if (val != null) {
              ThemeController.setThemeMode(val);
              Navigator.pop(context);
            }
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              RadioListTile<ThemeMode>(
                title: Text('Light'),
                value: ThemeMode.light,
              ),
              RadioListTile<ThemeMode>(
                title: Text('Dark'),
                value: ThemeMode.dark,
              ),
              RadioListTile<ThemeMode>(
                title: Text('System default'),
                value: ThemeMode.system,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Notifications ──────────────────────────────────────────────────────

  Widget _buildNotificationToggle(BuildContext context, bool enabled) {
    return SwitchListTile(
      secondary: const Icon(Icons.notifications_outlined),
      title: const Text('Enable Notifications'),
      subtitle: const Text('Receive reminders for exams and assignments'),
      value: enabled,
      onChanged: (value) {
        SettingsController.updateNotifications(value);
      },
    );
  }

  Widget _buildTestNotificationButton(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.notification_add_outlined),
      title: const Text('Test Notification'),
      subtitle: const Text('Send a test notification'),
      onTap: () {
        // TODO: Trigger test notification
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Test notification sent!')),
        );
      },
    );
  }

  Widget _buildReminderTimeTile(BuildContext context, int minutes) {
    return ListTile(
      leading: const Icon(Icons.access_time_outlined),
      title: const Text('Default Reminder Time'),
      subtitle: Text('$minutes minutes before'),
      onTap: () => _showReminderTimeDialog(context, minutes),
    );
  }

  void _showReminderTimeDialog(BuildContext context, int currentMinutes) {
    int selectedMinutes = currentMinutes;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reminder Time'),
        content: StatefulBuilder(
          builder: (context, setState) => RadioGroup<int>(
            groupValue: selectedMinutes,
            onChanged: (value) {
              if (value != null) {
                setState(() => selectedMinutes = value);
              }
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                RadioListTile<int>(title: Text('15 minutes'), value: 15),
                RadioListTile<int>(title: Text('30 minutes'), value: 30),
                RadioListTile<int>(title: Text('1 hour'), value: 60),
                RadioListTile<int>(title: Text('1 day'), value: 1440),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              SettingsController.updateReminderTime(selectedMinutes);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // ── Academic ────────────────────────────────────────────────────────────

  Widget _buildAttendanceTargetTile(BuildContext context, int target) {
    return ListTile(
      leading: const Icon(Icons.flag_outlined),
      title: const Text('Attendance Target'),
      subtitle: Text('$target%'),
      onTap: () => _showAttendanceTargetDialog(context, target),
    );
  }

  void _showAttendanceTargetDialog(BuildContext context, int currentTarget) {
    int selectedTarget = currentTarget;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Attendance Target'),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Slider(
                value: selectedTarget.toDouble(),
                min: 50,
                max: 100,
                divisions: 10,
                label: '$selectedTarget%',
                onChanged: (value) =>
                    setState(() => selectedTarget = value.toInt()),
              ),
              Text(
                '$selectedTarget%',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              SettingsController.updateAttendanceTarget(selectedTarget);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildSemesterDatesTile(
    BuildContext context,
    DateTime? start,
    DateTime? end,
  ) {
    String subtitle = 'Not set';
    if (start != null && end != null) {
      subtitle = '${_formatDate(start)} - ${_formatDate(end)}';
    }

    return ListTile(
      leading: const Icon(Icons.calendar_month_outlined),
      title: const Text('Semester Dates'),
      subtitle: Text(subtitle),
      onTap: () => _showSemesterDatesPickerDialog(context, start, end),
    );
  }

  Future<void> _showSemesterDatesPickerDialog(
    BuildContext context,
    DateTime? currentStart,
    DateTime? currentEnd,
  ) async {
    final now = DateTime.now();

    final startDate = await showDatePicker(
      context: context,
      initialDate: currentStart ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 2),
      helpText: 'Select semester start date',
    );

    if (startDate != null && context.mounted) {
      final endDate = await showDatePicker(
        context: context,
        initialDate: currentEnd ?? startDate.add(const Duration(days: 120)),
        firstDate: startDate,
        lastDate: DateTime(now.year + 2),
        helpText: 'Select semester end date',
      );

      if (endDate != null) {
        SettingsController.updateSemesterDates(startDate, endDate);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Semester dates set: ${_formatDate(startDate)} - ${_formatDate(endDate)}',
              ),
            ),
          );
        }
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildResetAcademicDataButton(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.refresh_outlined, color: AppColors.warning),
      title: Text(
        'Reset Academic Data',
        style: TextStyle(color: AppColors.warning),
      ),
      subtitle: const Text(
        'Clear all subjects, attendance, exams, and assignments',
      ),
      onTap: () => _showResetAcademicDataDialog(context),
    );
  }

  void _showResetAcademicDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Academic Data?'),
        content: const Text(
          'This will permanently delete all your subjects, attendance records, exams, and assignments. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              Navigator.pop(context);
              _performAcademicDataReset(context);
            },
            child: const Text('Reset All Data'),
          ),
        ],
      ),
    );
  }

  Future<void> _performAcademicDataReset(BuildContext context) async {
    try {
      // Clear all academic data
      await ref.read(subjectRepositoryProvider).clearAll();
      await ref.read(attendanceRepositoryProvider).clearAll();
      await ref.read(assignmentRepositoryProvider).clearAll();
      await ref.read(classSessionRepositoryProvider).clearAll();

      // Clear exams directly via Hive service since no repo yet
      await ref.read(hiveServiceProvider).examBox.clear();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All academic data has been reset successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error resetting data: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  // ── Data Management ────────────────────────────────────────────────────

  Widget _buildExportDataTile(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.copy_all_outlined),
      title: const Text('Export Data to Clipboard'),
      subtitle: const Text('Copy all app data as JSON'),
      onTap: () => _exportDataToClipboard(context),
    );
  }

  Future<void> _exportDataToClipboard(BuildContext context) async {
    try {
      final subjectBox = ref.read(hiveServiceProvider).subjectBox;
      final assignmentBox = ref.read(hiveServiceProvider).assignmentBox;
      final attendanceBox = ref.read(hiveServiceProvider).attendanceBox;
      final classSessionBox = ref.read(hiveServiceProvider).classSessionBox;
      final examBox = ref.read(hiveServiceProvider).examBox;
      final settings = ref.read(settingsProvider);

      final buffer = StringBuffer();
      buffer.writeln('=== Student Companion Backup ===');
      buffer.writeln('Date: ${DateTime.now()}');
      buffer.writeln('\n--- Settings ---');
      buffer.writeln('Name: ${settings.userName}');
      buffer.writeln('Semester: ${settings.currentSemester}');
      buffer.writeln('Attendance Target: ${settings.attendanceTarget}%');

      buffer.writeln('\n--- Subjects ---');
      for (var s in subjectBox.values) {
        buffer.writeln('- ${s.name} (${s.professorName})');
      }

      buffer.writeln('\n--- Assignments ---');
      for (var a in assignmentBox.values) {
        buffer.writeln(
          '- [${a.isCompleted ? "x" : " "}] ${a.title} (Due: ${a.deadline})',
        );
      }

      buffer.writeln('\n--- Exams ---');
      for (var e in examBox.values) {
        buffer.writeln('- ${e.title} (${e.date}) @ ${e.location}');
      }

      buffer.writeln('\n--- Attendance Records ---');
      for (var rec in attendanceBox.values) {
        buffer.writeln(
          '- Subject ID ${rec.subjectId}: ${rec.date.toIso8601String().split("T")[0]} - ${rec.status.name}',
        );
      }

      buffer.writeln('\n--- Class Sessions ---');
      for (var s in classSessionBox.values) {
        buffer.writeln(
          '- Subject ID ${s.subjectId}: Day ${s.dayOfWeek} @ ${s.startTime}',
        );
      }

      await Clipboard.setData(ClipboardData(text: buffer.toString()));

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data copied to clipboard!')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Export failed: $e')));
      }
    }
  }

  Widget _buildClearDataButton(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.delete_outline, color: AppColors.error),
      title: Text('Clear All Data', style: TextStyle(color: AppColors.error)),
      subtitle: const Text('Permanently delete all app data'),
      onTap: () => _showClearDataDialog(context),
    );
  }

  void _showClearDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data?'),
        content: const Text(
          'This will permanently delete ALL your data including settings, subjects, attendance, exams, and assignments. This action cannot be undone!\n\nAre you absolutely sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              Navigator.pop(context);
              _showConfirmClearDataDialog(context);
            },
            child: const Text('Yes, Clear All'),
          ),
        ],
      ),
    );
  }

  void _showConfirmClearDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Final Confirmation'),
        content: const Text(
          'This is your last chance. All data will be permanently deleted. Type "DELETE" to confirm.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              Navigator.pop(context);
              _performFullDataClear(context);
            },
            child: const Text('Delete Forever'),
          ),
        ],
      ),
    );
  }

  Future<void> _performFullDataClear(BuildContext context) async {
    try {
      // 1. Reset all academic data first
      await _performAcademicDataReset(context);

      // 2. Reset Settings
      await SettingsController.resetToDefaults();

      // 3. Reset Theme
      await ThemeController.setThemeMode(ThemeMode.system);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('App has been completely reset to factory defaults'),
            backgroundColor: AppColors.success,
            duration: Duration(seconds: 4),
          ),
        );

        // Navigate to home to refresh state
        context.go('/');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error clearing data: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Widget _buildBackupRestorePlaceholder(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.cloud_upload_outlined),
      title: const Text('Backup & Restore'),
      subtitle: const Text('Coming soon'),
      enabled: false,
    );
  }

  // ── About ──────────────────────────────────────────────────────────────

  Widget _buildAboutTiles(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.info_outlined),
          title: const Text('Version'),
          subtitle: Text(_appVersion.isNotEmpty ? _appVersion : 'Loading...'),
        ),
        const ListTile(
          leading: Icon(Icons.person_outlined),
          title: Text('Developer'),
          subtitle: Text('Student Companion Team'),
        ),
        const ListTile(
          leading: Icon(Icons.description_outlined),
          title: Text('About'),
          subtitle: Text(
            'A comprehensive productivity app for students to manage timetables, assignments, exams, and attendance tracking.',
          ),
        ),
      ],
    );
  }
}

// ── Helper class for accent color options ──────────────────────────────────
class _AccentColorOption {
  final String name;
  final Color displayColor;
  final int? colorInt; // null means "default / Indigo"

  const _AccentColorOption(this.name, this.displayColor, this.colorInt);
}
