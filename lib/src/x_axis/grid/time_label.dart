import 'package:intl/intl.dart' show DateFormat;

/// Returns the time label for the given [time].
String timeLabel(DateTime time) {
  final is0h0m0s = time.hour == 0 && time.minute == 0 && time.second == 0;
  if (time.month == 1 && time.day == 1 && is0h0m0s) {
    return DateFormat('y').format(time);
  }
  if (time.day == 1 && is0h0m0s) {
    return DateFormat('MMMM').format(time);
  }
  if (is0h0m0s) {
    return DateFormat('d MMM').format(time);
  }
  return DateFormat('Hms').format(time);
}
