import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/blog_write_viewmodel.dart';

class BlogWritePage extends StatefulWidget {
  final int? initialPaperId; // 논문 상세에서 넘어올 때 참조용
  const BlogWritePage({super.key, this.initialPaperId});

  @override
  State<BlogWritePage> createState() => _BlogWritePageState();

  static Widget fromArgs(Object? args) {
    int? pid;
    if (args is int) pid = args;
    if (args is Map && args['paperId'] is int) pid = args['paperId'];
    return ChangeNotifierProvider(
      create: (_) => BlogWriteViewModel(),
      child: BlogWritePage(initialPaperId: pid),
    );
  }
}

class _BlogWritePageState extends State<BlogWritePage> {
  final _title = TextEditingController();
  final _content = TextEditingController();
  final _paperId = TextEditingController();
  final List<({String name, List<int> bytes})> _images = [];

  @override
  void initState() {
    super.initState();
    if (widget.initialPaperId != null)
      _paperId.text = widget.initialPaperId.toString();
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

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<BlogWriteViewModel>();
    return Scaffold(
      appBar: AppBar(title: const Text('Write Post')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _title,
              decoration: const InputDecoration(labelText: '제목'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _content,
              maxLines: 12,
              decoration: const InputDecoration(
                labelText: '내용',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _paperId,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: '인용 논문 ID (선택)'),
            ),
            const SizedBox(height: 8),
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
                          final pid = int.tryParse(_paperId.text.trim());
                          await context.read<BlogWriteViewModel>().submit(
                            title: _title.text.trim(),
                            content: _content.text.trim(),
                            paperId: pid,
                            images: _images,
                          );
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('작성 완료')),
                          );
                          Navigator.of(context).pop(true);
                        } catch (e) {
                          if (!mounted) return;
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text('작성 실패: $e')));
                        }
                      },
                child: vm.submitting
                    ? const CircularProgressIndicator()
                    : const Text('등록'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
