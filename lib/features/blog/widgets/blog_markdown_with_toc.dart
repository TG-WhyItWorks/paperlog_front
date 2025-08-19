import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;

/// 목차 항목
class _TocEntry {
  final String id;
  final String text;
  final int level; // 1~6
  final GlobalKey key = GlobalKey();
  _TocEntry({required this.id, required this.text, required this.level});
}

/// 헤더에 앵커(GlobalKey) 꽂아주는 빌더
class _HeaderAnchorBuilder extends MarkdownElementBuilder {
  final List<_TocEntry> toc;
  int _i = 0; // 렌더 순서대로 헤더에 키 매칭
  _HeaderAnchorBuilder(this.toc);

  TextStyle _styleFor(BuildContext ctx, int level) {
    final t = Theme.of(ctx).textTheme;
    switch (level) {
      case 1:
        return (t.headlineSmall ?? const TextStyle(fontSize: 24)).copyWith(
          fontWeight: FontWeight.w800,
        );
      case 2:
        return (t.titleLarge ?? const TextStyle(fontSize: 22)).copyWith(
          fontWeight: FontWeight.w800,
        );
      case 3:
        return (t.titleMedium ?? const TextStyle(fontSize: 20)).copyWith(
          fontWeight: FontWeight.w700,
        );
      case 4:
        return (t.titleSmall ?? const TextStyle(fontSize: 18)).copyWith(
          fontWeight: FontWeight.w700,
        );
      default:
        return (t.bodyLarge ?? const TextStyle(fontSize: 16)).copyWith(
          fontWeight: FontWeight.w700,
        );
    }
  }

  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    // element.tag: 'h1' ~ 'h6'
    final level = int.tryParse(element.tag?.substring(1) ?? '1') ?? 1;
    final idx = _i < toc.length ? _i++ : _i;
    final entry = idx < toc.length ? toc[idx] : null;
    final titleText = element.textContent;

    return Builder(
      builder: (ctx) => Container(
        key: entry?.key,
        margin: EdgeInsets.only(top: level <= 2 ? 24 : 16, bottom: 8),
        child: Text(titleText, style: _styleFor(ctx, level)),
      ),
    );
  }
}

/// 본문 + 오른쪽 목차(와이드 화면) / 상단 접이식 목차(모바일)
class BlogMarkdownWithToc extends StatefulWidget {
  final String text;
  final double maxBodyWidth;
  const BlogMarkdownWithToc({
    super.key,
    required this.text,
    this.maxBodyWidth = 820,
  });

  @override
  State<BlogMarkdownWithToc> createState() => _BlogMarkdownWithTocState();
}

class _BlogMarkdownWithTocState extends State<BlogMarkdownWithToc> {
  late List<_TocEntry> _toc;

  @override
  void initState() {
    super.initState();
    _toc = _extractToc(widget.text);
  }

  @override
  void didUpdateWidget(covariant BlogMarkdownWithToc oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _toc = _extractToc(widget.text);
    }
  }

  List<_TocEntry> _extractToc(String mdText) {
    final lines = mdText.split('\n');
    final reg = RegExp(r'^(#{1,6})\s+(.+)$');
    int seq = 0;
    final out = <_TocEntry>[];
    for (final raw in lines) {
      final m = reg.firstMatch(raw.trimRight());
      if (m == null) continue;
      final level = m.group(1)!.length;
      var text = m.group(2)!.trim();
      // 간단 slug
      var id = text.toLowerCase().replaceAll(RegExp(r'[^a-z0-9가-힣]+'), '-');
      id = '$id-$seq';
      seq++;
      out.add(_TocEntry(id: id, text: text, level: level));
    }
    return out;
  }

  Future<void> _scrollTo(_TocEntry e) async {
    final ctx = e.key.currentContext;
    if (ctx == null) return;
    await Scrollable.ensureVisible(
      ctx,
      alignment: 0.08,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final headerBuilder = _HeaderAnchorBuilder(_toc);

    final sheet = MarkdownStyleSheet.fromTheme(theme).copyWith(
      p: theme.textTheme.bodyLarge?.copyWith(height: 1.8, fontSize: 16),
      blockquoteDecoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: theme.colorScheme.primary.withOpacity(0.25),
            width: 4,
          ),
        ),
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.25),
      ),
      codeblockDecoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.dividerColor),
      ),
      a: theme.textTheme.bodyLarge?.copyWith(
        decoration: TextDecoration.underline,
        color: theme.colorScheme.primary,
      ),
    );

    return LayoutBuilder(
      builder: (ctx, c) {
        final wide = c.maxWidth >= 1100; // 와이드면 오른쪽 목차 레일
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 본문
            Expanded(
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: widget.maxBodyWidth),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!wide && _toc.isNotEmpty) ...[
                        ExpansionTile(
                          tilePadding: EdgeInsets.zero,
                          title: const Text('목차'),
                          childrenPadding: EdgeInsets.zero,
                          children: _buildTocList(theme, compact: true),
                        ),
                        const SizedBox(height: 8),
                      ],
                      MarkdownBody(
                        selectable: true,
                        data: widget.text,
                        styleSheet: sheet,
                        builders: {
                          'h1': headerBuilder,
                          'h2': headerBuilder,
                          'h3': headerBuilder,
                          'h4': headerBuilder,
                          'h5': headerBuilder,
                          'h6': headerBuilder,
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 오른쪽 목차 레일
            if (wide && _toc.isNotEmpty) ...[
              const SizedBox(width: 24),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 260),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('목차', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 8),
                    ..._buildTocList(theme, compact: false),
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  List<Widget> _buildTocList(ThemeData theme, {required bool compact}) {
    final items = <Widget>[];
    for (final e in _toc) {
      final indent = (e.level - 1) * 12.0;
      items.add(
        Padding(
          padding: EdgeInsets.only(left: indent),
          child: TextButton(
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(
                horizontal: compact ? 8 : 10,
                vertical: compact ? 4 : 6,
              ),
              foregroundColor: theme.colorScheme.onSurface,
            ),
            onPressed: () => _scrollTo(e),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                e.text,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ),
        ),
      );
    }
    return items;
  }
}
