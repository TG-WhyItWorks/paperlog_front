import 'package:flutter/material.dart';
import 'features/dashboard/view/main_screen.dart';

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
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color.fromARGB(255, 18, 32, 47),
      ),
      home: const MainScreen(),
    );
  }
}