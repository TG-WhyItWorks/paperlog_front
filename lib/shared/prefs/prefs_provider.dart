import 'package:flutter/material.dart';

enum DateFormatOption { ymdDots, ymdDash, ymdSlash, ymdKorean, relative }

class PrefsProvider extends ChangeNotifier {
  DateFormatOption dateFormat = DateFormatOption.ymdDots; // 기본값: 2025.08.12

  void setDateFormat(DateFormatOption v) {
    dateFormat = v;
    notifyListeners();
  }
}
