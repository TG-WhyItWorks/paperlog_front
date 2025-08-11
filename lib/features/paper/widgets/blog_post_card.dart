import 'package:flutter/material.dart';
import '../../../core/models/paper_detail_model.dart';
import 'package:url_launcher/url_launcher.dart';

class BlogPostCard extends StatelessWidget {
  final BlogPost blog;
  const BlogPostCard({Key? key, required this.blog}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        onTap: () {
          if (blog.url.isNotEmpty) launchUrl(Uri.parse(blog.url));
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Blog Post',
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
                      blog.excerpt,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () {
                        if (blog.url.isNotEmpty) launchUrl(Uri.parse(blog.url));
                      },
                      child: Text('Visit'),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 120,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(6),
                  image: blog.imageUrl != null
                      ? DecorationImage(
                          image: NetworkImage(blog.imageUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
