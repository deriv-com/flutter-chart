import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/models/barrier_objects.dart';
import 'package:deriv_chart/src/theme/painting_styles/barrier_style.dart';

import '../chart_annotation.dart';

/// Base class of barrier
abstract class Barrier extends ChartAnnotation<BarrierObject> {
  /// Initializes a base class of barrier.
  Barrier({
    this.epoch,
    this.quote,
    String? id,
    this.title,
    this.longLine = true,
    BarrierStyle? style,
  }) : super(id ?? '$title$style$longLine', style: style);

  /// Title of the barrier.
  final String? title;

  /// Barrier line start from screen edge or from the tick.
  ///
  /// Will be ignored if the barrier has only an epoch or a value, and not both.
  final bool longLine;

  /// Epoch of the vertical barrier.
  final int? epoch;

  /// The value that this barrier points to.
  final double? quote;

  @override
  int? getMaxEpoch() => epoch;

  @override
  int? getMinEpoch() => epoch;
}
