import 'package:flutter/material.dart';

class MiniInput extends StatelessWidget {
  const MiniInput({required this.label, super.key});
  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      child: TextField(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
      ),
    );
  }
}
