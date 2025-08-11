import 'package:flutter/material.dart';
import '../../../core/models/paper_model.dart';

class PaperCard extends StatelessWidget {
  final Paper paper;
  const PaperCard({required this.paper, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      child: InkWell(
        onTap: () {
          Navigator.of(context).pushNamed('/paper', arguments: paper.id);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                paper.title,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              // ✅ (추가) 저자 및 연도 정보 표시
              Text(
                '${paper.authors.join(', ')} (${paper.year})',
                style: Theme.of(context).textTheme.bodySmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),

              // ✅ (수정) summary -> abstractText
              Text(
                paper.abstractText,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),

              // ✅ (수정) tags -> fields
              if (paper.fields.isNotEmpty)
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: paper.fields
                      .map(
                        (field) => Chip(
                          label: Text(field, style: TextStyle(fontSize: 12)),
                          // 칩 디자인을 조금 더 컴팩트하게 조절
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 0,
                          ),
                        ),
                      )
                      .toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
