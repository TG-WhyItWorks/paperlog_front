import 'package:flutter/material.dart';
import 'package:paperlog_front/shared/prefs/prefs_provider.dart';
import 'package:provider/provider.dart';
import '../../../shared/theme/theme_provider.dart';
import '../../auth/viewmodel/auth_viewmodel.dart';

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
                        padding: EdgeInsetsGeometry.all(16),
                        child: Text(
                          'User Settings',
                          style: Theme.of(context).textTheme.bodyLarge!
                              .copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                        ),
                      ),
                      _NavTile(
                        label: 'Profile',
                        icon: Icons.person_outline,
                        selected: _tab == SettingsSection.profile,
                        onTap: () =>
                            setState(() => _tab = SettingsSection.profile),
                      ),
                      _NavTile(
                        label: 'Notifications',
                        icon: Icons.notifications_outlined,
                        selected: _tab == SettingsSection.notifications,
                        onTap: () => setState(
                          () => _tab = SettingsSection.notifications,
                        ),
                      ),
                      _NavTile(
                        label: 'Appearance',
                        icon: Icons.dark_mode_outlined,
                        selected: _tab == SettingsSection.appearance,
                        onTap: () =>
                            setState(() => _tab = SettingsSection.appearance),
                      ),
                      _NavTile(
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
        return const _ProfilePanel();
      case SettingsSection.notifications:
        return const _NotificationsPanel();
      case SettingsSection.appearance:
        return const _AppearancePanel();
      case SettingsSection.connections:
        return const _ConnectionsPanel();
    }
  }
}

// ---------- NAV tile ----------
class _NavTile extends StatelessWidget {
  const _NavTile({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = selected
        ? theme.colorScheme.primary.withOpacity(0.10)
        : Colors.transparent;
    final fg = selected
        ? theme.colorScheme.primary
        : theme.colorScheme.onSurface;

    return InkWell(
      onTap: onTap,
      child: Container(
        height: 44,
        color: bg,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            Icon(icon, color: fg),
            const SizedBox(width: 10),
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: fg,
                fontWeight: selected ? FontWeight.w700 : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------- PANELS ----------
class _ProfilePanel extends StatelessWidget {
  const _ProfilePanel();

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return ListView(
      children: [
        _Card(
          title: '프로필',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('이름, 소개, 아바타 등은 프로필 화면에서 수정할 수 있어요.', style: t.bodySmall),
              const SizedBox(height: 8),
              FilledButton.tonal(
                onPressed: () => Navigator.of(context).pushNamed('/profile'),
                child: const Text('프로필로 이동'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _NotificationsPanel extends StatefulWidget {
  const _NotificationsPanel();

  @override
  State<_NotificationsPanel> createState() => _NotificationsPanelState();
}

class _NotificationsPanelState extends State<_NotificationsPanel> {
  bool directOn = false;
  bool relevantOn = false;
  bool pushOn = false;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        _Card(
          title: '다이렉트 알림',
          subtitle: '댓글/멘션/팔로우 중인 논문 활동을 이메일로 받아요.',
          child: _OnOffRow(
            value: directOn,
            onChanged: (v) => setState(() => directOn = v),
          ),
        ),
        _Card(
          title: '관련 토론',
          subtitle: '관심 주제의 주간 트렌딩 토론을 이메일로 받아요.',
          child: _OnOffRow(
            value: relevantOn,
            onChanged: (v) => setState(() => relevantOn = v),
          ),
        ),
        _Card(
          title: '푸시 알림',
          subtitle: '브라우저 푸시 권한이 필요할 수 있어요.',
          child: _OnOffRow(
            value: pushOn,
            onChanged: (v) => setState(() => pushOn = v),
          ),
        ),
      ],
    );
  }
}

class _AppearancePanel extends StatelessWidget {
  const _AppearancePanel();

  @override
  Widget build(BuildContext context) {
    final themeProv = context.watch<ThemeProvider>();
    final prefs = context.watch<PrefsProvider>();
    final mode = themeProv.mode;

    return ListView(
      children: [
        _Card(
          title: '테마',
          subtitle: '인터페이스의 밝기 모드를 선택하세요.',
          child: Column(
            children: [
              RadioListTile<ThemeMode>(
                value: ThemeMode.light,
                groupValue: mode,
                title: const Text('라이트 모드'),
                onChanged: (m) => context.read<ThemeProvider>().setMode(m!),
              ),
              RadioListTile<ThemeMode>(
                value: ThemeMode.dark,
                groupValue: mode,
                title: const Text('다크 모드'),
                onChanged: (m) => context.read<ThemeProvider>().setMode(m!),
              ),
              // 필요 시 시스템 모드도 추가 가능
              // RadioListTile(value: ThemeMode.system, ...)
            ],
          ),
        ),
        // ✅ 여기부터 추가: 날짜 형식 카드
        _Card(
          title: '날짜 형식',
          subtitle: '목록/카드에서 날짜를 표시하는 형식입니다.',
          child: Column(
            children: [
              RadioListTile<DateFormatOption>(
                value: DateFormatOption.ymdDots,
                groupValue: prefs.dateFormat,
                title: const Text('2025.08.12'),
                onChanged: (v) =>
                    context.read<PrefsProvider>().setDateFormat(v!),
              ),
              RadioListTile<DateFormatOption>(
                value: DateFormatOption.ymdDash,
                groupValue: prefs.dateFormat,
                title: const Text('2025-08-12'),
                onChanged: (v) =>
                    context.read<PrefsProvider>().setDateFormat(v!),
              ),
              RadioListTile<DateFormatOption>(
                value: DateFormatOption.ymdSlash,
                groupValue: prefs.dateFormat,
                title: const Text('2025/08/12'),
                onChanged: (v) =>
                    context.read<PrefsProvider>().setDateFormat(v!),
              ),
              RadioListTile<DateFormatOption>(
                value: DateFormatOption.ymdKorean,
                groupValue: prefs.dateFormat,
                title: const Text('2025년 08월 12일'),
                onChanged: (v) =>
                    context.read<PrefsProvider>().setDateFormat(v!),
              ),
              RadioListTile<DateFormatOption>(
                value: DateFormatOption.relative,
                groupValue: prefs.dateFormat,
                title: const Text('상대 시간(오늘/어제/…)'),
                onChanged: (v) =>
                    context.read<PrefsProvider>().setDateFormat(v!),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ConnectionsPanel extends StatelessWidget {
  const _ConnectionsPanel();

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        _Card(
          title: '소셜 링크',
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: const [
              _MiniInput(label: 'GitHub 사용자명'),
              _MiniInput(label: 'X(Twitter) 사용자명'),
              _MiniInput(label: 'LinkedIn 사용자명'),
              _MiniInput(label: 'Bluesky 핸들'),
              _MiniInput(label: '공개 이메일'),
            ],
          ),
        ),
        _Card(
          title: 'Academic Profiles',
          subtitle: 'ORCID, Google Scholar 연동으로 퍼블리케이션을 자동 임포트해요.',
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              OutlinedButton(
                onPressed: () {},
                child: const Text('Connect ORCID'),
              ),
              OutlinedButton(
                onPressed: () {},
                child: const Text('Connect Scholar'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------- small widgets ----------
class _Card extends StatelessWidget {
  const _Card({required this.title, this.subtitle, required this.child});
  final String title;
  final String? subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 6),
              Text(subtitle!, style: t.bodySmall),
            ],
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _OnOffRow extends StatelessWidget {
  const _OnOffRow({required this.value, required this.onChanged});
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Radio<bool>(
          value: true,
          groupValue: value,
          onChanged: (_) => onChanged(true),
        ),
        const Text('On'),
        const SizedBox(width: 12),
        Radio<bool>(
          value: false,
          groupValue: value,
          onChanged: (_) => onChanged(false),
        ),
        const Text('Off'),
      ],
    );
  }
}

class _MiniInput extends StatelessWidget {
  const _MiniInput({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      child: TextField(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
      ),
    );
  }
}
