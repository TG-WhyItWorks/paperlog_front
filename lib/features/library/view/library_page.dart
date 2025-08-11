import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:paperlog_front/features/dashboard/widgets/header_widget.dart';
import 'package:paperlog_front/features/dashboard/widgets/sidebar_widget.dart';
import 'package:paperlog_front/features/dashboard/viewmodel/dashboard_viewmodel.dart';
import '../viewmodel/library_viewmodel.dart';
import '../../../core/models/library_models.dart';

class LibraryPage extends StatelessWidget {
  const LibraryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<LibraryViewModel>();

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
                  : _LibraryContent(vm: vm),
            ),
          ),
        ],
      ),
    );
  }
}

class _LibraryContent extends StatelessWidget {
  final LibraryViewModel vm;
  const _LibraryContent({required this.vm});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 상단 탭 (Papers | Private Notes | Conversations)
        DefaultTabController(
          length: 3,
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: TabBar(
                  isScrollable: true,
                  labelColor: Theme.of(context).colorScheme.primary,
                  unselectedLabelColor: text.bodyMedium?.color,
                  dividerColor: Theme.of(context).dividerColor,
                  tabs: const [
                    Tab(text: 'Papers'),
                    Tab(text: 'Private Notes'),
                    Tab(text: 'Conversations'),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),

        // 검색바
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

        // 액션 버튼
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: [
            OutlinedButton.icon(
              onPressed: () {
                /* TODO: 파일 업로드 */
              },
              icon: const Icon(Icons.upload_file),
              label: const Text('Upload Private Paper'),
            ),
            OutlinedButton.icon(
              onPressed: () {
                /* TODO: 폴더 생성 */
              },
              icon: const Icon(Icons.create_new_folder_outlined),
              label: const Text('New folder'),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // 섹션들
        Expanded(
          child: ListView(
            children: [
              _SectionTile(
                title: 'Want to read',
                items: vm.section(LibrarySection.wantToRead),
              ),
              _SectionTile(
                title: 'Reading',
                items: vm.section(LibrarySection.reading),
              ),
              _SectionTile(
                title: 'Completed',
                items: vm.section(LibrarySection.completed),
              ),
              _SectionTile(
                title: 'My publications',
                items: vm.section(LibrarySection.myPublications),
              ),
              _SectionTile(
                title: 'Private Papers',
                items: vm.section(LibrarySection.private),
              ),
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
  const _SectionTile({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.only(left: 8),
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
              onTap: () {
                Navigator.of(context).pushNamed('/paper', arguments: paper.id);
              },
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
        onPressed: () {
          /* TODO: more menu */
        },
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
