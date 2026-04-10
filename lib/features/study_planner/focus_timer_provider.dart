import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/focus_session_model.dart';
import '../../domain/providers/providers.dart';

enum TimerState { initial, running, paused, finished }

class FocusTimerState {
  final TimerState state;
  final int initialDurationMinutes;
  final int remainingSeconds;
  final String? selectedSubjectId;

  FocusTimerState({
    required this.state,
    required this.initialDurationMinutes,
    required this.remainingSeconds,
    this.selectedSubjectId,
  });

  FocusTimerState copyWith({
    TimerState? state,
    int? initialDurationMinutes,
    int? remainingSeconds,
    String? selectedSubjectId,
  }) {
    return FocusTimerState(
      state: state ?? this.state,
      initialDurationMinutes:
          initialDurationMinutes ?? this.initialDurationMinutes,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      selectedSubjectId: selectedSubjectId ?? this.selectedSubjectId,
    );
  }

  double get progress {
    if (initialDurationMinutes == 0) return 0;
    return remainingSeconds / (initialDurationMinutes * 60);
  }

  String get formattedTime {
    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

class FocusTimerNotifier extends Notifier<FocusTimerState> {
  Timer? _timer;

  @override
  FocusTimerState build() {
    ref.onDispose(() {
      _timer?.cancel();
    });
    return FocusTimerState(
      state: TimerState.initial,
      initialDurationMinutes: 25,
      remainingSeconds: 25 * 60,
    );
  }

  void setSubject(String? subjectId) {
    state = state.copyWith(selectedSubjectId: subjectId);
  }

  void setDuration(int minutes) {
    if (state.state == TimerState.running || state.state == TimerState.paused) {
      return; // Cannot change duration while running
    }
    state = state.copyWith(
      initialDurationMinutes: minutes,
      remainingSeconds: minutes * 60,
      state: TimerState.initial,
    );
  }

  void start() {
    if (state.state == TimerState.running) return;

    if (state.state == TimerState.finished) {
      // Reset before starting if finished
      setDuration(state.initialDurationMinutes);
    }

    state = state.copyWith(state: TimerState.running);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.remainingSeconds > 0) {
        state = state.copyWith(remainingSeconds: state.remainingSeconds - 1);
      } else {
        _finishSession();
      }
    });
  }

  void pause() {
    _timer?.cancel();
    state = state.copyWith(state: TimerState.paused);
  }

  void stop() {
    _timer?.cancel();
    state = state.copyWith(
      state: TimerState.initial,
      remainingSeconds: state.initialDurationMinutes * 60,
    );
  }

  Future<void> _finishSession() async {
    _timer?.cancel();
    state = state.copyWith(state: TimerState.finished);

    // Save session
    final hiveService = ref.read(hiveServiceProvider);
    
    // Retrieve subject name if we have a subject ID
    String? subjectName;
    if (state.selectedSubjectId != null) {
      try {
        final subject = hiveService.subjectBox.values.firstWhere(
            (s) => s.id == state.selectedSubjectId);
        subjectName = subject.name;
      } catch (_) {}
    }

    final session = FocusSession(
      subjectId: state.selectedSubjectId,
      subjectName: subjectName,
      startTime: DateTime.now().subtract(
        Duration(minutes: state.initialDurationMinutes),
      ),
      durationMinutes: state.initialDurationMinutes,
      isCompleted: true,
    );

    await hiveService.focusSessionBox.add(session);
  }
  void disposeTimer() {
    _timer?.cancel();
  }
}

final focusTimerProvider =
    NotifierProvider<FocusTimerNotifier, FocusTimerState>(
  FocusTimerNotifier.new,
);
