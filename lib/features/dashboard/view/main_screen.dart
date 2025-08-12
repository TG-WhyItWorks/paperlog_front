import 'package:flutter/material.dart';
import '../viewmodel/dashboard_viewmodel.dart';
import '../widgets/header_widget.dart';
import '../widgets/sidebar_widget.dart';
import '../widgets/recommend_paper_card.dart';
import 'package:provider/provider.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MainViewModel>();
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: HeaderWidget(),
      ),

      body: Column(
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SidebarWidget(),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeInOutCubic,
                  width: 1,
                  color: vm.isSidebarOpen
                      ? Theme.of(context).dividerColor
                      : Colors.transparent,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 24),
                        Text(
                          'Recommended Papers',
                          style: Theme.of(context).textTheme.displayLarge
                              ?.copyWith(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: ListView(
                            padding: EdgeInsets.zero,
                            children: vm.recommendPapers
                                .map(
                                  (paper) => RecommendPaperCard(paper: paper),
                                )
                                .toList(),
                          ),
                        ),
                      ],
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
