import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'features/dashboard/view/main_screen.dart';
import 'shared/theme/app_theme.dart';
import 'shared/theme/theme_provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const PaperLogApp(),
    ),
  );
}

class PaperLogApp extends StatelessWidget {
  const PaperLogApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeMode = context.watch<ThemeProvider>().mode;

    return MaterialApp(
      title: 'PaperLog',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: const MainScreen(),
    );
  }
}
