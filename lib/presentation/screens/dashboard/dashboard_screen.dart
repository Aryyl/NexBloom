import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:studentcompanionapp/domain/providers/providers.dart';
import 'package:studentcompanionapp/domain/providers/theme_provider.dart';
import 'package:studentcompanionapp/core/constants/colors.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:studentcompanionapp/presentation/widgets/today_summary_card.dart';
import 'package:studentcompanionapp/data/models/assignment.dart';
import 'package:studentcompanionapp/features/notes/notes_provider.dart';
import 'package:studentcompanionapp/data/models/note_model.dart';
import 'package:studentcompanionapp/features/study_planner/study_planner_provider.dart';
import 'package:studentcompanionapp/data/models/study_plan_model.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assignmentsAsync = ref.watch(assignmentsProvider);
    final examsAsync = ref.watch(examsProvider);
    final sessionsAsync = ref.watch(classSessionsProvider);
    final subjectsAsync = ref.watch(subjectsProvider);
    final notesAsync = ref.watch(notesProvider);
    final settings = ref.watch(settingsProvider);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ── Collapsible App Bar ──────────────────────────────────────
          SliverAppBar(
            expandedHeight: 120,
            floating: true,
            pinned: false,
            snap: true,
            backgroundColor: cs.surface,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getGreeting(),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: cs.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      ),
                      Text(
                        '${settings.userName} 👋',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: cs.onSurface,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => context.push('/settings'),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: cs.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.settings_outlined,
                        color: cs.onPrimaryContainer,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // ── Date ────────────────────────────────────────────────
                Text(
                  DateFormat('EEEE, MMMM d').format(DateTime.now()),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.55),
                  ),
                ).animate().fadeIn(duration: 400.ms),

                if (settings.currentSemester.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: cs.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        settings.currentSemester,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: cs.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ).animate().fadeIn(duration: 400.ms),

                const SizedBox(height: 20),

                // ── Today Summary ────────────────────────────────────────
                const TodaySummaryCard()
                    .animate()
                    .fadeIn(delay: 100.ms, duration: 500.ms)
                    .slideY(begin: 0.15),

                const SizedBox(height: 24),

                // ── Today's Schedule ─────────────────────────────────────
                _SectionHeader(
                  title: "Today's Schedule",
                  onTap: () => context.go('/timetable'),
                ),
                const SizedBox(height: 10),
                _TodayScheduleCard(
                      sessionsAsync: sessionsAsync,
                      subjectsAsync: subjectsAsync,
                    )
                    .animate()
                    .fadeIn(delay: 200.ms, duration: 500.ms)
                    .slideY(begin: 0.15),

                const SizedBox(height: 24),

                // ── Pending Assignments ──────────────────────────────────
                _SectionHeader(
                  title: 'Pending Tasks',
                  onTap: () => context.go('/assignments'),
                ),
                const SizedBox(height: 10),
                _PendingAssignmentsCard(assignmentsAsync: assignmentsAsync)
                    .animate()
                    .fadeIn(delay: 300.ms, duration: 500.ms)
                    .slideY(begin: 0.15),

                const SizedBox(height: 24),

                // ── Next Exam Countdown ──────────────────────────────────
                _SectionHeader(
                  title: 'Next Exam',
                  onTap: () => context.go('/exams'),
                ),
                const SizedBox(height: 10),
                _NextExamCard(examsAsync: examsAsync)
                    .animate()
                    .fadeIn(delay: 400.ms, duration: 500.ms)
                    .slideY(begin: 0.15),

                const SizedBox(height: 24),

                // ── My Notes ──────────────────────────────────────────────
                _SectionHeader(
                  title: 'My Notes',
                  onTap: () => context.push('/notes'),
                ),
                const SizedBox(height: 10),
                _RecentNotesCard(notesAsync: notesAsync)
                    .animate()
                    .fadeIn(delay: 500.ms, duration: 500.ms)
                    .slideY(begin: 0.15),

                const SizedBox(height: 24),

                // ── Study Planner ─────────────────────────────────────────
                _SectionHeader(
                  title: 'Study Planner',
                  onTap: () => context.push('/study-planner'),
                ),
                const SizedBox(height: 10),
                _TodayStudyCard()
                    .animate()
                    .fadeIn(delay: 600.ms, duration: 500.ms)
                    .slideY(begin: 0.15),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Section Header ────────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onTap;
  const _SectionHeader({required this.title, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
        if (onTap != null)
          GestureDetector(
            onTap: onTap,
            child: Text(
              'See all',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }
}

// ── Quick Stats Row ───────────────────────────────────────────────────────────

// ── Today's Schedule Card ─────────────────────────────────────────────────────
class _TodayScheduleCard extends ConsumerWidget {
  final AsyncValue sessionsAsync;
  final AsyncValue subjectsAsync;

  const _TodayScheduleCard({
    required this.sessionsAsync,
    required this.subjectsAsync,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final todayWeekday = DateTime.now().weekday; // 1=Mon

    return sessionsAsync.when(
      data: (sessions) {
        final todaySessions =
            (sessions as List)
                .where((s) => s.dayOfWeek == todayWeekday)
                .toList()
              ..sort((a, b) => a.startTime.compareTo(b.startTime));

        if (todaySessions.isEmpty) {
          return _EmptyCard(
            icon: Icons.free_breakfast_outlined,
            message: 'No classes today — enjoy your day!',
          );
        }

        return Container(
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: todaySessions.asMap().entries.map((entry) {
              final i = entry.key;
              final session = entry.value;
              final subjectIterable = subjectsAsync.value?.where(
                (s) => s.id == session.subjectId,
              );
              final subject =
                  (subjectIterable != null && subjectIterable.isNotEmpty)
                  ? subjectIterable.first
                  : null;
              final subjectColor = subject != null
                  ? Color(subject.colorValue)
                  : cs.primary;
              final isLast = i == todaySessions.length - 1;

              return Container(
                decoration: BoxDecoration(
                  border: isLast
                      ? null
                      : Border(
                          bottom: BorderSide(
                            color: cs.outlineVariant.withValues(alpha: 0.3),
                          ),
                        ),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  leading: Container(
                    width: 4,
                    height: 40,
                    decoration: BoxDecoration(
                      color: subjectColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  title: Text(
                    subject?.name ?? 'Unknown',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  subtitle: Text(
                    '${session.startTime} – ${session.endTime}',
                    style: TextStyle(
                      fontSize: 12,
                      color: cs.onSurface.withValues(alpha: 0.55),
                    ),
                  ),
                  trailing: subject?.roomNumber.isNotEmpty == true
                      ? Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: subjectColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            subject!.roomNumber,
                            style: TextStyle(
                              color: subjectColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                      : null,
                ),
              );
            }).toList(),
          ),
        );
      },
      loading: () => _ShimmerCard(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

// ── Pending Assignments Card ──────────────────────────────────────────────────
class _PendingAssignmentsCard extends ConsumerWidget {
  final AsyncValue assignmentsAsync;
  const _PendingAssignmentsCard({required this.assignmentsAsync});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;

    return assignmentsAsync.when(
      data: (assignments) {
        final pending =
            (assignments as List<Assignment>)
                .where((a) => !a.isCompleted)
                .toList()
              ..sort((a, b) => a.deadline.compareTo(b.deadline));

        if (pending.isEmpty) {
          return _EmptyCard(
            icon: Icons.task_alt,
            message: 'All caught up! No pending tasks.',
          );
        }

        final shown = pending.take(3).toList();

        return Container(
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              ...shown.asMap().entries.map((entry) {
                final i = entry.key;
                final task = entry.value;
                final daysLeft = task.deadline
                    .difference(DateTime.now())
                    .inDays;
                final isOverdue = daysLeft < 0;
                final isUrgent = daysLeft <= 1 && !isOverdue;
                final isLast = i == shown.length - 1 && pending.length <= 3;

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

                return Container(
                  decoration: BoxDecoration(
                    border: isLast
                        ? null
                        : Border(
                            bottom: BorderSide(
                              color: cs.outlineVariant.withValues(alpha: 0.3),
                            ),
                          ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    leading: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: _priorityColor(
                          task.priority,
                        ).withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.assignment_outlined,
                        color: _priorityColor(task.priority),
                        size: 16,
                      ),
                    ),
                    title: Text(
                      task.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      dueText,
                      style: TextStyle(
                        color: dueColor,
                        fontSize: 12,
                        fontWeight: isOverdue || isUrgent
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: _priorityColor(
                          task.priority,
                        ).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
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
                  ),
                );
              }),
              if (pending.length > 3)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    '+${pending.length - 3} more tasks',
                    style: TextStyle(
                      color: cs.primary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
      loading: () => _ShimmerCard(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Color _priorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return AppColors.error;
      case 'medium':
        return Colors.orange;
      default:
        return Colors.green;
    }
  }
}

// ── Next Exam Card ────────────────────────────────────────────────────────────
class _NextExamCard extends ConsumerWidget {
  final AsyncValue examsAsync;
  const _NextExamCard({required this.examsAsync});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;

    return examsAsync.when(
      data: (exams) {
        final upcoming =
            (exams as List)
                .where((e) => e.date.isAfter(DateTime.now()))
                .toList()
              ..sort((a, b) => a.date.compareTo(b.date));

        if (upcoming.isEmpty) {
          return _EmptyCard(
            icon: Icons.event_available_outlined,
            message: 'No upcoming exams scheduled.',
          );
        }

        final exam = upcoming.first;
        final daysLeft = exam.date.difference(DateTime.now()).inDays;
        final isUrgent = daysLeft <= 3;
        final urgentColor = daysLeft == 0
            ? Colors.red
            : daysLeft <= 3
            ? Colors.orange
            : cs.primary;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [urgentColor.withValues(alpha: 0.8), urgentColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.notifications_active,
                          color: Colors.white70,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isUrgent ? 'Coming up soon!' : 'Upcoming',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      exam.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('EEEE, MMM d • h:mm a').format(exam.date),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Column(
                children: [
                  Text(
                    daysLeft == 0 ? 'Today!' : '$daysLeft',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (daysLeft > 0)
                    const Text(
                      'days left',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                ],
              ),
            ],
          ),
        );
      },
      loading: () => _ShimmerCard(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────
class _EmptyCard extends StatelessWidget {
  final IconData icon;
  final String message;
  const _EmptyCard({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, color: cs.onSurface.withValues(alpha: 0.35), size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: cs.onSurface.withValues(alpha: 0.55),
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShimmerCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
          height: 80,
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(20),
          ),
        )
        .animate(onPlay: (c) => c.repeat())
        .shimmer(
          duration: 1200.ms,
          color: cs.onSurface.withValues(alpha: 0.06),
        );
  }
}

// ── Recent Notes Card ────────────────────────────────────────────────────────
class _RecentNotesCard extends ConsumerWidget {
  final AsyncValue notesAsync;
  const _RecentNotesCard({required this.notesAsync});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;

    return notesAsync.when(
      data: (notes) {
        final List<Note> recentNotes = (notes as List<Note>).toList()
          ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

        if (recentNotes.isEmpty) {
          return GestureDetector(
            onTap: () => context.push('/notes/edit'),
            child: const _EmptyCard(
              icon: Icons.lightbulb_outline,
              message: 'No notes yet. Tap to create one!',
            ),
          );
        }

        final note = recentNotes.first; // Show the most recent one

        return GestureDetector(
          onTap: () => context.push('/notes'),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: note.colorValue != null
                  ? Color(note.colorValue!).withValues(alpha: 0.2)
                  : cs.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: note.colorValue != null
                        ? Color(note.colorValue!).withValues(alpha: 0.4)
                        : cs.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    note.isChecklist ? Icons.check_box_outlined : Icons.notes,
                    color: note.colorValue != null
                        ? Color(note.colorValue!)
                        : cs.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        note.title.isNotEmpty ? note.title : 'Untitled Note',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        note.isChecklist
                            ? '${note.checklist?.length ?? 0} items'
                            : (note.content ?? 'Empty Note'),
                        style: TextStyle(
                          color: cs.onSurface.withValues(alpha: 0.6),
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
          ),
        );
      },
      loading: () => _ShimmerCard(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

// ── Study Planner Carousel ──────────────────────────────────────────────────────────
class _TodayStudyCard extends ConsumerStatefulWidget {
  @override
  ConsumerState<_TodayStudyCard> createState() => _TodayStudyCardState();
}

class _TodayStudyCardState extends ConsumerState<_TodayStudyCard> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final plansAsync = ref.watch(studyPlannerProvider);

    return plansAsync.when(
      data: (plans) {
        if (plans.isEmpty) {
          return GestureDetector(
            onTap: () => context.push('/study-planner'),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.auto_stories_outlined,
                    color: cs.onSurface.withValues(alpha: 0.35),
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'No study plan. Tap to create one!',
                      style: TextStyle(
                        color: cs.onSurface.withValues(alpha: 0.55),
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Column(
          children: [
            SizedBox(
              height: 160,
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemCount: plans.length,
                itemBuilder: (context, index) {
                  final plan = plans[index];

                  // Find today's day if it exists
                  final now = DateTime.now();
                  StudyDay? todayDay;
                  try {
                    todayDay = plan.studyDays.firstWhere(
                      (d) =>
                          d.date.year == now.year &&
                          d.date.month == now.month &&
                          d.date.day == now.day,
                    );
                  } catch (_) {}

                  return GestureDetector(
                    onTap: () =>
                        context.push('/study-planner/detail', extra: plan),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            cs.primary.withValues(alpha: 0.8),
                            cs.primary,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.auto_stories,
                                color: Colors.white70,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  plan.subject,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '${plan.daysLeft}d left',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          // Progress Bar section inside the card
                          Row(
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: plan.progress,
                                    backgroundColor: Colors.white.withValues(
                                      alpha: 0.2,
                                    ),
                                    valueColor: const AlwaysStoppedAnimation(
                                      Colors.white,
                                    ),
                                    minHeight: 6,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${(plan.progress * 100).toInt()}%',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          // Topics or status
                          Expanded(
                            child: todayDay != null
                                ? SingleChildScrollView(
                                    child: Wrap(
                                      spacing: 6,
                                      runSpacing: 6,
                                      children: todayDay.topics.map((t) {
                                        return Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 3,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withValues(
                                              alpha: 0.15,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Text(
                                            t,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  )
                                : Container(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      plan.isCompleted
                                          ? 'Plan Completed! 🎉'
                                          : 'No topics scheduled for today.',
                                      style: TextStyle(
                                        color: Colors.white.withValues(
                                          alpha: 0.8,
                                        ),
                                        fontStyle: FontStyle.italic,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Page Indicators
            if (plans.length > 1) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  plans.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: 6,
                    width: _currentPage == index ? 20 : 6,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? cs.primary
                          : cs.primary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),
            ],
          ],
        );
      },
      loading: () => _ShimmerCard(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
