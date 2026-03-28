import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:studentcompanionapp/domain/providers/providers.dart';
import 'package:studentcompanionapp/data/models/assignment.dart';
import 'package:studentcompanionapp/core/constants/colors.dart';

enum _Filter { all, pending, completed, highPriority }

class AssignmentsScreen extends ConsumerStatefulWidget {
  const AssignmentsScreen({super.key});

  @override
  ConsumerState<AssignmentsScreen> createState() => _AssignmentsScreenState();
}

class _AssignmentsScreenState extends ConsumerState<AssignmentsScreen> {
  _Filter _activeFilter = _Filter.all;

  @override
  Widget build(BuildContext context) {
    final assignmentsAsync = ref.watch(assignmentsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Assignments')),
      body: Column(
        children: [
          // ── Filter Chips ─────────────────────────────────────────────
          SizedBox(
            height: 52,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: [
                _FilterChip(
                  label: 'All',
                  selected: _activeFilter == _Filter.all,
                  onTap: () => setState(() => _activeFilter = _Filter.all),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Pending',
                  selected: _activeFilter == _Filter.pending,
                  onTap: () => setState(() => _activeFilter = _Filter.pending),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Completed',
                  selected: _activeFilter == _Filter.completed,
                  onTap: () =>
                      setState(() => _activeFilter = _Filter.completed),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: '🔥 High Priority',
                  selected: _activeFilter == _Filter.highPriority,
                  onTap: () =>
                      setState(() => _activeFilter = _Filter.highPriority),
                ),
              ],
            ),
          ),

          // ── List ─────────────────────────────────────────────────────
          Expanded(
            child: assignmentsAsync.when(
              data: (all) {
                final assignments = List<Assignment>.from(all);

                // Apply filter
                List<Assignment> filtered;
                switch (_activeFilter) {
                  case _Filter.pending:
                    filtered = assignments
                        .where((a) => !a.isCompleted)
                        .toList();
                    break;
                  case _Filter.completed:
                    filtered = assignments.where((a) => a.isCompleted).toList();
                    break;
                  case _Filter.highPriority:
                    filtered = assignments
                        .where(
                          (a) =>
                              a.priority.toLowerCase() == 'high' &&
                              !a.isCompleted,
                        )
                        .toList();
                    break;
                  default:
                    filtered = assignments;
                }

                filtered.sort((a, b) => a.deadline.compareTo(b.deadline));

                if (filtered.isEmpty) {
                  return _buildEmptyState(context);
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final task = filtered[index];
                    return _TaskCard(
                      task: task,
                      onComplete: () => _markComplete(context, ref, task),
                      onDelete: () => _deleteTask(context, ref, task),
                      onTap: () =>
                          context.push('/assignments/edit', extra: task),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/assignments/add'),
        icon: const Icon(Icons.add),
        label: const Text('New Task'),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    String message;
    IconData icon;
    switch (_activeFilter) {
      case _Filter.pending:
        message = 'All caught up! No pending tasks.';
        icon = Icons.task_alt;
        break;
      case _Filter.completed:
        message = 'No completed tasks yet.';
        icon = Icons.check_circle_outline;
        break;
      case _Filter.highPriority:
        message = 'No high priority tasks.';
        icon = Icons.priority_high;
        break;
      default:
        message = 'No assignments yet.\nTap + to add one!';
        icon = Icons.assignment_outlined;
    }
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 64, color: cs.onSurface.withValues(alpha: 0.2)),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: cs.onSurface.withValues(alpha: 0.45),
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  void _markComplete(BuildContext context, WidgetRef ref, Assignment task) {
    ref.read(assignmentRepositoryProvider).toggleCompletion(task.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          task.isCompleted
              ? '"${task.title}" marked as pending'
              : '"${task.title}" completed! ✓',
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _deleteTask(BuildContext context, WidgetRef ref, Assignment task) {
    ref.read(assignmentRepositoryProvider).deleteAssignment(task.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('"${task.title}" deleted'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            // Re-add the assignment
            ref.read(assignmentRepositoryProvider).addAssignment(task);
          },
        ),
      ),
    );
  }
}

// ── Filter Chip ───────────────────────────────────────────────────────────────
class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? cs.primary
              : cs.surfaceContainerHighest.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(20),
          border: selected
              ? null
              : Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected
                ? cs.onPrimary
                : cs.onSurface.withValues(alpha: 0.7),
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

// ── Task Card ─────────────────────────────────────────────────────────────────
class _TaskCard extends StatelessWidget {
  final Assignment task;
  final VoidCallback onComplete;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const _TaskCard({
    required this.task,
    required this.onComplete,
    required this.onDelete,
    required this.onTap,
  });

  Color _priorityColor(String p) {
    switch (p.toLowerCase()) {
      case 'high':
        return AppColors.error;
      case 'medium':
        return Colors.orange;
      default:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final daysLeft = task.deadline.difference(DateTime.now()).inDays;
    final isOverdue = daysLeft < 0;
    final isUrgent = daysLeft <= 1 && !isOverdue;

    Color dueColor = cs.onSurface.withValues(alpha: 0.5);
    if (isOverdue) {
      dueColor = AppColors.error;
    } else if (isUrgent) {
      dueColor = Colors.orange;
    }

    String dueText;
    if (isOverdue) {
      dueText = 'Overdue!';
    } else if (daysLeft == 0) {
      dueText = 'Due today';
    } else if (daysLeft == 1) {
      dueText = 'Due tomorrow';
    } else {
      dueText = 'Due in $daysLeft days';
    }

    return Dismissible(
      key: Key(task.id),
      // Swipe right → complete
      background: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: Colors.green,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        child: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Text(
              'Complete',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      // Swipe left → delete
      secondaryBackground: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              'Delete',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 8),
            Icon(Icons.delete, color: Colors.white),
          ],
        ),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          onComplete();
          return false; // Don't actually dismiss — just toggle
        } else {
          onDelete();
          return true;
        }
      },
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest.withValues(
              alpha: task.isCompleted ? 0.3 : 0.6,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              // Checkbox
              GestureDetector(
                onTap: onComplete,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: task.isCompleted ? Colors.green : Colors.transparent,
                    border: Border.all(
                      color: task.isCompleted
                          ? Colors.green
                          : cs.outlineVariant,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: task.isCompleted
                      ? const Icon(Icons.check, color: Colors.white, size: 14)
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        decoration: task.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                        color: task.isCompleted
                            ? cs.onSurface.withValues(alpha: 0.4)
                            : cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      dueText,
                      style: TextStyle(
                        color: task.isCompleted
                            ? cs.onSurface.withValues(alpha: 0.35)
                            : dueColor,
                        fontSize: 12,
                        fontWeight: isOverdue || isUrgent
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
              // Priority pill
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _priorityColor(task.priority).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  task.priority,
                  style: TextStyle(
                    color: _priorityColor(task.priority),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
