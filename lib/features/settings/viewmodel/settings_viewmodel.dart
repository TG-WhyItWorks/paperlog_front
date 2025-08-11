import 'package:flutter/material.dart';

enum SettingsMenu {
  profile,
  notifications,
  appearance,
  connections,
  privacy,
  data,
}

enum AppThemeChoice { system, light, dark }

class SettingsViewModel extends ChangeNotifier {
  bool isLoading = false;
  String? error;

  // 사이드바 선택 상태
  SettingsMenu menu = SettingsMenu.notifications;

  // ----------------- Notifications -----------------
  bool notifDirect = false; // 댓글/팔로잉 활동 이메일
  bool notifRelevantWeekly = false; // 주간 관련 토픽 이메일
  bool pushEnabled = false; // 브라우저/앱 푸시

  // ----------------- Appearance -----------------
  AppThemeChoice theme = AppThemeChoice.system;
  bool compactDensity = false; // 컴팩트 모드
  bool reduceMotion = false; // 애니메이션 최소화
  double uiScale = 1.0; // 글자/컴포넌트 스케일

  // ----------------- Connections -----------------
  String github = '';
  String twitter = '';
  String linkedin = '';
  String bluesky = '';
  String publicEmail = '';

  bool orcidConnected = false;
  bool scholarConnected = false;

  // 샘플 로드/세이브 (서비스 연동은 추후)
  Future<void> load() async {
    isLoading = true;
    error = null;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 300));
    // 서버/로컬에서 데이터 가져왔다고 가정
    isLoading = false;
    notifyListeners();
  }

  void setMenu(SettingsMenu m) {
    menu = m;
    notifyListeners();
  }

  // -------- Notifications ----------
  Future<void> saveNotifications() async {
    await Future.delayed(const Duration(milliseconds: 200));
  }

  // -------- Appearance ----------
  Future<void> saveAppearance() async {
    await Future.delayed(const Duration(milliseconds: 200));
  }

  // -------- Connections ----------
  Future<void> saveConnections() async {
    await Future.delayed(const Duration(milliseconds: 200));
  }

  Future<void> connectOrcid() async {
    // TODO: OAuth/링크 처리
    orcidConnected = true;
    notifyListeners();
  }

  Future<void> connectScholar() async {
    // TODO: Scholar 연동(스크래핑/수동추가 등 정책에 맞게)
    scholarConnected = true;
    notifyListeners();
  }
}
