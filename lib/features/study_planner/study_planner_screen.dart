import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../data/models/study_plan_model.dart';
import 'study_planner_provider.dart';

class StudyPlannerScreen extends ConsumerWidget {
  const StudyPlannerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plansAsync = ref.watch(studyPlannerProvider);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Study Planner'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/study-planner/create'),
        icon: const Icon(Icons.add),
        label: const Text('New Plan'),
      ),
      body: plansAsync.when(
        data: (plans) {
          if (plans.isEmpty) {
            return _EmptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            itemCount: plans.length,
            itemBuilder: (context, index) {
              final plan = plans[index];
              return _PlanCard(plan: plan)
                  .animate()
                  .fadeIn(
                    delay: Duration(milliseconds: 50 * index),
                    duration: 400.ms,
                  )
                  .slideY(begin: 0.1);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text('Error: $e', style: TextStyle(color: cs.error)),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: cs.primaryContainer.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.auto_stories_outlined,
                size: 56,
                color: cs.primary.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Study Plans Yet',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Create a smart study plan to organize\nyour exam preparation efficiently.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: cs.onSurface.withValues(alpha: 0.55),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => context.push('/study-planner/create'),
              icon: const Icon(Icons.add),
              label: const Text('Create Plan'),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 500.ms).scale(begin: const Offset(0.95, 0.95));
  }
}

class _PlanCard extends ConsumerWidget {
  final StudyPlan plan;
  const _PlanCard({required this.plan});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final daysLeft = plan.daysLeft;
    final progress = plan.progress;

    Color statusColor;
    String statusText;

    if (plan.isCompleted) {
      statusColor = Colors.green;
      statusText = 'Completed ✓';
    } else if (daysLeft < 0) {
      statusColor = Colors.red;
      statusText = 'Exam passed';
    } else if (daysLeft == 0) {
      statusColor = Colors.red;
      statusText = 'Exam today!';
    } else if (daysLeft <= 3) {
      statusColor = Colors.orange;
      statusText = '$daysLeft days left';
    } else {
      statusColor = cs.primary;
      statusText = '$daysLeft days left';
    }

    return GestureDetector(
      onTap: () => context.push('/study-planner/detail', extra: plan),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: cs.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.auto_stories, color: cs.primary, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        plan.subject,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Exam: ${DateFormat('MMM d, yyyy').format(plan.examDate)}',
                        style: TextStyle(
                          color: cs.onSurface.withValues(alpha: 0.55),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            // Progress bar
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 6,
                      backgroundColor: cs.outline.withValues(alpha: 0.2),
                      valueColor: AlwaysStoppedAnimation(statusColor),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${(progress * 100).toInt()}%',
                  style: TextStyle(
                    color: cs.onSurface.withValues(alpha: 0.6),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Info chips
            Row(
              children: [
                _InfoChip(
                  icon: Icons.book_outlined,
                  label: '${plan.chapters.length} chapters',
                ),
                const SizedBox(width: 10),
                _InfoChip(
                  icon: Icons.schedule,
                  label: '${plan.dailyStudyHours}h/day',
                ),
                const SizedBox(width: 10),
                _InfoChip(
                  icon: Icons.calendar_today_outlined,
                  label: '${plan.studyDays.length} days',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: cs.onSurface.withValues(alpha: 0.45)),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: cs.onSurface.withValues(alpha: 0.55),
          ),
        ),
      ],
    );
  }
}
