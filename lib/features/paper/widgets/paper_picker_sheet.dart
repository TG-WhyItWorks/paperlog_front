import 'package:flutter/material.dart';
import '../../../core/models/paper_model.dart';
import '../service/paper_search_service.dart';

class PaperPickerSheet extends StatefulWidget {
  const PaperPickerSheet({super.key});

  @override
  State<PaperPickerSheet> createState() => _PaperPickerSheetState();
}

class _PaperPickerSheetState extends State<PaperPickerSheet> {
  final _svc = PaperSearchService();
  final _ctrl = TextEditingController();
  bool _loading = false;
  String? _error;
  List<Paper> _results = const [];

  Future<void> _doSearch([String? q]) async {
    final keyword = (q ?? _ctrl.text).trim();
    if (keyword.isEmpty) {
      setState(() {
        _results = const [];
        _error = null;
      });
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final r = await _svc.search(keyword, limit: 30);
      setState(() => _results = r);
    } catch (e) {
      setState(() => _error = '$e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('논문 검색', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            TextField(
              controller: _ctrl,
              decoration: InputDecoration(
                hintText: '제목 / 저자 / arXiv ID',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    _ctrl.clear();
                    _doSearch('');
                  },
                ),
                border: const OutlineInputBorder(),
              ),
              textInputAction: TextInputAction.search,
              onSubmitted: _doSearch,
            ),
            const SizedBox(height: 12),
            if (_loading) const LinearProgressIndicator(),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  '검색 실패: $_error',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: _results.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, i) {
                  final p = _results[i];
                  return ListTile(
                    leading: const Icon(Icons.description_outlined),
                    title: Text(
                      p.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      '${p.authors.join(', ')} • ${p.year} • ${p.id}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () => Navigator.of(context).pop<Paper>(p),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
