import 'package:flutter/material.dart';
import 'package:paperlog_front/core/models/profile_model.dart';
import 'package:paperlog_front/features/profile/widgets/profile_card_shell.dart';

class InterestCard extends StatelessWidget {
  final List<InterestStat> interests;
  const InterestCard({super.key, required this.interests});

  @override
  Widget build(BuildContext context) {
    if (interests.isEmpty) {
      return ProfileCardShell(
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
    return ProfileCardShell(
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
}
