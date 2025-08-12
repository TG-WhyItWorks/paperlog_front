import 'package:flutter/material.dart';
import '../../../core/models/paper_model.dart';
import '../../../shared/prefs/date_formatting.dart' as df;
import '../../../shared/prefs/prefs_provider.dart' as prefs;
import 'package:provider/provider.dart';

class PaperCard extends StatelessWidget {
  const PaperCard({required this.paper, Key? key}) : super(key: key);
  final Paper paper;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
            children: [
              //상단: 날짜와 카테고리
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _DateBadge(text: _dateText(context, paper)),
                  const SizedBox(width: 12),
                  Expanded(
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

              //논문 제목
              Text(
                paper.title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.primary,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 8),

              //논문 저자
              if (paper.authors.isNotEmpty)
                Text(
                  paper.authors.join(', '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall,
                ),
              const SizedBox(height: 10),

              //논문 요약
              if (paper.abstractText.isNotEmpty)
                Container(
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
              const SizedBox(height: 10),

              //하단의 액션 아이콘
              Row(
                children: [
                  _BookmarkButton(
                    onTap: () {
                      /*TODO: 북마크 액션*/
                    },
                  ),
                  const SizedBox(width: 8),
                  _LikeButton(
                    count: paper.likeCount ?? 0,
                    onTap: () {
                      /*TODO: */
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _dateText(BuildContext context, Paper p) {
    DateTime? dt = p.publishedAt;

    if (dt == null) {
      final y = int.tryParse(p.year);
      if (y != null) dt = DateTime(y, 1, 1);
    }
    if (dt == null) return '';

    final opt = context.read<prefs.PrefsProvider>().dateFormat;
    return df.formatDate(dt, opt);
  }
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
        children: [
          Text('Bookmark'),
          SizedBox(width: 2),
          Icon(Icons.keyboard_arrow_down, size: 18),
        ],
      ),
    );
  }
}

class _LikeButton extends StatelessWidget {
  const _LikeButton({required this.count, required this.onTap});
  final VoidCallback onTap;
  final int count;
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return TextButton.icon(
      onPressed: onTap,
      style: TextButton.styleFrom(foregroundColor: t.colorScheme.onSurface),
      icon: const Icon(Icons.thumb_up_alt_outlined),
      label: Text('$count'),
    );
  }
}
