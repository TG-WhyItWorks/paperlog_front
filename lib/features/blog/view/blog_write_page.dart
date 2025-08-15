import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../dashboard/widgets/header_widget.dart';
import '../../dashboard/widgets/sidebar_widget.dart';
import '../../dashboard/viewmodel/dashboard_viewmodel.dart';
import '../viewmodel/blog_write_viewmodel.dart';
import '../../paper/widgets/paper_picker_sheet.dart';
import '../../../core/models/paper_model.dart';

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

  Paper? _selectedPaper;

  @override
  void initState() {
    super.initState();
    if (widget.initialPaperId != null) {
      _paperId.text = widget.initialPaperId.toString();
    }
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

                    TextField(
                      controller: _title,
                      decoration: const InputDecoration(
                        labelText: '제목',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      controller: _content,
                      maxLines: 14,
                      decoration: const InputDecoration(
                        labelText: '내용',
                        alignLabelWithHint: true,
                        border: OutlineInputBorder(),
                      ),
                    ),
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
