import 'package:flutter/material.dart';

class PaperBreadcrumb extends StatelessWidget {
  const PaperBreadcrumb({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        TextButton(
          onPressed: () => Navigator.of(context).pushNamed('/'),
          child: const Text('Home'),
        ),
        const Text(' / '),
        const Text(
          'Paper Details',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
