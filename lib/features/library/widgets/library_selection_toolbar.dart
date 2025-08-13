import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/library_viewmodel.dart';
import '../../../core/models/library_models.dart';

class LibrarySelectionToolbar extends StatelessWidget {
  final Future<String?> Function() pickFolder;
  const LibrarySelectionToolbar({super.key, required this.pickFolder});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<LibraryViewModel>();
    if (!vm.isSelecting) return const SizedBox.shrink();
    return Container(
      key: const ValueKey('select-bar'), // AnimatedSwitcher 구분
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.35),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.6),
        ),
      ),
      child: Row(
        children: [
          // --- Move ---
          PopupMenuButton<String>(
            tooltip: 'Move',
            itemBuilder: (ctx) => const [
              PopupMenuItem(value: 'want', child: Text('Move → Want to read')),
              PopupMenuItem(value: 'reading', child: Text('Move → Reading')),
              PopupMenuItem(
                value: 'completed',
                child: Text('Move → Completed'),
              ),
              PopupMenuDivider(),
              PopupMenuItem(value: 'folder', child: Text('Move → Folder…')),
            ],
            onSelected: (v) async {
              if (v == 'want') {
                await vm.moveSelectedToSection(LibrarySection.wantToRead);
              }
              if (v == 'reading') {
                await vm.moveSelectedToSection(LibrarySection.reading);
              }
              if (v == 'completed') {
                await vm.moveSelectedToSection(LibrarySection.completed);
              }
              if (v == 'folder') {
                final id = await pickFolder();
                if (id != null) await vm.moveSelectedToFolder(id);
              }
            },
            child: Row(
              children: const [
                Icon(Icons.drive_file_move_outlined, size: 18),
                SizedBox(width: 6),
                Text('Move'),
                Icon(Icons.arrow_drop_down),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // --- Delete ---
          TextButton.icon(
            onPressed: () async => await vm.deleteSelected(),
            icon: const Icon(Icons.delete_outline),
            label: const Text('Delete'),
          ),
          const Spacer(),
          // --- Count ---
          Text(
            '${vm.selectedPaperCount} papers'
            '${vm.selectedPostCount > 0 ? ' · ${vm.selectedPostCount} posts' : ''}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(width: 12),
          TextButton(onPressed: vm.clearSelection, child: const Text('Cancel')),
        ],
      ),
    );
  }
}
