import 'package:flutter/material.dart';
import 'features/dashboard/view/main_screen.dart';
import 'shared/theme/app_theme.dart';

void main() {
  runApp(const PaperLogApp());
}

class PaperLogApp extends StatelessWidget {
  const PaperLogApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PaperLog',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: const MainScreen(),
    );
  }
}
