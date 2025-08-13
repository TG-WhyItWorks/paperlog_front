import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/dashboard_viewmodel.dart';
import '../../../shared/theme/theme_provider.dart';
import 'notification_icon.dart';
import '../../profile/widgets/avatar_menu.dart';
import '../../settings/view/settings_dialog.dart';

class HeaderWidget extends StatefulWidget {
  const HeaderWidget({Key? key}) : super(key: key);

  @override
  _HeaderWidgetState createState() => _HeaderWidgetState();
}

class _HeaderWidgetState extends State<HeaderWidget> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    final vm = context.read<MainViewModel>();
    _ctrl = TextEditingController(text: vm.searchQuery);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLight = context.watch<ThemeProvider>().mode == ThemeMode.light;
    final vm = context.watch<MainViewModel>();
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
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: vm.toggleSidebar,
              child: Row(
                children: [
                  Icon(
                    vm.isSidebarOpen ? Icons.menu_open : Icons.menu,
                    color: Theme.of(context).iconTheme.color,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 20),

          /// 로고 및 Home 버튼
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () {
                // 현재 경로가 메인 페이지인지 확인
                final current = ModalRoute.of(context)?.settings.name;
                if (current != '/') {
                  // 메인 페이지가 아니면 메인 페이지로 이동(쌓인 라우트 모두 정리)
                  Navigator.of(
                    context,
                  ).pushNamedAndRemoveUntil('/', (route) => false);
                }
              },
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
          ),
          const SizedBox(width: 20),

          _NavItem(
            label: 'Explore',
            selected: vm.currentPage == PageType.explore,
            onTap: () {
              vm.navigationTo(PageType.explore);
              final current = ModalRoute.of(context)?.settings.name;
              if (current != '/explore') {
                Navigator.of(context).pushNamed('/explore');
              }
            },
          ),
          _NavItem(
            label: 'My Library',
            selected: vm.currentPage == PageType.library,
            onTap: () {
              vm.navigationTo(PageType.library);
              final current = ModalRoute.of(context)?.settings.name;
              if (current != '/library') {
                Navigator.of(context).pushNamed('/library');
              }
            },
          ),
          _NavItem(
            label: 'My Blog',
            selected: vm.currentPage == PageType.blog,
            onTap: () {
              vm.navigationTo(PageType.blog);
              final current = ModalRoute.of(context)?.settings.name;
              if (current != '/blog') {
                Navigator.of(context).pushNamed('/blog');
              }
            },
          ),

          const Spacer(),

          /// 검색창
          SizedBox(
            width: 200,
            child: TextField(
              controller: _ctrl,
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
              textInputAction: TextInputAction.search,
              onChanged: vm.setSearchQuery,
              onSubmitted: (q) {
                final query = q.trim();
                if (query.isNotEmpty) {
                  Navigator.of(context).pushNamed('/explore', arguments: query);
                }
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
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => SettingsDialog.show(context),
          ),
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
