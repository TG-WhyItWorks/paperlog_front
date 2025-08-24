import 'package:flutter/material.dart';
import '../../../core/models/review_models.dart';

class ReviewGridCard extends StatelessWidget {
  final BlogReviewSummary summary;
  const ReviewGridCard({super.key, required this.summary});

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
      onTap: () =>
          Navigator.of(context).pushNamed('/blog', arguments: summary.id),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Container(
                color: theme.colorScheme.surfaceContainerHighest,
                child: thumb == null
                    ? Icon(
                        Icons.image_outlined,
                        size: 42,
                        color: theme.colorScheme.onSurface.withOpacity(.35),
                      )
                    : Image.network(thumb, fit: BoxFit.cover),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            summary.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                summary.user?.username ?? 'unknown',
                style: theme.textTheme.labelMedium,
              ),
              const Spacer(),
              const Icon(Icons.favorite, size: 14),
              const SizedBox(width: 4),
              Text('${summary.voteCount}', style: theme.textTheme.labelSmall),
            ],
          ),
        ],
      ),
    );
  }
}
