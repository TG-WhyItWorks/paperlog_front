import 'package:intl/intl.dart';
import 'prefs_provider.dart';

String formatDate(DateTime? dt, DateFormatOption opt) {
  if (dt == null) return '';
  switch (opt) {
    case DateFormatOption.ymdDots:
      return DateFormat('yyyy.MM.dd').format(dt);
    case DateFormatOption.ymdDash:
      return DateFormat('yyyy-MM-dd').format(dt);
    case DateFormatOption.ymdSlash:
      return DateFormat('yyyy/MM/dd').format(dt);
    case DateFormatOption.ymdKorean:
      return DateFormat('yyyy년 MM월 dd일').format(dt);
    case DateFormatOption.relative:
      final now = DateTime.now();
      final diff = now.difference(dt).inDays;
      if (diff == 0) return '오늘';
      if (diff == 1) return '어제';
      if (diff < 7) return '${diff}일 전';
      return DateFormat('yyyy.MM.dd').format(dt);
  }
}
