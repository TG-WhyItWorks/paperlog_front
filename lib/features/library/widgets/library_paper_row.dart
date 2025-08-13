import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/library_viewmodel.dart';
import '../../../core/models/library_models.dart';
import '../../../core/models/paper_model.dart';
import '../../../shared/prefs/date_formatting.dart' as df;
import '../../../shared/prefs/prefs_provider.dart' as prefs;

class LibraryPaperRow extends StatefulWidget {
  final LibraryItem item;
  const LibraryPaperRow({super.key, required this.item});

  @override
  State<LibraryPaperRow> createState() => _LibraryPaperRowState();
}

class _LibraryPaperRowState extends State<LibraryPaperRow> {
  bool _hover = false;
  String _dateString(Paper p) {
    DateTime? dt = p.publishedAt;

    if (dt == null) {
      final y = int.tryParse(p.year);
      if (y != null) {
        dt = DateTime(y, 1, 1);
      }
    }
    final opt = context.read<prefs.PrefsProvider>().dateFormat;
    if (dt == null) return '';
    return df.formatDate(dt, opt);
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<LibraryViewModel>();
    final p = widget.item.paper;
    final selected = vm.isPaperSelected(p.id);

    final authors = (p.authors.isNotEmpty) ? p.authors.join(', ') : '';

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: ListTile(
        dense: true,
        contentPadding: const EdgeInsets.only(left: 0, right: 8),
        // ⬅ leading: 체크박스(선택 중/호버일 때) 또는 아이콘
        leading: AnimatedSwitcher(
          duration: const Duration(milliseconds: 140),
          child: (selected || _hover)
              ? Checkbox(
                  key: const ValueKey('cb'),
                  value: selected,
                  onChanged: (_) => vm.togglePaperSelected(p.id),
                  visualDensity: VisualDensity.compact,
                )
              : const Icon(
                  Icons.article_outlined,
                  size: 18,
                  key: ValueKey('ic'),
                ),
        ),
        // ⬅ 제목 + (Private Chip)
        title: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  if (vm.isSelecting) {
                    vm.togglePaperSelected(p.id);
                  } else {
                    Navigator.of(context).pushNamed('/paper', arguments: p.id);
                  }
                },
                child: Text(
                  p.title,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    decoration: vm.isPaperSelected(p.id)
                        ? TextDecoration.underline
                        : TextDecoration.none,
                  ),
                ),
              ),
            ),
            if (widget.item.isPrivate)
              Container(
                margin: const EdgeInsets.only(left: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.4),
                  ),
                ),
                child: Text(
                  'Private',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ),
          ],
        ),
        // 날짜 · 저자만
        subtitle: Row(
          children: [
            if (_dateString(p).isNotEmpty)
              Text(
                _dateString(p),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            if (_dateString(p).isNotEmpty && authors.isNotEmpty)
              Text(' · ', style: Theme.of(context).textTheme.bodySmall),
            if (authors.isNotEmpty)
              Expanded(
                child: Text(
                  authors,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
          ],
        ),
        // ⬅ trailing: hover/선택 시 삭제 아이콘
        trailing: AnimatedOpacity(
          opacity: (_hover || selected) ? 1 : 0,
          duration: const Duration(milliseconds: 140),
          child: IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Delete',
            onPressed: () async {
              vm.clearSelection();
              vm.togglePaperSelected(p.id);
              await vm.deleteSelected();
            },
          ),
        ),
        // ⬅ 행 전체 클릭 시 선택 토글(선택 모드일 때)
        onTap: vm.isSelecting ? () => vm.togglePaperSelected(p.id) : null,
      ),
    );
  }
}
