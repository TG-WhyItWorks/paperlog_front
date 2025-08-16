import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../dashboard/widgets/header_widget.dart';
import '../../dashboard/widgets/sidebar_widget.dart';
import '../viewmodel/blog_feed_viewmodel.dart';
import '../viewmodel/blog_search_viewmodel.dart';
import '../widgets/review_card.dart';

class BlogHomePage extends StatelessWidget {
  const BlogHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    String initialKeyword = '';
    bool initialOrderByVotes = false;
    int initialTabIndex = 0; // 0: 내 포스트, 1: 검색

    if (args is Map) {
      final tab = (args['tab'] ?? '').toString();
      if (tab == 'search') initialTabIndex = 1;
      initialKeyword = (args['keyword'] ?? '').toString();
      initialOrderByVotes = args['orderByVotes'] == true;
    }
    return ChangeNotifierProvider(
      // 페이지 전체에서 공유
      create: (_) => BlogFeedViewModel()..loadMine(),
      child: DefaultTabController(
        length: 2,
        initialIndex: initialTabIndex,
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
                          Tab(text: '내 포스트'),
                          Tab(text: '둘러보기'),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: TabBarView(
                          children: [
                            const _MyBlogTab(),

                            // 🔽 검색 탭: 인자로 초기 검색 수행
                            ChangeNotifierProvider(
                              create: (_) {
                                final vm = BlogSearchViewModel();
                                if (initialKeyword.isNotEmpty) {
                                  vm.setKeyword(initialKeyword);
                                  vm.setOrderByVotes(initialOrderByVotes);
                                  vm.search(); // 자동 검색
                                }
                                return vm;
                              },
                              child: _SearchTab(
                                initialKeyword: initialKeyword,
                                initialOrderByVotes: initialOrderByVotes,
                              ),
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
          floatingActionButton: Builder(
            // FAB도 같은 BlogFeedViewModel을 읽을 수 있게 Builder로 하위 context 확보
            builder: (ctx) => FloatingActionButton.extended(
              onPressed: () async {
                final created = await Navigator.of(ctx).pushNamed('/blog/new');
                if (created == true) {
                  await ctx.read<BlogFeedViewModel>().loadMine(); // 즉시 리로드
                }
              },
              icon: const Icon(Icons.edit),
              label: const Text('Write'),
            ),
          ),
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
      itemBuilder: (ctx, i) {
        final s = vm.items[i];
        return ReviewCard(
          summary: s,
          canManage: true, // 내 글 탭이므로 관리 허용
          onTap: () async {
            await Navigator.of(ctx).pushNamed('/blog', arguments: s.id);
            await ctx.read<BlogFeedViewModel>().loadMine();
          },
          onEdit: () async {
            final updated = await Navigator.of(ctx).pushNamed(
              '/blog/edit',
              arguments: {
                'reviewId': s.id,
                'title': s.title,
                'content': s.content, // summary에 있는 값으로 미리 채움
                // paperId는 update에서 사용하지 않으니 생략 가능
              },
            );
            if (updated == true) {
              await ctx.read<BlogFeedViewModel>().loadMine();
            }
          },
          onDelete: () async {
            final ok = await showDialog<bool>(
              context: ctx,
              builder: (_) => AlertDialog(
                title: const Text('삭제'),
                content: const Text('정말 삭제할까요?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text('취소'),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text('삭제'),
                  ),
                ],
              ),
            );
            if (ok != true) return;
            try {
              await ctx.read<BlogFeedViewModel>().deleteReview(s.id);
              ScaffoldMessenger.of(
                ctx,
              ).showSnackBar(const SnackBar(content: Text('삭제 완료')));
            } catch (e) {
              ScaffoldMessenger.of(
                ctx,
              ).showSnackBar(SnackBar(content: Text('삭제 실패: $e')));
            }
          },
        );
      },
    );
  }
}

// 🔽 초기 키워드/정렬을 입력창에도 반영
class _SearchTab extends StatefulWidget {
  final String initialKeyword;
  final bool initialOrderByVotes;
  const _SearchTab({
    this.initialKeyword = '',
    this.initialOrderByVotes = false,
    super.key,
  });

  @override
  State<_SearchTab> createState() => _SearchTabState();
}

class _SearchTabState extends State<_SearchTab> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initialKeyword);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

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
