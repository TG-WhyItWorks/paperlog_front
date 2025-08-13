import 'package:flutter/material.dart';

class LibraryCollectionTile extends StatefulWidget {
  final String title;
  final int count;
  final bool initiallyExpanded;
  final List<Widget> children;
  final VoidCallback? onAdd;
  final VoidCallback? onRename;
  final VoidCallback? onDelete;
  const LibraryCollectionTile({
    super.key,
    required this.title,
    required this.count,
    this.initiallyExpanded = false,
    this.children = const [],
    this.onAdd,
    this.onRename,
    this.onDelete,
  });

  @override
  State<LibraryCollectionTile> createState() => _LibraryCollectionTileState();
}

class _LibraryCollectionTileState extends State<LibraryCollectionTile> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: widget.initiallyExpanded,
          tilePadding: EdgeInsets.zero,
          childrenPadding: const EdgeInsets.only(left: 8),
          leading: Icon(
            Icons.folder_outlined,
            size: 18,
            color: Theme.of(context).iconTheme.color,
          ),
          title: Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Text(
                      widget.title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(width: 8),
                    _CountChip(count: widget.count),
                  ],
                ),
              ),
              if (_hover) ...[
                if (widget.onRename != null)
                  IconButton(
                    tooltip: 'Rename',
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    onPressed: widget.onRename,
                  ),
                if (widget.onDelete != null)
                  IconButton(
                    tooltip: 'Delete folder',
                    icon: const Icon(Icons.delete_outline, size: 18),
                    onPressed: widget.onDelete,
                  ),
              ],
              if (widget.onAdd != null)
                IconButton(
                  tooltip: 'Add subfolder',
                  icon: const Icon(Icons.create_new_folder_outlined, size: 18),
                  onPressed: widget.onAdd,
                ),
            ],
          ),
          children: widget.children.isEmpty
              ? [
                  Padding(
                    padding: const EdgeInsets.only(left: 8, bottom: 12),
                    child: Text(
                      '없음',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ]
              : widget.children,
        ),
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
