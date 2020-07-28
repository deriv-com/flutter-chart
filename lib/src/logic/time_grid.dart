import 'package:meta/meta.dart';

import 'conversion.dart';

const _day = const Duration(days: 1);
const _week = const Duration(days: DateTime.daysPerWeek);

List<DateTime> gridTimestamps({
  @required Duration timeGridInterval,
  @required int leftBoundEpoch,
  @required int rightBoundEpoch,
}) {
  final timestamps = <DateTime>[];
  final rightBoundTime = DateTime.fromMillisecondsSinceEpoch(rightBoundEpoch);

  var t = _gridEpochStart(timeGridInterval, leftBoundEpoch);

  while (t.compareTo(rightBoundTime) <= 0) {
    timestamps.add(t);
    t = t.add(timeGridInterval);
  }
  return timestamps;
}

DateTime _gridEpochStart(Duration timeGridInterval, int leftBoundEpoch) {
  if (timeGridInterval == _week) {
    var t = _nextDayStart(leftBoundEpoch);
    while (t.weekday != DateTime.monday) t = t.add(_day);
    return t;
  } else if (timeGridInterval == _day) {
    return _nextDayStart(leftBoundEpoch);
  } else {
    final diff = timeGridInterval.inMilliseconds;
    final firstLeft = (leftBoundEpoch / diff).ceil() * diff;
    return DateTime.fromMillisecondsSinceEpoch(firstLeft);
  }
}

DateTime _nextDayStart(int leftBoundEpoch) {
  final left = DateTime.fromMillisecondsSinceEpoch(leftBoundEpoch);
  var t = DateTime(left.year, left.month, left.day); // time set to 00:00:00
  return t.isBefore(left) ? t.add(_day) : t;
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
