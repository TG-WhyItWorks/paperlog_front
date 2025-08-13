import 'package:flutter/material.dart';

class OnOffRow extends StatelessWidget {
  const OnOffRow({required this.value, required this.onChanged, super.key});
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Radio<bool>(
          value: true,
          groupValue: value,
          onChanged: (_) => onChanged(true),
        ),
        const Text('On'),
        const SizedBox(width: 12),
        Radio<bool>(
          value: false,
          groupValue: value,
          onChanged: (_) => onChanged(false),
        ),
        const Text('Off'),
      ],
    );
  }
}
