import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/dashboard_viewmodel.dart';
import '../../../core/models/library_models.dart';
import '../../library/viewmodel/library_viewmodel.dart';
import '../../auth/viewmodel/auth_viewmodel.dart';

class SidebarWidget extends StatelessWidget {
  const SidebarWidget({Key? key}) : super(key: key);

  Future<void> _addFolder(BuildContext context) async {
    final libVm = context.read<LibraryViewModel>();
    final auth = context.read<AuthViewModel>();
    if (!auth.isLoggedIn) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('로그인 후 이용해 주세요.')));
      return;
    }
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('New folder'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Folder name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Create'),
          ),
        ],
      ),
    );
    if (name != null && name.trim().isNotEmpty) {
      await libVm.createFolder(name.trim(), parentFolderId: null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final main = context.watch<MainViewModel>();
    final lib = context.watch<LibraryViewModel>();
    final auth = context.watch<AuthViewModel>();

    Widget libItem(String title, LibrarySection s) {
      final count = lib.section(s).length;
      return ListTile(
        contentPadding: EdgeInsets.zero,
        dense: true,
        title: Text(title, style: Theme.of(context).textTheme.bodyLarge),
        trailing: Text('$count', style: Theme.of(context).textTheme.bodyMedium),
        onTap: () {
          // 라이브러리 페이지로 이동 (선택한 섹션 전달)
          Navigator.of(context).pushNamed('/library', arguments: s);
        },
      );
    }

    return Container(
      width: 320,
      color: Theme.of(context).colorScheme.surface,
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===== Quick Lists =====
            Text(
              'My Library',
              style: Theme.of(
                context,
              ).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            libItem('Want to read', LibrarySection.wantToRead),
            libItem('Reading', LibrarySection.reading),
            libItem('Completed', LibrarySection.completed),

            const Divider(height: 24),

            // ===== Collections (My publications / Private / Folders) =====
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'My Collections',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold),
                ),
                if (auth.isLoggedIn)
                  IconButton(
                    tooltip: 'New folder',
                    icon: Icon(
                      Icons.add,
                      color: Theme.of(context).iconTheme.color,
                    ),
                    onPressed: () => _addFolder(context),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            _collectionRow(
              context,
              title: 'My publications',
              count: lib.section(LibrarySection.myPublications).length,
              icon: Icons.school_outlined,
              onTap: () => Navigator.of(
                context,
              ).pushNamed('/library', arguments: LibrarySection.myPublications),
            ),
            if (auth.isLoggedIn)
              _collectionRow(
                context,
                title: 'Private Papers',
                count: lib.section(LibrarySection.private).length,
                icon: Icons.lock_outline,
                onTap: () => Navigator.of(
                  context,
                ).pushNamed('/library', arguments: LibrarySection.private),
              ),

            // 사용자 폴더
            if (auth.isLoggedIn) ..._buildFolderTreeSidebar(context, lib),

            ///TODO: 블로그 구현
            // const Divider(),

            // Text(
            //   'Blog',
            //   style: Theme.of(
            //     context,
            //   ).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold),
            // ),
            // const SizedBox(height: 8),
            // //예시용 블로그 리스트
            // ...[
            //   {'name': 'Interesting Blog', 'count': 12},
            //   {'name': 'Interesting Post', 'count': 64},
            // ].map(
            //   (data) => ListTile(
            //     contentPadding: EdgeInsets.zero,
            //     title: Text(
            //       data['name'] as String,
            //       style: Theme.of(context).textTheme.bodyLarge,
            //     ),
            //     trailing: Text(
            //       '${data['count']} posts',
            //       style: Theme.of(context).textTheme.bodySmall,
            //     ),
            //     onTap: () {
            //       //TODO: 블로그 클릭 핸들러
            //     },
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  // My Collections 공통 표시용
  Widget _collectionRow(
    BuildContext context, {
    required String title,
    required int count,
    required VoidCallback onTap,
    IconData icon = Icons.folder_outlined,
  }) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, size: 18, color: Theme.of(context).iconTheme.color),
      title: Text(title, style: Theme.of(context).textTheme.bodyLarge),
      subtitle: Text(
        '$count papers',
        style: Theme.of(context).textTheme.bodySmall,
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: Theme.of(context).iconTheme.color,
      ),
      onTap: onTap,
    );
  }

  List<Widget> _buildFolderTreeSidebar(
    BuildContext context,
    LibraryViewModel vm,
  ) {
    final all = vm.folders;
    // if (all.isEmpty) {
    //   return const [
    //     Padding(
    //       padding: EdgeInsets.only(left: 8, bottom: 12),
    //       child: Text('없음'),
    //     ),
    //   ];
    // }

    // parentId -> children
    final Map<String?, List<LibraryFolder>> byParent = {};
    for (final f in all) {
      byParent.putIfAbsent(f.parentId, () => <LibraryFolder>[]).add(f);
    }

    List<Widget> buildBranch(String? parentId) {
      final children = byParent[parentId] ?? const <LibraryFolder>[];
      return children.map((f) {
        final grand = buildBranch(f.id);
        final title = Row(
          children: [
            Expanded(
              child: Text(f.name, style: Theme.of(context).textTheme.bodyLarge),
            ),
            Text('${f.count}', style: Theme.of(context).textTheme.bodyMedium),
          ],
        );

        if (grand.isEmpty) {
          // leaf → ListTile
          return ListTile(
            dense: true,
            contentPadding: const EdgeInsets.only(left: 12),
            leading: Icon(
              Icons.folder_outlined,
              size: 18,
              color: Theme.of(context).iconTheme.color,
            ),
            title: title,
            onTap: () => Navigator.of(context).pushNamed('/library'),
          );
        }

        // has children → ExpansionTile
        return Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.only(left: 0),
            childrenPadding: const EdgeInsets.only(left: 16),
            leading: Icon(
              Icons.folder_outlined,
              size: 18,
              color: Theme.of(context).iconTheme.color,
            ),
            title: title,
            children: grand,
          ),
        );
      }).toList();
    }

    // 루트(parentId == null)부터 그리기
    return buildBranch(null);
  }
}
