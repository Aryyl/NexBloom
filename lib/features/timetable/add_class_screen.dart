import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:studentcompanionapp/domain/providers/providers.dart';
import 'package:studentcompanionapp/data/models/subject.dart';

class AddClassScreen extends ConsumerStatefulWidget {
  final int initialDay;
  final ClassSession? sessionToEdit;

  const AddClassScreen({super.key, this.initialDay = 1, this.sessionToEdit});

  @override
  ConsumerState<AddClassScreen> createState() => _AddClassScreenState();
}

class _AddClassScreenState extends ConsumerState<AddClassScreen> {
  final _formKey = GlobalKey<FormState>();
  String _selectedSubjectId = '';
  late int _selectedDay;
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 10, minute: 0);

  @override
  void initState() {
    super.initState();
    if (widget.sessionToEdit != null) {
      _selectedSubjectId = widget.sessionToEdit!.subjectId;
      _selectedDay = widget.sessionToEdit!.dayOfWeek;
      _startTime = _parseTime(widget.sessionToEdit!.startTime);
      _endTime = _parseTime(widget.sessionToEdit!.endTime);
    } else {
      _selectedDay = widget.initialDay;
    }
  }

  TimeOfDay _parseTime(String timeString) {
    try {
      final parts = timeString.split(':');
      return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    } catch (_) {
      return const TimeOfDay(hour: 9, minute: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final subjectsAsync = ref.watch(subjectsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.sessionToEdit != null ? 'Edit Class' : 'Add Class'),
      ),
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
              DropdownButtonFormField<int>(
                initialValue: _selectedDay,
                decoration: const InputDecoration(
                  labelText: 'Day',
                  border: OutlineInputBorder(),
                ),
                items: List.generate(
                  7,
                  (index) => DropdownMenuItem(
                    value: index + 1,
                    child: Text(_getDayName(index + 1)),
                  ),
                ),
                onChanged: (val) => setState(() => _selectedDay = val!),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ListTile(
                      title: const Text('Start Time'),
                      subtitle: Text(_startTime.format(context)),
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: _startTime,
                        );
                        if (picked != null) setState(() => _startTime = picked);
                      },
                    ),
                  ),
                  Expanded(
                    child: ListTile(
                      title: const Text('End Time'),
                      subtitle: Text(_endTime.format(context)),
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: _endTime,
                        );
                        if (picked != null) setState(() => _endTime = picked);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              FilledButton(
                onPressed: () {
                  if (_formKey.currentState!.validate() &&
                      _selectedSubjectId.isNotEmpty) {
                    final isEditing = widget.sessionToEdit != null;
                    final newSession = ClassSession(
                      id: isEditing
                          ? widget.sessionToEdit!.id
                          : const Uuid().v4(),
                      subjectId: _selectedSubjectId,
                      dayOfWeek: _selectedDay,
                      startTime: _formatTimeOfDay(_startTime),
                      endTime: _formatTimeOfDay(_endTime),
                    );

                    // addSession gracefully handles Hive `.put()` which replaces ID if exists.
                    ref
                        .read(classSessionRepositoryProvider)
                        .addSession(newSession);
                    context.pop();
                  }
                },
                child: Text(
                  widget.sessionToEdit != null ? 'Update Class' : 'Save Class',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getDayName(int day) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[day - 1];
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
