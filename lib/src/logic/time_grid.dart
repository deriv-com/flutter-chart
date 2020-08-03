import 'package:intl/intl.dart' show DateFormat;
import 'package:meta/meta.dart';

import 'conversion.dart';

const _day = Duration(days: 1);
const _week = Duration(days: DateTime.daysPerWeek);
const month = Duration(days: 30);

List<DateTime> gridTimestamps({
  @required Duration timeGridInterval,
  @required int leftBoundEpoch,
  @required int rightBoundEpoch,
}) {
  final timestamps = <DateTime>[];
  final rightBoundTime =
      DateTime.fromMillisecondsSinceEpoch(rightBoundEpoch, isUtc: true);

  var t = _gridEpochStart(timeGridInterval, leftBoundEpoch);

  while (t.compareTo(rightBoundTime) <= 0) {
    timestamps.add(t);
    t = timeGridInterval == month ? _addMonth(t) : t.add(timeGridInterval);
  }
  return timestamps;
}

DateTime _gridEpochStart(Duration timeGridInterval, int leftBoundEpoch) {
  if (timeGridInterval == month) {
    return _closestFutureMonthStart(leftBoundEpoch);
  } else if (timeGridInterval == _week) {
    final t = _closestFutureDayStart(leftBoundEpoch);
    final daysUntilMonday = (8 - t.weekday) % 7;
    return t.add(Duration(days: daysUntilMonday));
  } else if (timeGridInterval == _day) {
    return _closestFutureDayStart(leftBoundEpoch);
  } else {
    final diff = timeGridInterval.inMilliseconds;
    final firstLeft = (leftBoundEpoch / diff).ceil() * diff;
    return DateTime.fromMillisecondsSinceEpoch(firstLeft, isUtc: true);
  }
}

DateTime _closestFutureDayStart(int epoch) {
  final time = DateTime.fromMillisecondsSinceEpoch(epoch);
  final dayStart =
      DateTime.utc(time.year, time.month, time.day); // time 00:00:00
  return dayStart.isBefore(time) ? dayStart.add(_day) : dayStart;
}

DateTime _closestFutureMonthStart(int epoch) {
  final time = DateTime.fromMillisecondsSinceEpoch(epoch);
  final monthStart =
      DateTime.utc(time.year, time.month); // day 1, time 00:00:00
  return monthStart.isBefore(time) ? _addMonth(monthStart) : monthStart;
}

DateTime _addMonth(DateTime time) {
  return DateTime.utc(time.year, time.month + 1);
}

Duration timeGridInterval(
  double msPerPx, {
  double minDistanceBetweenLines = 100,
  List<Duration> intervals = const [
    Duration(seconds: 5),
    Duration(seconds: 10),
    Duration(seconds: 30),
    Duration(minutes: 1),
    Duration(minutes: 2),
    Duration(minutes: 3),
    Duration(minutes: 5),
    Duration(minutes: 10),
    Duration(minutes: 15),
    Duration(minutes: 30),
    Duration(hours: 1),
    Duration(hours: 2),
    Duration(hours: 4),
    Duration(hours: 8),
    _day,
    _week,
    month,
  ],
}) {
  bool hasEnoughDistanceBetweenLines(Duration interval) {
    final distanceBetweenLines = msToPx(
      interval.inMilliseconds,
      msPerPx: msPerPx,
    );
    return distanceBetweenLines >= minDistanceBetweenLines;
  }

  return intervals.firstWhere(
    hasEnoughDistanceBetweenLines,
    orElse: () => intervals.last,
  );
}

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
