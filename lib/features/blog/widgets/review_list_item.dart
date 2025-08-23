import 'package:flutter/material.dart';
import '../../../core/models/review_models.dart';

/// 블로그 홈/검색용 리스트 아이템 (텍스트 좌측, 썸네일 우측)
class ReviewListItem extends StatelessWidget {
  final BlogReviewSummary summary;
  final bool canManage;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;
  final String? thumbnailUrl; // 없으면 content에서 자동 추출 시도

  const ReviewListItem({
    super.key,
    required this.summary,
    this.canManage = false,
    this.onEdit,
    this.onDelete,
    this.onTap,
    this.thumbnailUrl,
  });

  String? _extractFirstImageFromContent(String text) {
    // ![alt](url) 형태 우선
    final md = RegExp(r'!\[[^\]]*\]\((.*?)\)');
    final m = md.firstMatch(text);
    if (m != null && m.groupCount >= 1) return m.group(1);

    // URL 대충이라도 잡기 (png/jpg/webp 등)
    final url = RegExp(
      r'(https?:\/\/[^\s)]+?\.(?:png|jpe?g|gif|webp))',
      caseSensitive: false,
    );
    final m2 = url.firstMatch(text);
    if (m2 != null) return m2.group(1);
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final thumb =
        thumbnailUrl ?? _extractFirstImageFromContent(summary.content);

    return InkWell(
      onTap:
          onTap ??
          () => Navigator.of(context).pushNamed('/blog', arguments: summary.id),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 본문 영역
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 카테고리/태그 영역이 있으면 여기에 배치 가능
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          summary.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
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
                  Text(
                    summary.content,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        summary.user?.username ?? 'unknown',
                        style: theme.textTheme.labelMedium,
                      ),
                      const SizedBox(width: 12),
                      if (summary.modifyDate != null)
                        Text(
                          '${summary.modifyDate}',
                          style: theme.textTheme.labelSmall,
                        ),
                      const Spacer(),
                      const Icon(Icons.favorite, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        '${summary.voteCount}',
                        style: theme.textTheme.labelSmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 썸네일
            const SizedBox(width: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Container(
                width: 190,
                height: 110,
                color: theme.colorScheme.surfaceContainerHighest,
                child: thumb == null
                    ? Icon(
                        Icons.image_outlined,
                        color: theme.colorScheme.onSurface.withOpacity(.4),
                        size: 32,
                      )
                    : Image.network(
                        thumb,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Icon(
                          Icons.image_not_supported_outlined,
                          color: theme.colorScheme.onSurface.withOpacity(.4),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
