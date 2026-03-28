import 'package:hive_flutter/hive_flutter.dart';
import '../../data/models/subject.dart';
import '../../data/models/assignment.dart';
import '../../data/models/attendance_record.dart';
import '../../data/models/note_model.dart';
import '../../data/models/study_plan_model.dart';

class HiveService {
  static const String subjectBoxName = 'subjects';
  static const String assignmentBoxName = 'assignments';
  static const String attendanceBoxName = 'attendance';
  static const String examBoxName = 'exams';
  static const String classSessionBoxName = 'class_sessions';
  static const String notesBoxName = 'notes';
  static const String studyPlanBoxName = 'study_plans';

  Future<void> init() async {
    // Open all boxes
    await Hive.openBox<Subject>(subjectBoxName);
    await Hive.openBox<Assignment>(assignmentBoxName);
    try {
      final box = await Hive.openBox<AttendanceRecord>(attendanceBoxName);
      box.values.toList(); // Force iteration to catch type cast errors
    } catch (e) {
      await Hive.deleteBoxFromDisk(attendanceBoxName);
      await Hive.openBox<AttendanceRecord>(attendanceBoxName);
    }
    await Hive.openBox<Exam>(examBoxName);
    // ClassSession is usually embedded or in its own box, let's keep it simple for now and maybe not open it if it's not a top-level entity, but it probably is.
    await Hive.openBox<ClassSession>(classSessionBoxName);
    await Hive.openBox<Note>(notesBoxName);
    await Hive.openBox<StudyPlan>(studyPlanBoxName);
  }

  Box<Subject> get subjectBox => Hive.box<Subject>(subjectBoxName);
  Box<Assignment> get assignmentBox => Hive.box<Assignment>(assignmentBoxName);
  Box<AttendanceRecord> get attendanceBox =>
      Hive.box<AttendanceRecord>(attendanceBoxName);
  Box<Exam> get examBox => Hive.box<Exam>(examBoxName);
  Box<ClassSession> get classSessionBox =>
      Hive.box<ClassSession>(classSessionBoxName);
  Box<Note> get noteBox => Hive.box<Note>(notesBoxName);
  Box<StudyPlan> get studyPlanBox => Hive.box<StudyPlan>(studyPlanBoxName);
}
