import 'package:flutter/material.dart';
import '../viewmodel/library_viewmodel.dart';

class LibraryFolderActions {
  /// 상단 My Collections의 + 버튼: 업로드/새 폴더
  static Future<void> showCollections(
    BuildContext context,
    LibraryViewModel vm,
  ) async {
    await showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.upload_file),
              title: const Text('Upload Private Paper'),
              onTap: () async {
                Navigator.pop(context);
                await vm.uploadPrivatePaper(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.create_new_folder_outlined),
              title: const Text('New folder'),
              onTap: () async {
                Navigator.pop(context);
                final controller = TextEditingController();
                final name = await showDialog<String>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('New folder'),
                    content: TextField(
                      controller: controller,
                      autofocus: true,
                      decoration: const InputDecoration(
                        hintText: 'Folder name',
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () =>
                            Navigator.pop(context, controller.text),
                        child: const Text('Create'),
                      ),
                    ],
                  ),
                );
                if (name != null && name.trim().isNotEmpty) {
                  await vm.createFolder(name.trim(), parentFolderId: null);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  /// 폴더 타일의 ... 액션
  static Future<void> showFolder(
    BuildContext context,
    LibraryViewModel vm,
    String folderId,
  ) async {
    await showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.upload_file),
              title: const Text('Upload to this folder'),
              onTap: () async {
                Navigator.pop(context);
                await vm.uploadPrivatePaperToFolder(
                  context,
                  folderIdStr: folderId,
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.create_new_folder_outlined),
              title: const Text('Create subfolder'),
              onTap: () async {
                Navigator.pop(context);
                final controller = TextEditingController();
                final name = await showDialog<String>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('New subfolder'),
                    content: TextField(
                      controller: controller,
                      autofocus: true,
                      decoration: const InputDecoration(
                        hintText: 'Folder name',
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () =>
                            Navigator.pop(context, controller.text),
                        child: const Text('Create'),
                      ),
                    ],
                  ),
                );
                if (name != null && name.trim().isNotEmpty) {
                  final parentId = int.tryParse(folderId);
                  await vm.createFolder(name.trim(), parentFolderId: parentId);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  /// 폴더 선택 다이얼로그 (상태 반영 포함)
  static Future<String?> pickFolder(BuildContext context, LibraryViewModel vm) {
    return showDialog<String>(
      context: context,
      builder: (_) {
        String? selected;
        return StatefulBuilder(
          builder: (ctx, setState) => AlertDialog(
            title: const Text('Select folder'),
            content: SizedBox(
              width: 360,
              height: 320,
              child: ListView(
                children: vm.folders
                    .map(
                      (f) => RadioListTile<String>(
                        value: f.id,
                        groupValue: selected,
                        onChanged: (v) => setState(() => selected = v),
                        title: Text(f.name),
                        secondary: const Icon(Icons.folder_outlined, size: 18),
                      ),
                    )
                    .toList(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, selected),
                child: const Text('Move'),
              ),
            ],
          ),
        );
      },
    );
  }
}
