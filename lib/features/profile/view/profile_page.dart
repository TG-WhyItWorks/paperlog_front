import 'package:flutter/material.dart';
import 'package:paperlog_front/features/dashboard/viewmodel/dashboard_viewmodel.dart';
import 'package:provider/provider.dart';

//import '../../../core/models/profile_model.dart';
import '../viewmodel/profile_viewmodel.dart';
import '../widgets/profile_avatar_widget.dart';
import '../widgets/profile_stat_widget.dart';
import '../../dashboard/widgets/header_widget.dart';
import '../../dashboard/widgets/sidebar_widget.dart';
import '../../auth/viewmodel/auth_viewmodel.dart';

import '../widgets/badge_card.dart';
import '../widgets/interest_card.dart';

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) =>
          ProfileViewmodel(ctx.read<AuthViewModel>())..loadProfile(),
      child: Consumer<ProfileViewmodel>(
        builder: (context, vm, _) {
          final profile = vm.profile;
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
                  const SidebarWidget(),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 280),
                    curve: Curves.easeInOutCubic,
                    width: 1,
                    color: context.watch<MainViewModel>().isSidebarOpen
                        ? Theme.of(context).dividerColor
                        : Colors.transparent,
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final isWeb = constraints.maxWidth > 600;
                          final avatarSize = isWeb ? 120.0 : 80.0;
                          final cardWidth = isWeb ? 800.0 : double.infinity;
                          return Center(
                            child: Container(
                              width: cardWidth,
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 8,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  ProfileAvatar(
                                    avatarUrl: profile.avatarUrl,
                                    size: avatarSize,
                                  ),
                                  const SizedBox(height: 16),

                                  Text(
                                    profile.username,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.headlineMedium,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    profile.subtitle, //ex 'Ustar2002 ' he/him'
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                  ),
                                  const SizedBox(height: 12),

                                  if (profile.bio.isNotEmpty) ...[
                                    Text(
                                      '"${profile.bio}"',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyMedium,
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 16),
                                  ],
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      ProfileStat(
                                        label: '팔로워',
                                        count: vm.profile.followers,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '·',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodyMedium,
                                      ),

                                      const SizedBox(width: 8),
                                      ProfileStat(
                                        label: '팔로윙',
                                        count: vm.profile.following,
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 16),

                                  OutlinedButton(
                                    onPressed: () =>
                                        _showEditBioDialog(context, vm),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Theme.of(
                                        context,
                                      ).textTheme.labelLarge?.color,

                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 24,
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: const Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                      child: Text('프로필 수정'),
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  InterestCard(interests: vm.interests),
                                  const SizedBox(height: 24),
                                  BadgeCard(badges: vm.badges),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  //TODO: 모바일 레이아웃용

  // List<Widget> _buildContent(
  //   ProfileModel profile,
  //   double avatarSize,
  //   ProfileViewmodel vm,
  //   BuildContext context,
  // ) {
  //   return [
  //     ProfileAvatar(avatarUrl: profile.avatarUrl, size: avatarSize),
  //     SizedBox(width: 24, height: 24),
  //     Expanded(
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Text(
  //             profile.username,
  //             style: Theme.of(context).textTheme.headlineMedium,
  //           ),
  //           SizedBox(height: 8),
  //           Text(profile.bio),
  //           SizedBox(height: 16),
  //           Row(
  //             children: [
  //               ProfileStat(label: '팔로워', count: int.parse(profile.followers)),
  //               SizedBox(height: 16),
  //               ProfileStat(label: '팔로윙', count: int.parse(profile.following)),
  //             ],
  //           ),
  //           SizedBox(height: 24),
  //           ElevatedButton(
  //             onPressed: () => _showEditBioDialog(context, vm),
  //             child: Text('프로필 수정'),
  //           ),
  //         ],
  //       ),
  //     ),
  //   ];
  // }

  void _showEditBioDialog(BuildContext context, ProfileViewmodel vm) {
    final TextEditingController controller = TextEditingController(
      text: vm.profile.bio,
    );
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text('자기소개 수정'),
          content: TextField(
            controller: controller,
            maxLines: 3,
            decoration: InputDecoration(hintText: '새로운 자기 소개를 입력하세요'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('취소'),
            ),
            ElevatedButton(
              onPressed: () {
                vm.updateBio(controller.text);
                Navigator.of(context).pop();
              },
              child: Text('저장'),
            ),
          ],
        );
      },
    );
  }
}
