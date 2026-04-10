import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:studentcompanionapp/domain/providers/providers.dart';
import 'package:studentcompanionapp/data/models/assignment.dart'; // For Exam

class AddExamScreen extends ConsumerStatefulWidget {
  const AddExamScreen({super.key});

  @override
  ConsumerState<AddExamScreen> createState() => _AddExamScreenState();
}

class _AddExamScreenState extends ConsumerState<AddExamScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  DateTime _date = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _time = const TimeOfDay(hour: 10, minute: 0);
  String _selectedSubjectId = '';

  @override
  Widget build(BuildContext context) {
    final subjectsAsync = ref.watch(subjectsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Add Exam')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              subjectsAsync.when(
                data: (subjects) {
                  if (subjects.isEmpty) {
                    return const Text('Please add subjects first!');
                  }
                  if (_selectedSubjectId.isEmpty) {
                    _selectedSubjectId = subjects.first.id;
                  }
                  return DropdownButtonFormField<String>(
                    initialValue: _selectedSubjectId,
                    decoration: const InputDecoration(
                      labelText: 'Subject',
                      border: OutlineInputBorder(),
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
                  );
                },
                loading: () => const CircularProgressIndicator(),
                error: (e, s) => Text('Error loading subjects: $e'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Exam Title (e.g. Midterm 1)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a title' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Location (Room)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ListTile(
                      title: const Text('Date'),
                      subtitle: Text("${_date.toLocal()}".split(' ')[0]),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _date,
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2101),
                        );
                        if (picked != null) setState(() => _date = picked);
                      },
                    ),
                  ),
                  Expanded(
                    child: ListTile(
                      title: const Text('Time'),
                      subtitle: Text(_time.format(context)),
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: _time,
                        );
                        if (picked != null) setState(() => _time = picked);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              FilledButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate() &&
                      _selectedSubjectId.isNotEmpty) {
                    final examDate = DateTime(
                      _date.year,
                      _date.month,
                      _date.day,
                      _time.hour,
                      _time.minute,
                    );
                    final formattedTime = _time.format(context);

                    final newExam = Exam(
                      id: const Uuid().v4(),
                      subjectId: _selectedSubjectId,
                      title: _titleController.text,
                      date: examDate,
                      location: _locationController.text,
                    );

                    // Save to Hive
                    final hiveService = ref.read(hiveServiceProvider);
                    await hiveService.examBox.put(newExam.id, newExam);

                    // Schedule Notification
                    try {
                      await ref
                          .read(notificationServiceProvider)
                          .scheduleNotification(
                            id: newExam.id.hashCode,
                            title: 'Upcoming Exam: ${newExam.title}',
                            body:
                                'Exam at $formattedTime in ${_locationController.text}',
                            scheduledDate: examDate.subtract(
                              const Duration(hours: 1),
                            ), // 1 hour before
                          );
                    } catch (e) {
                      debugPrint('Notification error: $e');
                    }

                    if (context.mounted) context.pop();
                  }
                },
                child: const Text('Schedule Exam'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
