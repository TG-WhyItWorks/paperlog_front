import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../dashboard/widgets/header_widget.dart';
import '../../dashboard/widgets/sidebar_widget.dart';
import '../../dashboard/viewmodel/dashboard_viewmodel.dart';
import '../service/blog_service.dart';
import '../../paper/widgets/paper_picker_sheet.dart';
import '../../../core/models/paper_model.dart';
import '../widgets/markdown_format_toolbar.dart';
import '../models/compose_mode.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class BlogEditPage extends StatefulWidget {
  final int reviewId;
  final String? initialTitle;
  final String? initialContent;
  final int? initialPaperId;

  const BlogEditPage({
    super.key,
    required this.reviewId,
    this.initialTitle,
    this.initialContent,
    this.initialPaperId,
  });

  // routes['/blog/edit'] 에서 사용:
  // return BlogEditPage.fromArgs(ModalRoute.of(ctx)?.settings.arguments)
  static Widget fromArgs(Object? args) {
    int id = 0;
    String? title;
    String? content;
    int? paperId;

    if (args is int) {
      id = args;
    } else if (args is Map) {
      if (args['reviewId'] is int) id = args['reviewId'] as int;
      if (args['title'] != null) title = args['title']?.toString();
      if (args['content'] != null) content = args['content']?.toString();
      if (args['paperId'] != null) {
        final v = args['paperId'];
        if (v is int) paperId = v;
        if (v is String) paperId = int.tryParse(v);
      }
    }

    return BlogEditPage(
      reviewId: id,
      initialTitle: title,
      initialContent: content,
      initialPaperId: paperId,
    );
  }

  @override
  State<BlogEditPage> createState() => _BlogEditPageState();
}

class _BlogEditPageState extends State<BlogEditPage> {
  final _svc = BlogService();
  final _title = TextEditingController();
  final _content = TextEditingController();
  final _paperId = TextEditingController();
  Paper? _selectedPaper;
  final FocusNode _contentFocus = FocusNode();
  String? _category;
  ComposeMode _mode = ComposeMode.basic;

  bool _loading = false; // 페이지 로딩(상세 불러오기)용
  bool _saving = false; // 저장 버튼 중복방지

  @override
  void initState() {
    super.initState();

    // 1) 전달된 값으로 먼저 채워두기(깜빡임/빈 화면 방지)
    _title.text = widget.initialTitle ?? '';
    _content.text = widget.initialContent ?? '';
    _paperId.text = (widget.initialPaperId?.toString() ?? '');

    // 2) 안정성을 위해 서버에서 한 번 더 최신 상세를 가져와 갱신
    // (이미 값이 있으면 그대로 보이고, 도착하면 교체됨)
    _fetchDetailIfNeeded();
  }

  Future<void> _fetchDetailIfNeeded() async {
    if (_title.text.isNotEmpty && _content.text.isNotEmpty) {
      // 이미 내용이 들어있다면 필수는 아님. 원하시면 주석 해제해도 OK.
      return;
    }
    setState(() => _loading = true);
    try {
      final detail = await _svc.detail(widget.reviewId);
      // detail → BlogReview
      _title.text = detail.title;
      _content.text = detail.content;
      _paperId.text = detail.paperId?.toString() ?? '';
    } catch (_) {
      // 무시(초기값으로라도 수정 가능)
    } finally {
      if (mounted) setState(() => _loading = false);
    }
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
        // 서버가 paper_id 정수면 아래 변환 필요: int.tryParse(picked.id)
        _paperId.text = picked.id;
      });
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _content.dispose();
    _paperId.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);

    try {
      final pid = int.tryParse(_paperId.text.trim());
      await _svc.update(
        reviewId: widget.reviewId,
        title: _title.text.trim(),
        content: _content.text.trim(),
        paperId: pid, // null 허용
      );

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('수정 완료')));
      Navigator.of(context).pop(true); // ← true로 돌려주면 리스트/디테일에서 reload 가능
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('수정 실패: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final main = context.watch<MainViewModel>();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(80),
        child: HeaderWidget(),
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (main.isSidebarOpen) const SidebarWidget(),
          VerticalDivider(
            width: 1,
            thickness: 1,
            color: Theme.of(context).dividerColor,
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Edit Post',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),

                        Row(
                          children: [
                            DropdownButton<String>(
                              value: _category,
                              hint: const Text('카테고리'),
                              items: const [
                                DropdownMenuItem(
                                  value: 'AI',
                                  child: Text('AI'),
                                ),
                                DropdownMenuItem(
                                  value: 'Cloud',
                                  child: Text('Cloud'),
                                ),
                                DropdownMenuItem(
                                  value: 'DB',
                                  child: Text('DB'),
                                ),
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
                        TextField(
                          controller: _title,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                          decoration: const InputDecoration(
                            hintText: '제목을 입력하세요',
                            border: InputBorder.none,
                          ),
                        ),
                        const Divider(height: 24),
                        if (_mode == ComposeMode.basic) ...[
                          MarkdownFormatToolbar(
                            controller: _content,
                            focusNode: _contentFocus,
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _content,
                            focusNode: _contentFocus,
                            minLines: 16,
                            maxLines: null,
                            decoration: const InputDecoration(
                              hintText: '본문을 입력하세요',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ] else ...[
                          LayoutBuilder(
                            builder: (ctx, c) {
                              final wide = c.maxWidth >= 1000;
                              final editor = TextField(
                                controller: _content,
                                minLines: 18,
                                maxLines: null,
                                style: const TextStyle(fontFamily: 'monospace'),
                                decoration: const InputDecoration(
                                  hintText: 'Markdown을 입력하세요',
                                  border: OutlineInputBorder(),
                                ),
                              );
                              return ValueListenableBuilder<TextEditingValue>(
                                valueListenable: _content,
                                builder: (_, __, ___) {
                                  final pv = _MarkdownPreview(
                                    md: _content.text,
                                  );
                                  if (wide) {
                                    return Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(child: editor),
                                        const SizedBox(width: 12),
                                        Expanded(child: pv),
                                      ],
                                    );
                                  }
                                  return Column(
                                    children: [
                                      editor,
                                      const SizedBox(height: 12),
                                      pv,
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                        ],
                        const SizedBox(height: 8),

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
                                        onPressed: () => setState(() {
                                          _paperId.clear();
                                          _selectedPaper = null;
                                        }),
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
                                  '${_selectedPaper!.title}\n'
                                  '${_selectedPaper!.authors.join(', ')} • '
                                  '${_selectedPaper!.year} • ${_selectedPaper!.id}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 16),

                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: _saving ? null : _save,
                            icon: _saving
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.save),
                            label: const Text('저장'),
                          ),
                        ),
                      ],
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
