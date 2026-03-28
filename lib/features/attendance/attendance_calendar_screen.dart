import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../data/models/attendance_record.dart';
import '../../data/models/subject.dart';
import '../../domain/providers/providers.dart';
import 'attendance_provider.dart';
import 'widgets/mark_attendance_sheet.dart';
import 'attendance_report_screen.dart';

class AttendanceCalendarScreen extends ConsumerStatefulWidget {
  const AttendanceCalendarScreen({super.key});

  @override
  ConsumerState<AttendanceCalendarScreen> createState() =>
      _AttendanceCalendarScreenState();
}

class _AttendanceCalendarScreenState
    extends ConsumerState<AttendanceCalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  String? _selectedSubjectFilter; // null means 'All Subjects'

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subjectsAsync = ref.watch(subjectsProvider);
    final attendanceRecords = ref.watch(attendanceStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AttendanceReportScreen(),
                ),
              );
            },
            tooltip: 'Monthly Report',
          ),
        ],
      ),
      body: subjectsAsync.when(
        data: (subjects) {
          if (subjects.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.library_books,
                    size: 64,
                    color: theme.colorScheme.primary.withAlpha(128),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No subjects found.',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  const Text('Add subjects in Settings to track attendance.'),
                ],
              ),
            );
          }

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildSubjectFilter(subjects, theme)),
              SliverToBoxAdapter(
                child: _buildCalendar(attendanceRecords, subjects, theme),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text('Summary', style: theme.textTheme.titleLarge),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 8)),
              if (_selectedSubjectFilter == null)
                SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    return _buildSubjectSummaryCard(subjects[index], theme);
                  }, childCount: subjects.length),
                )
              else
                SliverToBoxAdapter(
                  child: _buildSubjectSummaryCard(
                    subjects.firstWhere((s) => s.id == _selectedSubjectFilter),
                    theme,
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildSubjectFilter(List<Subject> subjects, ThemeData theme) {
    return SizedBox(
      height: 60,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: const Text('All Subjects'),
              selected: _selectedSubjectFilter == null,
              onSelected: (selected) {
                if (selected) setState(() => _selectedSubjectFilter = null);
              },
            ),
          ),
          ...subjects.map((subject) {
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: ChoiceChip(
                label: Text(subject.name),
                selected: _selectedSubjectFilter == subject.id,
                onSelected: (selected) {
                  setState(() {
                    _selectedSubjectFilter = selected ? subject.id : null;
                  });
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCalendar(
    List<AttendanceRecord> records,
    List<Subject> subjects,
    ThemeData theme,
  ) {
    return Card(
      margin: const EdgeInsets.all(16.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TableCalendar(
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: _focusedDay,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          calendarFormat: CalendarFormat.month,
          availableCalendarFormats: const {CalendarFormat.month: 'Month'},
          headerStyle: const HeaderStyle(
            titleCentered: true,
            formatButtonVisible: false,
          ),
          daysOfWeekStyle: DaysOfWeekStyle(
            weekdayStyle: theme.textTheme.bodySmall!.copyWith(
              fontWeight: FontWeight.bold,
            ),
            weekendStyle: theme.textTheme.bodySmall!.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          calendarStyle: CalendarStyle(
            todayDecoration: BoxDecoration(
              color: theme.colorScheme.primary.withAlpha(128),
              shape: BoxShape.circle,
            ),
            selectedDecoration: BoxDecoration(
              color: theme.colorScheme.primary,
              shape: BoxShape.circle,
            ),
            markersMaxCount: 4,
          ),
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
            _showMarkAttendanceSheet(context, selectedDay, subjects);
          },
          onPageChanged: (focusedDay) {
            _focusedDay = focusedDay;
          },
          calendarBuilders: CalendarBuilders(
            markerBuilder: (context, date, events) {
              // Filter records for this day
              var dayRecords = records.where((r) => isSameDay(r.date, date));

              if (_selectedSubjectFilter != null) {
                dayRecords = dayRecords.where(
                  (r) => r.subjectId == _selectedSubjectFilter,
                );
              }

              if (dayRecords.isEmpty) return const SizedBox();

              return Positioned(
                bottom: 1,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: dayRecords.take(4).map((record) {
                    Color dotColor;
                    switch (record.status) {
                      case AttendanceStatus.present:
                        dotColor = Colors.green;
                        break;
                      case AttendanceStatus.absent:
                        dotColor = Colors.red;
                        break;
                      case AttendanceStatus.holiday:
                        dotColor = Colors.grey;
                        break;
                    }
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 1.5),
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: dotColor,
                        shape: BoxShape.circle,
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSubjectSummaryCard(Subject subject, ThemeData theme) {
    final pct = ref
        .read(attendanceStateProvider.notifier)
        .getSubjectPercentage(subject.id);
    final target =
        75.0; // Hardcoded default target as Subject model doesn't have targetAttendance by default

    Color progressColor;
    if (pct >= target) {
      progressColor = Colors.green;
    } else if (pct >= target - 10) {
      progressColor = Colors.orange;
    } else {
      progressColor = Colors.red;
    }

    // Get specific counts for the UI
    final records = ref
        .read(attendanceStateProvider)
        .where((r) => r.subjectId == subject.id);
    final presentCount = records
        .where((r) => r.status == AttendanceStatus.present)
        .length;
    final absentCount = records
        .where((r) => r.status == AttendanceStatus.absent)
        .length;
    final holidayCount = records
        .where((r) => r.status == AttendanceStatus.holiday)
        .length;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  subject.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${pct.toStringAsFixed(1)}%',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: progressColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: records.isEmpty ? 0 : pct / 100,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              color: progressColor,
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatSpan('Present', presentCount, Colors.green),
                _buildStatSpan('Absent', absentCount, Colors.red),
                _buildStatSpan('Holiday', holidayCount, Colors.grey),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatSpan(String label, int value, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text('$label: $value', style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  void _showMarkAttendanceSheet(
    BuildContext context,
    DateTime selectedDate,
    List<Subject> subjects,
  ) {
    if (selectedDate.isAfter(DateTime.now())) {
      // Future date hint
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot mark attendance for future dates.'),
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return MarkAttendanceSheet(date: selectedDate, allSubjects: subjects);
      },
    );
  }
}
