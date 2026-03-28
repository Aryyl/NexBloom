// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AppSettingsAdapter extends TypeAdapter<AppSettings> {
  @override
  final int typeId = 10;

  @override
  AppSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AppSettings(
      themeMode: fields[0] as String,
      notificationsEnabled: fields[1] as bool,
      defaultReminderMinutes: fields[2] as int,
      attendanceTarget: fields[3] as int,
      semesterStart: fields[4] as DateTime?,
      semesterEnd: fields[5] as DateTime?,
      userName: (fields[6] as String?) ?? 'Student',
      currentSemester: (fields[7] as String?) ?? '',
      primaryColorValue: fields[8] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, AppSettings obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.themeMode)
      ..writeByte(1)
      ..write(obj.notificationsEnabled)
      ..writeByte(2)
      ..write(obj.defaultReminderMinutes)
      ..writeByte(3)
      ..write(obj.attendanceTarget)
      ..writeByte(4)
      ..write(obj.semesterStart)
      ..writeByte(5)
      ..write(obj.semesterEnd)
      ..writeByte(6)
      ..write(obj.userName)
      ..writeByte(7)
      ..write(obj.currentSemester)
      ..writeByte(8)
      ..write(obj.primaryColorValue);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
