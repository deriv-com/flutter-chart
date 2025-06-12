import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_data.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/interactable_drawings/drawing_v2.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/interactive_layer_states/interactive_state.dart';
import 'package:deriv_chart/src/models/axis_range.dart';
import 'package:deriv_chart/src/models/chart_config.dart';
import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

import '../chart/data_visualization/chart_series/data_series.dart';
import '../chart/data_visualization/drawing_tools/ray/ray_line_drawing.dart';
import '../chart/data_visualization/models/animation_info.dart';
import '../chart/y_axis/y_axis_config.dart';
import 'enums/drawing_tool_state.dart';
import 'helpers/types.dart';

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
    required this.drawingState,
    required this.currentDrawingState,
    required this.epochRange,
    required this.quoteRange,
    this.animationInfo = const AnimationInfo(),
  });

  /// Drawing to paint.
  final DrawingV2 drawing;

  /// A callback to get the updated state of any drawing tool when calling it.
  ///
  /// To see where this callback is implemented check [InteractiveState]
  /// classes.
  final GetDrawingState drawingState;

  /// The current state of drawing the [drawing] when we added its painter in
  /// the widget tree, this is used to do the comparison between between old
  /// state and new state of repainting logic of the
  /// [InteractableDrawingCustomPainter].
  final Set<DrawingToolState> currentDrawingState;

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

  /// Current epoch range (x-axis) of the chart;
  final EpochRange epochRange;

  /// Current quote range (y-axis) of the chart;
  final QuoteRange quoteRange;

  @override
  void paint(Canvas canvas, Size size) {
    YAxisConfig.instance.yAxisClipping(canvas, size, () {
      drawing.paint(
        canvas,
        size,
        epochToX,
        quoteToY,
        animationInfo,
        chartConfig,
        theme,
        drawingState,
      );
    });

    drawing.paintOverYAxis(
      canvas,
      size,
      epochToX,
      quoteToY,
      animationInfo,
      chartConfig,
      theme,
      drawingState,
    );
  }

  @override
  bool shouldRepaint(InteractableDrawingCustomPainter oldDelegate) {
    final drawingIsInRange = drawing.isInViewPort(epochRange, quoteRange);

    final bool isSeriesChanged = series.input.isEmpty ||
        oldDelegate.series.input.isEmpty ||
        series.input.first != oldDelegate.series.input.first;

    return isSeriesChanged ||
        (drawingIsInRange &&
            // Drawing state is changed
            (!setEquals(oldDelegate.currentDrawingState, currentDrawingState) ||
                // Epoch range is changed
                oldDelegate.epochRange != epochRange ||
                // Quote range is changed
                oldDelegate.quoteRange != quoteRange ||
                // Theme is changed
                oldDelegate.theme != theme ||
                // Drawing needs repaint
                drawing.shouldRepaint(
                    currentDrawingState, oldDelegate.drawing)));
  }

  @override
  bool shouldRebuildSemantics(InteractableDrawingCustomPainter oldDelegate) =>
      false;

  @override
  bool hitTest(Offset position) =>
      drawing.hitTest(position, epochToX, quoteToY);
}
