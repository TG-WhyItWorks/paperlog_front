import 'package:flutter/material.dart';
import 'package:paperlog_front/features/dashboard/viewmodel/dashboard_viewmodel.dart';
import 'package:paperlog_front/features/profile/widgets/edit_bio_dialog.dart';
import 'package:provider/provider.dart';

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
                                    onPressed: () async {
                                      final newBio = await EditBioDialog.show(
                                        context,
                                        initial: vm.profile.bio,
                                      );
                                      if (newBio != null) {
                                        vm.updateBio(newBio);
                                      }
                                    },
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
}
