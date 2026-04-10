import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../domain/providers/providers.dart';
import '../../../data/models/subject.dart';
import '../../../core/constants/colors.dart';

class AddEditSubjectScreen extends ConsumerStatefulWidget {
  final Subject? subject;

  const AddEditSubjectScreen({super.key, this.subject});

  @override
  ConsumerState<AddEditSubjectScreen> createState() =>
      _AddEditSubjectScreenState();
}

class _AddEditSubjectScreenState extends ConsumerState<AddEditSubjectScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _professorController;
  late TextEditingController _roomController;
  int _selectedColorIndex = 0;

  bool get _isEditing => widget.subject != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.subject?.name ?? '');
    _professorController = TextEditingController(
      text: widget.subject?.professorName ?? '',
    );
    _roomController = TextEditingController(
      text: widget.subject?.roomNumber ?? '',
    );

    if (_isEditing) {
      // Find index of subject color
      final colorValue = widget.subject!.colorValue;
      final index = AppColors.subjectColors.indexWhere(
        (c) => c.toARGB32() == colorValue,
      );
      if (index != -1) {
        _selectedColorIndex = index;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _professorController.dispose();
    _roomController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit Subject' : 'Add Subject')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Subject Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.book_outlined),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _professorController,
                decoration: const InputDecoration(
                  labelText: 'Professor Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_outline),
                ),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _roomController,
                decoration: const InputDecoration(
                  labelText: 'Room Number',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Color Code',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 60,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: AppColors.subjectColors.length,
                  itemBuilder: (context, index) {
                    final isSelected = _selectedColorIndex == index;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedColorIndex = index),
                      child: Container(
                        margin: const EdgeInsets.only(right: 12),
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: AppColors.subjectColors[index],
                          shape: BoxShape.circle,
                          border: isSelected
                              ? Border.all(
                                  color: Theme.of(context).colorScheme.primary,
                                  width: 3,
                                )
                              : null,
                          boxShadow: [
                            if (isSelected)
                              BoxShadow(
                                color: AppColors.subjectColors[index]
                                    .withValues(alpha: 0.4),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                          ],
                        ),
                        child: isSelected
                            ? const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 24,
                              )
                            : null,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: _saveSubject,
                icon: const Icon(Icons.save),
                label: Text(_isEditing ? 'Update Subject' : 'Save Subject'),
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

  void _saveSubject() {
    if (_formKey.currentState!.validate()) {
      final id = _isEditing ? widget.subject!.id : const Uuid().v4();
      final colorVal = AppColors.subjectColors[_selectedColorIndex].toARGB32();

      final subject = Subject(
        id: id,
        name: _nameController.text.trim(),
        professorName: _professorController.text.trim(),
        roomNumber: _roomController.text.trim(),
        colorValue: colorVal,
      );

      final repo = ref.read(subjectRepositoryProvider);
      if (_isEditing) {
        repo.updateSubject(subject);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Subject updated successfully')),
        );
      } else {
        repo.addSubject(subject);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Subject added successfully')),
        );
      }

      context.pop();
    }
  }
}
