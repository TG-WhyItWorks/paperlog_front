import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../dashboard/widgets/header_widget.dart';
import '../../dashboard/widgets/sidebar_widget.dart';
import '../../dashboard/viewmodel/dashboard_viewmodel.dart';
import '../viewmodel/paper_detail_viewmodel.dart';
import '../widgets/blog_post_card.dart';
import '../widgets/recommended_papers_list.dart';

class PaperDetailPage extends StatefulWidget {
  final String paperId;
  const PaperDetailPage({Key? key, required this.paperId}) : super(key: key);

  @override
  _PaperDetailedPageState createState() => _PaperDetailedPageState();
}

class _PaperDetailedPageState extends State<PaperDetailPage>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PaperDetailViewModel>().loadDetail(widget.paperId);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PaperDetailViewModel>();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: HeaderWidget(),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (context.watch<MainViewModel>().isSidebarOpen) SidebarWidget(),
            VerticalDivider(
              width: 1,
              thickness: 1,
              color: Theme.of(context).dividerColor,
            ),
            Expanded(
              child: vm.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : vm.error != null
                  ? Center(child: Text('오류 발생: ${vm.error}'))
                  : _buildContent(context, vm),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, PaperDetailViewModel vm) {
    final detail = vm.detail;
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
          ),
          const SizedBox(height: 16),
          Text(
            detail!.title,
            style: Theme.of(
              context,
            ).textTheme.displayLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Authors: ${detail.authors.join(', ')} | Published: ${detail.year} | Fields: ${detail.fields.join(', ')}',
            style: Theme.of(context).textTheme.labelSmall,
          ),

          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _launchUrl(detail.pdfUrl),
            icon: const Icon(Icons.download_rounded),
            label: const Text('Download Paper'),
          ),

          const SizedBox(height: 24),
          TabBar(
            controller: _tabController,
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
            height: 300,
            child: TabBarView(
              children: [
                SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: Text(detail.abstractText),
                ),
                SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: Text(detail.translatedAbstract),
                ),
                SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: Text(detail.blogSummary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Related Blog Posts',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...detail.relatedBlogs.map((b) => BlogPostCard(blog: b)),

          const SizedBox(height: 12),
          RecommendedPapersList(),
        ],
      ),
    );
  }

  void _launchUrl(String url) {
    //url_luancher 로 구현
  }
}
