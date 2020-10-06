import 'package:deriv_chart/src/logic/annotations/chart_annotation.dart';
import 'package:deriv_chart/src/models/chart_object.dart';
import 'package:deriv_chart/src/theme/painting_styles/barrier_style.dart';

/// Barrier object
abstract class BarrierObject extends ChartObject {
  /// Initializes
  BarrierObject(
    int leftEpoch,
    int rightEpoch,
    double bottomValue,
    double topValue,
  ) : super(leftEpoch, rightEpoch, bottomValue, topValue);
}

/// Base class of barrier
abstract class Barrier extends ChartAnnotation<BarrierObject> {
  /// Initializes
  Barrier({
    String id,
    this.title,
    BarrierStyle style,
  }) : super(id ?? title, style: style ?? const BarrierStyle());

  /// Title of the barrier
  final String title;
}
