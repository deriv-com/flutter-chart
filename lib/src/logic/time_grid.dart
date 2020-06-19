import 'package:meta/meta.dart';

List<int> gridEpochs({
  @required int timeGridInterval,
  @required int leftBoundEpoch,
  @required int rightBoundEpoch,
}) {
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
    60,
    300,
    600,
    1800,
    3600,
  ],
}) {
  return intervalsInSeconds.firstWhere(
    (intervalInSeconds) {
      final distanceBetweenLines = intervalInSeconds * 1000 / msPerPx;
      return distanceBetweenLines >= minDistanceBetweenLines;
    },
    orElse: () => intervalsInSeconds.last,
  );
}
