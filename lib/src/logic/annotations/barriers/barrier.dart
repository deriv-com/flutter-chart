import 'package:deriv_chart/src/logic/annotations/chart_annotation.dart';
import 'package:deriv_chart/src/models/chart_object.dart';
import 'package:deriv_chart/src/theme/painting_styles/barrier_style.dart';

abstract class BarrierObject extends ChartObject {
  BarrierObject(
    int leftEpoch,
    int rightEpoch,
    double bottomValue,
    double topValue,
  ) : super(leftEpoch, rightEpoch, bottomValue, topValue);
}

abstract class Barrier extends ChartAnnotation<BarrierObject> {
  Barrier({
    String id,
    this.title,
    BarrierStyle style,
  }) : super(id, style: style ?? const BarrierStyle());

  /// Title of the barrier
  final String title;
}
