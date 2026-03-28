// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'study_plan_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class StudyPlanAdapter extends TypeAdapter<StudyPlan> {
  @override
  final int typeId = 20;

  @override
  StudyPlan read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StudyPlan(
      id: fields[0] as String?,
      subject: fields[1] as String,
      examDate: fields[2] as DateTime,
      dailyStudyHours: fields[3] as int,
      hoursPerChapter: fields[4] as int,
      chapters: (fields[5] as List).cast<String>(),
      studyDays: (fields[6] as List).cast<StudyDay>(),
      isCompleted: fields[7] as bool,
      createdAt: fields[8] as DateTime?,
      subjectId: fields[9] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, StudyPlan obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.subject)
      ..writeByte(2)
      ..write(obj.examDate)
      ..writeByte(3)
      ..write(obj.dailyStudyHours)
      ..writeByte(4)
      ..write(obj.hoursPerChapter)
      ..writeByte(5)
      ..write(obj.chapters)
      ..writeByte(6)
      ..write(obj.studyDays)
      ..writeByte(7)
      ..write(obj.isCompleted)
      ..writeByte(8)
      ..write(obj.createdAt)
      ..writeByte(9)
      ..write(obj.subjectId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StudyPlanAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class StudyDayAdapter extends TypeAdapter<StudyDay> {
  @override
  final int typeId = 21;

  @override
  StudyDay read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StudyDay(
      date: fields[0] as DateTime,
      topics: (fields[1] as List).cast<String>(),
      completed: fields[2] as bool,
      isRevision: fields[3] as bool,
      topicCompleted:
          fields[4] == null ? [] : (fields[4] as List?)?.cast<bool>(),
    );
  }

  @override
  void write(BinaryWriter writer, StudyDay obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.topics)
      ..writeByte(2)
      ..write(obj.completed)
      ..writeByte(3)
      ..write(obj.isRevision)
      ..writeByte(4)
      ..write(obj.topicCompleted);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StudyDayAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
