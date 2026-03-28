import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'notes_provider.dart';
import '../../domain/providers/providers.dart';
import 'widgets/note_card.dart';
import '../../presentation/widgets/empty_state.dart';
import '../../data/models/subject.dart';

class NotesScreen extends ConsumerStatefulWidget {
  const NotesScreen({super.key});

  @override
  ConsumerState<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends ConsumerState<NotesScreen> {
  bool _showArchived = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final notesAsync = ref.watch(filteredNotesProvider);
    final subjectsAsync = ref.watch(subjectsProvider);
    final isSearching = ref.watch(notesSearchQueryProvider).isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Notes',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: SegmentedButton<bool>(
              segments: const [
                ButtonSegment(value: false, label: Text('Active')),
                ButtonSegment(value: true, label: Text('Archived')),
              ],
              selected: {_showArchived},
              onSelectionChanged: (Set<bool> newSelection) {
                setState(() {
                  _showArchived = newSelection.first;
                });
              },
              showSelectedIcon: false,
              style: SegmentedButton.styleFrom(
                visualDensity: VisualDensity.compact,
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              onChanged: (val) =>
                  ref.read(notesSearchQueryProvider.notifier).updateQuery(val),
              decoration: InputDecoration(
                hintText: 'Search notes...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: cs.surfaceContainerHighest.withValues(alpha: 0.5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
        ),
      ),
      body: notesAsync.when(
        data: (notes) {
          final pinnedNotes = notes
              .where((n) => n.isPinned && n.isArchived == _showArchived)
              .toList();
          final otherNotes = notes
              .where((n) => !n.isPinned && n.isArchived == _showArchived)
              .toList();
          final activeNotes = [...pinnedNotes, ...otherNotes];

          if (activeNotes.isEmpty) {
            return Center(
              child: EmptyState(
                icon: isSearching ? Icons.search_off : Icons.lightbulb_outline,
                title: 'No Notes',
                subtitle: isSearching
                    ? 'No notes match your search.'
                    : 'Capture your thoughts.\nTap + to create a note.',
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (pinnedNotes.isNotEmpty) ...[
                  _buildSectionLabel('Pinned', theme, cs),
                  _buildNotesGrid(pinnedNotes, subjectsAsync, context),
                  const SizedBox(height: 16),
                ],
                if (otherNotes.isNotEmpty) ...[
                  if (pinnedNotes.isNotEmpty)
                    _buildSectionLabel('Others', theme, cs),
                  _buildNotesGrid(otherNotes, subjectsAsync, context),
                ],
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, st) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline, color: cs.error, size: 48),
                const SizedBox(height: 12),
                Text(
                  'Failed to load notes',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: cs.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  err.toString(),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: cs.onSurface.withValues(alpha: 0.6)),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/notes/edit'),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSectionLabel(String title, ThemeData theme, ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 10),
      child: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: cs.onSurface.withValues(alpha: 0.6),
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildNotesGrid(
    List notes,
    AsyncValue subjectsAsync,
    BuildContext context,
  ) {
    return MasonryGridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        final matches = subjectsAsync.value?.where(
          (s) => s.id == note.subjectId,
        );
        final Subject? subject = (matches != null && matches.isNotEmpty)
            ? matches.first
            : null;

        return NoteCard(
          note: note,
          subject: subject,
          onTap: () => context.push('/notes/edit', extra: note),
        );
      },
    );
  }
}
