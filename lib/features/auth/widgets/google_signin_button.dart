import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/auth_viewmodel.dart';

// 웹 전용: 구글 버튼 렌더러
// 버튼 스타일 타입 등은 web_only 네임스페이스 안에 있음
// ignore: avoid_web_libraries_in_flutter
import 'package:google_sign_in_web/web_only.dart' as web;

class GoogleSignInButton extends StatelessWidget {
  const GoogleSignInButton({super.key});

  @override
  Widget build(BuildContext context) {
    final authVm = context.read<AuthViewModel>();

    if (kIsWeb) {
      return SizedBox(
        width: 300,
        child: web.renderButton(
          configuration: web.GSIButtonConfiguration(
            type: web.GSIButtonType.standard,
            theme: web.GSIButtonTheme.filledBlue,
            size: web.GSIButtonSize.large,
            text: web.GSIButtonText.signinWith,
            shape: web.GSIButtonShape.pill,
            logoAlignment: web.GSIButtonLogoAlignment.center,
            minimumWidth: 300,
          ),
        ),
      );
    }

    // 모바일/데스크톱(앱)용
    return ElevatedButton.icon(
      icon: Image.asset('assets/images/google_logo.png', height: 24, width: 24),
      onPressed: () async {
        await authVm.signInWithGoogle();
      },
      label: const Text('Sign in with Google'),
    );
  }
}
