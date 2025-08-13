import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/library_viewmodel.dart';
import '../../../core/models/folder_model.dart';
import 'library_collection_tile.dart';
import 'library_paper_row.dart';

typedef FolderId = String;

class FolderTree extends StatelessWidget {
  final LibraryViewModel vm;
  final Future<void> Function(FolderId folderId)? onAddToFolder;
  final Future<void> Function()? onShowCollections;
  final Future<String?> Function()? onPickFolder;

  const FolderTree({
    super.key,
    required this.vm,
    this.onAddToFolder,
    this.onShowCollections,
    this.onPickFolder,
  });

  @override
  Widget build(BuildContext context) {
    final all = context.select<LibraryViewModel, List<LibraryFolder>>(
      (v) => v.folders,
    );

    // parentId -> children
    final Map<String?, List<LibraryFolder>> byParent = {};
    for (final f in all) {
      byParent.putIfAbsent(f.parentId, () => <LibraryFolder>[]).add(f);
    }

    List<Widget> buildBranch(String? parentId) {
      final children = byParent[parentId] ?? const <LibraryFolder>[];
      return children.map((f) {
        final grandChildren = buildBranch(f.id);
        final papers = vm.itemsInFolder(f.id);
        final paperRows = papers.map((e) => LibraryPaperRow(item: e)).toList();

        final composed = <Widget>[
          ...grandChildren,
          if (grandChildren.isNotEmpty && paperRows.isNotEmpty)
            const SizedBox(height: 6),
          ...paperRows,
          if (grandChildren.isEmpty && paperRows.isEmpty)
            const Padding(
              padding: EdgeInsets.only(left: 8, bottom: 12),
              child: Text('없음'),
            ),
        ];

        return LibraryCollectionTile(
          title: f.name,
          count: f.count,
          initiallyExpanded: false,
          onAdd: onAddToFolder != null ? () => onAddToFolder!(f.id) : null,
          onRename: () async {
            final controller = TextEditingController(text: f.name);
            final newName = await showDialog<String>(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('Rename folder'),
                content: TextField(controller: controller, autofocus: true),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () =>
                        Navigator.pop(context, controller.text.trim()),
                    child: const Text('Save'),
                  ),
                ],
              ),
            );
            if (newName != null && newName.isNotEmpty) {
              await vm.renameFolder(f.id, newName);
              await vm.refresh();
            }
          },
          onDelete: () async {
            final ok = await showDialog<bool>(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('Delete folder'),
                content: Text('Delete "${f.name}"?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Delete'),
                  ),
                ],
              ),
            );
            if (ok == true) {
              await vm.deleteFolder(f.id);
              await vm.refresh();
            }
          },
          children: composed,
        );
      }).toList();
    }

    return Column(children: buildBranch(null));
  }
}
