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
