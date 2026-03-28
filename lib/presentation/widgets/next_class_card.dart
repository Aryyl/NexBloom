import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../../domain/providers/providers.dart';
import '../../../data/models/subject.dart';
import '../../../core/constants/colors.dart';
import 'modern_card.dart';

class NextClassCard extends ConsumerWidget {
  const NextClassCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsAsync = ref.watch(classSessionsProvider);
    final subjectsAsync = ref.watch(subjectsProvider);

    return sessionsAsync.when(
      data: (sessions) {
        if (sessions.isEmpty) {
          return const SizedBox.shrink(); // No classes at all
        }

        final nextClass = _findNextClass(sessions);
        if (nextClass == null) {
          return const ModernCard(
            color: AppColors.surface,
            child: Row(
              children: [
                Icon(Icons.event_available, color: Colors.grey),
                SizedBox(width: 12),
                Text(
                  "No upcoming classes this week.",
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        // Find subject details
        final subject = subjectsAsync.value?.firstWhere(
          (s) => s.id == nextClass.session.subjectId,
          orElse: () => Subject(
            id: '?',
            name: 'Unknown',
            professorName: '',
            roomNumber: '',
            colorValue: Colors.grey.toARGB32(),
          ),
        );

        if (subject == null) return const SizedBox.shrink();

        final now = DateTime.now();

        String dayLabel;
        if (nextClass.dayOffset == 0) {
          dayLabel = 'Today';
        } else if (nextClass.dayOffset == 1) {
          dayLabel = 'Tomorrow';
        } else {
          // Get weekday name
          final targetDate = now.add(Duration(days: nextClass.dayOffset));
          dayLabel = DateFormat('EEEE').format(targetDate);
        }

        final startTimeShort = _formatTime(nextClass.session.startTime);
        final endTimeShort = _formatTime(nextClass.session.endTime);

        return ModernCard(
          onTap: () {
            context.go('/timetable?day=${nextClass.session.dayOfWeek}');
          },
          gradient: LinearGradient(
            colors: [
              Color(subject.colorValue).withValues(alpha: 0.8),
              Color(subject.colorValue),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      dayLabel,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward,
                    color: Colors.white70,
                    size: 20,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                subject.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(
                    Icons.access_time,
                    color: Colors.white70,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$startTimeShort - $endTimeShort',
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  if (subject.roomNumber.isNotEmpty) ...[
                    const SizedBox(width: 16),
                    const Icon(
                      Icons.location_on,
                      color: Colors.white70,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      subject.roomNumber,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ],
                ],
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox(
        height: 100,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  _NextClassResult? _findNextClass(List<ClassSession> sessions) {
    // Logic: Look for today's classes after now.
    // If none, look for tomorrow, etc. up to 7 days.

    final now = DateTime.now();
    final currentDay = now.weekday;
    final currentTime = now.hour * 60 + now.minute;

    for (int offset = 0; offset < 7; offset++) {
      // Calculate target weekday (1-7)
      int targetDay = currentDay + offset;
      if (targetDay > 7) targetDay -= 7;

      // Find sessions for this day
      final daySessions = sessions
          .where((s) => s.dayOfWeek == targetDay)
          .toList();

      if (daySessions.isEmpty) continue;

      // Sort by start time
      daySessions.sort(
        (a, b) =>
            _timeToMinutes(a.startTime).compareTo(_timeToMinutes(b.startTime)),
      );

      if (offset == 0) {
        // If today, filter out passed classes
        final upcoming = daySessions
            .where((s) => _timeToMinutes(s.startTime) > currentTime)
            .toList();
        if (upcoming.isNotEmpty) {
          return _NextClassResult(upcoming.first, offset);
        }
      } else {
        // Future day, return first class
        return _NextClassResult(daySessions.first, offset);
      }
    }
    return null;
  }

  int _timeToMinutes(String hhmm) {
    try {
      // Handle AM/PM format
      if (hhmm.toUpperCase().contains('AM') ||
          hhmm.toUpperCase().contains('PM')) {
        // Normalize
        final normalized = hhmm.replaceAll(RegExp(r'\s+'), ' ').trim();
        // Parse using DateFormat
        final dt = DateFormat('h:mm a').parse(normalized);
        return dt.hour * 60 + dt.minute;
      }

      // Handle HH:mm format
      final parts = hhmm.split(':');
      if (parts.length != 2) return 0;
      return int.parse(parts[0].trim()) * 60 + int.parse(parts[1].trim());
    } catch (e) {
      debugPrint('Error parsing time: $hhmm - $e');
      return 0;
    }
  }

  String _formatTime(String hhmm) {
    try {
      // If it's already in AM/PM format, verify/normalize or just return
      if (hhmm.toUpperCase().contains('AM') ||
          hhmm.toUpperCase().contains('PM')) {
        return hhmm;
      }

      final parts = hhmm.split(':');
      final dt = DateTime(2022, 1, 1, int.parse(parts[0]), int.parse(parts[1]));
      return DateFormat('h:mm a').format(dt);
    } catch (e) {
      // Fallback if parsing fails
      return hhmm;
    }
  }
}

class _NextClassResult {
  final ClassSession session;
  final int dayOffset;
  _NextClassResult(this.session, this.dayOffset);
}
