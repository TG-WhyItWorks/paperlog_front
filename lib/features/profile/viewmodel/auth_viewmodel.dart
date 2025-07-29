import 'package:flutter/foundation.dart';

///로그인 상태 관리
class AuthViewModel extends ChangeNotifier {
  bool isLoggedIn = false;
  String? userAvatarUrl;

  void login() {
    isLoggedIn = true;
    notifyListeners();
  }

  void logout() {
    isLoggedIn = false;
    notifyListeners();
  }
}
