import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/paper_model.dart';
import '../../explore/widgets/paper_card.dart'; // ← PaperCard 재사용
import '../viewmodel/recommended_papers_viewmodel.dart';

class RecommendedPapersList extends StatelessWidget {
  final String category; // 예: 'trending' 또는 'cs.LG'
  final int limit;
  const RecommendedPapersList({
    super.key,
    required this.category,
    this.limit = 6,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RecommendedPapersViewModel()..load(category, limit: limit),
      child: const _Body(),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RecommendedPapersViewModel>();

    if (vm.loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (vm.error != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text('추천 논문 로드 실패: ${vm.error}'),
      );
    }
    if (vm.items.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Text('추천할 논문이 아직 없어요.'),
      );
    }

    final List<Paper> recs = vm.items;

    // ⬇️ 부모(ListView)가 스크롤을 담당하므로 스크롤 위젯 사용하지 않음.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [for (final p in recs) PaperCard(paper: p)],
    );
  }
}
