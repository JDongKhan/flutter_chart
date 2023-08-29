import 'dart:ui';

/// @author jd

const List<Color> colors10 = [
  Color(0xff5b8ff9),
  Color(0xff5ad8a6),
  Color(0xff5d7092),
  Color(0xfff6bd16),
  Color(0xff6f5ef9),
  Color(0xff6dc8ec),
  Color(0xff945fb9),
  Color(0xffff9845),
  Color(0xff1e9493),
  Color(0xffff99c3),
];

///时间差转换成double  单位为天
double parserDateTimeToDayValue(DateTime? dateTime, DateTime startTime) {
  if (dateTime == null) {
    return 0;
  }
  return dateTime.difference(startTime).inMilliseconds / (24 * 60 * 60 * 1000);
}

///时间差转换成double  单位为小时
double parserDateTimeToHourValue(DateTime? dateTime, DateTime startTime) {
  if (dateTime == null) {
    return 0;
  }
  return dateTime.difference(startTime).inMilliseconds / (60 * 60 * 1000);
}
