import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../core/models/user_model.dart';
import '../service/auth_service.dart';

enum AuthStatus { idle, loading, authenticated, unauthenticated, error }

class AuthViewModel extends ChangeNotifier {
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);
  final AuthService _authService = AuthService();
  String? userAvatarUrl;

  AuthStatus _status = AuthStatus.idle;
  String? _errorMessage;
  UserModel? _user;

  AuthStatus get status => _status;
  String? get errorMessage => _errorMessage;
  UserModel? get user => _user;
  bool get isLoggedIn => _status == AuthStatus.authenticated;

  Future<void> signInWithGoogle() async {
    _status = AuthStatus.loading;
    notifyListeners();

    try {
      final account = await _googleSignIn.signIn();
      if (account == null) {
        // 사용자가 팝업을 닫은 경우
        _status = AuthStatus.unauthenticated;
      } else {
        final auth = await account.authentication;
        _user = await _authService.loginWithGoogle(
          accessToken: auth.accessToken!,
          idToken: auth.idToken!,
        );
        _status = AuthStatus.authenticated;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _status = AuthStatus.error;
    }
    notifyListeners();
  }

  Future<void> signInWithEmail(String email, String password) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _user = await _authService.loginWithEmail(email, password);
      _status = AuthStatus.authenticated;
    } catch (e) {
      _errorMessage = e.toString();
      _status = AuthStatus.error;
    }
    notifyListeners();
  }

  Future<void> signOut() async {
    _status = AuthStatus.loading;
    notifyListeners();

    try {
      await _authService.logout();
      await _googleSignIn.signOut();
      _user = null;
      _status = AuthStatus.unauthenticated;
    } catch (e) {
      _errorMessage = e.toString();
      _status = AuthStatus.error;
    }
    notifyListeners();
  }
}
