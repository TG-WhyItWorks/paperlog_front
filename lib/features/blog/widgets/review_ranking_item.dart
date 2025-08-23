import 'package:flutter/material.dart';
import '../../../core/models/review_models.dart';

class ReviewRankingItem extends StatelessWidget {
  final int rank;
  final BlogReviewSummary summary;
  final VoidCallback? onTap;
  const ReviewRankingItem({
    super.key,
    required this.rank,
    required this.summary,
    this.onTap,
  });

  String? _extractThumb(String text) {
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final thumb = _extractThumb(summary.content);
    return InkWell(
      onTap:
          onTap ??
          () => Navigator.of(context).pushNamed('/blog', arguments: summary.id),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              '$rank',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                summary.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 80,
                height: 80,
                color: theme.colorScheme.surfaceContainerHighest,
                child: thumb == null
                    ? Icon(
                        Icons.image_outlined,
                        color: theme.colorScheme.onSurface.withOpacity(.35),
                      )
                    : Image.network(thumb, fit: BoxFit.cover),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
