import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/models/study_plan_model.dart';

class StudyDayCard extends StatelessWidget {
  final StudyDay day;
  final int dayIndex;
  final VoidCallback onToggle;
  final Function(int) onTopicToggle;

  const StudyDayCard({
    super.key,
    required this.day,
    required this.dayIndex,
    required this.onToggle,
    required this.onTopicToggle,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isToday = _isToday(day.date);
    final isPast = day.date.isBefore(
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day),
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: day.completed
            ? cs.primary.withValues(alpha: 0.06)
            : isToday
            ? cs.primaryContainer.withValues(alpha: 0.5)
            : cs.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(16),
        border: isToday
            ? Border.all(color: cs.primary.withValues(alpha: 0.4), width: 1.5)
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onToggle,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Completion checkbox
                GestureDetector(
                  onTap: onToggle,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: day.completed ? cs.primary : Colors.transparent,
                      border: Border.all(
                        color: day.completed
                            ? cs.primary
                            : cs.outline.withValues(alpha: 0.5),
                        width: 2,
                      ),
                    ),
                    child: day.completed
                        ? const Icon(Icons.check, size: 16, color: Colors.white)
                        : null,
                  ),
                ),
                const SizedBox(width: 14),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            DateFormat('EEE, MMM d').format(day.date),
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              color: day.completed
                                  ? cs.onSurface.withValues(alpha: 0.4)
                                  : cs.onSurface,
                              decoration: day.completed
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                          if (isToday) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: cs.primary,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'TODAY',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                          if (day.isRevision) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.amber.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'REVISION',
                                style: TextStyle(
                                  color: Colors.amber[800],
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                          if (isPast && !day.completed && !isToday) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'MISSED',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: day.topics.asMap().entries.map((entry) {
                          final idx = entry.key;
                          final topic = entry.value;

                          // Safely handle backward compatibility if topicCompleted is empty
                          final bool isTopicDone =
                              (day.topicCompleted.length > idx)
                              ? day.topicCompleted[idx]
                              : false;

                          final isVisualDone = day.completed || isTopicDone;

                          return GestureDetector(
                            onTap: () => onTopicToggle(idx),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: day.isRevision
                                    ? Colors.amber.withValues(
                                        alpha: isVisualDone ? 0.05 : 0.15,
                                      )
                                    : isVisualDone
                                    ? cs.primary.withValues(alpha: 0.04)
                                    : cs.primary.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(10),
                                border: isVisualDone
                                    ? Border.all(
                                        color: cs.outline.withValues(
                                          alpha: 0.3,
                                        ),
                                      )
                                    : null,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (isVisualDone) ...[
                                    Icon(
                                      Icons.check_circle,
                                      size: 14,
                                      color: day.isRevision
                                          ? Colors.amber.withValues(alpha: 0.5)
                                          : cs.primary.withValues(alpha: 0.5),
                                    ),
                                    const SizedBox(width: 4),
                                  ],
                                  Text(
                                    topic,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: isVisualDone
                                          ? FontWeight.normal
                                          : FontWeight.w600,
                                      color: isVisualDone
                                          ? cs.onSurface.withValues(alpha: 0.4)
                                          : (day.isRevision
                                                ? Colors.amber[900]
                                                : cs.primary),
                                      decoration: isVisualDone
                                          ? TextDecoration.lineThrough
                                          : null,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }
}
