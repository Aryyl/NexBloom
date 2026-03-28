import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/study_plan_model.dart';
import 'study_planner_provider.dart';
import 'widgets/study_day_card.dart';
import 'widgets/risk_indicator.dart';
import 'study_planner_logic.dart';

class PlanDetailScreen extends ConsumerWidget {
  final StudyPlan plan;
  const PlanDetailScreen({super.key, required this.plan});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch for live updates
    final plansAsync = ref.watch(studyPlannerProvider);

    // Get the latest version of this plan
    final currentPlan = plansAsync.whenData((plans) {
      try {
        return plans.firstWhere((p) => p.id == plan.id);
      } catch (_) {
        return plan;
      }
    });

    return currentPlan.when(
      data: (livePlan) => _buildContent(context, ref, livePlan),
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    StudyPlan livePlan,
  ) {
    final cs = Theme.of(context).colorScheme;
    final daysLeft = livePlan.daysLeft;
    final totalRequired = livePlan.totalRequiredHours;
    final totalAvailable = daysLeft * livePlan.dailyStudyHours;

    // Determine risk
    RiskLevel riskLevel;
    String riskMessage;

    if (daysLeft <= 0) {
      riskLevel = RiskLevel.critical;
      riskMessage = 'Exam date has passed or is today.';
    } else if (totalAvailable < totalRequired) {
      riskLevel = RiskLevel.critical;
      riskMessage = 'Not enough time remaining!';
    } else if (daysLeft < livePlan.chapters.length) {
      riskLevel = RiskLevel.high;
      riskMessage = 'Fewer days than chapters.';
    } else if (totalAvailable < totalRequired * 1.3) {
      riskLevel = RiskLevel.tight;
      riskMessage = 'Tight schedule.';
    } else {
      riskLevel = RiskLevel.none;
      riskMessage = 'On track!';
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(livePlan.subject),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) async {
              switch (value) {
                case 'tasks':
                  final count = await ref
                      .read(studyPlannerProvider.notifier)
                      .convertToTasks(livePlan.id);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Created $count tasks'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                  break;
                case 'regenerate':
                  await ref
                      .read(studyPlannerProvider.notifier)
                      .regeneratePlan(livePlan.id);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Plan regenerated'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                  break;
                case 'delete':
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Delete Plan?'),
                      content: const Text(
                        'This will permanently delete this study plan.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('Cancel'),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          style: FilledButton.styleFrom(
                            backgroundColor: cs.error,
                          ),
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    await ref
                        .read(studyPlannerProvider.notifier)
                        .deletePlan(livePlan.id);
                    if (context.mounted) context.pop();
                  }
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'tasks',
                child: ListTile(
                  leading: Icon(Icons.task_alt),
                  title: Text('Convert to Tasks'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'regenerate',
                child: ListTile(
                  leading: Icon(Icons.refresh),
                  title: Text('Regenerate'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: ListTile(
                  leading: Icon(Icons.delete_outline, color: cs.error),
                  title: Text('Delete', style: TextStyle(color: cs.error)),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // Stats header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Column(
                children: [
                  // Stats row
                  Row(
                    children: [
                      _StatBox(
                        icon: Icons.calendar_today,
                        value: '$daysLeft',
                        label: 'Days Left',
                        color: cs.primary,
                      ),
                      const SizedBox(width: 10),
                      _StatBox(
                        icon: Icons.access_time,
                        value: '$totalRequired h',
                        label: 'Required',
                        color: Colors.orange,
                      ),
                      const SizedBox(width: 10),
                      _StatBox(
                        icon: Icons.battery_charging_full,
                        value: '${totalAvailable > 0 ? totalAvailable : 0} h',
                        label: 'Available',
                        color: Colors.green,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Progress
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHighest.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Progress',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: cs.onSurface.withValues(alpha: 0.7),
                              ),
                            ),
                            Text(
                              '${livePlan.completedDays}/${livePlan.studyDays.length} days',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: cs.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: livePlan.progress,
                            minHeight: 8,
                            backgroundColor: cs.outline.withValues(alpha: 0.2),
                            valueColor: AlwaysStoppedAnimation(cs.primary),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Risk Indicator
                  RiskIndicator(riskLevel: riskLevel, message: riskMessage),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Daily Schedule',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
          // Day list
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final day = livePlan.studyDays[index];
                return StudyDayCard(
                  day: day,
                  dayIndex: index,
                  onToggle: () {
                    ref
                        .read(studyPlannerProvider.notifier)
                        .toggleDayComplete(livePlan.id, index);
                  },
                  onTopicToggle: (topicIndex) {
                    ref
                        .read(studyPlannerProvider.notifier)
                        .toggleTopicComplete(livePlan.id, index, topicIndex);
                  },
                );
              }, childCount: livePlan.studyDays.length),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatBox({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: cs.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
