import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../dashboard/widgets/header_widget.dart';
import '../../dashboard/widgets/sidebar_widget.dart';
import '../viewmodel/blog_feed_viewmodel.dart';
import '../viewmodel/blog_search_viewmodel.dart';
import '../widgets/review_card.dart';
import '../widgets/review_list_item.dart';
import '../viewmodel/blog_discover_viewmodel.dart';
import '../widgets/review_ranking_item.dart';
import '../widgets/review_grid_card.dart';

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
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TabBar(
                        labelColor: Theme.of(context).colorScheme.onSurface,
                        tabs: const [
                          Tab(text: '내 포스트'),
                          Tab(text: '탐색'),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: TabBarView(
                          children: [
                            const _MyBlogTab(),

                            // 🔽 검색 탭: 인자로 초기 검색 수행
                            ChangeNotifierProvider(
                              create: (_) => BlogDiscoverViewModel()..load(),
                              child: const _DiscoverTab(),
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
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 980),
        child: ListView.separated(
          itemCount: vm.items.length + 1,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (ctx, i) {
            // 헤더 섹션
            if (i == 0) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Text(
                      '전체 글',
                      style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.view_list_outlined),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.view_module_outlined),
                    ),
                  ],
                ),
              );
            }
            final s = vm.items[i - 1];
            return ReviewListItem(
              summary: s,
              canManage: true,
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
                    'content': s.content,
                  },
                );
                if (updated == true)
                  await ctx.read<BlogFeedViewModel>().loadMine();
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
        ),
      ),
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
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 980),
              child: ListView.separated(
                itemCount: vm.results.length + (vm.results.isEmpty ? 0 : 1),
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, i) {
                  if (vm.results.isEmpty) return const SizedBox.shrink();
                  if (i == 0) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Text(
                            '검색 결과',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.view_list_outlined),
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.view_module_outlined),
                          ),
                        ],
                      ),
                    );
                  }
                  final s = vm.results[i - 1];
                  return ReviewListItem(summary: s);
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DiscoverTab extends StatefulWidget {
  const _DiscoverTab();

  @override
  State<_DiscoverTab> createState() => _DiscoverTabState();
}

class _DiscoverTabState extends State<_DiscoverTab> {
  final _page = PageController(viewportFraction: 1.0);
  int _idx = 0;
  final _categories = const [
    'AI',
    'NLP',
    'LLM',
    'Cloud',
    'DB',
    'Security',
    'Vision',
    'Recsys',
  ];

  @override
  void dispose() {
    _page.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<BlogDiscoverViewModel>();
    if (vm.loading) return const Center(child: CircularProgressIndicator());
    if (vm.error != null) return Center(child: Text('로드 실패: ${vm.error}'));

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1100),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // === Hero Carousel ===
              if (vm.featured.isNotEmpty)
                Column(
                  children: [
                    AspectRatio(
                      aspectRatio: 16 / 6.5,
                      child: PageView.builder(
                        controller: _page,
                        onPageChanged: (i) => setState(() => _idx = i),
                        itemCount: vm.featured.length,
                        itemBuilder: (ctx, i) {
                          final s = vm.featured[i];
                          // 썸네일 대충 추출 (Grid와 동일 로직 복붙)
                          String? _thumbFrom(String text) {
                            final md = RegExp(r'!\[[^\]]*\]\((.*?)\)');
                            final m = md.firstMatch(text);
                            if (m != null) return m.group(1);
                            final url = RegExp(
                              r'(https?:\/\/[^\s)]+?\.(?:png|jpe?g|gif|webp))',
                              caseSensitive: false,
                            );
                            final m2 = url.firstMatch(text);
                            return m2?.group(1);
                          }

                          final thumb = _thumbFrom(s.content);
                          return InkWell(
                            onTap: () => Navigator.of(
                              context,
                            ).pushNamed('/blog', arguments: s.id),
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Container(
                                    width: double.infinity,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.surfaceContainerHighest,
                                    child: thumb == null
                                        ? Icon(
                                            Icons.image_outlined,
                                            size: 72,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface
                                                .withOpacity(.35),
                                          )
                                        : Image.network(
                                            thumb,
                                            fit: BoxFit.cover,
                                          ),
                                  ),
                                ),
                                // 그라데이션 + 타이틀
                                Positioned.fill(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      gradient: LinearGradient(
                                        begin: Alignment.bottomCenter,
                                        end: Alignment.topCenter,
                                        colors: [
                                          Colors.black.withOpacity(.55),
                                          Colors.transparent,
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: 20,
                                  right: 20,
                                  bottom: 18,
                                  child: Text(
                                    s.title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w800,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(vm.featured.length, (i) {
                        final active = i == _idx;
                        return Container(
                          width: active ? 8 : 6,
                          height: active ? 8 : 6,
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: active
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.outlineVariant,
                          ),
                        );
                      }),
                    ),
                  ],
                ),

              const SizedBox(height: 18),

              // === Ranking List ===
              if (vm.ranking.isNotEmpty) ...[
                Text(
                  '인기 글',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Divider(),
                ...List.generate(vm.ranking.length, (i) {
                  final s = vm.ranking[i];
                  return ReviewRankingItem(rank: i + 1, summary: s);
                }),
              ],

              const SizedBox(height: 16),

              // === Category Chips ===
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _categories.map((c) {
                  final sel = vm.selectedCategory == c;
                  return FilterChip(
                    selected: sel,
                    label: Text(c),
                    onSelected: (_) =>
                        context.read<BlogDiscoverViewModel>().pickCategory(c),
                  );
                }).toList(),
              ),

              const SizedBox(height: 12),

              // === Grid: 선택 카테고리 or 최신 ===
              Row(
                children: [
                  Text(
                    vm.selectedCategory == null
                        ? '최신 글'
                        : '${vm.selectedCategory} 추천',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LayoutBuilder(
                builder: (ctx, c) {
                  final cross = c.maxWidth >= 1024
                      ? 3
                      : (c.maxWidth >= 720 ? 2 : 1);
                  final items = vm.selectedCategory == null
                      ? vm.latest
                      : vm.categoryItems;
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: items.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: cross,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 18,
                      childAspectRatio: 16 / 12,
                    ),
                    itemBuilder: (_, i) => ReviewGridCard(summary: items[i]),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
