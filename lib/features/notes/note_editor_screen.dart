import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../data/models/note_model.dart';
import '../../../domain/providers/providers.dart';
import 'notes_provider.dart';

class NoteEditorScreen extends ConsumerStatefulWidget {
  final Note? existingNote;

  const NoteEditorScreen({super.key, this.existingNote});

  @override
  ConsumerState<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends ConsumerState<NoteEditorScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  bool _canPop = false;

  bool _isChecklist = false;
  List<ChecklistItem> _checklist = [];
  String? _selectedSubjectId;
  bool _isPinned = false;
  bool _isArchived = false;
  int? _colorValue;

  final List<Color> _availableColors = [
    Colors.redAccent,
    Colors.orangeAccent,
    Colors.amber,
    Colors.green,
    Colors.blueAccent,
    Colors.purpleAccent,
    Colors.pinkAccent,
    Colors.white,
  ];

  @override
  void initState() {
    super.initState();
    try {
      final note = widget.existingNote;
      _titleController = TextEditingController(text: note?.title ?? '');
      _contentController = TextEditingController(text: note?.content ?? '');
      _isChecklist = note?.isChecklist ?? false;
      _checklist = note?.checklist?.map((e) => e.copyWith()).toList() ?? [];
      _selectedSubjectId = note?.subjectId;
      _isPinned = note?.isPinned ?? false;
      _isArchived = note?.isArchived ?? false;
      _colorValue = note?.colorValue;
    } catch (e) {
      _titleController = TextEditingController();
      _contentController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _saveNote() {
    if (_isDeleted) return;

    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    // Only save if there's actual content
    if (title.isNotEmpty || content.isNotEmpty || _checklist.isNotEmpty) {
      final newNote = Note(
        id: widget.existingNote?.id,
        title: title,
        content: _isChecklist ? null : content,
        checklist: _isChecklist ? _checklist : null,
        subjectId: _selectedSubjectId,
        isPinned: _isPinned,
        isArchived: _isArchived,
        colorValue: _colorValue,
        createdAt: widget.existingNote?.createdAt,
        updatedAt: DateTime.now(),
      );

      if (widget.existingNote == null) {
        ref.read(notesProvider.notifier).addNote(newNote);
      } else {
        ref.read(notesProvider.notifier).updateNote(newNote);
      }
    }

    setState(() {
      _canPop = true;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.pop();
    });
  }

  bool _isDeleted = false;

  void _deleteNote() async {
    if (widget.existingNote == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note'),
        content: const Text('Are you sure you want to delete this note?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      _isDeleted = true;
      ref.read(notesProvider.notifier).deleteNote(widget.existingNote!.id);
      setState(() {
        _canPop = true;
      });
      if (mounted) context.pop();
    }
  }

  void _toggleChecklistMode() {
    setState(() {
      _isChecklist = !_isChecklist;
      if (_isChecklist &&
          _checklist.isEmpty &&
          _contentController.text.isNotEmpty) {
        // Convert multiline text to checklist items
        final lines = _contentController.text.split('\n');
        _checklist = lines
            .where((line) => line.trim().isNotEmpty)
            .map((line) => ChecklistItem(text: line.trim()))
            .toList();
      } else if (!_isChecklist && _checklist.isNotEmpty) {
        // Convert checklist back to text
        _contentController.text = _checklist.map((c) => c.text).join('\n');
      }
    });
  }

  void _showColorPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Note Color',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    // Default Color
                    GestureDetector(
                      onTap: () {
                        setState(() => _colorValue = null);
                        Navigator.pop(context);
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 12),
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Theme.of(context).colorScheme.outline,
                            width: 2,
                          ),
                        ),
                        child: _colorValue == null
                            ? const Icon(Icons.check, size: 20)
                            : null,
                      ),
                    ),
                    // Specific Colors
                    ..._availableColors.map((color) {
                      return GestureDetector(
                        onTap: () {
                          setState(() => _colorValue = color.toARGB32());
                          Navigator.pop(context);
                        },
                        child: Container(
                          margin: const EdgeInsets.only(right: 12),
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                          child: _colorValue == color.toARGB32()
                              ? const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 20,
                                )
                              : null,
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    // Set background if color is chosen
    Color bgColor = theme.scaffoldBackgroundColor;
    if (_colorValue != null) {
      bgColor = Color(
        _colorValue!,
      ).withValues(alpha: theme.brightness == Brightness.dark ? 0.2 : 0.8);
    }

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_isPinned ? Icons.push_pin : Icons.push_pin_outlined),
            onPressed: () => setState(() => _isPinned = !_isPinned),
            tooltip: _isPinned ? 'Unpin' : 'Pin',
          ),
          IconButton(
            icon: const Icon(Icons.color_lens_outlined),
            onPressed: _showColorPicker,
            tooltip: 'Change Color',
          ),
          IconButton(
            icon: Icon(_isArchived ? Icons.unarchive : Icons.archive_outlined),
            onPressed: () => setState(() => _isArchived = !_isArchived),
            tooltip: _isArchived ? 'Unarchive' : 'Archive',
          ),
          if (widget.existingNote != null)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _deleteNote,
              tooltip: 'Delete',
            ),
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveNote,
            tooltip: 'Save',
          ),
        ],
      ),
      body: SafeArea(
        child: PopScope(
          canPop: _canPop,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) return;
            _saveNote();
          },
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title Input
                      TextField(
                        controller: _titleController,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Title',
                          border: InputBorder.none,
                        ),
                        maxLines: null,
                        textCapitalization: TextCapitalization.sentences,
                      ),

                      // Subject Selector
                      Consumer(
                        builder: (context, ref, child) {
                          final subjectsAsync = ref.watch(subjectsProvider);
                          return subjectsAsync.maybeWhen(
                            data: (subjects) {
                              if (subjects.isEmpty) {
                                return const SizedBox.shrink();
                              }
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: _selectedSubjectId,
                                    hint: Text(
                                      'Assign to subject',
                                      style: TextStyle(
                                        color: cs.onSurface.withValues(
                                          alpha: 0.5,
                                        ),
                                      ),
                                    ),
                                    isExpanded: true,
                                    icon: const Icon(
                                      Icons.label_outline,
                                      size: 20,
                                    ),
                                    items: [
                                      const DropdownMenuItem<String>(
                                        value: null,
                                        child: Text('No Subject'),
                                      ),
                                      ...subjects.map(
                                        (s) => DropdownMenuItem(
                                          value: s.id,
                                          child: Text(s.name),
                                        ),
                                      ),
                                    ],
                                    onChanged: (val) => setState(
                                      () => _selectedSubjectId = val,
                                    ),
                                  ),
                                ),
                              );
                            },
                            orElse: () => const SizedBox.shrink(),
                          );
                        },
                      ),

                      // Content or Checklist
                      if (_isChecklist)
                        _buildChecklistEditor(theme, cs)
                      else
                        TextField(
                          controller: _contentController,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            height: 1.5,
                          ),
                          decoration: const InputDecoration(
                            hintText: 'Note',
                            border: InputBorder.none,
                          ),
                          maxLines: null,
                          keyboardType: TextInputType.multiline,
                          textCapitalization: TextCapitalization.sentences,
                        ),
                    ],
                  ),
                ),
              ),

              // Bottom Toolbar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: cs.outlineVariant.withValues(alpha: 0.4),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        _isChecklist ? Icons.notes : Icons.check_box_outlined,
                      ),
                      onPressed: _toggleChecklistMode,
                      tooltip: _isChecklist
                          ? 'Switch to text note'
                          : 'Switch to checklist',
                    ),
                    const Spacer(),
                    if (widget.existingNote != null)
                      TextButton.icon(
                        icon: const Icon(
                          Icons.assignment_turned_in_outlined,
                          size: 18,
                        ),
                        label: const Text('Convert to Task'),
                        onPressed: _convertToTask,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChecklistEditor(ThemeData theme, ColorScheme cs) {
    return Column(
      children: [
        ReorderableListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _checklist.length,
          onReorder: (oldIndex, newIndex) {
            setState(() {
              if (oldIndex < newIndex) newIndex -= 1;
              final item = _checklist.removeAt(oldIndex);
              _checklist.insert(newIndex, item);
            });
          },
          itemBuilder: (context, index) {
            final item = _checklist[index];
            return Padding(
              key: ValueKey(item.id),
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Reorder handle built-in, but we can also use custom
                  ReorderableDragStartListener(
                    index: index,
                    child: const Icon(
                      Icons.drag_indicator,
                      size: 20,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Checkbox(
                    value: item.isChecked,
                    onChanged: (val) {
                      setState(() {
                        _checklist[index] = item.copyWith(isChecked: val);
                      });
                    },
                  ),
                  Expanded(
                    child: TextFormField(
                      initialValue: item.text,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        decoration: item.isChecked
                            ? TextDecoration.lineThrough
                            : null,
                        color: item.isChecked
                            ? cs.onSurface.withValues(alpha: 0.5)
                            : cs.onSurface,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                      ),
                      onChanged: (val) {
                        _checklist[index] = item.copyWith(text: val);
                      },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () {
                      setState(() {
                        _checklist.removeAt(index);
                      });
                    },
                  ),
                ],
              ),
            );
          },
        ),
        // Add new item row
        Padding(
          padding: const EdgeInsets.only(
            top: 8,
            left: 36,
          ), // Align with text fields above
          child: Row(
            children: [
              const Icon(Icons.add, size: 20),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'List item',
                    border: InputBorder.none,
                  ),
                  onSubmitted: (val) {
                    if (val.trim().isNotEmpty) {
                      setState(() {
                        _checklist.add(ChecklistItem(text: val.trim()));
                      });
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _convertToTask() {
    final title = _titleController.text.trim();
    final description = _isChecklist
        ? _checklist.map((c) => c.text).join('\n')
        : _contentController.text;

    context.push(
      '/assignments/add',
      extra: {
        'initialTitle': title.isEmpty ? 'New Task from Note' : title,
        'initialDescription': description,
      },
    );
  }
}
