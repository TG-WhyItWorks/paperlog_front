import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../dashboard/widgets/header_widget.dart';
import '../../dashboard/widgets/sidebar_widget.dart';
import '../../dashboard/viewmodel/dashboard_viewmodel.dart';
import '../../../core/models/review_models.dart';
import '../viewmodel/blog_detail_viewmodel.dart';
import '../../auth/viewmodel/auth_viewmodel.dart';

class BlogDetailPage extends StatefulWidget {
  final int reviewId;
  const BlogDetailPage({super.key, required this.reviewId});

  // routes['/blog'] 사용 시:
  // return BlogDetailPage.fromArgs(ModalRoute.of(ctx)?.settings.arguments);
  static Widget fromArgs(Object? args) {
    int? id;
    if (args is int) id = args;
    if (args is Map && args['id'] is int) id = args['id'] as int;
    return ChangeNotifierProvider(
      create: (_) => BlogDetailViewModel()..load(id ?? 0),
      child: BlogDetailPage(reviewId: id ?? 0),
    );
  }

  @override
  State<BlogDetailPage> createState() => _BlogDetailPageState();
}

class _BlogDetailPageState extends State<BlogDetailPage> {
  bool _trackedRecent = false; // 최근 보기 기록 플래그

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<BlogDetailViewModel>();

    if (vm.loading) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: const PreferredSize(
          preferredSize: Size.fromHeight(80),
          child: HeaderWidget(),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (vm.error != null) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: const PreferredSize(
          preferredSize: Size.fromHeight(80),
          child: HeaderWidget(),
        ),
        body: Center(child: Text('오류: ${vm.error}')),
      );
    }

    final r = vm.review!;
    final meId = context.watch<AuthViewModel>().user?.id;

    // 리뷰가 준비되면 최근 본 포스트에 1번만 기록
    if (!_trackedRecent) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final summary = BlogReviewSummary(
          id: r.id,
          title: r.title,
          content: r.content,
          modifyDate: r.modifyDate,
          user: r.user,
          voteCount: r.voteCount,
        );
        context.read<MainViewModel>().viewedBlog(summary);
        setState(() => _trackedRecent = true);
      });
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
          if (context.watch<MainViewModel>().isSidebarOpen)
            const SidebarWidget(),
          VerticalDivider(
            width: 1,
            thickness: 1,
            color: Theme.of(context).dividerColor,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 상단 액션(좋아요)
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          r.title,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),
                      IconButton(
                        tooltip: vm.liked ? '좋아요 취소' : '좋아요',
                        onPressed: vm.likeBusy
                            ? null
                            : () async {
                                // 로그인 확인(미로그인 → 로그인 페이지로)
                                final me = context.read<AuthViewModel>().user;
                                if (me == null) {
                                  if (!mounted) return;
                                  Navigator.of(context).pushNamed('/login');
                                  return;
                                }

                                try {
                                  await context
                                      .read<BlogDetailViewModel>()
                                      .toggleLike();
                                } catch (e) {
                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('좋아요 처리 실패: $e')),
                                  );
                                }
                              },
                        icon: Icon(
                          vm.liked ? Icons.favorite : Icons.favorite_border,
                        ),
                      ),
                      if (meId != null && r.user?.id == meId) // 내 글일 때만
                        PopupMenuButton<String>(
                          onSelected: (v) async {
                            if (v == 'edit') {
                              final updated = await Navigator.of(context)
                                  .pushNamed(
                                    '/blog/edit',
                                    arguments: {
                                      'reviewId': r.id,
                                      'title': r.title,
                                      'content': r.content,
                                      'paperId': r.paperId,
                                    },
                                  );
                              if (updated == true) await vm.reload();
                            }
                            if (v == 'delete') {
                              final ok = await showDialog<bool>(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: const Text('삭제'),
                                  content: const Text('정말 삭제할까요?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: const Text('취소'),
                                    ),
                                    FilledButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      child: const Text('삭제'),
                                    ),
                                  ],
                                ),
                              );
                              if (ok == true) {
                                await vm.deleteCurrent();
                                if (!mounted) return;
                                Navigator.of(
                                  context,
                                ).pop({'deleted': true, 'reviewId': r.id});
                              }
                            }
                          },
                          itemBuilder: (_) => const [
                            PopupMenuItem(value: 'edit', child: Text('수정')),
                            PopupMenuItem(value: 'delete', child: Text('삭제')),
                          ],
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // 제목/메타
                  Text(
                    r.title,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(r.user?.username ?? 'unknown'),
                      const SizedBox(width: 12),
                      Text('${r.createDate ?? r.modifyDate}'),
                      const Spacer(),
                      Icon(
                        Icons.favorite,
                        size: 18,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Text('${r.voteCount}'),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // 인용 논문으로 이동
                  if (r.paperId != null)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.of(
                          context,
                        ).pushNamed('/paper', arguments: '${r.paperId}'),
                        icon: const Icon(Icons.description_outlined),
                        label: const Text('인용 논문으로 이동'),
                      ),
                    ),

                  const SizedBox(height: 12),
                  Text(r.content),
                  const SizedBox(height: 16),

                  // 이미지들
                  if (r.images.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: r.images
                          .map(
                            (img) => ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                img.imagePath,
                                width: 160,
                                height: 120,
                                fit: BoxFit.cover,
                              ),
                            ),
                          )
                          .toList(),
                    ),

                  const SizedBox(height: 24),
                  Text(
                    'Comments',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),

                  // 댓글들
                  ...r.comments.map(
                    (c) => ListTile(
                      leading: const Icon(Icons.comment),
                      title: Text(c.user?.username ?? 'anon'),
                      subtitle: Text(c.content),
                      trailing: c.createDate != null
                          ? Text('${c.createDate}')
                          : null,
                    ),
                  ),
                  // TODO: 댓글 작성 입력창/등록 버튼 (API 준비되면 연결)
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
