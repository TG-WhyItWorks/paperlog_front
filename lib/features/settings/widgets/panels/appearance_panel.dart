import 'package:flutter/material.dart';
import 'package:paperlog_front/shared/prefs/prefs_provider.dart';
import 'package:provider/provider.dart';
import '../setting_card.dart';
import '../../../../shared/theme/theme_provider.dart';

class AppearancePanel extends StatelessWidget {
  const AppearancePanel({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProv = context.watch<ThemeProvider>();
    final prefs = context.watch<PrefsProvider>();
    final mode = themeProv.mode;

    return ListView(
      children: [
        SettingCard(
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
            ],
          ),
        ),
        // 날짜 형식 카드
        SettingCard(
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
