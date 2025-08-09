import 'package:flutter/material.dart';
import 'package:paperlog_front/features/auth/view/login_page.dart';
import 'package:paperlog_front/features/explore/view/explore_page.dart';
import 'package:paperlog_front/features/explore/viewmodel/explore_viewmodel.dart';
import 'package:paperlog_front/features/paper/view/paper_detail_page.dart';
import 'package:paperlog_front/features/paper/viewmodel/paper_detail_viewmodel.dart';
import 'package:provider/provider.dart';
import 'features/dashboard/view/main_screen.dart';
import 'shared/theme/app_theme.dart';
import 'shared/theme/theme_provider.dart';
import 'features/dashboard/viewmodel/notification_viewmodel.dart';
import 'features/auth/viewmodel/auth_viewmodel.dart';
import 'features/dashboard/viewmodel/dashboard_viewmodel.dart';
import 'features/profile/view/profile_page.dart';
//import 'features/auth/view/login_page.dart';
//import 'features/settings/view/settings_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => NotificationViewModel()),
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => MainViewModel()),
      ],
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

      //라우트 정리
      routes: {
        '/': (_) => const MainScreen(),
        '/login': (_) => const LoginPage(),

        // '/login': (context) => ChangeNotifierProvider.value(
        //   value: Provider.of<AuthViewModel>(context, listen: false),
        //   child: const LoginPage(),
        // ),
        //'/signup':(_) => const SignUpPage(),
        '/profile': (_) => ProfilePage(),
        '/explore': (context) {
          final initialQuery =
              ModalRoute.of(context)!.settings.arguments as String? ?? '';
          return ChangeNotifierProvider<ExploreViewmodel>(
            create: (_) => ExploreViewmodel()..search(initialQuery),
            child: ExplorePage(initialQuery: initialQuery),
          );
        },
        '/paper': (context) {
          final paperId =
              ModalRoute.of(context)!.settings.arguments as String? ?? '';
          return ChangeNotifierProvider(
            create: (_) => PaperDetailViewModel()..loadDetail(paperId),
            child: PaperDetailPage(paperId: paperId),
          );
        },
        //'/library': (_) => LibraryPage(),
        //'/login': (context) => LoginPage(),
        //'/settings': (context) => SettingsPage(),
      },

      //존재하지 않는 라우트 요청 시 처리
      onUnknownRoute: (settings) =>
          MaterialPageRoute(builder: (_) => const MainScreen()),
    );
  }
}
