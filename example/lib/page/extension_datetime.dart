extension ExtensionDateTime on DateTime {
  DateTime firstDayOfMonth() {
    return copyWith(day: 1, hour: 0, minute: 0, second: 0, millisecond: 0);
  }

  //第一时刻
  DateTime firstMoment() {
    return copyWith(hour: 0, minute: 0, second: 0, millisecond: 0);
  }

  //最后一刻
  DateTime lastMoment() {
    return copyWith(hour: 23, minute: 59, second: 59, millisecond: 999);
  }

  /// get WeekDay.
  /// dateTime
  /// isUtc
  /// languageCode zh or en
  /// short
  String getWeekdayDesc({String languageCode = 'en', bool short = false}) {
    String weekday = "";
    switch (this.weekday) {
      case 1:
        weekday = languageCode == 'zh' ? '星期一' : 'Monday';
        break;
      case 2:
        weekday = languageCode == 'zh' ? '星期二' : 'Tuesday';
        break;
      case 3:
        weekday = languageCode == 'zh' ? '星期三' : 'Wednesday';
        break;
      case 4:
        weekday = languageCode == 'zh' ? '星期四' : 'Thursday';
        break;
      case 5:
        weekday = languageCode == 'zh' ? '星期五' : 'Friday';
        break;
      case 6:
        weekday = languageCode == 'zh' ? '星期六' : 'Saturday';
        break;
      case 7:
        weekday = languageCode == 'zh' ? '星期日' : 'Sunday';
        break;
      default:
        break;
    }
    return languageCode == 'zh' ? (short ? weekday.replaceAll('星期', '周') : weekday) : weekday.substring(0, short ? 3 : weekday.length);
  }

  /// get day of year.
  /// 在今年的第几天.
  int getDayOfYear() {
    int month = this.month;
    int days = day;
    for (int i = 1; i < month; i++) {
      days = days +
          DateTime(
            year,
            i,
          ).daysInMonth();
    }
    return days;
  }

  /// Return whether it is leap year.
  /// 是否是闰年
  bool isLeapYear() {
    return year % 4 == 0 && year % 100 != 0 || year % 400 == 0;
  }

  //获取当月的天数
  int daysInMonth() {
    DateTime x1 = DateTime(year, month, 0).toUtc();
    var days = DateTime(year, month + 1, 0).toUtc().difference(x1).inDays;
    return days;
  }

  //时间格式化
  String toStringWithFormat({String? format}) {
    format = format ?? 'yyyy-MM-dd HH:mm:ss';
    if (format.contains('yy')) {
      String year = this.year.toString();
      if (format.contains('yyyy')) {
        format = format.replaceAll('yyyy', year);
      } else {
        format = format.replaceAll('yy', year.substring(year.length - 2, year.length));
      }
    }

    format = _comFormat(month, format, 'M', 'MM');
    format = _comFormat(day, format, 'd', 'dd');
    format = _comFormat(hour, format, 'H', 'HH');
    format = _comFormat(minute, format, 'm', 'mm');
    format = _comFormat(second, format, 's', 'ss');
    format = _comFormat(millisecond, format, 'S', 'SSS');

    return format;
  }

  /// com format.
  static String _comFormat(int value, String format, String single, String full) {
    if (format.contains(single)) {
      if (format.contains(full)) {
        format = format.replaceAll(full, value < 10 ? '0$value' : value.toString());
      } else {
        format = format.replaceAll(single, value.toString());
      }
    }
    return format;
  }
}
