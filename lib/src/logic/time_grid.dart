import 'package:meta/meta.dart';

import 'conversion.dart';

List<int> gridEpochs({
  @required Duration timeGridInterval,
  @required int leftBoundEpoch,
  @required int rightBoundEpoch,
}) {
  final epochs = <int>[];
  if (timeGridInterval == Duration(days: DateTime.daysPerWeek)) {
    final left = DateTime.fromMillisecondsSinceEpoch(leftBoundEpoch);
    final right = DateTime.fromMillisecondsSinceEpoch(rightBoundEpoch);
    var d = DateTime(left.year, left.month, left.day);
    if (d.isBefore(left)) d = d.add(Duration(days: 1));
    while (d.weekday != DateTime.monday) d = d.add(Duration(days: 1));
    while (d.isBefore(right)) {
      epochs.add(d.millisecondsSinceEpoch);
      d = d.add(Duration(days: DateTime.daysPerWeek));
    }
    return epochs;
  }
  if (timeGridInterval == Duration(days: 1)) {
    final left = DateTime.fromMillisecondsSinceEpoch(leftBoundEpoch);
    final right = DateTime.fromMillisecondsSinceEpoch(rightBoundEpoch);
    var d = DateTime(left.year, left.month, left.day);
    if (d.isBefore(left)) d = d.add(Duration(days: 1));
    while (d.isBefore(right)) {
      epochs.add(d.millisecondsSinceEpoch);
      d = d.add(Duration(days: 1));
    }
    return epochs;
  }
  final diff = timeGridInterval.inMilliseconds;
  final remainder = leftBoundEpoch % diff;
  final leftToInterval = remainder > 0 ? diff - remainder : 0;
  final firstLeft = leftBoundEpoch + leftToInterval;
  for (int epoch = firstLeft; epoch <= rightBoundEpoch; epoch += diff) {
    epochs.add(epoch);
  }
  // print('left ${DateTime.fromMillisecondsSinceEpoch(leftBoundEpoch)}');
  // print('right ${DateTime.fromMillisecondsSinceEpoch(rightBoundEpoch)}');
  // for (var e in epochs) print(DateTime.fromMillisecondsSinceEpoch(e));
  return epochs;
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
    Duration(days: 1),
    Duration(days: 2),
    Duration(days: 3),
    Duration(days: DateTime.daysPerWeek),
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
