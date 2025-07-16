import 'package:flutter/material.dart';
import '../../../core/models/paper_model.dart';

class RecommendPaperCard extends StatelessWidget{
  final Paper paper;
  const RecommendPaperCard({required this.paper, Key?key}) : super(key:key);

  @override
  Widget build(BuildContext context){
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(paper.title,style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(paper.summary, maxLines: 3, overflow: TextOverflow.ellipsis,),
        ],
      ),
      ),
    );
  }
}