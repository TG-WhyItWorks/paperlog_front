import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/viewmodel/auth_viewmodel.dart';
import '../widgets/panels/profile_panel.dart';
import '../widgets/nav_tile.dart';
import '../widgets/panels/appearance_panel.dart';
import '../widgets/panels/connections_panel.dart';
import '../widgets/panels/notifications_panel.dart';

enum SettingsSection { profile, notifications, appearance, connections }

class SettingsDialog extends StatefulWidget {
  const SettingsDialog({super.key, this.initial = SettingsSection.profile});
  final SettingsSection initial;

  /// anywhere: await SettingsDialog.show(context);
  static Future<void> show(
    BuildContext context, {
    SettingsSection initial = SettingsSection.profile,
  }) {
    return showGeneralDialog(
      context: context,
      barrierLabel: 'Settings',
      barrierDismissible: true,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (_, __, ___) => Align(
        alignment: Alignment.center,
        child: SettingsDialog(initial: initial),
      ),
      transitionBuilder: (_, anim, __, child) {
        final curved = CurvedAnimation(
          parent: anim,
          curve: Curves.easeOutCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween(begin: 0.98, end: 1.0).animate(curved),
            child: child,
          ),
        );
      },
    );
  }

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  late SettingsSection _tab;

  @override
  void initState() {
    super.initState();
    _tab = widget.initial;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    // responsive 크기
    final double maxW = 960;
    final double maxH = 680;
    final double w = (size.width - 48).clamp(320, maxW);
    final double h = (size.height - 48).clamp(420, maxH);

    return Material(
      type: MaterialType.transparency,
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: w.toDouble(),
            height: h.toDouble(),
            color: theme.colorScheme.surface,
            child: Row(
              children: [
                // left nav
                Container(
                  width: 220,
                  color: theme.colorScheme.surfaceVariant.withOpacity(0.25),
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          'User Settings',
                          style: Theme.of(context).textTheme.bodyLarge!
                              .copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                        ),
                      ),
                      NavTile(
                        label: 'Profile',
                        icon: Icons.person_outline,
                        selected: _tab == SettingsSection.profile,
                        onTap: () =>
                            setState(() => _tab = SettingsSection.profile),
                      ),
                      NavTile(
                        label: 'Notifications',
                        icon: Icons.notifications_outlined,
                        selected: _tab == SettingsSection.notifications,
                        onTap: () => setState(
                          () => _tab = SettingsSection.notifications,
                        ),
                      ),
                      NavTile(
                        label: 'Appearance',
                        icon: Icons.dark_mode_outlined,
                        selected: _tab == SettingsSection.appearance,
                        onTap: () =>
                            setState(() => _tab = SettingsSection.appearance),
                      ),
                      NavTile(
                        label: 'Connections',
                        icon: Icons.link_outlined,
                        selected: _tab == SettingsSection.connections,
                        onTap: () =>
                            setState(() => _tab = SettingsSection.connections),
                      ),
                      const Spacer(),
                      const Divider(height: 1),
                      // 로그아웃
                      Builder(
                        builder: (ctx) => ListTile(
                          leading: const Icon(
                            Icons.logout,
                            color: Colors.redAccent,
                          ),
                          title: const Text(
                            'Log out',
                            style: TextStyle(color: Colors.redAccent),
                          ),
                          onTap: () async {
                            await ctx.read<AuthViewModel>().signOut();
                            if (mounted) Navigator.of(context).pop();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                VerticalDivider(
                  width: 1, // 차지하는 가로공간
                  thickness: 1, // 선 두께
                  color: theme.dividerColor,
                ),

                // right content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: _buildPanel(_tab),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPanel(SettingsSection s) {
    switch (s) {
      case SettingsSection.profile:
        return const ProfilePanel();
      case SettingsSection.notifications:
        return const NotificationsPanel();
      case SettingsSection.appearance:
        return const AppearancePanel();
      case SettingsSection.connections:
        return const ConnectionsPanel();
    }
  }
}
