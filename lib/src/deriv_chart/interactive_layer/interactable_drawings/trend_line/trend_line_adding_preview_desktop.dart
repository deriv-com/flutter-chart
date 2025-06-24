import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_data.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/edge_point.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/models/animation_info.dart';
import 'package:deriv_chart/src/models/chart_config.dart';
import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../helpers/types.dart';
import 'trend_line_adding_preview.dart';

/// A class to show a preview and handle adding [TrendLineInteractableDrawing]
/// to the chart. It's for when we're on [InteractiveLayerDesktopBehaviour]
class TrendLineAddingPreviewDesktop extends TrendLineAddingPreview {
  /// Initializes [TrendLineInteractableDrawing].
  TrendLineAddingPreviewDesktop({
    required super.interactiveLayerBehaviour,
    required super.interactableDrawing,
  });

  Offset? _hoverPosition;

  @override
  void onHover(PointerHoverEvent event, EpochFromX epochFromX,
      QuoteFromY quoteFromY, EpochToX epochToX, QuoteToY quoteToY) {
    _hoverPosition = event.localPosition;
  }

  @override
  void paint(
    Canvas canvas,
    Size size,
    EpochToX epochToX,
    QuoteToY quoteToY,
    AnimationInfo animationInfo,
    ChartConfig chartConfig,
    ChartTheme chartTheme,
    GetDrawingState getDrawingState,
  ) {}

  @override
  void paintOverYAxis(
      Canvas canvas,
      Size size,
      EpochToX epochToX,
      QuoteToY quoteToY,
      EpochFromX? epochFromX,
      QuoteFromY? quoteFromY,
      AnimationInfo animationInfo,
      ChartConfig chartConfig,
      ChartTheme chartTheme,
      GetDrawingState getDrawingState) {
    final (paintStyle, lineStyle) = getStyles();
    final EdgePoint? startPoint = interactableDrawing.startPoint;

    if (startPoint != null) {
      drawStyledPoint(
          startPoint, epochToX, quoteToY, canvas, paintStyle, lineStyle);

      if (_hoverPosition != null) {
        // endPoint doesn't exist yet and it means we're creating this line.
        // Drawing preview line from startPoint to hoverPosition.
        final Offset startPosition =
            edgePointToOffset(startPoint, epochToX, quoteToY);
        drawPreviewLine(
            canvas, startPosition, _hoverPosition!, paintStyle, lineStyle);

        // Draw alignment guides with labels
        drawAlignmentGuidesWithLabels(canvas, size, _hoverPosition!, epochToX,
            quoteToY, chartConfig, chartTheme, epochFromX, quoteFromY);
      }
    } else if (_hoverPosition != null) {
      // Show alignment guides with labels when hovering before first point is set
      drawAlignmentGuidesWithLabels(canvas, size, _hoverPosition!, epochToX,
          quoteToY, chartConfig, chartTheme, epochFromX, quoteFromY);
    }

    if (interactableDrawing.endPoint != null) {
      drawStyledPoint(interactableDrawing.endPoint!, epochToX, quoteToY, canvas,
          paintStyle, lineStyle);
    }
  }

  @override
  void onCreateTap(
    TapUpDetails details,
    EpochFromX epochFromX,
    QuoteFromY quoteFromY,
    EpochToX epochToX,
    QuoteToY quoteToY,
    VoidCallback onDone,
  ) {
    createPoint(details.localPosition, epochFromX, quoteFromY, onDone);
  }

  @override
  String get id => 'line-adding-preview-desktop';

  @override
  bool hitTest(Offset offset, EpochToX epochToX, QuoteToY quoteToY) => false;
}
