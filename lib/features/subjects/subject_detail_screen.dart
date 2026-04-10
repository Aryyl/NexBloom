import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../data/models/attendance_record.dart';
import '../../../data/models/subject.dart';
import '../../../data/models/settings.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../domain/providers/providers.dart';
import '../../../features/attendance/attendance_provider.dart';
import '../../../core/constants/colors.dart';

class SubjectDetailScreen extends ConsumerWidget {
  final String subjectId;

  const SubjectDetailScreen({super.key, required this.subjectId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subjects = ref.watch(subjectsProvider).value ?? [];
    final subject = subjects.firstWhere(
      (s) => s.id == subjectId,
      orElse: () => Subject(
        id: 'error',
        name: 'Unknown Subject',
        professorName: '',
        roomNumber: '',
        colorValue: Colors.grey.toARGB32(),
      ),
    );

    if (subject.id == 'error') {
      return Scaffold(
        appBar: AppBar(title: const Text('Subject Details')),
        body: const Center(child: Text('Subject not found')),
      );
    }

    final attendanceList = ref.watch(attendanceStateProvider);
    final subjectRecords = attendanceList
        .where((a) => a.subjectId == subjectId)
        .toList();

    final percentage = ref
        .read(attendanceStateProvider.notifier)
        .getSubjectPercentage(subjectId);
    final totalClasses = subjectRecords.length;
    final attendedClasses = subjectRecords
        .where((r) => r.status == AttendanceStatus.present)
        .length;

    // Get Target Percentage from Settings
    final settingsBox = Hive.box<AppSettings>('settings');
    final settings = settingsBox.get('settings');
    final targetPercentage = (settings?.attendanceTarget ?? 75).toDouble();

    return Scaffold(
      appBar: AppBar(
        title: Text(subject.name),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'reset') {
                _confirmReset(context, ref);
              } else if (value == 'delete') {
                _confirmDelete(context, ref);
              } else if (value == 'edit') {
                context.push('/subject/edit', extra: subject);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'edit', child: Text('Edit Subject')),
              const PopupMenuItem(
                value: 'reset',
                child: Text('Reset Attendance'),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Text(
                  'Delete Subject',
                  style: TextStyle(color: AppColors.error),
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderCard(context, subject),
            const SizedBox(height: 16),
            _buildAttendanceCard(
              context,
              percentage,
              totalClasses,
              attendedClasses,
              targetPercentage,
            ),
            const SizedBox(height: 16),
            _buildInsightsCard(
              context,
              percentage,
              totalClasses,
              attendedClasses,
              targetPercentage,
            ),
            const SizedBox(height: 24),
            const SizedBox(height: 24),
            _buildHistoryList(context, subjectRecords),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context, Subject subject) {
    return Card(
      elevation: 0,
      color: Color(subject.colorValue).withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Color(subject.colorValue).withValues(alpha: 0.2),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Color(subject.colorValue).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  subject.name.isNotEmpty ? subject.name[0].toUpperCase() : '?',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(subject.colorValue),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subject.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (subject.professorName.isNotEmpty)
                    Text(
                      'Prof. ${subject.professorName}',
                      style: TextStyle(
                        color: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                      ),
                    ),
                  if (subject.roomNumber.isNotEmpty)
                    Text(
                      'Room: ${subject.roomNumber}',
                      style: TextStyle(
                        color: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceCard(
    BuildContext context,
    double percentage,
    int totalClasses,
    int attendedClasses,
    double target,
  ) {
    final isSafe = percentage >= target;
    final color = isSafe ? AppColors.success : AppColors.error;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Attendance',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${percentage.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    Text(
                      '$attendedClasses / $totalClasses Classes',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
                SizedBox(
                  width: 80,
                  height: 80,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: totalClasses == 0 ? 0 : percentage / 100,
                        backgroundColor: Colors.grey[200],
                        color: color,
                        strokeWidth: 8,
                      ),
                      Icon(
                        isSafe
                            ? Icons.check_circle
                            : Icons.warning_amber_rounded,
                        color: color,
                        size: 32,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightsCard(
    BuildContext context,
    double currentPercent,
    int totalClasses,
    int attendedClasses,
    double target,
  ) {
    if (totalClasses == 0) return const SizedBox.shrink();

    String message = '';
    IconData icon = Icons.info_outline;
    Color color = AppColors.primary;

    if (currentPercent >= target) {
      // Calculate how many you can miss
      // (P) / (T + X) >= target/100
      // 100P >= target(T+X)
      // 100P >= target*T + target*X
      // 100P - target*T >= target*X
      // X <= (100P - target*T) / target

      final p = attendedClasses;
      final t = totalClasses;
      final x = ((100 * p - target * t) / target).floor();

      if (x > 0) {
        message = 'You can miss $x classes and stay above ${target.toInt()}%';
        icon = Icons.check_circle_outline;
        color = AppColors.success;
      } else {
        message = 'You are on track! Keep it up.';
        icon = Icons.thumb_up_outlined;
        color = AppColors.success;
      }
    } else {
      // Calculate how many to attend
      // (P + Y) / (T + Y) >= target/100
      // 100(P+Y) >= target(T+Y)
      // 100P + 100Y >= target*T + target*Y
      // 100Y - target*Y >= target*T - 100P
      // Y(100 - target) >= target*T - 100P
      // Y >= (target*T - 100P) / (100 - target)

      final p = attendedClasses;
      final t = totalClasses;
      final numerator = (target * t) - (100 * p);
      final denominator = 100 - target;

      if (denominator > 0) {
        final y = (numerator / denominator).ceil();
        if (y > 0) {
          message = 'Attend $y more classes to reach ${target.toInt()}%';
          icon = Icons.warning_amber_rounded;
          color = AppColors.warning; // Or error
        } else {
          message = 'You are close to the target!';
        }
      }
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: color.withValues(alpha: 0.8),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList(
    BuildContext context,
    List<AttendanceRecord> records,
  ) {
    // Sort descending (newest first)
    final history = List<AttendanceRecord>.from(records)
      ..sort((a, b) => b.date.compareTo(a.date));

    if (history.isEmpty) {
      return const Center(child: Text('No attendance history yet.'));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('History', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: history.length > 5 ? 5 : history.length, // Show last 5
          itemBuilder: (context, index) {
            final entry = history[index];
            final isPresent = entry.status == AttendanceStatus.present;

            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                isPresent
                    ? Icons.check_circle
                    : (entry.status == AttendanceStatus.absent
                          ? Icons.cancel
                          : Icons.holiday_village),
                color: isPresent
                    ? AppColors.success
                    : (entry.status == AttendanceStatus.absent
                          ? AppColors.error
                          : Colors.blue),
                size: 20,
              ),
              title: Text(
                DateFormat('MMM d, y • h:mm a').format(entry.date),
                style: const TextStyle(fontSize: 14),
              ),
              trailing: Text(
                entry.status.name.toUpperCase(),
                style: TextStyle(
                  color: isPresent
                      ? AppColors.success
                      : (entry.status == AttendanceStatus.absent
                            ? AppColors.error
                            : Colors.blue),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  void _confirmReset(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Attendance?'),
        content: const Text(
          'This will clear all attendance history for this subject. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref
                  .read(attendanceStateProvider.notifier)
                  .resetAttendance(subjectId);
              Navigator.pop(context);
            },
            child: const Text(
              'Reset',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Subject?'),
        content: const Text(
          'This will permanently delete the subject and ALL associated data (assignments, exams, attendance, timetable). This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog

              // Perform Cascade Delete
              // 1. Attendance
              await ref
                  .read(attendanceStateProvider.notifier)
                  .resetAttendance(subjectId);

              // 2. Assignments
              await ref
                  .read(assignmentRepositoryProvider)
                  .deleteBySubject(subjectId);

              // 3. Class Sessions
              await ref
                  .read(classSessionRepositoryProvider)
                  .deleteBySubject(subjectId);

              // 4. Exams (Direct Box Access as no Repo)
              final hiveService = ref.read(hiveServiceProvider);
              final examsToDelete = hiveService.examBox.values
                  .where((e) => e.subjectId == subjectId)
                  .toList();
              for (var e in examsToDelete) {
                await hiveService.examBox.delete(e.id);
                // Also cancel notification? assignment/session repos handle it. Exams logic is inside exam creation?
                // Exam notification cancel logic is missing here but acceptable for now.
                // Ideally ref.read(notificationServiceProvider).cancelExamReminder(e.id);
                ref
                    .read(notificationServiceProvider)
                    .cancelNotification(e.id.hashCode);
              }

              // 5. Subject itself
              await ref
                  .read(subjectRepositoryProvider)
                  .deleteSubject(subjectId);

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Subject deleted successfully')),
                );
                context.go('/'); // Return to Dashboard
              }
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
