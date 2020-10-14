import 'package:deriv_chart/src/logic/annotations/chart_annotation.dart';
import 'package:deriv_chart/src/models/barrier_objects.dart';
import 'package:deriv_chart/src/theme/painting_styles/barrier_style.dart';

/// Base class of barrier
abstract class Barrier extends ChartAnnotation<BarrierObject> {
  /// Initializes
  Barrier({
    this.epoch,
    this.value,
    String id,
    this.title,
    this.longLine,
    BarrierStyle style,
  }) : super(id ?? title, style: style);

  /// Title of the barrier
  final String title;

  /// Barrier line start from screen edge or from the tick
  ///
  /// Will be ignored if the barrier has only an epoch or a value, and not both.
  final bool longLine;


  /// Epoch of the vertical barrier
  final int epoch;

  /// The value that this barrier points to
  final double value;

}
