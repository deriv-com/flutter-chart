import 'package:deriv_chart/src/add_ons/drawing_tools_ui/drawing_tool_config.dart';
import 'package:deriv_chart/src/models/chart_config.dart';
import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:flutter/rendering.dart';

import '../chart/data_visualization/chart_series/data_series.dart';
import '../chart/data_visualization/drawing_tools/ray/ray_line_drawing.dart';
import '../chart/data_visualization/models/animation_info.dart';
import '../chart/y_axis/y_axis_config.dart';

/// A callback which calling it should return if the [drawing] is selected.
typedef IsDrawingSelected = bool Function(InteractableDrawing drawing);

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
    required this.isSelected,
  });

  final InteractableDrawing drawing;
  final DataSeries<Tick> series;
  final ChartTheme theme;
  final ChartConfig chartConfig;
  final int Function(double x) epochFromX;
  final double Function(int x) epochToX;
  final double Function(double y) quoteToY;

  double Function(double) quoteFromY;

  // final Function() onDrawingToolClicked;

  /// Returns `true` if the drawing tool is selected.
  final bool Function(InteractableDrawing) isSelected;

  @override
  void paint(Canvas canvas, Size size) {
    YAxisConfig.instance.yAxisClipping(canvas, size, () {
      drawing.paint(
        canvas,
        size,
        epochToX,
        quoteToY,
        const AnimationInfo(),
        isSelected,
      );
      // TODO(NA): Paint the [drawing]
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
  bool hitTest(Offset position) {
    if (drawing.hitTest(position, epochToX, quoteToY)) {
      // onDrawingToolClicked();
      return true;
    }
    return false;
  }
}
