import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/assignments/add_edit_assignment_screen.dart';
import '../../features/assignments/assignments_screen.dart';
import '../../data/models/assignment.dart';
import '../../features/timetable/timetable_screen.dart';

import '../../features/timetable/add_class_screen.dart';
import '../../features/attendance/attendance_calendar_screen.dart';
import '../../features/exams/exams_screen.dart';
import '../../features/exams/add_exam_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/subjects/subject_detail_screen.dart';
import '../../features/subjects/add_edit_subject_screen.dart';
import 'scaffold_with_navbar.dart';
import '../../data/models/subject.dart';
import '../../data/models/note_model.dart';
import '../../features/notes/notes_screen.dart';
import '../../features/notes/note_editor_screen.dart';
import '../../features/study_planner/study_planner_screen.dart';
import '../../features/study_planner/create_plan_screen.dart';
import '../../features/study_planner/plan_detail_screen.dart';
import '../../data/models/study_plan_model.dart';
import '../../features/study_planner/focus_timer_screen.dart';



final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [

    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return ScaffoldWithNavBar(navigationShell: child);
      },
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const DashboardScreen(),
        ),
        GoRoute(
          path: '/timetable',
          builder: (context, state) {
            final dayStr = state.uri.queryParameters['day'];
            final day = dayStr != null ? int.tryParse(dayStr) ?? 0 : 0;
            return TimetableScreen(initialDay: day);
          },
        ),
        GoRoute(
          path: '/assignments',
          builder: (context, state) => const AssignmentsScreen(),
        ),
        GoRoute(
          path: '/attendance',
          builder: (context, state) => const AttendanceCalendarScreen(),
        ),
        GoRoute(
          path: '/exams',
          builder: (context, state) => const ExamsScreen(),
        ),
      ],
    ),

    // Full Screen Routes (Outside Shell)
    GoRoute(
      path: '/timetable/add_subject',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const AddEditSubjectScreen(),
    ),
    GoRoute(
      path: '/timetable/add_class',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final dayStr = state.uri.queryParameters['day'];
        final day = dayStr != null ? int.tryParse(dayStr) ?? 1 : 1;
        return AddClassScreen(initialDay: day);
      },
    ),
    GoRoute(
      path: '/timetable/edit_class',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final session = state.extra as ClassSession?;
        return AddClassScreen(
          sessionToEdit: session,
          initialDay: session?.dayOfWeek ?? 1,
        );
      },
    ),
    GoRoute(
      path: '/assignments/add',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return AddEditAssignmentScreen(
          initialTitle: extra?['initialTitle'] as String?,
          initialDescription: extra?['initialDescription'] as String?,
        );
      },
    ),
    GoRoute(
      path: '/assignments/edit',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final assignment = state.extra as Assignment;
        return AddEditAssignmentScreen(assignment: assignment);
      },
    ),
    GoRoute(
      path: '/exams/add',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const AddExamScreen(),
    ),
    GoRoute(
      path: '/notes',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const NotesScreen(),
    ),
    GoRoute(
      path: '/notes/edit',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final note = state.extra as Note?;
        return NoteEditorScreen(existingNote: note);
      },
    ),
    GoRoute(
      path: '/settings',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/subject/:id',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return SubjectDetailScreen(subjectId: id);
      },
    ),
    GoRoute(
      path: '/subject/edit',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final subject = state.extra as Subject;
        return AddEditSubjectScreen(subject: subject);
      },
    ),
    GoRoute(
      path: '/study-planner',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const StudyPlannerScreen(),
    ),
    GoRoute(
      path: '/study-planner/create',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const CreatePlanScreen(),
    ),
    GoRoute(
      path: '/study-planner/detail',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final plan = state.extra as StudyPlan;
        return PlanDetailScreen(plan: plan);
      },
    ),
    GoRoute(
      path: '/study-planner/focus-timer',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const FocusTimerScreen(),
    ),
  ],
);
