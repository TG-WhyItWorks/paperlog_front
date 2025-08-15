import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/paper_review_list_viewmodel.dart';
import '../../blog/widgets/review_card.dart';

class PaperReviewList extends StatelessWidget {
  final String paperTitle;
  final int limit;
  const PaperReviewList({super.key, required this.paperTitle, this.limit = 10});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) =>
          PaperReviewListViewModel()
            ..loadByPaperTitle(paperTitle, limit: limit),
      child: const _Body(),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PaperReviewListViewModel>();
    if (vm.loading) return const Center(child: CircularProgressIndicator());
    if (vm.error != null) return Text('리뷰 로드 실패: ${vm.error}');
    if (vm.items.isEmpty) return const Text('이 논문을 리뷰한 포스트가 아직 없어요.');

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: vm.items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) => ReviewCard(summary: vm.items[i]),
    );
  }
}
