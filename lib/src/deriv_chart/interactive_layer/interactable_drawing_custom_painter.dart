import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_data.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/interactable_drawings/interactable_drawing.dart';
import 'package:deriv_chart/src/models/chart_config.dart';
import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:flutter/rendering.dart';

import '../chart/data_visualization/chart_series/data_series.dart';
import '../chart/data_visualization/drawing_tools/ray/ray_line_drawing.dart';
import '../chart/data_visualization/models/animation_info.dart';
import '../chart/y_axis/y_axis_config.dart';

/// A callback which calling it should return if the [drawing] is selected.
typedef GetDrawingState = Set<DrawingToolState> Function(
  InteractableDrawing drawing,
);

/// Interactable drawing custom painter.
class InteractableDrawingCustomPainter extends CustomPainter {
  /// Initializes the interactable drawing custom painter.
  InteractableDrawingCustomPainter({
    required this.drawing,
    required this.series,
    required this.theme,
    required this.chartConfig,
    required this.epochFromX,
    required this.epochToX,
    required this.quoteToY,
    required this.quoteFromY,
    required this.getDrawingState,
    this.animationInfo = const AnimationInfo(),
  });

  /// Drawing to paint.
  final InteractableDrawing drawing;

  /// The main series of the chart.
  final DataSeries<Tick> series;

  /// Chart theme.
  final ChartTheme theme;

  /// Chart's general config.
  final ChartConfig chartConfig;

  /// Converts x coordinate (in pixels) to epoch timestamp.
  final EpochFromX epochFromX;

  /// Converts epoch timestamp to x coordinate (in pixels).
  final EpochToX epochToX;

  /// Converts y coordinate (in pixels) to quote value.
  final QuoteToY quoteToY;

  /// Converts quote value to y coordinate (in pixels).
  final QuoteFromY quoteFromY;

  /// Showing animations progress.
  final AnimationInfo animationInfo;

  /// Returns `true` if the drawing tool is selected.
  final Set<DrawingToolState> Function(InteractableDrawing) getDrawingState;

  @override
  void paint(Canvas canvas, Size size) {
    YAxisConfig.instance.yAxisClipping(canvas, size, () {
      drawing.paint(
        canvas,
        size,
        epochToX,
        quoteToY,
        animationInfo,
        getDrawingState,
      );
    });
  }

  @override
  bool shouldRepaint(InteractableDrawingCustomPainter oldDelegate) =>
      // TODO(NA): Return true/false based on the [drawing] state
      true;

  @override
  bool shouldRebuildSemantics(InteractableDrawingCustomPainter oldDelegate) =>
      false;

  @override
  bool hitTest(Offset position) =>
      drawing.hitTest(position, epochToX, quoteToY);
}
