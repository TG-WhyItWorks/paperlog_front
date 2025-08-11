// lib/features/library/view/library_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:paperlog_front/features/dashboard/widgets/header_widget.dart';
import 'package:paperlog_front/features/dashboard/widgets/sidebar_widget.dart';
import 'package:paperlog_front/features/dashboard/viewmodel/dashboard_viewmodel.dart';
import '../viewmodel/library_viewmodel.dart';
import '../../../core/models/library_models.dart';
import '../../auth/viewmodel/auth_viewmodel.dart';
import '../../../core/models/paper_model.dart';

class LibraryPage extends StatelessWidget {
  final LibrarySection? initialSection;
  //0 = library, 1= Recent
  final int initialTab;
  const LibraryPage({Key? key, this.initialSection, this.initialTab = 0})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final main = context.watch<MainViewModel>();
    final vm = context.watch<LibraryViewModel>();
    final auth = context.watch<AuthViewModel>();
    vm.bindAuth(auth);

    final args = ModalRoute.of(context)?.settings.arguments;
    int effectiveTab = initialTab;
    LibrarySection? effectiveSection = initialSection;
    if (args is Map) {
      final t = args['initialTab'];
      if (t is int) effectiveTab = t.clamp(0, 1);
      final sec = args['section'];
      if (sec is LibrarySection) effectiveSection = sec;
    } else if (args is int) {
      effectiveTab = args.clamp(0, 1);
    } else if (args is LibrarySection) {
      effectiveSection = args;
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(80),
        child: HeaderWidget(),
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SidebarWidget(),
          AnimatedContainer(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeInOutCubic,
            width: 1,
            color: main.isSidebarOpen
                ? Theme.of(context).dividerColor
                : Colors.transparent,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: vm.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : vm.error != null
                  ? Center(child: Text('로드 실패: ${vm.error}'))
                  : DefaultTabController(
                      length: 2,
                      initialIndex: effectiveTab,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TabBar(
                            isScrollable: false,
                            labelColor: Theme.of(context).colorScheme.onSurface,
                            tabs: const [
                              Tab(text: 'Library'),
                              Tab(text: 'Recent'),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Expanded(
                            child: TabBarView(
                              children: [
                                _LibraryContent(
                                  vm: vm,
                                  initialSection: effectiveSection,
                                ),
                                const _RecentContent(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
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
              hintText: 'Search on bookmarks...',
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

        //체크박스 선택시 나타나는 행
        ClipRect(
          // overflow 깔끔히 자르기
          child: AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeInOutCubic,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) {
                // 위에서 내려오고(enter), 위로 사라짐(exit)
                final slide = Tween<Offset>(
                  begin: const Offset(0, -0.25), // 위(-y)에서 시작
                  end: Offset.zero,
                ).animate(animation);

                return SlideTransition(
                  position: slide,
                  child: FadeTransition(opacity: animation, child: child),
                );
              },
              child: vm.isSelecting
                  ? Container(
                      key: const ValueKey('select-bar'), // AnimatedSwitcher 구분
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceVariant.withOpacity(0.35),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Theme.of(
                            context,
                          ).dividerColor.withOpacity(0.6),
                        ),
                      ),
                      child: Row(
                        children: [
                          // --- Move ---
                          PopupMenuButton<String>(
                            tooltip: 'Move',
                            itemBuilder: (ctx) => const [
                              PopupMenuItem(
                                value: 'want',
                                child: Text('Move → Want to read'),
                              ),
                              PopupMenuItem(
                                value: 'reading',
                                child: Text('Move → Reading'),
                              ),
                              PopupMenuItem(
                                value: 'completed',
                                child: Text('Move → Completed'),
                              ),
                              PopupMenuDivider(),
                              PopupMenuItem(
                                value: 'folder',
                                child: Text('Move → Folder…'),
                              ),
                            ],
                            onSelected: (v) async {
                              if (v == 'want')
                                await vm.moveSelectedToSection(
                                  LibrarySection.wantToRead,
                                );
                              if (v == 'reading')
                                await vm.moveSelectedToSection(
                                  LibrarySection.reading,
                                );
                              if (v == 'completed')
                                await vm.moveSelectedToSection(
                                  LibrarySection.completed,
                                );
                              if (v == 'folder') {
                                final id = await _pickFolder(context, vm);
                                if (id != null)
                                  await vm.moveSelectedToFolder(id);
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
                          TextButton(
                            onPressed: vm.clearSelection,
                            child: const Text('Cancel'),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink(key: ValueKey('empty')),
            ),
          ),
        ),

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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      'My Collections',
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (auth.isLoggedIn)
                    IconButton(
                      tooltip: 'Add (upload or new folder)',
                      icon: const Icon(Icons.add),
                      onPressed: () => _showCollectionsActions(context, vm),
                    ),
                ],
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

class _RecentContent extends StatelessWidget {
  const _RecentContent();

  @override
  Widget build(BuildContext context) {
    final main = context.watch<MainViewModel>();
    final papers = (main.recentPapers ?? const <Paper>[]);
    final blogs = (main.recentBlogs ?? const <BlogPostSummary>[]);

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            '최근 본 논문',
            style: Theme.of(
              context,
            ).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        if (papers.isEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text('없음', style: Theme.of(context).textTheme.bodySmall),
          )
        else
          ...papers.map(
            (p) => ListTile(
              dense: true,
              contentPadding: const EdgeInsets.only(right: 8),
              leading: const Icon(Icons.article_outlined, size: 18),
              title: Text(
                p.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              subtitle: (p.authors != null && p.authors!.isNotEmpty)
                  ? Text(
                      p.authors!.join(', '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )
                  : null,
              onTap: () =>
                  Navigator.of(context).pushNamed('/paper', arguments: p.id),
            ),
          ),
        const Divider(height: 32),

        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            '최근 본 포스트',
            style: Theme.of(
              context,
            ).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        if (blogs.isEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text('없음', style: Theme.of(context).textTheme.bodySmall),
          )
        else
          ...blogs.map(
            (b) => ListTile(
              dense: true,
              contentPadding: const EdgeInsets.only(right: 8),
              leading: const Icon(Icons.article_outlined, size: 18),
              title: Text(
                b.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              subtitle: (b.source?.isNotEmpty ?? false)
                  ? Text(
                      b.source!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    )
                  : null,
              onTap: () =>
                  Navigator.of(context).pushNamed('/blog', arguments: b.url),
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
  // if (all.isEmpty) {
  //   return const [
  //     Padding(padding: EdgeInsets.only(left: 8, bottom: 12), child: Text('없음')),
  //   ];
  // }
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
            await vm.renameFolder(f.id!, newName);
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
            await vm.deleteFolder(f.id!);
            await vm.refresh();
          }
        },
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

class _PaperRow extends StatefulWidget {
  final LibraryItem item;
  const _PaperRow({required this.item});

  @override
  State<_PaperRow> createState() => _PaperRowState();
}

class _PaperRowState extends State<_PaperRow> {
  bool _hover = false;
  String _dateString(Paper p) {
    if (p.year != null) return '${p.year}.';
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<LibraryViewModel>();
    final p = widget.item.paper;
    final selected = vm.isPaperSelected(p.id);

    final authors = (p.authors != null && p.authors!.isNotEmpty)
        ? p.authors!.join(', ')
        : '';

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
class _CollectionTile extends StatefulWidget {
  final String title;
  final int count;
  final bool initiallyExpanded;
  final List<Widget> children;
  final VoidCallback? onAdd;
  final VoidCallback? onRename;
  final VoidCallback? onDelete;
  const _CollectionTile({
    required this.title,
    required this.count,
    this.initiallyExpanded = false,
    this.children = const [],
    this.onAdd,
    this.onRename,
    this.onDelete,
  });

  @override
  State<_CollectionTile> createState() => _CollectionTileState();
}

class _CollectionTileState extends State<_CollectionTile> {
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
              if (widget.onAdd != null && !_hover)
                IconButton(
                  tooltip: 'Add to folder',
                  icon: const Icon(Icons.add, size: 18),
                  onPressed: widget.onAdd,
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

// 상단 My Collections + 버튼 액션: Upload / New folder
void _showCollectionsActions(BuildContext context, LibraryViewModel vm) {
  showModalBottomSheet(
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
                await vm.createFolder(name.trim(), parentFolderId: null);
              }
            },
          ),
        ],
      ),
    ),
  );
}

Future<String?> _pickFolder(BuildContext context, LibraryViewModel vm) async {
  String? selected;
  return showDialog<String>(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Select folder'),
      content: SizedBox(
        width: 360,
        height: 320,
        child: ListView(
          children: vm.folders
              .map(
                (f) => RadioListTile<String>(
                  value: f.id!,
                  groupValue: selected,
                  onChanged: (v) => selected = v,
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
}
