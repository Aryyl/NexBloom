import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'note_model.g.dart';

@HiveType(typeId: 11)
class Note extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String? content;

  @HiveField(3)
  List<ChecklistItem>? checklist;

  @HiveField(4)
  String? subjectId;

  @HiveField(5)
  bool isPinned;

  @HiveField(6)
  bool isArchived;

  @HiveField(7)
  int? colorValue;

  @HiveField(8)
  final DateTime createdAt;

  @HiveField(9)
  DateTime updatedAt;

  Note({
    String? id,
    required this.title,
    this.content,
    this.checklist,
    this.subjectId,
    this.isPinned = false,
    this.isArchived = false,
    this.colorValue,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  bool get isChecklist => checklist != null;

  Color? get color => colorValue != null ? Color(colorValue!) : null;

  Note copyWith({
    String? title,
    String? content,
    List<ChecklistItem>? checklist,
    String? subjectId,
    bool? isPinned,
    bool? isArchived,
    int? colorValue,
    DateTime? updatedAt,
  }) {
    return Note(
      id: id,
      title: title ?? this.title,
      content: content ?? this.content,
      checklist: checklist ?? this.checklist,
      subjectId: subjectId ?? this.subjectId,
      isPinned: isPinned ?? this.isPinned,
      isArchived: isArchived ?? this.isArchived,
      colorValue: colorValue ?? this.colorValue,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}

@HiveType(typeId: 12)
class ChecklistItem {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String text;

  @HiveField(2)
  bool isChecked;

  ChecklistItem({String? id, required this.text, this.isChecked = false})
    : id = id ?? const Uuid().v4();

  ChecklistItem copyWith({String? text, bool? isChecked}) {
    return ChecklistItem(
      id: id,
      text: text ?? this.text,
      isChecked: isChecked ?? this.isChecked,
    );
  }
}
