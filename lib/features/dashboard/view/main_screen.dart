import 'package:flutter/material.dart';
import '../viewmodel/dashboard_viewmodel.dart';
import '../widgets/header_widget.dart';
import '../widgets/sidebar_widget.dart';
import '../widgets/searchbar_widget.dart';
import '../widgets/recommend_paper_card.dart';
import '../widgets/folder_list_widget.dart';
import 'package:provider/provider.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late final MainViewModel vm;

  @override
  void initState() {
    super.initState();
    vm = MainViewModel();
    vm.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    vm.removeListener(() {});
    super.dispose();
  }

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
          const SizedBox(height: 24),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (vm.isSidebarOpen) SidebarWidget(),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
