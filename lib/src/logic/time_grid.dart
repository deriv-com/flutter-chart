import 'package:meta/meta.dart';

import 'conversion.dart';

List<int> gridEpochs({
  @required int timeGridInterval,
  @required int leftBoundEpoch,
  @required int rightBoundEpoch,
}) {
  if (timeGridInterval == Duration(days: 1).inMilliseconds) {
    final epochs = <int>[];
    final left = DateTime.fromMillisecondsSinceEpoch(leftBoundEpoch);
    final right = DateTime.fromMillisecondsSinceEpoch(rightBoundEpoch);
    var d = DateTime(left.year, left.month, left.day + 1);
    while (d.isBefore(right)) {
      epochs.add(d.millisecondsSinceEpoch);
      d = d.add(Duration(days: 1));
    }
    return epochs;
  }
  final firstRight =
      (rightBoundEpoch - rightBoundEpoch % timeGridInterval).toInt();
  final epochs = <int>[];
  for (int epoch = firstRight;
      epoch >= leftBoundEpoch;
      epoch -= timeGridInterval) {
    epochs.add(epoch);
  }
  return epochs;
}

int timeGridIntervalInSeconds(
  double msPerPx, {
  double minDistanceBetweenLines = 100,
  List<int> intervalsInSeconds = const [
    5, // 5 sec
    10, // 10 sec
    30, // 30 sec
    60, // 1 min
    120, // 2 min
    180, // 3 min
    300, // 5 min
    600, // 10 min
    900, // 15 min
    1800, // 30 min
    3600, // 1 hour
    7200, // 2 hours
    14400, // 4 hours
    28800, // 8 hours
    86400, // 24 hours
    172800, // 2 days
    259200, // 3 days
    604800, // 1 week
    2419200, // 4 weeks
  ],
}) {
  bool hasEnoughDistanceBetweenLines(int intervalInSeconds) {
    final distanceBetweenLines = msToPx(
      intervalInSeconds * 1000,
      msPerPx: msPerPx,
    );
    return distanceBetweenLines >= minDistanceBetweenLines;
  }

  return intervalsInSeconds.firstWhere(
    hasEnoughDistanceBetweenLines,
    orElse: () => intervalsInSeconds.last,
  );
}
