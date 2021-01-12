import 'package:meta/meta.dart';

const Duration _day = Duration(days: 1);
const Duration _week = Duration(days: DateTime.daysPerWeek);
const Duration month = Duration(days: 30);

List<DateTime> gridTimestamps({
  @required Duration timeGridInterval,
  @required int leftBoundEpoch,
  @required int rightBoundEpoch,
}) {
  final List<DateTime> timestamps = <DateTime>[];
  final DateTime rightBoundTime =
      DateTime.fromMillisecondsSinceEpoch(rightBoundEpoch, isUtc: true);

  DateTime t = _gridEpochStart(timeGridInterval, leftBoundEpoch);

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
    final DateTime t = _closestFutureDayStart(leftBoundEpoch);
    final int daysUntilMonday = (8 - t.weekday) % 7;
    return t.add(Duration(days: daysUntilMonday));
  } else if (timeGridInterval == _day) {
    return _closestFutureDayStart(leftBoundEpoch);
  } else {
    final int diff = timeGridInterval.inMilliseconds;
    final int firstLeft = (leftBoundEpoch / diff).ceil() * diff;
    return DateTime.fromMillisecondsSinceEpoch(firstLeft, isUtc: true);
  }
}

DateTime _closestFutureDayStart(int epoch) {
  final DateTime time = DateTime.fromMillisecondsSinceEpoch(epoch, isUtc: true);
  final DateTime dayStart =
      DateTime.utc(time.year, time.month, time.day); // time 00:00:00
  return dayStart.isBefore(time) ? dayStart.add(_day) : dayStart;
}

DateTime _closestFutureMonthStart(int epoch) {
  final DateTime time = DateTime.fromMillisecondsSinceEpoch(epoch, isUtc: true);
  final DateTime monthStart =
      DateTime.utc(time.year, time.month); // day 1, time 00:00:00
  return monthStart.isBefore(time) ? _addMonth(monthStart) : monthStart;
}

DateTime _addMonth(DateTime time) => DateTime.utc(time.year, time.month + 1);

/// Px width of duration in ms on time axis with current scale.
/// Conversion callback dependency of [timeGridInterval].
typedef PxFromMs = double Function(int ms);

Duration timeGridInterval(
  PxFromMs pxFromMs, {
  double minDistanceBetweenLines = 100,
  List<Duration> intervals = const <Duration>[
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
    Duration(days: 4),
    _week,
    Duration(days: 14),
    Duration(days: 21),
    month,
  ],
}) {
  bool hasEnoughDistanceBetweenLines(Duration interval) {
    final double distanceBetweenLines = pxFromMs(interval.inMilliseconds);
    return distanceBetweenLines >= minDistanceBetweenLines;
  }

  return intervals.firstWhere(
    hasEnoughDistanceBetweenLines,
    orElse: () => intervals.last,
  );
}
