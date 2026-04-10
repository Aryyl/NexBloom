import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:studentcompanionapp/core/services/widget_service.dart';
import 'package:studentcompanionapp/domain/providers/providers.dart';
import 'package:studentcompanionapp/data/models/assignment.dart';
import 'package:studentcompanionapp/presentation/widgets/empty_state.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ExamsScreen extends ConsumerWidget {
  const ExamsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final examsAsync = ref.watch(examsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Exams')),
      body: examsAsync.when(
        data: (exams) {
          final sorted = List<Exam>.from(exams)
            ..sort((a, b) => a.date.compareTo(b.date));

          if (sorted.isEmpty) {
            return const EmptyState(
              icon: Icons.event_note_outlined,
              title: 'No upcoming exams',
              subtitle: 'Add exams to get reminders and track your schedule.',
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            itemCount: sorted.length,
            itemBuilder: (context, index) {
              final exam = sorted[index];
              return _ExamCard(
                    exam: exam,
                    onDelete: () => _deleteExam(context, ref, exam),
                  )
                  .animate()
                  .fadeIn(delay: (index * 80).ms, duration: 400.ms)
                  .slideY(begin: 0.1);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/exams/add'),
        icon: const Icon(Icons.add),
        label: const Text('Add Exam'),
      ),
    );
  }

  void _deleteExam(BuildContext context, WidgetRef ref, Exam exam) {
    ref.read(hiveServiceProvider).examBox.delete(exam.id);
    WidgetService.updateWidget(); // widget: exam removed
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('"${exam.title}" deleted'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            ref.read(hiveServiceProvider).examBox.put(exam.id, exam);
            WidgetService.updateWidget(); // widget: exam restored
          },
        ),
      ),
    );
  }
}

// ── Exam Card ─────────────────────────────────────────────────────────────────
class _ExamCard extends StatelessWidget {
  final Exam exam;
  final VoidCallback onDelete;

  const _ExamCard({required this.exam, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final daysLeft = exam.date.difference(DateTime.now()).inDays;
    final isPast = daysLeft < 0;

    Color urgencyColor;
    String countdownText;
    IconData countdownIcon;

    if (isPast) {
      urgencyColor = cs.onSurface.withValues(alpha: 0.4);
      countdownText = 'Past';
      countdownIcon = Icons.event_busy_outlined;
    } else if (daysLeft == 0) {
      urgencyColor = Colors.red;
      countdownText = 'Today!';
      countdownIcon = Icons.warning_amber_rounded;
    } else if (daysLeft <= 3) {
      urgencyColor = Colors.red;
      countdownText = '$daysLeft days left';
      countdownIcon = Icons.notifications_active;
    } else if (daysLeft <= 7) {
      urgencyColor = Colors.orange;
      countdownText = '$daysLeft days left';
      countdownIcon = Icons.notifications_outlined;
    } else {
      urgencyColor = cs.primary;
      countdownText = '$daysLeft days left';
      countdownIcon = Icons.event_outlined;
    }

    return Dismissible(
      key: Key(exam.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(20),
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
      confirmDismiss: (_) async {
        onDelete();
        return true;
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest.withValues(
            alpha: isPast ? 0.3 : 0.6,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isPast
                ? cs.outlineVariant.withValues(alpha: 0.2)
                : urgencyColor.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            // Countdown badge
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: urgencyColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(countdownIcon, color: urgencyColor, size: 20),
                  const SizedBox(height: 2),
                  Text(
                    isPast ? 'Done' : (daysLeft == 0 ? '🔥' : '$daysLeft'),
                    style: TextStyle(
                      color: urgencyColor,
                      fontWeight: FontWeight.bold,
                      fontSize: daysLeft == 0 ? 18 : 16,
                    ),
                  ),
                  if (!isPast && daysLeft > 0)
                    Text(
                      'days',
                      style: TextStyle(
                        color: urgencyColor.withValues(alpha: 0.7),
                        fontSize: 10,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exam.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isPast
                          ? cs.onSurface.withValues(alpha: 0.5)
                          : cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 12,
                        color: cs.onSurface.withValues(alpha: 0.5),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('EEE, MMM d • h:mm a').format(exam.date),
                        style: TextStyle(
                          fontSize: 12,
                          color: cs.onSurface.withValues(alpha: 0.55),
                        ),
                      ),
                    ],
                  ),
                  if (exam.location.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 12,
                          color: cs.onSurface.withValues(alpha: 0.5),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          exam.location,
                          style: TextStyle(
                            fontSize: 12,
                            color: cs.onSurface.withValues(alpha: 0.55),
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: urgencyColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      countdownText,
                      style: TextStyle(
                        color: urgencyColor,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.delete_outline,
                color: cs.onSurface.withValues(alpha: 0.3),
                size: 20,
              ),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
