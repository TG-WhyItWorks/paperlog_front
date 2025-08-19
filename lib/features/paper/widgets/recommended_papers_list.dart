import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/paper_model.dart';
import '../../dashboard/widgets/recommend_paper_card.dart';
import '../viewmodel/recommended_papers_viewmodel.dart';

class RecommendedPapersList extends StatelessWidget {
  final String category; // 예: 'trending' 또는 'cs.LG'
  final int limit;
  const RecommendedPapersList({
    super.key,
    required this.category,
    this.limit = 3,
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
      return const SizedBox(
        height: 220,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (vm.error != null) {
      return SizedBox(height: 56, child: Text('추천 논문 로드 실패: ${vm.error}'));
    }
    if (vm.items.isEmpty) {
      return const SizedBox(height: 56, child: Text('추천할 논문이 아직 없어요.'));
    }
    final recs = vm.items;
    return SizedBox(
      height: 220,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemBuilder: (_, i) => RecommendPaperCard(paper: recs[i]),
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemCount: recs.length,
      ),
    );
  }
}
