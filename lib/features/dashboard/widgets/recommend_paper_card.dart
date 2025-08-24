import 'package:flutter/material.dart';
import '../../../core/models/paper_model.dart';
import '../../library/widgets/save_bookmark_dialog.dart';
import '../../paper/widgets/like_button.dart';

class RecommendPaperCard extends StatelessWidget {
  final Paper paper;
  final EdgeInsetsGeometry? outerMargin; // ⬅️ 추가

  const RecommendPaperCard({
    required this.paper,
    this.outerMargin, // ⬅️ 추가
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      constraints: const BoxConstraints(maxWidth: 360),
      margin:
          outerMargin ??
          const EdgeInsets.symmetric(horizontal: 12, vertical: 10), // ⬅️ 수정
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.dividerColor),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () =>
            Navigator.of(context).pushNamed('/paper', arguments: paper.id),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            // 그리드에선 mainAxisExtent로 높이가 정해지므로 min/overflow 이슈가 줄어듭니다.
            mainAxisSize: MainAxisSize.max,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _DateBadge(text: _dateText(paper)),
                  const SizedBox(width: 12),
                  Flexible(
                    fit: FlexFit.loose,
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.end,
                      children: paper.fields
                          .take(5)
                          .map((t) => _TagPill(t))
                          .toList(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              Text(
                paper.title,
                maxLines: 2, // ⬅️ 제목 줄수 제한(그리드 높이에 맞춤)
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.primary,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 8),

              if (paper.authors.isNotEmpty)
                Text(
                  paper.authors.join(', '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall,
                ),
              const SizedBox(height: 10),

              // 요약은 남는 공간을 쓰도록 Flexible로
              Flexible(
                fit: FlexFit.loose,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Theme.of(context).dividerColor),
                  ),
                  child: Text(
                    paper.abstractText,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ),
              const SizedBox(height: 10),

              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _BookmarkButton(
                    onTap: () => SaveBookmarkDialog.show(context, paper: paper),
                  ),
                  const SizedBox(width: 8),
                  LikeButton(
                    paperId: paper.id,
                    initialCount: paper.likeCount,
                    initialLiked: paper.isLiked ?? false,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _dateText(Paper p) {
  if (p.publishedAt != null) {
    final d = p.publishedAt!;
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${d.day.toString().padLeft(2, '0')} ${months[d.month - 1]} ${d.year}';
  }
  if (p.year.isNotEmpty) return p.year;
  return '';
}

class _DateBadge extends StatelessWidget {
  const _DateBadge({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: t.dividerColor),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(text, style: t.textTheme.labelMedium),
    );
  }
}

class _TagPill extends StatelessWidget {
  const _TagPill(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: t.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label, style: t.textTheme.labelSmall),
    );
  }
}

class _BookmarkButton extends StatelessWidget {
  const _BookmarkButton({required this.onTap});
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return TextButton.icon(
      onPressed: onTap,
      style: TextButton.styleFrom(foregroundColor: t.colorScheme.onSurface),
      icon: const Icon(Icons.bookmark_border),
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Bookmark'),
          SizedBox(width: 2),
          Icon(Icons.keyboard_arrow_down, size: 18),
        ],
      ),
    );
  }
}
