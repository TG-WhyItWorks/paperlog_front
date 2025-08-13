import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PaperHeader extends StatelessWidget {
  const PaperHeader({
    super.key,
    required this.title,
    required this.authors,
    required this.year,
    required this.fields,
    required this.pdfUrl,
  });

  final String title;
  final List<String> authors;
  final String year;
  final List<String> fields;
  final String pdfUrl;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.displayLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Authors: ${authors.join(', ')} | Published: $year | Fields: ${fields.join(', ')}',
          style: Theme.of(context).textTheme.labelSmall,
        ),

        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: () => _launchUrl(context, pdfUrl),
          icon: const Icon(Icons.download_rounded),
          label: const Text('Download Paper'),
        ),
      ],
    );
  }

  Future<void> _launchUrl(BuildContext context, String url) async {
    if (url.isEmpty) return;
    final uri = Uri.tryParse(url);
    if (uri == null) return;

    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('링크를 열 수 없습니다.')));
    }
  }
}
