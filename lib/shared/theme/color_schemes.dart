import 'package:flutter/material.dart';

class AppColors {
  // === KyungHee Brand Base (from guide) ===
  // 201C
  static const khRed = Color(0xFFA40F16); // R164 G15  B22
  // 295C
  static const khBlue = Color(0xFF0D326F); // R13  G50  B111
  // 872C
  static const khGold = Color(0xFFC0A353); // R192 G163 B83
  // Cool Gray 11C
  static const khCoolGray = Color(0xFF717171); // R113 G113 B113
  // Silver 877C
  static const khSilver = Color(0xFFB5B5B5); // R181 G181 B181

  // === Default Light/Dark mapped to KyungHee ===
  // Light (KyungHee)
  static const lightBackground = Color(0xFFFFFFFF);
  static const lightSurface = Color(0xFFF5F5F5); // Silver 톤의 얕은 표면
  static const lightPrimary = khRed; // 메인 브랜드 Red
  static const lightOnPrimary = Color(0xFFFFFFFF);
  static const lightText = Color(0xFF121212);

  // Dark (KyungHee)
  static const darkBackground = Color(0xFF151515); // 아주 짙은 회색
  static const darkSurface = Color(0xFF1E1E1E);
  static const darkPrimary = khRed; // 일관성 유지
  static const darkOnPrimary = Color(0xFFFFFFFF);
  static const darkText = Color(0xFFEAEAEA);
}
