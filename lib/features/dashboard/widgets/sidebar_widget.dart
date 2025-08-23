import 'package:flutter/material.dart';
import 'package:paperlog_front/core/models/review_models.dart';
import 'package:provider/provider.dart';
import '../viewmodel/dashboard_viewmodel.dart';
import '../../../core/models/library_models.dart';
import '../../library/viewmodel/library_viewmodel.dart';
import '../../auth/viewmodel/auth_viewmodel.dart';
import '../../../core/models/paper_model.dart';
import '../../../core/models/folder_model.dart';

class SidebarWidget extends StatefulWidget {
  const SidebarWidget({Key? key}) : super(key: key);
  static const double _kSidebarWidth = 320.0;

  @override
  State<SidebarWidget> createState() => _SideBarWidgetState();
}

class _SideBarWidgetState extends State<SidebarWidget> {
  final Set<String> _expandedIds = <String>{};
  bool _isExpanded(String? id) => id != null && _expandedIds.contains(id);

  void _toggleExpanded(String? id) {
    if (id == null) return;
    setState(() {
      if (!_expandedIds.add(id)) _expandedIds.remove(id);
    });
  }

  //새 폴더 생성 다이얼로그
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
    final bool isOpen = main.isSidebarOpen;

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

    if (!isOpen) {
      return const SizedBox(width: 0, height: double.infinity);
    }

    return Container(
      width: SidebarWidget._kSidebarWidth,
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
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
                    'Custom Folders',
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
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

              // 사용자 폴더
              if (auth.isLoggedIn) ..._buildFolderTreeSidebar(context, lib),

              // Recent View
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent View',
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(
                        context,
                      ).pushNamed('/library', arguments: {'initialTab': 1});
                    },
                    child: const Text('View all'),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              if ((main.recentPapers.isNotEmpty)) ...[
                Text(
                  '최근 본 논문',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                ...main.recentPapers
                    .take(3)
                    .map((p) => _recentPaperTile(context, p))
                    .toList(),
                const SizedBox(height: 12),
              ],
              if ((main.recentBlogs.isNotEmpty)) ...[
                Text(
                  '최근 본 블로그 포스트',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                ...main.recentBlogs
                    .take(3)
                    .map((b) => _recentBlogTile(context, b))
                    .toList(),
                const SizedBox(height: 12),
              ],
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildFolderTreeSidebar(
    BuildContext context,
    LibraryViewModel vm,
  ) {
    final all = vm.folders; // List<LibraryFolder>(id, name, count, parentId)

    // parentId -> children 매핑
    final Map<String?, List<LibraryFolder>> byParent = {};
    for (final f in all) {
      byParent.putIfAbsent(f.parentId, () => <LibraryFolder>[]).add(f);
    }

    List<Widget> buildBranch(String? parentId, int depth) {
      final children = byParent[parentId] ?? const <LibraryFolder>[];
      return children.expand((f) {
        final hasChildren = (byParent[f.id]?.isNotEmpty ?? false);
        final expanded = _isExpanded(f.id);

        final row = _folderRow(
          context: context,
          folder: f,
          depth: depth,
          hasChildren: hasChildren,
          expanded: expanded,
          onTap: () => Navigator.of(
            context,
          ).pushNamed('/library', arguments: {'folderId': f.id}),
          onToggle: hasChildren ? () => _toggleExpanded(f.id) : null,
        );

        if (!hasChildren || !expanded) {
          return [row];
        }
        return [row, ...buildBranch(f.id, depth + 1)];
      }).toList();
    }

    // 루트부터
    return buildBranch(null, 0);
  }

  Widget _recentPaperTile(BuildContext context, Paper p) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.article_outlined, size: 18),
      title: Text(
        p.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: p.authors.isNotEmpty
          ? Text(
              p.authors.join(', '),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )
          : null,
      onTap: () => Navigator.of(context).pushNamed('/paper', arguments: p.id),
    );
  }

  Widget _folderRow({
    required BuildContext context,
    required LibraryFolder folder,
    required int depth,
    required bool hasChildren,
    required bool expanded,
    required VoidCallback onTap,
    VoidCallback? onToggle,
  }) {
    // 들여쓰기: depth * 14 + base
    final left = 8.0 + depth * 14.0;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.only(left: left, right: 6, top: 6, bottom: 6),
        child: Row(
          children: [
            const Icon(Icons.folder_outlined, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                folder.name,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            Text(
              '${folder.count}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(width: 6),

            // 토글 버튼 유무와 관계없이 24x24 폭을 확보해 열 정렬 유지
            hasChildren
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      iconSize: 18,
                      tooltip: expanded ? 'Collapse' : 'Expand',
                      onPressed: onToggle,
                      icon: Icon(
                        expanded ? Icons.expand_more : Icons.chevron_right,
                      ),
                    ),
                  )
                : const SizedBox(width: 24, height: 24),
          ],
        ),
      ),
    );
  }

  Widget _recentBlogTile(BuildContext context, BlogReviewSummary b) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.article_outlined, size: 18),
      title: Text(
        b.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: (b.user?.username.isNotEmpty ?? false)
          ? Text(
              b.user!.username,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            )
          : null,
      onTap: () => Navigator.of(context).pushNamed('/blog', arguments: b.id),
    );
  }
}
