// lib/features/library/view/library_page.dart
import 'package:flutter/material.dart';
import 'package:paperlog_front/features/library/widgets/library_recent_tab.dart';
import 'package:provider/provider.dart';
import 'package:paperlog_front/features/dashboard/widgets/header_widget.dart';
import 'package:paperlog_front/features/dashboard/widgets/sidebar_widget.dart';
import 'package:paperlog_front/features/dashboard/viewmodel/dashboard_viewmodel.dart';
import '../viewmodel/library_viewmodel.dart';
import '../../../core/models/library_models.dart';
import '../../auth/viewmodel/auth_viewmodel.dart';
import '../widgets/library_search_field.dart';
import '../widgets/library_selection_toolbar.dart';
import '../widgets/library_section_tile.dart';
import '../widgets/library_paper_row.dart';
import '../widgets/library_collection_tile.dart';
import '../widgets/library_folder_actions.dart';
import '../widgets/folder_tree.dart';

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
      if (t is int) effectiveTab = (t.clamp(0, 1));
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
                                const LibraryRecentTab(),
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
    final auth = context.watch<AuthViewModel>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 북마크 검색
        const LibrarySearchField(),
        const SizedBox(height: 12),

        //체크박스 선택시 나타나는 행 (Move/Delete/Cancel)
        LibrarySelectionToolbar(
          pickFolder: () => LibraryFolderActions.pickFolder(context, vm),
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
              LibrarySectionTile(
                title: 'Want to read',
                items: vm.section(LibrarySection.wantToRead),
                initiallyExpanded: _isInit(LibrarySection.wantToRead),
              ),
              LibrarySectionTile(
                title: 'Reading',
                items: vm.section(LibrarySection.reading),
                initiallyExpanded: _isInit(LibrarySection.reading),
              ),
              LibrarySectionTile(
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
                      onPressed: () =>
                          LibraryFolderActions.showCollections(context, vm),
                    ),
                ],
              ),
              LibraryCollectionTile(
                title: 'My publications',
                count: vm.section(LibrarySection.myPublications).length,
                initiallyExpanded: _isInit(LibrarySection.myPublications),
                children: vm
                    .section(LibrarySection.myPublications)
                    .map<Widget>((e) => LibraryPaperRow(item: e))
                    .toList(),
              ),
              if (auth.isLoggedIn)
                LibraryCollectionTile(
                  title: 'Private Papers',
                  count: vm.section(LibrarySection.private).length,
                  initiallyExpanded: _isInit(LibrarySection.private),
                  children: vm
                      .section(LibrarySection.private)
                      .map<Widget>((e) => LibraryPaperRow(item: e))
                      .toList(),
                ),
              // 사용자 폴더도 Expandable
              FolderTree(
                vm: vm,
                onAddToFolder: (id) =>
                    LibraryFolderActions.showFolder(context, vm, id),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
