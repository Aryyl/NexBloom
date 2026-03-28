import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../data/models/subject.dart';
import '../../domain/providers/providers.dart';
import 'study_planner_logic.dart';
import 'study_planner_provider.dart';
import 'widgets/risk_indicator.dart';

class CreatePlanScreen extends ConsumerStatefulWidget {
  const CreatePlanScreen({super.key});

  @override
  ConsumerState<CreatePlanScreen> createState() => _CreatePlanScreenState();
}

class _CreatePlanScreenState extends ConsumerState<CreatePlanScreen> {
  final _formKey = GlobalKey<FormState>();

  String? _selectedSubjectId;
  String _customSubject = '';
  DateTime? _examDate;
  int _hoursPerChapter = 2;
  int _dailyStudyHours = 3;
  final List<TextEditingController> _chapterControllers = [
    TextEditingController(),
  ];

  StudyPlanResult? _previewResult;
  bool _showPreview = false;

  @override
  void dispose() {
    for (final c in _chapterControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _addChapter() {
    setState(() {
      _chapterControllers.add(TextEditingController());
    });
  }

  void _removeChapter(int index) {
    if (_chapterControllers.length > 1) {
      setState(() {
        _chapterControllers[index].dispose();
        _chapterControllers.removeAt(index);
      });
    }
  }

  void _generatePlan(List<Subject> subjects) {
    if (!_formKey.currentState!.validate()) return;
    if (_examDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an exam date'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final chapters = _chapterControllers
        .map((c) => c.text.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    if (chapters.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one chapter'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    String subjectName = _customSubject;
    if (_selectedSubjectId != null && _selectedSubjectId!.isNotEmpty) {
      final subject = subjects.where((s) => s.id == _selectedSubjectId);
      if (subject.isNotEmpty) {
        subjectName = subject.first.name;
      }
    }

    if (subjectName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select or enter a subject'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final result = StudyPlannerLogic.generatePlan(
      subject: subjectName,
      examDate: _examDate!,
      chapters: chapters,
      hoursPerChapter: _hoursPerChapter,
      dailyStudyHours: _dailyStudyHours,
      subjectId: _selectedSubjectId,
    );

    setState(() {
      _previewResult = result;
      _showPreview = true;
    });
  }

  Future<void> _savePlan() async {
    if (_previewResult == null) return;

    await ref.read(studyPlannerProvider.notifier).addPlan(_previewResult!.plan);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Study plan saved!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final subjectsAsync = ref.watch(subjectsProvider);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Study Plan'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: subjectsAsync.when(
        data: (subjects) => _buildForm(subjects, cs),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildForm(List<Subject> subjects, ColorScheme cs) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Subject selection
            Text(
              'Subject',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: cs.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 8),
            if (subjects.isNotEmpty)
              DropdownButtonFormField<String>(
                initialValue: _selectedSubjectId,
                decoration: InputDecoration(
                  hintText: 'Select a subject',
                  filled: true,
                  fillColor: cs.surfaceContainerHighest.withValues(alpha: 0.4),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                items: [
                  const DropdownMenuItem(
                    value: '',
                    child: Text('Custom subject...'),
                  ),
                  ...subjects.map(
                    (s) => DropdownMenuItem(
                      value: s.id,
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: Color(s.colorValue),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(s.name),
                        ],
                      ),
                    ),
                  ),
                ],
                onChanged: (val) {
                  setState(() {
                    _selectedSubjectId = val;
                    _showPreview = false;
                  });
                },
              ),
            if (_selectedSubjectId == '' || subjects.isEmpty) ...[
              const SizedBox(height: 8),
              TextFormField(
                decoration: InputDecoration(
                  hintText: 'e.g. Mathematics',
                  filled: true,
                  fillColor: cs.surfaceContainerHighest.withValues(alpha: 0.4),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                onChanged: (val) {
                  _customSubject = val;
                  _showPreview = false;
                },
                validator: (val) {
                  if ((_selectedSubjectId == null ||
                          _selectedSubjectId!.isEmpty) &&
                      (val == null || val.trim().isEmpty)) {
                    return 'Enter a subject name';
                  }
                  return null;
                },
              ),
            ],

            const SizedBox(height: 20),

            // Exam date
            Text(
              'Exam Date',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: cs.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate:
                      _examDate ?? DateTime.now().add(const Duration(days: 7)),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (picked != null) {
                  setState(() {
                    _examDate = picked;
                    _showPreview = false;
                  });
                }
              },
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today, size: 20, color: cs.primary),
                    const SizedBox(width: 12),
                    Text(
                      _examDate != null
                          ? DateFormat('EEEE, MMM d, yyyy').format(_examDate!)
                          : 'Select exam date',
                      style: TextStyle(
                        color: _examDate != null
                            ? cs.onSurface
                            : cs.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Hours config
            Row(
              children: [
                Expanded(
                  child: _NumberInput(
                    label: 'Hours/Chapter',
                    value: _hoursPerChapter,
                    min: 1,
                    max: 12,
                    onChanged: (v) {
                      setState(() {
                        _hoursPerChapter = v;
                        _showPreview = false;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _NumberInput(
                    label: 'Daily Study Hours',
                    value: _dailyStudyHours,
                    min: 1,
                    max: 16,
                    onChanged: (v) {
                      setState(() {
                        _dailyStudyHours = v;
                        _showPreview = false;
                      });
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Chapters
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Chapters / Topics',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                TextButton.icon(
                  onPressed: _addChapter,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add'),
                ),
              ],
            ),
            const SizedBox(height: 4),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _chapterControllers.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: cs.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: cs.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          controller: _chapterControllers[index],
                          decoration: InputDecoration(
                            hintText: 'Chapter ${index + 1}',
                            filled: true,
                            fillColor: cs.surfaceContainerHighest.withValues(
                              alpha: 0.4,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            isDense: true,
                          ),
                          onChanged: (_) {
                            if (_showPreview) {
                              setState(() => _showPreview = false);
                            }
                          },
                        ),
                      ),
                      if (_chapterControllers.length > 1) ...[
                        const SizedBox(width: 4),
                        IconButton(
                          onPressed: () => _removeChapter(index),
                          icon: Icon(
                            Icons.remove_circle_outline,
                            color: cs.error.withValues(alpha: 0.6),
                            size: 22,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 36,
                            minHeight: 36,
                          ),
                          padding: EdgeInsets.zero,
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // Generate button
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () =>
                    _generatePlan((ref.read(subjectsProvider).value ?? [])),
                icon: const Icon(Icons.auto_awesome),
                label: const Text('Generate Plan'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),

            // Preview
            if (_showPreview && _previewResult != null) ...[
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),

              Text(
                'Plan Preview',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              // Stats
              Row(
                children: [
                  _PreviewStat(
                    label: 'Days Left',
                    value: '${_previewResult!.daysLeft}',
                    icon: Icons.calendar_today,
                  ),
                  const SizedBox(width: 8),
                  _PreviewStat(
                    label: 'Required',
                    value: '${_previewResult!.totalRequiredHours}h',
                    icon: Icons.access_time,
                  ),
                  const SizedBox(width: 8),
                  _PreviewStat(
                    label: 'Available',
                    value: '${_previewResult!.totalAvailableHours}h',
                    icon: Icons.battery_charging_full,
                  ),
                ],
              ),
              const SizedBox(height: 12),

              RiskIndicator(
                riskLevel: _previewResult!.riskLevel,
                message: _previewResult!.riskMessage,
              ),

              const SizedBox(height: 16),

              // Day preview list
              ...(_previewResult!.plan.studyDays.asMap().entries.map((entry) {
                final day = entry.value;
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: day.isRevision
                        ? Colors.amber.withValues(alpha: 0.08)
                        : cs.surfaceContainerHighest.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: day.isRevision
                              ? Colors.amber.withValues(alpha: 0.15)
                              : cs.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          DateFormat('d').format(day.date),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: day.isRevision
                                ? Colors.amber[800]
                                : cs.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              DateFormat('EEEE, MMM d').format(day.date),
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Wrap(
                              spacing: 4,
                              runSpacing: 4,
                              children: day.topics.map((t) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: day.isRevision
                                        ? Colors.amber.withValues(alpha: 0.1)
                                        : cs.primary.withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    t,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: cs.onSurface.withValues(
                                        alpha: 0.7,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              })),

              const SizedBox(height: 16),

              // Save button
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _savePlan,
                  icon: const Icon(Icons.save),
                  label: const Text('Save Plan'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    backgroundColor: Colors.green,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _NumberInput extends StatelessWidget {
  final String label;
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  const _NumberInput({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: cs.onSurface.withValues(alpha: 0.7),
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: value > min ? () => onChanged(value - 1) : null,
                icon: const Icon(Icons.remove, size: 20),
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                padding: EdgeInsets.zero,
              ),
              Text(
                '$value',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              IconButton(
                onPressed: value < max ? () => onChanged(value + 1) : null,
                icon: const Icon(Icons.add, size: 20),
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PreviewStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _PreviewStat({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: cs.primary),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: cs.primary,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: cs.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
