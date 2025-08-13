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
        children: [
          TabBar(
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
            child: TabBarView(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Text(abstractText),
                ),
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Text(translatedAbstract),
                ),
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Text(blogSummary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
