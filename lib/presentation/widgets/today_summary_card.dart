import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:studentcompanionapp/domain/providers/providers.dart';
import '../../features/attendance/attendance_provider.dart';
import 'modern_card.dart';

class TodaySummaryCard extends ConsumerWidget {
  const TodaySummaryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assignmentsAsync = ref.watch(assignmentsProvider);
    final sessionsAsync = ref.watch(classSessionsProvider);
    final attendanceRecords = ref.watch(attendanceStateProvider);

    return ModernCard(
      padding: EdgeInsets.zero,
      gradient: const LinearGradient(
        colors: [Color(0xFF6366F1), Color(0xFF14B8A6)], // Indigo to Teal
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Today\'s Overview',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('MMMM d, yyyy').format(DateTime.now()),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.insights,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                _buildStatItem(
                  context,
                  label: 'Pending',
                  value: assignmentsAsync.when(
                    data: (data) =>
                        data.where((a) => !a.isCompleted).length.toString(),
                    loading: () => '-',
                    error: (_, __) => '-',
                  ),
                  icon: Icons.assignment_outlined,
                ),
                _buildDivider(),
                _buildStatItem(
                  context,
                  label: 'Classes',
                  value: sessionsAsync.when(
                    data: (data) {
                      final today = DateTime.now().weekday;
                      return data
                          .where((s) => s.dayOfWeek == today)
                          .length
                          .toString();
                    },
                    loading: () => '-',
                    error: (_, __) => '-',
                  ),
                  icon: Icons.class_outlined,
                ),
                _buildDivider(),
                _buildStatItem(
                  context,
                  label: 'Attendance',
                  value: attendanceRecords.isEmpty
                      ? '0%'
                      : '${ref.read(attendanceStateProvider.notifier).getOverallPercentage().toStringAsFixed(0)}%',
                  icon: Icons.check_circle_outlined,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white.withValues(alpha: 0.8), size: 16),
              const SizedBox(width: 4),
              Text(
                value,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 30,
      width: 1,
      color: Colors.white.withValues(alpha: 0.3),
    );
  }
}
