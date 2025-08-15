import 'package:flutter/material.dart';
import '../../../core/models/review_models.dart';

class ReviewCard extends StatelessWidget {
  final BlogReviewSummary summary;
  const ReviewCard({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () =>
            Navigator.of(context).pushNamed('/blog', arguments: summary.id),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      summary.title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      summary.content,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
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
            ],
          ),
        ),
      ),
    );
  }
}
