// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'note_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NoteAdapter extends TypeAdapter<Note> {
  @override
  final int typeId = 11;

  @override
  Note read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Note(
      id: fields[0] as String?,
      title: fields[1] as String,
      content: fields[2] as String?,
      checklist: (fields[3] as List?)?.cast<ChecklistItem>(),
      subjectId: fields[4] as String?,
      isPinned: fields[5] as bool,
      isArchived: fields[6] as bool,
      colorValue: fields[7] as int?,
      createdAt: fields[8] as DateTime?,
      updatedAt: fields[9] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Note obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.content)
      ..writeByte(3)
      ..write(obj.checklist)
      ..writeByte(4)
      ..write(obj.subjectId)
      ..writeByte(5)
      ..write(obj.isPinned)
      ..writeByte(6)
      ..write(obj.isArchived)
      ..writeByte(7)
      ..write(obj.colorValue)
      ..writeByte(8)
      ..write(obj.createdAt)
      ..writeByte(9)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NoteAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ChecklistItemAdapter extends TypeAdapter<ChecklistItem> {
  @override
  final int typeId = 12;

  @override
  ChecklistItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ChecklistItem(
      id: fields[0] as String?,
      text: fields[1] as String,
      isChecked: fields[2] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, ChecklistItem obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.text)
      ..writeByte(2)
      ..write(obj.isChecked);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChecklistItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
