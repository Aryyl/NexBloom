import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/colors.dart';

class QuickActionsBar extends StatelessWidget {
  const QuickActionsBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _ActionButton(
            icon: Icons.add_task,
            label: 'Add Task',
            color: AppColors.primary,
            onTap: () => context.push('/assignments/add'),
          ),
          const SizedBox(width: 12),
          _ActionButton(
            icon: Icons.post_add,
            label: 'Add Class',
            color: AppColors.secondary,
            // Need to decide where to go. '/timetable/add_class' or 'add_subject'
            // Add Class requires selecting day. Usually adds to timetable.
            // Let's go to '/timetable' for now or '/timetable/add_class?day=1'
            onTap: () => context.push(
              '/timetable/add_class?day=${DateTime.now().weekday}',
            ),
          ),
          const SizedBox(width: 12),
          _ActionButton(
            icon: Icons.notification_add,
            label: 'Add Exam',
            color: AppColors.error, // or orange
            onTap: () => context.push('/exams/add'),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
