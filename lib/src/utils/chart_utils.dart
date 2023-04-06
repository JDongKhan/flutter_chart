/// @author jd

double parserDateTimeToDayValue(DateTime? dateTime, DateTime startTime) {
  if (dateTime == null) {
    return 0;
  }
  return dateTime.difference(startTime).inMilliseconds / (24 * 60 * 60 * 1000);
}

// double parserDateTimeToHourValue(DateTime? dateTime, DateTime startTime) {
//   if (dateTime == null) {
//     return 0;
//   }
//   return dateTime.difference(startTime).inMilliseconds / (60 * 60 * 1000);
// }
