import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../domain/providers/providers.dart';
import 'attendance_provider.dart';

class AttendanceReportScreen extends ConsumerStatefulWidget {
  const AttendanceReportScreen({super.key});

  @override
  ConsumerState<AttendanceReportScreen> createState() =>
      _AttendanceReportScreenState();
}

class _AttendanceReportScreenState
    extends ConsumerState<AttendanceReportScreen> {
  DateTime _selectedMonth = DateTime.now();
  String? _selectedSubjectId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subjectsAsync = ref.watch(subjectsProvider);
    final monthStr = DateFormat('MMMM yyyy').format(_selectedMonth);

    return Scaffold(
      appBar: AppBar(title: const Text('Monthly Report')),
      body: subjectsAsync.when(
        data: (subjects) {
          if (subjects.isEmpty) {
            return const Center(child: Text('No subjects available.'));
          }

          final summary = ref
              .read(attendanceStateProvider.notifier)
              .getMonthlySummary(_selectedMonth, subjectId: _selectedSubjectId);

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left),
                        onPressed: () {
                          setState(() {
                            _selectedMonth = DateTime(
                              _selectedMonth.year,
                              _selectedMonth.month - 1,
                            );
                          });
                        },
                      ),
                      Text(
                        monthStr,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed: () {
                          setState(() {
                            _selectedMonth = DateTime(
                              _selectedMonth.year,
                              _selectedMonth.month + 1,
                            );
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 60,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: const Text('All Subjects'),
                          selected: _selectedSubjectId == null,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() => _selectedSubjectId = null);
                            }
                          },
                        ),
                      ),
                      ...subjects.map((subject) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ChoiceChip(
                            label: Text(subject.name),
                            selected: _selectedSubjectId == subject.id,
                            onSelected: (selected) {
                              setState(() {
                                _selectedSubjectId = selected
                                    ? subject.id
                                    : null;
                              });
                            },
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildMainStatCard(summary, theme),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildSmallStatCard(
                              'Present',
                              summary.presentCount,
                              Colors.green,
                              theme,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildSmallStatCard(
                              'Absent',
                              summary.absentCount,
                              Colors.red,
                              theme,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildSmallStatCard(
                              'Holiday',
                              summary.holidayCount,
                              Colors.grey,
                              theme,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // We could include a fl_chart line chart here if needed,
              // but the robust data models are the core requirement.
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildMainStatCard(dynamic summary, ThemeData theme) {
    Color trendColor = summary.trend >= 0 ? Colors.green : Colors.red;
    IconData trendIcon = summary.trend >= 0
        ? Icons.trending_up
        : Icons.trending_down;
    String trendText =
        '${summary.trend.abs().toStringAsFixed(1)}% from last month';

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Text(
              'Attendance',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${summary.percentage.toStringAsFixed(1)}%',
              style: theme.textTheme.displayMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            if (summary.totalClasses > 0)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(trendIcon, color: trendColor, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    trendText,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: trendColor,
                    ),
                  ),
                ],
              ),
            if (summary.totalClasses == 0)
              Text('No classes marked yet', style: theme.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallStatCard(
    String title,
    int count,
    Color color,
    ThemeData theme,
  ) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
        child: Column(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(height: 8),
            Text(
              count.toString(),
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
