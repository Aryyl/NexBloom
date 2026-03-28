import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:studentcompanionapp/domain/providers/providers.dart';
import 'package:studentcompanionapp/data/models/subject.dart';

class TimetableScreen extends ConsumerStatefulWidget {
  final int initialDay;
  const TimetableScreen({super.key, this.initialDay = 0});

  @override
  ConsumerState<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends ConsumerState<TimetableScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _dayNames = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  @override
  void initState() {
    super.initState();
    final today = DateTime.now().weekday - 1; // 0=Mon, 6=Sun
    _tabController = TabController(
      length: 7,
      vsync: this,
      initialIndex: (widget.initialDay > 0) ? widget.initialDay - 1 : today,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sessionsAsync = ref.watch(classSessionsProvider);
    final subjectsAsync = ref.watch(subjectsProvider);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Timetable'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: cs.primary,
          unselectedLabelColor: cs.onSurface.withValues(alpha: 0.6),
          indicatorColor: cs.primary,
          indicatorWeight: 3,
          labelPadding: const EdgeInsets.symmetric(horizontal: 20),
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          tabs: _dayNames.map((day) => Tab(text: day)).toList(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_outlined),
            tooltip: 'Add Subject',
            onPressed: () => context.push('/timetable/add_subject'),
          ),
        ],
      ),
      body: sessionsAsync.when(
        data: (sessions) {
          return subjectsAsync.when(
            data: (subjects) {
              return TabBarView(
                controller: _tabController,
                children: List.generate(7, (dayIndex) {
                  final dayNum = dayIndex + 1;
                  final daySessions =
                      sessions.where((s) => s.dayOfWeek == dayNum).toList()
                        ..sort((a, b) => a.startTime.compareTo(b.startTime));

                  if (daySessions.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.free_breakfast_outlined,
                            size: 64,
                            color: cs.onSurface.withValues(alpha: 0.2),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No classes on ${_dayNames[dayIndex]}',
                            style: TextStyle(
                              color: cs.onSurface.withValues(alpha: 0.5),
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                    itemCount: daySessions.length,
                    itemBuilder: (context, index) {
                      final session = daySessions[index];
                      Subject? subject;
                      try {
                        subject = subjects.firstWhere(
                          (s) => s.id == session.subjectId,
                        );
                      } catch (_) {
                        if (subjects.isNotEmpty) subject = subjects.first;
                      }

                      Color subjectColor = cs.primary;
                      String subjectName = 'Unknown Subject';
                      String room = '';

                      if (subject != null) {
                        subjectColor = Color(subject.colorValue);
                        subjectName = subject.name;
                        room = subject.roomNumber;
                      }

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: cs.surfaceContainerHighest.withValues(
                            alpha: 0.5,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border(
                            left: BorderSide(color: subjectColor, width: 4),
                          ),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          title: Text(
                            subjectName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 14,
                                color: cs.onSurface.withValues(alpha: 0.6),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${session.startTime} - ${session.endTime}',
                                style: TextStyle(
                                  color: cs.onSurface.withValues(alpha: 0.6),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          trailing: room.isNotEmpty
                              ? Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: subjectColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    room,
                                    style: TextStyle(
                                      color: subjectColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                )
                              : null,
                          onLongPress: () {
                            _showSessionOptions(context, ref, session);
                          },
                        ),
                      );
                    },
                  );
                }),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, s) => Center(child: Text('Error: $e')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Pass current tab index as day (1-based)
          final currentDay = _tabController.index + 1;
          context.push('/timetable/add_class?day=$currentDay');
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Class'),
      ),
    );
  }

  void _showSessionOptions(
    BuildContext context,
    WidgetRef ref,
    dynamic session,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Class'),
              onTap: () {
                Navigator.pop(ctx);
                context.push('/timetable/edit_class', extra: session);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text(
                'Delete Class',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                Navigator.pop(ctx);
                ref
                    .read(classSessionRepositoryProvider)
                    .deleteSession(session.id);
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Class deleted')));
              },
            ),
          ],
        ),
      ),
    );
  }
}
