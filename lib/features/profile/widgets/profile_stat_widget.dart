import 'package:flutter/material.dart';

class ProfileStat extends StatelessWidget {
  final String label;
  final int count;

  const ProfileStat({Key? key, required this.label, required this.count})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$count',
          style: Theme.of(
            context,
          ).textTheme.displayMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
