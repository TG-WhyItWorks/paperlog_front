import 'package:flutter/material.dart';
import '../../../core/models/paper_model.dart';
import '../../dashboard/widgets/recommend_paper_card.dart';

class RecommendedPapersList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final recs = Paper.sampleList();
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
