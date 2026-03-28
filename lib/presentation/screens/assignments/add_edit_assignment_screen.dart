import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../domain/providers/providers.dart';
import '../../../data/models/assignment.dart';

class AddEditAssignmentScreen extends ConsumerStatefulWidget {
  final Assignment? assignment;
  final String? initialTitle;
  final String? initialDescription;

  const AddEditAssignmentScreen({
    super.key,
    this.assignment,
    this.initialTitle,
    this.initialDescription,
  });

  @override
  ConsumerState<AddEditAssignmentScreen> createState() =>
      _AddEditAssignmentScreenState();
}

class _AddEditAssignmentScreenState
    extends ConsumerState<AddEditAssignmentScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late DateTime _deadline;
  late String _priority;
  late String _selectedSubjectId;

  bool get _isEditing => widget.assignment != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.assignment?.title ?? widget.initialTitle ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.assignment?.description ?? widget.initialDescription ?? '',
    );
    _deadline =
        widget.assignment?.deadline ??
        DateTime.now().add(const Duration(days: 1));
    _priority = widget.assignment?.priority ?? 'Medium';
    _selectedSubjectId = widget.assignment?.subjectId ?? '';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final subjectsAsync = ref.watch(subjectsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Assignment' : 'Add Assignment'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
                textCapitalization: TextCapitalization.sentences,
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a title' : null,
              ),
              const SizedBox(height: 16),
              subjectsAsync.when(
                data: (subjects) {
                  if (subjects.isEmpty) {
                    return const Text('Please add subjects first!');
                  }
                  if (_selectedSubjectId.isEmpty && !_isEditing) {
                    _selectedSubjectId = subjects.first.id;
                  } else if (_selectedSubjectId.isEmpty && _isEditing) {
                    // Should not happen if assignment exists, but safe fallback
                    if (subjects.any(
                      (s) => s.id == widget.assignment?.subjectId,
                    )) {
                      _selectedSubjectId = widget.assignment!.subjectId;
                    } else {
                      _selectedSubjectId = subjects.first.id;
                    }
                  }

                  return DropdownButtonFormField<String>(
                    initialValue:
                        _selectedSubjectId.isNotEmpty &&
                            subjects.any((s) => s.id == _selectedSubjectId)
                        ? _selectedSubjectId
                        : null,
                    decoration: const InputDecoration(
                      labelText: 'Subject',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.book_outlined),
                    ),
                    items: subjects
                        .map(
                          (s) => DropdownMenuItem(
                            value: s.id,
                            child: Text(s.name),
                          ),
                        )
                        .toList(),
                    onChanged: (val) {
                      setState(() => _selectedSubjectId = val!);
                    },
                    validator: (val) =>
                        val == null || val.isEmpty ? 'Select a subject' : null,
                  );
                },
                loading: () => const CircularProgressIndicator(),
                error: (e, s) => Text('Error loading subjects: $e'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (Optional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description_outlined),
                ),
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Deadline'),
                subtitle: Text("${_deadline.toLocal()}".split(' ')[0]),
                leading: const Icon(Icons.calendar_today),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                  side: const BorderSide(color: Colors.grey),
                ),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _deadline,
                    firstDate: DateTime.now().subtract(
                      const Duration(days: 365),
                    ), // Allow past dates for editing
                    lastDate: DateTime(2101),
                  );
                  if (picked != null && picked != _deadline) {
                    setState(() {
                      _deadline = picked;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _priority,
                decoration: const InputDecoration(
                  labelText: 'Priority',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.flag_outlined),
                ),
                items: ['Low', 'Medium', 'High']
                    .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                    .toList(),
                onChanged: (val) => setState(() => _priority = val!),
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: _saveAssignment,
                icon: const Icon(Icons.save),
                label: Text(
                  _isEditing ? 'Update Assignment' : 'Save Assignment',
                ),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveAssignment() {
    if (_formKey.currentState!.validate() && _selectedSubjectId.isNotEmpty) {
      final id = _isEditing ? widget.assignment!.id : const Uuid().v4();
      final isCompleted = _isEditing ? widget.assignment!.isCompleted : false;

      final assignment = Assignment(
        id: id,
        subjectId: _selectedSubjectId,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        deadline: _deadline,
        priority: _priority,
        isCompleted: isCompleted,
      );

      final repo = ref.read(assignmentRepositoryProvider);
      if (_isEditing) {
        repo.updateAssignment(assignment);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Assignment updated')));
      } else {
        repo.addAssignment(assignment);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Assignment added')));
      }
      context.pop();
    }
  }
}
