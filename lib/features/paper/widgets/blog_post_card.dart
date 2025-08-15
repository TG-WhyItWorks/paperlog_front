import 'package:flutter/material.dart';
import '../../../core/models/review_models.dart';

class BlogPostCard extends StatelessWidget {
  final BlogReviewSummary blog;
  const BlogPostCard({Key? key, required this.blog}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        onTap: () =>
            Navigator.of(context).pushNamed('/blog', arguments: blog.id),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Review',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      blog.title,
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      blog.content,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => Navigator.of(
                        context,
                      ).pushNamed('/blog', arguments: blog.id),
                      child: const Text('Open'),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 120,
                height: 80,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(Icons.rate_review_outlined),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
