import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../core/models/user_model.dart';
import '../service/auth_service.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

enum AuthStatus { idle, loading, authenticated, unauthenticated, error }

class AuthViewModel extends ChangeNotifier {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: kIsWeb
        ? '1045626017141-53ouu1tf82895ckrq7tsk4qkj6730f42.apps.googleusercontent.com'
        : null,
    scopes: ['email', 'profile', 'openid'],
  );
  final AuthService _authService = AuthService();
  String? userAvatarUrl;

  AuthStatus _status = AuthStatus.idle;
  String? _errorMessage;
  UserModel? _user;
  int? get userId => _user?.id;

  AuthStatus get status => _status;
  String? get errorMessage => _errorMessage;
  UserModel? get user => _user;
  bool get isLoggedIn => _status == AuthStatus.authenticated;

  AuthViewModel() {
    // 웹에서는 renderButton 클릭 시 or One Tap에 의해 여기로 이벤트가 옴
    _googleSignIn.onCurrentUserChanged.listen((account) async {
      if (account == null) {
        _status = AuthStatus.unauthenticated;
        notifyListeners();
        return;
      }
      userAvatarUrl = account.photoUrl;
      try {
        final auth =
            await account.authentication; // v6: 여기서 idToken/accessToken
        final idToken = auth.idToken; // ← 서버 검증용
        final accessToken = auth.accessToken; // ← 필요시 사용

        if (kIsWeb && (idToken == null || idToken.isEmpty)) {
          // 웹에서 idToken이 비어있으면 잘못된 경로(signIn())로 탄 것
          throw Exception(
            '웹에서는 renderButton/signInSilently를 통해서만 idToken이 발급됩니다.',
          );
        }

        debugPrint('[GSI] idToken len=${idToken?.length} → POST /auth/google');

        _user = await _authService.loginWithGoogle(
          accessToken: accessToken ?? '',
          idToken: idToken!,
        );

        debugPrint('[GSI] backend OK: ${_user?.email}');
        _status = AuthStatus.authenticated;
      } catch (e) {
        _errorMessage = e.toString();
        _status = AuthStatus.error;
      }
      notifyListeners();
    });

    // 앱 시작 시: 기존 세션/One Tap 시도 (웹에서 idToken을 받을 수 있는 경로)
    _googleSignIn
        .signInSilently(); // 웹 권장 흐름. :contentReference[oaicite:2]{index=2}
  }

  Future<void> signInWithGoogle() async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      if (kIsWeb) {
        // 웹은 커스텀 버튼 onPressed로 signIn()을 호출하면 idToken이 없음 (경고 로그가 뜨는 이유)
        // 반드시 renderButton 위젯을 사용해야 함.
        throw Exception('웹에서는 구글 제공 버튼(renderButton)으로 로그인하세요.');
      } else {
        // 모바일/데스크톱은 기존 방식 사용
        final account = await _googleSignIn.signIn();
        if (account == null) {
          _status = AuthStatus.unauthenticated;
        }
      }
    } catch (e) {
      _errorMessage = e.toString();
      _status = AuthStatus.error;
    }
    notifyListeners();
  }

  // Future<void> signInWithGoogle() async {
  //   _status = AuthStatus.loading;
  //   notifyListeners();

  //   try {
  //     final account = await _googleSignIn.signIn();
  //     if (account == null) {
  //       // 사용자가 팝업을 닫은 경우
  //       _status = AuthStatus.unauthenticated;
  //     } else {
  //       final auth = await account.authentication;
  //       _user = await _authService.loginWithGoogle(
  //         accessToken: auth.accessToken!,
  //         idToken: auth.idToken!,
  //       );
  //       _status = AuthStatus.authenticated;
  //     }
  //   } catch (e) {
  //     _errorMessage = e.toString();
  //     _status = AuthStatus.error;
  //   }
  //   notifyListeners();
  // }

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
      if (userAvatarUrl != null && userAvatarUrl!.isNotEmpty) {
        try {
          PaintingBinding.instance.imageCache.evict(
            NetworkImage(userAvatarUrl!),
          );
        } catch (_) {}
      }
      userAvatarUrl = null;
      _user = null;
      _status = AuthStatus.unauthenticated;
    } catch (e) {
      _errorMessage = e.toString();
      _status = AuthStatus.error;
    }
    notifyListeners();
  }
}
