import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../domain/providers/providers.dart';
import 'focus_timer_provider.dart';

class FocusTimerScreen extends ConsumerWidget {
  const FocusTimerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerState = ref.watch(focusTimerProvider);
    final timerNotifier = ref.read(focusTimerProvider.notifier);
    final cs = Theme.of(context).colorScheme;

    final isRunning = timerState.state == TimerState.running;
    final isPaused = timerState.state == TimerState.paused;
    final isFinished = timerState.state == TimerState.finished;
    final isInitial = timerState.state == TimerState.initial;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Focus Timer'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            children: [
              // Subject Picker
              _SubjectPicker(
                isEnabled: isInitial || isFinished,
                selectedId: timerState.selectedSubjectId,
                onChanged: (val) => timerNotifier.setSubject(val),
              ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2),
              
              const Spacer(),

              // Timer Display
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 280,
                    height: 280,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: isRunning
                          ? [
                              BoxShadow(
                                color: cs.primary.withValues(alpha: 0.3),
                                blurRadius: 40,
                                spreadRadius: 10,
                              )
                            ]
                          : [],
                    ),
                    child: CircularProgressIndicator(
                      value: timerState.progress,
                      strokeWidth: 12,
                      backgroundColor: cs.surfaceContainerHighest.withValues(alpha: 0.5),
                      valueColor: AlwaysStoppedAnimation(
                        isFinished ? Colors.green : cs.primary,
                      ),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        timerState.formattedTime,
                        style: TextStyle(
                          fontSize: 72,
                          fontWeight: FontWeight.w200,
                          color: isFinished ? Colors.green : cs.onSurface,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ).animate(target: isRunning ? 1 : 0).scale(
                        begin: const Offset(1, 1),
                        end: const Offset(1.05, 1.05),
                        duration: 1.seconds,
                        curve: Curves.easeInOut,
                      ),
                      if (isFinished)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            'Session Complete!',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ).animate().fadeIn().slideY(begin: 0.5),
                        ),
                    ],
                  ),
                ],
              ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),

              const Spacer(),

              // Duration Selector (only in initial state)
              if (isInitial || isFinished)
                Wrap(
                  spacing: 12,
                  alignment: WrapAlignment.center,
                  children: [15, 25, 45, 60].map((mins) {
                    final isSelected =
                        timerState.initialDurationMinutes == mins;
                    return FilterChip(
                      selected: isSelected,
                      label: Text('$mins min'),
                      onSelected: (_) => timerNotifier.setDuration(mins),
                      selectedColor: cs.primaryContainer,
                      checkmarkColor: cs.onPrimaryContainer,
                    );
                  }).toList(),
                ).animate().fadeIn(duration: 400.ms, delay: 200.ms),

              const SizedBox(height: 32),

              // Controls
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Stop/Reset
                  if (isRunning || isPaused || isFinished)
                    IconButton.filledTonal(
                      onPressed: () => timerNotifier.stop(),
                      iconSize: 32,
                      padding: const EdgeInsets.all(16),
                      icon: const Icon(Icons.stop_rounded),
                    ).animate().scale().fadeIn(),
                  
                  if (isRunning || isPaused || isFinished)
                    const SizedBox(width: 24),

                  // Start/Pause
                  IconButton.filled(
                    onPressed: () {
                      if (isRunning) {
                        timerNotifier.pause();
                      } else {
                        timerNotifier.start();
                      }
                    },
                    iconSize: 48,
                    padding: const EdgeInsets.all(20),
                    style: IconButton.styleFrom(
                      backgroundColor:
                          isRunning ? cs.secondary : cs.primary,
                      foregroundColor: isRunning
                          ? cs.onSecondary
                          : cs.onPrimary,
                    ),
                    icon: Icon(
                      isRunning
                          ? Icons.pause_rounded
                          : (isFinished ? Icons.replay_rounded : Icons.play_arrow_rounded),
                    ),
                  ).animate().scale(delay: 100.ms).fadeIn(delay: 100.ms),
                ],
              ),
              const SizedBox(height: 32),

              // Recent Sessions
              Expanded(
                child: _RecentSessions(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecentSessions extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hiveService = ref.watch(hiveServiceProvider);
    final cs = Theme.of(context).colorScheme;
    
    // Get today's completed sessions
    final now = DateTime.now();
    final todaySessions = hiveService.focusSessionBox.values.where((s) {
      if (!s.isCompleted) return false;
      return s.startTime.year == now.year &&
             s.startTime.month == now.month &&
             s.startTime.day == now.day;
    }).toList().reversed.toList();

    if (todaySessions.isEmpty) {
      return Center(
        child: Text(
          'No sessions yet today.\nStart focusing!',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: cs.onSurface.withValues(alpha: 0.6),
            fontSize: 14,
          ),
        ),
      ).animate().fadeIn(delay: 500.ms);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Today\'s Sessions',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: cs.onSurface.withValues(alpha: 0.8),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.builder(
            itemCount: todaySessions.length,
            itemBuilder: (context, index) {
              final s = todaySessions[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle_rounded, color: Colors.green, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        s.subjectName ?? 'General Focus',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    Text(
                      '${s.durationMinutes} min',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: cs.primary,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: Duration(milliseconds: 50 * index)).slideX();
            },
          ),
        ),
      ],
    );
  }
}

class _SubjectPicker extends ConsumerWidget {
  final bool isEnabled;
  final String? selectedId;
  final ValueChanged<String?> onChanged;

  const _SubjectPicker({
    required this.isEnabled,
    required this.selectedId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hiveService = ref.watch(hiveServiceProvider);
    final subjects = hiveService.subjectBox.values.toList();
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outline.withValues(alpha: 0.2)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          isExpanded: true,
          value: selectedId,
          hint: const Text('Select a subject to focus on (Optional)'),
          icon: const Icon(Icons.arrow_drop_down),
          menuMaxHeight: 300,
          onChanged: isEnabled ? onChanged : null,
          items: [
            const DropdownMenuItem(
              value: null,
              child: Text('No Subject / General Focus'),
            ),
            ...subjects.map(
              (s) => DropdownMenuItem(
                value: s.id,
                child: Row(
                  children: [
                    Icon(Icons.circle, size: 12, color: Color(s.colorValue)),
                    const SizedBox(width: 8),
                    Text(s.name),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
