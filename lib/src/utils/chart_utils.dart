/// @author jd

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
