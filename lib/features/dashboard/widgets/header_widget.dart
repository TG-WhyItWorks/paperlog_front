import 'package:flutter/material.dart';
import '../viewmodel/dashboard_viewmodel.dart';

class HeaderWidget extends StatelessWidget {
  final MainViewModel viewModel;
  const HeaderWidget({required this.viewModel, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE5E8EA))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          /// 로고& 사이드바 토글
          GestureDetector(
            onTap: viewModel.toggleSidebar,
            child: Row(
              children: [
                Icon(
                  viewModel.isSidebarOpen ? Icons.menu_open : Icons.menu,
                  color: Colors.white,
                ),
                const SizedBox(width: 8),
                const Text(
                  'PaperLog',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),

          _NavItem(
            label: 'Home',
            selected: viewModel.currentPage == PageType.home,
            onTap: () => viewModel.navigationTo(PageType.home),
          ),
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
                fillColor: const Color(0xFF2E3A4D),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(Icons.search, color: Colors.white70),
              ),
              style: const TextStyle(color: Colors.white),
              onSubmitted: (q) {
                //TODO: 검색 기능 구현
              },
            ),
          ),
          const SizedBox(width: 16),

          /// 알림 아이콘
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white),
            onPressed: () {},
          ),
          const SizedBox(width: 16),

          /// 프로필 아바타
          GestureDetector(
            onTap: () {
              //TODO: 프로필 페이지로 이동
            },
            child: CircleAvatar(
              radius: 20,
              backgroundImage: NetworkImage(
                'https://example.com/profile.jpg', // 프로필 이미지 URL
              ),
            ),
          ),
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
          color: selected ? Colors.white : Colors.grey,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
