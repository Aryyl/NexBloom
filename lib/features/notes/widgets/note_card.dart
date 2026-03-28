import 'package:flutter/material.dart';
import '../../../data/models/note_model.dart';
import '../../../data/models/subject.dart';

class NoteCard extends StatelessWidget {
  final Note note;
  final Subject? subject;
  final VoidCallback onTap;

  const NoteCard({
    super.key,
    required this.note,
    required this.onTap,
    this.subject,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    // Determine background color
    Color bgColor = cs.surfaceContainerHighest.withValues(alpha: 0.5);
    final noteColor = note.color;
    if (noteColor != null) {
      // Use the exact color but adapt for dark mode if needed
      bgColor = noteColor.withValues(
        alpha: theme.brightness == Brightness.dark ? 0.3 : 0.6,
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: cs.outlineVariant.withValues(alpha: 0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(
                alpha: theme.brightness == Brightness.dark ? 0.2 : 0.04,
              ),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            if (note.title.isNotEmpty) ...[
              Text(
                note.title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  height: 1.25,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 10),
            ],

            // Content Preview
            if (note.isChecklist && note.checklist != null) ...[
              _buildChecklistPreview(theme, cs),
            ] else if (note.content != null && note.content!.isNotEmpty) ...[
              Text(
                note.content!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: cs.onSurface.withValues(alpha: 0.8),
                  height: 1.4,
                ),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
            ],

            const SizedBox(height: 12),

            // Footer (Subject & Icons)
            Row(
              children: [
                if (subject != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Color(subject!.colorValue).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      subject!.name,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Color(subject!.colorValue),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                const Spacer(),
                if (note.isPinned)
                  Icon(
                    Icons.push_pin,
                    size: 14,
                    color: cs.onSurface.withValues(alpha: 0.6),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChecklistPreview(ThemeData theme, ColorScheme cs) {
    final items = note.checklist!.take(3).toList();
    final hasMore = note.checklist!.length > 3;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final item in items)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  item.isChecked
                      ? Icons.check_box
                      : Icons.check_box_outline_blank,
                  size: 16,
                  color: item.isChecked
                      ? cs.onSurface.withValues(alpha: 0.4)
                      : cs.onSurface.withValues(alpha: 0.7),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    item.text,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: item.isChecked
                          ? cs.onSurface.withValues(alpha: 0.4)
                          : cs.onSurface.withValues(alpha: 0.8),
                      decoration: item.isChecked
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        if (hasMore)
          Padding(
            padding: const EdgeInsets.only(top: 2, left: 24),
            child: Text(
              '+ ${note.checklist!.length - 3} more',
              style: theme.textTheme.bodySmall?.copyWith(
                color: cs.onSurface.withValues(alpha: 0.5),
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
      ],
    );
  }
}
