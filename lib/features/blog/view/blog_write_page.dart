import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../dashboard/widgets/header_widget.dart';
import '../../dashboard/widgets/sidebar_widget.dart';
import '../../dashboard/viewmodel/dashboard_viewmodel.dart';
import '../viewmodel/blog_write_viewmodel.dart';
import '../../paper/widgets/paper_picker_sheet.dart';
import '../../../core/models/paper_model.dart';
import '../widgets/markdown_format_toolbar.dart';
import '../models/compose_mode.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class BlogWritePage extends StatefulWidget {
  final int? reviewId;
  final int? initialPaperId;
  final String? initialTitle;
  final String? initialContent;

  const BlogWritePage({
    super.key,
    this.reviewId,
    this.initialPaperId,
    this.initialTitle,
    this.initialContent,
  });

  static Widget fromArgs(Object? args) {
    int? reviewId, paperId;
    String? title, content;
    if (args is Map) {
      reviewId = args['reviewId'] as int?;
      paperId = args['paperId'] as int?;
      title = args['title'] as String?;
      content = args['content'] as String?;
    }
    return ChangeNotifierProvider(
      create: (_) => BlogWriteViewModel(),
      child: BlogWritePage(
        reviewId: reviewId,
        initialPaperId: paperId,
        initialTitle: title,
        initialContent: content,
      ),
    );
  }

  @override
  State<BlogWritePage> createState() => _BlogWritePageState();
}

class _BlogWritePageState extends State<BlogWritePage> {
  final _title = TextEditingController();
  final _content = TextEditingController();
  final _paperId = TextEditingController();
  final List<({String name, List<int> bytes})> _images = [];
  final FocusNode _contentFocus = FocusNode();
  String? _category;
  ComposeMode _mode = ComposeMode.basic;

  Paper? _selectedPaper;

  @override
  void initState() {
    super.initState();
    if (widget.initialPaperId != null) {
      _paperId.text = widget.initialPaperId.toString();
    }
    if (widget.initialTitle != null) _title.text = widget.initialTitle!;
    if (widget.initialContent != null) _content.text = widget.initialContent!;
  }

  Future<void> _pickImages() async {
    final res = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.image,
      withData: true,
    );
    if (res == null) return;
    for (final f in res.files) {
      final bytes = f.bytes;
      if (bytes != null) {
        _images.add((name: f.name, bytes: bytes));
      }
    }
    setState(() {});
  }

  Future<void> _pickPaper() async {
    final picked = await showModalBottomSheet<Paper>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => const FractionallySizedBox(
        heightFactor: 0.85,
        child: PaperPickerSheet(),
      ),
    );
    if (picked != null) {
      setState(() {
        _selectedPaper = picked;
        _paperId.text = picked.id; // 서버가 기대하는 paper_id (정수라면 변환 필요)
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<BlogWriteViewModel>();
    final isEdit = widget.reviewId != null;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(80),
        child: HeaderWidget(),
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (context.watch<MainViewModel>().isSidebarOpen)
            const SidebarWidget(),
          VerticalDivider(
            width: 1,
            thickness: 1,
            color: Theme.of(context).dividerColor,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Write Post',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ===== 상단 카테고리 + 모드 전환 =====
                    Row(
                      children: [
                        DropdownButton<String>(
                          value: _category,
                          hint: const Text('카테고리'),
                          items: const [
                            DropdownMenuItem(value: 'AI', child: Text('AI')),
                            DropdownMenuItem(
                              value: 'Cloud',
                              child: Text('Cloud'),
                            ),
                            DropdownMenuItem(value: 'DB', child: Text('DB')),
                          ],
                          onChanged: (v) => setState(() => _category = v),
                        ),
                        const Spacer(),
                        SegmentedButton<ComposeMode>(
                          segments: const [
                            ButtonSegment(
                              value: ComposeMode.basic,
                              label: Text('기본모드'),
                            ),
                            ButtonSegment(
                              value: ComposeMode.markdown,
                              label: Text('Markdown'),
                            ),
                          ],
                          selected: <ComposeMode>{_mode},
                          onSelectionChanged: (s) =>
                              setState(() => _mode = s.first),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // ===== 제목 =====
                    TextField(
                      controller: _title,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w700),
                      decoration: const InputDecoration(
                        hintText: '제목을 입력하세요',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                    const Divider(height: 24),

                    // ===== 본문 에디터 =====
                    if (_mode == ComposeMode.basic) ...[
                      // 툴바
                      MarkdownFormatToolbar(
                        controller: _content,
                        focusNode: _contentFocus,
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _content,
                        focusNode: _contentFocus,
                        keyboardType: TextInputType.multiline,
                        minLines: 16,
                        maxLines: null,
                        decoration: const InputDecoration(
                          hintText: '본문을 입력하세요 (툴바로 빠르게 서식 적용)',
                          border: OutlineInputBorder(),
                          alignLabelWithHint: true,
                        ),
                      ),
                    ] else ...[
                      // Markdown 모드: 좌편집-우미리보기
                      LayoutBuilder(
                        builder: (ctx, c) {
                          final wide = c.maxWidth >= 1000;
                          final editor = TextField(
                            controller: _content,
                            keyboardType: TextInputType.multiline,
                            minLines: 18,
                            maxLines: null,
                            style: const TextStyle(fontFamily: 'monospace'),
                            decoration: const InputDecoration(
                              hintText: 'Markdown을 입력하세요',
                              border: OutlineInputBorder(),
                              alignLabelWithHint: true,
                            ),
                          );
                          final preview = _MarkdownPreview(md: _content.text);
                          return ValueListenableBuilder<TextEditingValue>(
                            valueListenable: _content,
                            builder: (_, __, ___) {
                              final right = _MarkdownPreview(md: _content.text);
                              if (wide) {
                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(child: editor),
                                    const SizedBox(width: 12),
                                    Expanded(child: right),
                                  ],
                                );
                              } else {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    editor,
                                    const SizedBox(height: 12),
                                    right,
                                  ],
                                );
                              }
                            },
                          );
                        },
                      ),
                    ],
                    const SizedBox(height: 12),

                    // ✅ 인용 논문 선택: 클릭하면 검색 시트 표시
                    GestureDetector(
                      onTap: _pickPaper,
                      child: AbsorbPointer(
                        child: TextField(
                          controller: _paperId,
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: '인용 논문 (검색으로 선택)',
                            border: const OutlineInputBorder(),
                            suffixIcon: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (_paperId.text.isNotEmpty)
                                  IconButton(
                                    tooltip: '지우기',
                                    onPressed: () {
                                      setState(() {
                                        _paperId.clear();
                                        _selectedPaper = null;
                                      });
                                    },
                                    icon: const Icon(Icons.clear),
                                  ),
                                IconButton(
                                  tooltip: '검색',
                                  onPressed: _pickPaper,
                                  icon: const Icon(Icons.search),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    if (_selectedPaper != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.description_outlined, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${_selectedPaper!.title}\n${_selectedPaper!.authors.join(', ')} • ${_selectedPaper!.year} • ${_selectedPaper!.id}',
                              style: Theme.of(context).textTheme.bodySmall,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        OutlinedButton.icon(
                          onPressed: _pickImages,
                          icon: const Icon(Icons.image_outlined),
                          label: const Text('이미지 추가'),
                        ),
                        const SizedBox(width: 12),
                        Text('${_images.length} files'),
                      ],
                    ),
                    const SizedBox(height: 16),

                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: vm.submitting
                            ? null
                            : () async {
                                try {
                                  final pid = int.tryParse(
                                    _paperId.text.trim(),
                                  );
                                  await context
                                      .read<BlogWriteViewModel>()
                                      .submit(
                                        reviewId: widget.reviewId,
                                        title: _title.text.trim(),
                                        content: _content.text.trim(),
                                        paperId: pid,
                                        images: _images,
                                      );
                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(isEdit ? '수정 완료' : '작성 완료'),
                                    ),
                                  );
                                  Navigator.of(context).pop(true);
                                } catch (e) {
                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('실패: $e')),
                                  );
                                }
                              },
                        child: vm.submitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(isEdit ? '수정' : '등록'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MarkdownPreview extends StatelessWidget {
  final String md;
  const _MarkdownPreview({required this.md});

  @override
  Widget build(BuildContext context) {
    // 상세 페이지와 비슷한 스타일의 미리보기
    final theme = Theme.of(context);
    final sheet = MarkdownStyleSheet.fromTheme(theme).copyWith(
      p: theme.textTheme.bodyLarge?.copyWith(height: 1.8, fontSize: 16),
      blockquoteDecoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: theme.colorScheme.primary.withOpacity(.25),
            width: 4,
          ),
        ),
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(.2),
      ),
      codeblockDecoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.dividerColor),
      ),
    );
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: theme.dividerColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: MarkdownBody(selectable: false, data: md, styleSheet: sheet),
    );
  }
}
