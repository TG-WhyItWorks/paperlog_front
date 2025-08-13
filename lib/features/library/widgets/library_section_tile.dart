import 'package:flutter/material.dart';
import '../../../core/models/library_models.dart';
import 'library_paper_row.dart';

class LibrarySectionTile extends StatelessWidget {
  final String title;
  final List<LibraryItem> items;
  final bool initiallyExpanded;
  const LibrarySectionTile({
    super.key,
    required this.title,
    required this.items,
    this.initiallyExpanded = false,
  });

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        initiallyExpanded: initiallyExpanded,
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.only(left: 24), //들여쓰기 조절
        title: Row(
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(width: 8),
            _CountChip(count: items.length),
          ],
        ),
        children: items.isEmpty
            ? [
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    '없음',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ]
            : items.map<Widget>((e) => LibraryPaperRow(item: e)).toList(),
      ),
    );
  }
}

class _CountChip extends StatelessWidget {
  final int count;
  const _CountChip({required this.count});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.4),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text('$count', style: Theme.of(context).textTheme.labelSmall),
    );
  }
}
