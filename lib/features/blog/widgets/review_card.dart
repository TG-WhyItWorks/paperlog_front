// lib/features/blog/widgets/review_card.dart
import 'package:flutter/material.dart';
import '../../../core/models/review_models.dart';

class ReviewCard extends StatelessWidget {
  final BlogReviewSummary summary;
  final bool canManage;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;

  const ReviewCard({
    super.key,
    required this.summary,
    this.canManage = false,
    this.onEdit,
    this.onDelete,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        // ✅ 외부에서 onTap 주면 그걸 사용, 없으면 기본 라우팅
        onTap:
            onTap ??
            () =>
                Navigator.of(context).pushNamed('/blog', arguments: summary.id),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ✅ 타이틀 + (내 글이면) 관리 메뉴
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      summary.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  if (canManage)
                    PopupMenuButton<String>(
                      onSelected: (v) {
                        if (v == 'edit') onEdit?.call();
                        if (v == 'delete') onDelete?.call();
                      },
                      itemBuilder: (_) => const [
                        PopupMenuItem(value: 'edit', child: Text('수정')),
                        PopupMenuItem(value: 'delete', child: Text('삭제')),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 6),

              // 본문 요약
              Text(
                summary.content,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),

              // 작성자/날짜/좋아요
              Row(
                children: [
                  Text(
                    summary.user?.username ?? 'unknown',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  const SizedBox(width: 12),
                  if (summary.modifyDate != null)
                    Text(
                      '${summary.modifyDate}',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  const Spacer(),
                  const Icon(Icons.favorite, size: 16),
                  const SizedBox(width: 4),
                  Text('${summary.voteCount}'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
