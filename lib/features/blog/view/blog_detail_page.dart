import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../dashboard/widgets/header_widget.dart';
import '../../dashboard/widgets/sidebar_widget.dart';
import '../../dashboard/viewmodel/dashboard_viewmodel.dart';
import '../../../core/models/review_models.dart';
import '../viewmodel/blog_detail_viewmodel.dart';
import '../../auth/viewmodel/auth_viewmodel.dart';
import '../widgets/blog_markdown_with_toc.dart';

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
  final _commentCtrl = TextEditingController();

  @override
  void dispose() {
    _commentCtrl.dispose(); // ⭐ 추가
    super.dispose();
  }

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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 960),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ===== Article Header =====
                      Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: Theme.of(context).dividerColor,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 18, 12, 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      r.title,
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.w800,
                                          ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 12,
                                          child: Text(
                                            (r.user?.username ?? 'U')
                                                .characters
                                                .first
                                                .toUpperCase(),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(r.user?.username ?? 'unknown'),
                                        const SizedBox(width: 12),
                                        Text(
                                          '${r.createDate ?? r.modifyDate}',
                                          style: Theme.of(
                                            context,
                                          ).textTheme.labelMedium,
                                        ),
                                        const Spacer(),
                                        IconButton(
                                          tooltip: vm.liked ? '좋아요 취소' : '좋아요',
                                          onPressed: vm.likeBusy
                                              ? null
                                              : () async {
                                                  final me = context
                                                      .read<AuthViewModel>()
                                                      .user;
                                                  if (me == null) {
                                                    if (!mounted) return;
                                                    Navigator.of(
                                                      context,
                                                    ).pushNamed('/login');
                                                    return;
                                                  }
                                                  try {
                                                    await context
                                                        .read<
                                                          BlogDetailViewModel
                                                        >()
                                                        .toggleLike();
                                                  } catch (e) {
                                                    if (!mounted) return;
                                                    ScaffoldMessenger.of(
                                                      context,
                                                    ).showSnackBar(
                                                      SnackBar(
                                                        content: Text(
                                                          '좋아요 처리 실패: $e',
                                                        ),
                                                      ),
                                                    );
                                                  }
                                                },
                                          icon: Icon(
                                            vm.liked
                                                ? Icons.favorite
                                                : Icons.favorite_border,
                                          ),
                                        ),
                                        Text('${r.voteCount}'),
                                        if (meId != null && r.user?.id == meId)
                                          PopupMenuButton<String>(
                                            onSelected: (v) async {
                                              if (v == 'edit') {
                                                final updated =
                                                    await Navigator.of(
                                                      context,
                                                    ).pushNamed(
                                                      '/blog/edit',
                                                      arguments: {
                                                        'reviewId': r.id,
                                                        'title': r.title,
                                                        'content': r.content,
                                                        'paperId': r.paperId,
                                                      },
                                                    );
                                                if (updated == true)
                                                  await vm.reload();
                                              }
                                              if (v == 'delete') {
                                                final ok = await showDialog<bool>(
                                                  context: context,
                                                  builder: (_) => AlertDialog(
                                                    title: const Text('삭제'),
                                                    content: const Text(
                                                      '정말 삭제할까요?',
                                                    ),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () =>
                                                            Navigator.pop(
                                                              context,
                                                              false,
                                                            ),
                                                        child: const Text('취소'),
                                                      ),
                                                      FilledButton(
                                                        onPressed: () =>
                                                            Navigator.pop(
                                                              context,
                                                              true,
                                                            ),
                                                        child: const Text('삭제'),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                                if (ok == true) {
                                                  await vm.deleteCurrent();
                                                  if (!mounted) return;
                                                  Navigator.of(context).pop({
                                                    'deleted': true,
                                                    'reviewId': r.id,
                                                  });
                                                }
                                              }
                                            },
                                            itemBuilder: (_) => const [
                                              PopupMenuItem(
                                                value: 'edit',
                                                child: Text('수정'),
                                              ),
                                              PopupMenuItem(
                                                value: 'delete',
                                                child: Text('삭제'),
                                              ),
                                            ],
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    if (r.paperId != null)
                                      Wrap(
                                        spacing: 8,
                                        children: [
                                          OutlinedButton.icon(
                                            onPressed: () =>
                                                Navigator.of(context).pushNamed(
                                                  '/paper',
                                                  arguments: '${r.paperId}',
                                                ),
                                            icon: const Icon(
                                              Icons.description_outlined,
                                            ),
                                            label: const Text('인용 논문으로 이동'),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),
                      const Divider(),
                      const SizedBox(height: 14),

                      // ===== Article Body (Markdown styled) =====
                      BlogMarkdownWithToc(text: r.content),

                      const SizedBox(height: 16),

                      // ===== Inline images at the end =====
                      if (r.images.isNotEmpty)
                        Align(
                          alignment: Alignment.topCenter,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 820),
                            child: Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: r.images
                                  .map(
                                    (img) => ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.network(
                                        img.imagePath,
                                        width: 240,
                                        height: 160,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                        ),

                      const SizedBox(height: 24),
                      Text(
                        '댓글',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),

                      // 댓글 리스트
                      ...r.comments.map(
                        (c) => Card(
                          child: ListTile(
                            leading: const Icon(Icons.account_circle_outlined),
                            title: Text(c.user?.username ?? 'anon'),
                            subtitle: Text(c.content),
                            trailing: c.createDate != null
                                ? Text(
                                    '${c.createDate}',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.labelSmall,
                                  )
                                : null,
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),
                      // 댓글 작성
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _commentCtrl,
                                  minLines: 2,
                                  maxLines: 6,
                                  decoration: const InputDecoration(
                                    hintText: '댓글을 입력하세요',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              FilledButton.icon(
                                onPressed:
                                    context
                                        .watch<BlogDetailViewModel>()
                                        .commentBusy
                                    ? null
                                    : () async {
                                        final me = context
                                            .read<AuthViewModel>()
                                            .user;
                                        if (me == null) {
                                          if (!mounted) return;
                                          Navigator.of(
                                            context,
                                          ).pushNamed('/login');
                                          return;
                                        }
                                        final text = _commentCtrl.text.trim();
                                        if (text.isEmpty) {
                                          if (!mounted) return;
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text('댓글을 입력해 주세요.'),
                                            ),
                                          );
                                          return;
                                        }
                                        try {
                                          await context
                                              .read<BlogDetailViewModel>()
                                              .submitComment(text);
                                          if (!mounted) return;
                                          _commentCtrl.clear();
                                        } catch (e) {
                                          if (!mounted) return;
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text('등록 실패: $e'),
                                            ),
                                          );
                                        }
                                      },
                                icon:
                                    context
                                        .watch<BlogDetailViewModel>()
                                        .commentBusy
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(Icons.send),
                                label: const Text('등록'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
