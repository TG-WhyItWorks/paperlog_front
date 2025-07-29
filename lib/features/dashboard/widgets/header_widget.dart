import 'package:flutter/material.dart';
import '../viewmodel/dashboard_viewmodel.dart';
import 'package:provider/provider.dart';
import '../../../shared/theme/theme_provider.dart';
import 'notification_icon.dart';
import '../../profile/viewmodel/auth_viewmodel.dart';
import '../../profile/widgets/avatar_menu.dart';

class HeaderWidget extends StatelessWidget {
  final MainViewModel viewModel;
  const HeaderWidget({required this.viewModel, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isLight = context.watch<ThemeProvider>().mode == ThemeMode.light;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          /// 사이드바 토글
          GestureDetector(
            onTap: viewModel.toggleSidebar,
            child: Row(
              children: [
                Icon(
                  viewModel.isSidebarOpen ? Icons.menu_open : Icons.menu,
                  color: Theme.of(context).iconTheme.color,
                ),
              ],
            ),
          ),

          const SizedBox(width: 20),

          /// 로고 및 Home 버튼
          GestureDetector(
            onTap: () => viewModel.navigationTo(PageType.home),
            child: Row(
              children: [
                Text(
                  'PaperLog',
                  style: Theme.of(context).textTheme.displayLarge!.copyWith(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),

          _NavItem(
            label: 'Explore',
            selected: viewModel.currentPage == PageType.explore,
            onTap: () => viewModel.navigationTo(PageType.explore),
          ),
          _NavItem(
            label: 'My Library',
            selected: viewModel.currentPage == PageType.library,
            onTap: () => viewModel.navigationTo(PageType.library),
          ),
          _NavItem(
            label: 'My Blog',
            selected: viewModel.currentPage == PageType.blog,
            onTap: () => viewModel.navigationTo(PageType.blog),
          ),

          const Spacer(),

          /// 검색창
          SizedBox(
            width: 200,
            child: TextField(
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                hintText: 'Search',
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: Theme.of(context).iconTheme.color?.withOpacity(0.7),
                ),
              ),
              style: const TextStyle(color: Colors.white),
              onSubmitted: (q) {
                //TODO: 검색 기능 구현
              },
            ),
          ),
          const SizedBox(width: 16),

          /// 알림 아이콘 & 테마 토글
          IconButton(
            icon: Icon(
              isLight ? Icons.dark_mode : Icons.light_mode,
              color: Theme.of(context).iconTheme.color,
            ),
            onPressed: () => context.read<ThemeProvider>().toggle(),
          ),
          const NotificationIcon(),
          const SizedBox(width: 16),

          /// 프로필 아바타
          const AvatarMenu(),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.label,
    required this.selected,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      child: Text(
        label,
        style: TextStyle(
          color: selected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).textTheme.bodyLarge?.color,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
