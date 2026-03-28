import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../data/models/attendance_record.dart';
import '../../../data/models/subject.dart';
import '../../../domain/providers/providers.dart';
import '../attendance_provider.dart';

class MarkAttendanceSheet extends ConsumerStatefulWidget {
  final DateTime date;
  final List<Subject> allSubjects;

  const MarkAttendanceSheet({
    super.key,
    required this.date,
    required this.allSubjects,
  });

  @override
  ConsumerState<MarkAttendanceSheet> createState() =>
      _MarkAttendanceSheetState();
}

class _MarkAttendanceSheetState extends ConsumerState<MarkAttendanceSheet> {
  // Map of subjectId to selected status
  final Map<String, AttendanceStatus> _selections = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill existing records
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final records = ref.read(attendanceStateProvider);

      for (var subject in widget.allSubjects) {
        final existing = records
            .where(
              (r) =>
                  r.subjectId == subject.id &&
                  r.date.year == widget.date.year &&
                  r.date.month == widget.date.month &&
                  r.date.day == widget.date.day,
            )
            .firstOrNull;

        if (existing != null) {
          setState(() {
            _selections[subject.id] = existing.status;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isToday =
        widget.date.year == DateTime.now().year &&
        widget.date.month == DateTime.now().month &&
        widget.date.day == DateTime.now().day;
    final dateStr = isToday
        ? 'Today'
        : DateFormat('MMM d, yyyy').format(widget.date);

    // Filter subjects by timetable if available
    final sessionsAsync = ref.watch(classSessionsProvider);
    List<Subject> displaySubjects = widget.allSubjects;

    sessionsAsync.whenData((sessions) {
      if (sessions.isNotEmpty) {
        // Find which subjects have classes on this weekday
        final weekday = widget.date.weekday;
        final scheduledSubjectIds = sessions
            .where((s) => s.dayOfWeek == weekday)
            .map((s) => s.subjectId)
            .toSet();

        if (scheduledSubjectIds.isNotEmpty) {
          displaySubjects = widget.allSubjects
              .where((s) => scheduledSubjectIds.contains(s.id))
              .toList();
        }
      }
    });

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurfaceVariant.withAlpha(100),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Attendance for $dateStr',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          if (displaySubjects.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32.0),
              child: Center(
                child: Text(
                  'No subjects found.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            )
          else
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: displaySubjects.length,
                itemBuilder: (context, index) {
                  final subject = displaySubjects[index];
                  return _buildSubjectRow(subject, theme);
                },
              ),
            ),

          const SizedBox(height: 24),
          FilledButton(
            onPressed: _isLoading ? null : _saveAttendance,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Save Attendance'),
          ),
          const SizedBox(height: 24), // Bottom padding
        ],
      ),
    );
  }

  Widget _buildSubjectRow(Subject subject, ThemeData theme) {
    final currentStatus = _selections[subject.id];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: Color(subject.colorValue),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  subject.name,
                  style: theme.textTheme.titleMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (currentStatus != null)
                IconButton(
                  icon: const Icon(Icons.clear, size: 20),
                  tooltip: 'Clear selection',
                  onPressed: () {
                    setState(() {
                      _selections.remove(subject.id);
                    });
                  },
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSegment(
                title: 'Present',
                status: AttendanceStatus.present,
                current: currentStatus,
                subjectId: subject.id,
                activeColor: Colors.green,
                theme: theme,
              ),
              const SizedBox(width: 8),
              _buildSegment(
                title: 'Absent',
                status: AttendanceStatus.absent,
                current: currentStatus,
                subjectId: subject.id,
                activeColor: Colors.red,
                theme: theme,
              ),
              const SizedBox(width: 8),
              _buildSegment(
                title: 'Holiday',
                status: AttendanceStatus.holiday,
                current: currentStatus,
                subjectId: subject.id,
                activeColor: Colors.grey,
                theme: theme,
              ),
            ],
          ),
          const Divider(height: 24),
        ],
      ),
    );
  }

  Widget _buildSegment({
    required String title,
    required AttendanceStatus status,
    required AttendanceStatus? current,
    required String subjectId,
    required Color activeColor,
    required ThemeData theme,
  }) {
    final isSelected = current == status;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selections[subjectId] = status;
          });
          HapticFeedback.lightImpact(); // Subtle haptic feedback
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? activeColor.withAlpha(30)
                : theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? activeColor : Colors.transparent,
              width: 1.5,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: TextStyle(
              color: isSelected ? activeColor : theme.colorScheme.onSurface,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  void _saveAttendance() async {
    setState(() => _isLoading = true);

    // Simulate slight delay for premium feel
    await Future.delayed(const Duration(milliseconds: 300));

    final notifier = ref.read(attendanceStateProvider.notifier);

    // In a real scenario with many subjects we'd want to batch this,
    // but Hive handles multiple put ops quite fast anyway.
    for (var entry in _selections.entries) {
      await notifier.markAttendance(entry.key, widget.date, entry.value);
    }

    // If a subject was previously defined for this day but is now cleared, we delete it
    // Wait, we didn't track deletions easily in the UI.
    // A better approach is to delete records that are missing from _selections.
    // Let's grab all current records for this day.
    final currentRecords = ref
        .read(attendanceStateProvider)
        .where(
          (r) =>
              r.date.year == widget.date.year &&
              r.date.month == widget.date.month &&
              r.date.day == widget.date.day,
        );

    for (var record in currentRecords) {
      if (!_selections.containsKey(record.subjectId)) {
        await notifier.undoAttendance(record.subjectId, widget.date);
      }
    }

    if (mounted) {
      setState(() => _isLoading = false);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Attendance saved successfully')),
      );
    }
  }
}
