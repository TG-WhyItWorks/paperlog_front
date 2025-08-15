import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../dashboard/widgets/header_widget.dart';
import '../../dashboard/widgets/sidebar_widget.dart';
import '../../dashboard/viewmodel/dashboard_viewmodel.dart';
import '../viewmodel/blog_feed_viewmodel.dart';
import '../viewmodel/blog_search_viewmodel.dart';
import '../widgets/review_card.dart';

class BlogHomePage extends StatelessWidget {
  const BlogHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: const PreferredSize(
          preferredSize: Size.fromHeight(80),
          child: HeaderWidget(),
        ),
        body: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SidebarWidget(),
            VerticalDivider(width: 1, color: Theme.of(context).dividerColor),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TabBar(
                      labelColor: Theme.of(context).colorScheme.onSurface,
                      tabs: const [
                        Tab(text: 'My Blog'),
                        Tab(text: 'Search'),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: TabBarView(
                        children: [
                          ChangeNotifierProvider(
                            create: (_) => BlogFeedViewModel()..loadMine(),
                            child: const _MyBlogTab(),
                          ),
                          ChangeNotifierProvider(
                            create: (_) => BlogSearchViewModel(),
                            child: const _SearchTab(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => Navigator.of(context).pushNamed('/blog/new'),
          icon: const Icon(Icons.edit),
          label: const Text('Write'),
        ),
      ),
    );
  }
}

class _MyBlogTab extends StatelessWidget {
  const _MyBlogTab();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<BlogFeedViewModel>();
    if (vm.loading) return const Center(child: CircularProgressIndicator());
    if (vm.error != null) return Center(child: Text('로드 실패: ${vm.error}'));
    if (vm.items.isEmpty) return const Center(child: Text('작성한 포스트가 없습니다.'));
    return ListView.separated(
      itemCount: vm.items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) => ReviewCard(summary: vm.items[i]),
    );
  }
}

class _SearchTab extends StatefulWidget {
  const _SearchTab();

  @override
  State<_SearchTab> createState() => _SearchTabState();
}

class _SearchTabState extends State<_SearchTab> {
  final _ctrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<BlogSearchViewModel>();
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _ctrl,
                decoration: const InputDecoration(
                  hintText: '아이디/제목/논문제목 검색',
                  prefixIcon: Icon(Icons.search),
                ),
                onSubmitted: (_) => context.read<BlogSearchViewModel>()
                  ..setKeyword(_ctrl.text)
                  ..search(),
              ),
            ),
            const SizedBox(width: 8),
            DropdownButton<BlogSearchFilter>(
              value: vm.filter,
              onChanged: (f) =>
                  context.read<BlogSearchViewModel>().setFilter(f!),
              items: const [
                DropdownMenuItem(
                  value: BlogSearchFilter.all,
                  child: Text('전체'),
                ),
                DropdownMenuItem(
                  value: BlogSearchFilter.title,
                  child: Text('제목'),
                ),
                DropdownMenuItem(
                  value: BlogSearchFilter.user,
                  child: Text('작성자'),
                ),
              ],
            ),
            const SizedBox(width: 8),
            FilterChip(
              label: const Text('좋아요순'),
              selected: vm.orderByVotes,
              onSelected: (v) => context.read<BlogSearchViewModel>()
                ..setOrderByVotes(v)
                ..search(),
            ),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: () => context.read<BlogSearchViewModel>()
                ..setKeyword(_ctrl.text)
                ..search(),
              child: const Text('검색'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (vm.loading) const LinearProgressIndicator(),
        const SizedBox(height: 8),
        if (vm.error != null) Text('검색 실패: ${vm.error}'),
        Expanded(
          child: ListView.separated(
            itemCount: vm.results.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) => ReviewCard(summary: vm.results[i]),
          ),
        ),
      ],
    );
  }
}
