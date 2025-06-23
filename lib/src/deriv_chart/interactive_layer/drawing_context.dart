import 'dart:ui';

import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/interactive_layer_base.dart';

/// The Interactive layer context for any [DrawingV2] that is being shown on the
/// layer.
class DrawingContext {
  /// Initializes the [DrawingContext].
  DrawingContext({required this.fullSize, required this.contentSize});

  /// The full size of the chart layer that [InteractiveLayerBase] can show
  /// drawings on it.
  final Size fullSize;

  /// The size of the content area of the chart layer excluding the Y-axis.
  final Size contentSize;
}
