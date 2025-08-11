import 'package:flutter/material.dart';
import '../../../core/models/paper_model.dart';

class RecommendPaperCard extends StatelessWidget {
  final Paper paper;
  const RecommendPaperCard({required this.paper, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () =>
          Navigator.of(context).pushNamed('/paper', arguments: paper.id),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8),
        color: Theme.of(context).cardColor,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              //좌측: 텍스트 영역
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // //추천 이유 (작은 회색 텍스트)
                    // Text(
                    //   paper.recommendationReason,
                    //   style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    //     color: Theme.of(context).hintColor,
                    //   ),
                    // // ),
                    // const SizedBox(height: 4),
                    // 논문 제목
                    Text(
                      paper.title,
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // 논문 요약
                    // ✅ 저자 정보 추가 (이미지가 없으므로 공간을 채우고 정보 추가)
                    Text(
                      // paper.authors는 List<String>이므로 join으로 합쳐서 표시
                      'Authors: ${paper.authors.join(', ')}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 8),

                    // ✅ 논문 요약 (summary -> abstractText로 변경)
                    Text(
                      paper.abstractText,
                      // 이미지가 없으므로 요약을 조금 더 보여주기 위해 maxLines를 늘림
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              // const SizedBox(width: 16),
              // //우측: 이미지 영역
              // ClipRRect(
              //   borderRadius: BorderRadius.circular(8),
              //   child: Image.network(
              //     paper.imageUrl,
              //     width: 100,
              //     height: 100,
              //     fit: BoxFit.cover,
              //     errorBuilder: (_, __, ___) => Image.asset(
              //       'assets/images/default_paper_image.png',
              //       width: 100,
              //       height: 100,
              //       fit: BoxFit.cover,
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
