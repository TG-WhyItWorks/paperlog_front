import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:paperlog_front/features/dashboard/viewmodel/dashboard_viewmodel.dart';

class LibraryRecentTab extends StatelessWidget {
  const LibraryRecentTab({super.key});

  @override
  Widget build(BuildContext context) {
    final main = context.watch<MainViewModel>();
    final papers = main.recentPapers;
    final blogs = main.recentBlogs;

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        _sectionHeader(context, '최근 본 논문'),
        if (papers.isEmpty)
          _emptyText(context)
        else
          ...papers.map(
            (p) => ListTile(
              dense: true,
              contentPadding: const EdgeInsets.only(right: 8),
              leading: const Icon(Icons.article_outlined, size: 18),
              title: Text(
                p.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              subtitle: p.authors.isNotEmpty
                  ? Text(
                      p.authors.join(', '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )
                  : null,
              onTap: () =>
                  Navigator.of(context).pushNamed('/paper', arguments: p.id),
            ),
          ),
        const Divider(height: 32),

        _sectionHeader(context, '최근 본 포스트'),

        if (blogs.isEmpty)
          _emptyText(context)
        else
          ...blogs.map(
            (b) => ListTile(
              dense: true,
              contentPadding: const EdgeInsets.only(right: 8),
              leading: const Icon(Icons.article_outlined, size: 18),
              title: Text(
                b.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              subtitle: (b.user?.username.isNotEmpty ?? false)
                  ? Text(
                      b.user!.username,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    )
                  : null,
              onTap: () =>
                  Navigator.of(context).pushNamed('/blog', arguments: b.id),
            ),
          ),
      ],
    );
  }

  Widget _sectionHeader(BuildContext context, String title) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold),
    ),
  );

  Widget _emptyText(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Text('없음', style: Theme.of(context).textTheme.bodySmall),
  );
}
