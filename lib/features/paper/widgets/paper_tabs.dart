import 'package:flutter/material.dart';

class PaperTabs extends StatelessWidget {
  const PaperTabs({
    super.key,
    required this.abstractText,
    required this.translatedAbstract,
    required this.blogSummary,
    this.height = 300,
  });

  final String abstractText;
  final String translatedAbstract;
  final String blogSummary;
  final double height;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TabBar(
            isScrollable: false,
            labelColor: Theme.of(context).colorScheme.primary,
            unselectedLabelColor: Theme.of(context).textTheme.bodyMedium?.color,
            indicatorColor: Theme.of(context).colorScheme.primary,
            tabs: const [
              Tab(text: 'Abstract'),
              Tab(text: 'Korean Translation'),
              Tab(text: 'Blog Summary'),
            ],
          ),
          SizedBox(
            height: height,
            width: double.infinity,
            child: TabBarView(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: SelectableText(
                    abstractText,
                    textAlign: TextAlign.left,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      height: 1.7, // 줄간격
                      fontSize: 15,
                      letterSpacing: 0.1,
                    ),
                  ),
                ),
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: SelectableText(
                    translatedAbstract,
                    textAlign: TextAlign.left,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      height: 1.7,
                      fontSize: 15,
                      letterSpacing: 0.1,
                    ),
                  ),
                ),
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: SelectableText(
                    blogSummary,
                    textAlign: TextAlign.left,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      height: 1.7,
                      fontSize: 15,
                      letterSpacing: 0.1,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
