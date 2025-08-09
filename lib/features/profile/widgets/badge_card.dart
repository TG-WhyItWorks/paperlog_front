import 'package:flutter/material.dart';
import 'package:paperlog_front/core/models/profile_model.dart';
import '../viewmodel/profile_viewmodel.dart';

class BadgeCard extends StatelessWidget {
  final List<BadgeModel> badges;
  const BadgeCard({super.key, required this.badges});

  @override
  Widget build(BuildContext context) {
    return _cardShell(
      context,
      title: '뱃지',
      child: Column(
        children: badges.map((b) {
          final iconColor = b.achieved
              ? Theme.of(context).colorScheme.primary
              : Colors.grey;
          final nameStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: b.achieved ? null : Colors.grey,
          );
          final descStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
            color: b.achieved ? null : Colors.grey,
          );
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: iconColor.withOpacity(0.12),
                  child: Icon(Icons.emoji_events_rounded, color: iconColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(b.name, style: nameStyle),
                      const SizedBox(height: 2),
                      Text(b.description, style: descStyle),
                    ],
                  ),
                ),
                if (b.achieved)
                  Icon(
                    Icons.check_circle,
                    color: Theme.of(context).colorScheme.primary,
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
