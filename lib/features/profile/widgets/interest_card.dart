import 'package:flutter/material.dart';
import 'package:paperlog_front/core/models/profile_model.dart';
import '../viewmodel/profile_viewmodel.dart';

class InterestCard extends StatelessWidget {
  final List<InterestStat> interests;
  const InterestCard({super.key, required this.interests});

  @override
  Widget build(BuildContext context) {
    if (interests.isEmpty) {
      return _cardShell(
        context,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              '아직 통계가 없어요.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ),
      );
    }
    final maxCount = interests.first.count;
    return _cardShell(
      context,
      title: '관심 영역',
      child: Column(
        children: interests.map((e) {
          final ratio = maxCount == 0 ? 0.0 : e.count / maxCount;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        e.field,
                        style: Theme.of(context).textTheme.bodyMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${e.count}',
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: ratio.clamp(0.0, 1.0),
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _cardShell(
    BuildContext context, {
    String? title,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
          ],
          child,
        ],
      ),
    );
  }
}
