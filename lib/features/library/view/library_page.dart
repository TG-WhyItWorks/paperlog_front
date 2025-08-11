// lib/features/library/view/library_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:paperlog_front/features/dashboard/widgets/header_widget.dart';
import 'package:paperlog_front/features/dashboard/widgets/sidebar_widget.dart';
import 'package:paperlog_front/features/dashboard/viewmodel/dashboard_viewmodel.dart';
import '../viewmodel/library_viewmodel.dart';
import '../../../core/models/library_models.dart';
import '../../auth/viewmodel/auth_viewmodel.dart';

class LibraryPage extends StatelessWidget {
  final LibrarySection? initialSection;
  const LibraryPage({Key? key, this.initialSection}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<LibraryViewModel>();
    final auth = context.watch<AuthViewModel>();
    // Auth 변화 바인딩(최초 1회만 효과, 동일 인스턴스면 조용히 리턴)
    vm.bindAuth(auth);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(80),
        child: HeaderWidget(),
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (context.watch<MainViewModel>().isSidebarOpen)
            const SidebarWidget(),
          VerticalDivider(
            width: 1,
            thickness: 1,
            color: Theme.of(context).dividerColor,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: vm.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : vm.error != null
                  ? Center(child: Text('로드 실패: ${vm.error}'))
                  : _LibraryContent(vm: vm, initialSection: initialSection),
            ),
          ),
        ],
      ),
    );
  }
}

class _LibraryContent extends StatelessWidget {
  final LibraryViewModel vm;
  final LibrarySection? initialSection;
  const _LibraryContent({required this.vm, this.initialSection});

  bool _isInit(LibrarySection s) => initialSection == s;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final auth = context.watch<AuthViewModel>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 검색
        SizedBox(
          height: 44,
          child: TextField(
            onChanged: vm.updateQuery,
            decoration: InputDecoration(
              hintText: 'Search bookmarks...',
              prefixIcon: const Icon(Icons.search),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // 액션
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: [
            if (auth.isLoggedIn)
              OutlinedButton.icon(
                onPressed: () => context
                    .read<LibraryViewModel>()
                    .uploadPrivatePaper(context),
                icon: const Icon(Icons.upload_file),
                label: const Text('Upload Private Paper'),
              ),
            if (auth.isLoggedIn)
              OutlinedButton.icon(
                onPressed: () async {
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
                  if (name != null) {
                    await vm.createFolder(name, parentFolderId: null);
                  }
                },
                icon: const Icon(Icons.create_new_folder_outlined),
                label: const Text('New folder'),
              ),
          ],
        ),
        const SizedBox(height: 16),

        Expanded(
          child: ListView(
            children: [
              // ===== Quick Lists =====
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  'Quick Lists',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              _SectionTile(
                title: 'Want to read',
                items: vm.section(LibrarySection.wantToRead),
                initiallyExpanded: _isInit(LibrarySection.wantToRead),
              ),
              _SectionTile(
                title: 'Reading',
                items: vm.section(LibrarySection.reading),
                initiallyExpanded: _isInit(LibrarySection.reading),
              ),
              _SectionTile(
                title: 'Completed',
                items: vm.section(LibrarySection.completed),
                initiallyExpanded: _isInit(LibrarySection.completed),
              ),

              const Divider(height: 32),

              // ===== My Collections =====
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  'My Collections',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              _CollectionTile(
                title: 'My publications',
                count: vm.section(LibrarySection.myPublications).length,
                initiallyExpanded: _isInit(LibrarySection.myPublications),
                children: vm
                    .section(LibrarySection.myPublications)
                    .map<Widget>((e) => _PaperRow(item: e))
                    .toList(),
              ),
              if (auth.isLoggedIn)
                _CollectionTile(
                  title: 'Private Papers',
                  count: vm.section(LibrarySection.private).length,
                  initiallyExpanded: _isInit(LibrarySection.private),
                  children: vm
                      .section(LibrarySection.private)
                      .map<Widget>((e) => _PaperRow(item: e))
                      .toList(),
                ),
              // 사용자 폴더도 Expandable
              ..._buildFolderTree(context, vm),
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionTile extends StatelessWidget {
  final String title;
  final List<LibraryItem> items;
  final bool initiallyExpanded;
  const _SectionTile({
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
            : items.map<Widget>((e) => _PaperRow(item: e)).toList(),
      ),
    );
  }
}

List<Widget> _buildFolderTree(BuildContext context, LibraryViewModel vm) {
  final all = vm.folders;
  if (all.isEmpty) {
    return const [
      Padding(padding: EdgeInsets.only(left: 8, bottom: 12), child: Text('없음')),
    ];
  }
  // parentId -> children 매핑
  final Map<String?, List<LibraryFolder>> byParent = {};
  for (final f in all) {
    byParent.putIfAbsent(f.parentId, () => <LibraryFolder>[]).add(f);
  }
  // 루트부터 재귀적으로 그리기
  List<Widget> buildBranch(String? parentId) {
    final children = byParent[parentId] ?? const <LibraryFolder>[];
    return children.map((f) {
      final grandChildren = buildBranch(f.id);
      return _CollectionTile(
        title: f.name,
        count: f.count,
        initiallyExpanded: false,
        onAdd: () => _showFolderActions(context, vm, f.id),
        children: grandChildren.isEmpty
            ? const [
                Padding(
                  padding: EdgeInsets.only(left: 8, bottom: 12),
                  child: Text('없음'),
                ),
              ]
            : grandChildren,
      );
    }).toList();
  }

  return buildBranch(null);
}

class _PaperRow extends StatelessWidget {
  final LibraryItem item;
  const _PaperRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final paper = item.paper;
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.only(left: 0, right: 8),
      leading: const Icon(Icons.article_outlined, size: 18),
      title: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () => Navigator.of(
                context,
              ).pushNamed('/paper', arguments: paper.id),
              child: Text(
                paper.title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          if (item.isPrivate)
            Container(
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.4),
                ),
              ),
              child: Text(
                'Private',
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ),
        ],
      ),
      subtitle: Text(
        paper.abstractText,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: IconButton(
        icon: const Icon(Icons.more_horiz),
        onPressed: () {},
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

/// My Collections(가상/사용자 폴더) 확장용 타일
class _CollectionTile extends StatelessWidget {
  final String title;
  final int count;
  final bool initiallyExpanded;
  final List<Widget> children;
  final VoidCallback? onAdd;
  const _CollectionTile({
    required this.title,
    required this.count,
    this.initiallyExpanded = false,
    this.children = const [],
    this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        initiallyExpanded: initiallyExpanded,
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
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(width: 8),
                  _CountChip(count: count),
                ],
              ),
            ),
            if (onAdd != null)
              IconButton(
                tooltip: 'Add to folder',
                icon: const Icon(Icons.add, size: 18),
                onPressed: onAdd,
              ),
          ],
        ),
        children: children.isEmpty
            ? [
                Padding(
                  padding: const EdgeInsets.only(left: 8, bottom: 12),
                  child: Text(
                    '없음',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ]
            : children,
      ),
    );
  }
}

// 폴더 액션: Upload / New Folder
void _showFolderActions(
  BuildContext context,
  LibraryViewModel vm,
  String folderId,
) {
  showModalBottomSheet(
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
