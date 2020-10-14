import 'package:deriv_chart/src/logic/annotations/chart_annotation.dart';
import 'package:deriv_chart/src/models/barrier_objects.dart';
import 'package:deriv_chart/src/theme/painting_styles/barrier_style.dart';

/// Base class of barrier
abstract class Barrier extends ChartAnnotation<BarrierObject> {
  /// Initializes
  Barrier({
    String id,
    this.title,
    this.longLine,
    BarrierStyle style,
  }) : super(id ?? title, style: style);

  /// Title of the barrier
  final String title;

  /// Vertical line start from top or from the tick
  ///
  /// Will be ignored if the [value] was null.
  final bool longLine;
}
