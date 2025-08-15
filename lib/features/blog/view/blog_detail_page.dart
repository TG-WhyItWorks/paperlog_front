import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/blog_detail_viewmodel.dart';

class BlogDetailPage extends StatelessWidget {
  final int reviewId;
  const BlogDetailPage({super.key, required this.reviewId});

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
  Widget build(BuildContext context) {
    final vm = context.watch<BlogDetailViewModel>();
    if (vm.loading)
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    if (vm.error != null)
      return Scaffold(body: Center(child: Text('오류: ${vm.error}')));

    final r = vm.review!;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post'),
        actions: [
          IconButton(
            tooltip: vm.liked ? '좋아요 취소' : '좋아요',
            onPressed: () async {
              try {
                await context.read<BlogDetailViewModel>().toggleLike();
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('처리 실패: $e')));
                }
              }
            },
            icon: Icon(vm.liked ? Icons.favorite : Icons.favorite_border),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(r.title, style: Theme.of(context).textTheme.headlineSmall),
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
            Text('Comments', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ...r.comments.map(
              (c) => ListTile(
                leading: const Icon(Icons.comment),
                title: Text(c.user?.username ?? 'anon'),
                subtitle: Text(c.content),
                trailing: c.createDate != null ? Text('${c.createDate}') : null,
              ),
            ),
            // TODO: 댓글 작성 API 제공 시 입력창/등록 버튼 추가
          ],
        ),
      ),
    );
  }
}
