import 'package:deriv_chart/src/models/chart_object.dart';

abstract class Barrier extends ChartObject {
  Barrier(
    int leftEpoch,
    int rightEpoch,
    double bottomValue,
    double topValue,
  ) : super(leftEpoch, rightEpoch, bottomValue, topValue);
}

class HorizontalBarrier extends Barrier {
  final double value;

  HorizontalBarrier(this.value) : super(null, null, value, value);
}
