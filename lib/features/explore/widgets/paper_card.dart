import 'package:flutter/material.dart';
import '../../../core/models/paper_model.dart';

class PaperCard extends StatelessWidget {
  final Paper paper;
  const PaperCard({required this.paper, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadiusGeometry.circular(8),
      ),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              paper.title,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 4),
            Text(paper.summary, maxLines: 3, overflow: TextOverflow.ellipsis),
            if (paper.tags.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                children: paper.tags
                    .map(
                      (tag) => Chip(
                        label: Text(tag, style: TextStyle(fontSize: 12)),
                      ),
                    )
                    .toList(),
              ),
            ],
            if (paper.recommendationReason.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                '추천 이유: ${paper.recommendationReason}',
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ],
            if (paper.imageUrl.isNotEmpty) ...[
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.network(
                  paper.imageUrl,
                  height: 100,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
