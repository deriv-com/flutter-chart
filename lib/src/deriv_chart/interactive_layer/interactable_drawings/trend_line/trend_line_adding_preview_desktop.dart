import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_data.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/drawing_paint_style.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/edge_point.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/models/animation_info.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/helpers/paint_helpers.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/interactive_layer_behaviours/interactive_layer_desktop_behaviour.dart';
import 'package:deriv_chart/src/models/chart_config.dart';
import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:deriv_chart/src/theme/painting_styles/line_style.dart';
import 'package:flutter/gestures.dart';

import 'package:flutter/material.dart';
import '../../helpers/types.dart';
import '../drawing_adding_preview.dart';
import 'trend_line_interactable_drawing.dart';

/// A class to show a preview and handle adding [TrendLineInteractableDrawing]
/// to the chart. It's for when we're on [InteractiveLayerDesktopBehaviour]
class TrendLineAddingPreviewDesktop
    extends DrawingAddingPreview<TrendLineInteractableDrawing> {
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
    final LineStyle lineStyle = interactableDrawing.config.lineStyle;
    final DrawingPaintStyle paintStyle = DrawingPaintStyle();

    final EdgePoint? startPoint = interactableDrawing.startPoint;

    if (startPoint != null) {
      drawPoint(startPoint, epochToX, quoteToY, canvas, paintStyle, lineStyle);

      if (_hoverPosition != null) {
        // endPoint doesn't exist yet and it means we're creating this line.
        // Drawing preview line from startPoint to hoverPosition.
        final Offset startPosition =
            Offset(epochToX(startPoint.epoch), quoteToY(startPoint.quote));

        canvas.drawLine(startPosition, _hoverPosition!,
            paintStyle.linePaintStyle(lineStyle.color, lineStyle.thickness));

        // Draw alignment guides with labels
        _drawAlignmentGuidesWithLabels(canvas, size, _hoverPosition!, epochToX,
            quoteToY, chartConfig, chartTheme, epochFromX, quoteFromY);
      }
    } else if (_hoverPosition != null) {
      // Show alignment guides with labels when hovering before first point is set
      _drawAlignmentGuidesWithLabels(canvas, size, _hoverPosition!, epochToX,
          quoteToY, chartConfig, chartTheme, epochFromX, quoteFromY);
    }

    if (interactableDrawing.endPoint != null) {
      drawPoint(interactableDrawing.endPoint!, epochToX, quoteToY, canvas,
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
    if (interactableDrawing.startPoint == null) {
      interactableDrawing.startPoint = EdgePoint(
        epoch: epochFromX(details.localPosition.dx),
        quote: quoteFromY(details.localPosition.dy),
      );
    } else {
      interactableDrawing.endPoint ??= EdgePoint(
        epoch: epochFromX(details.localPosition.dx),
        quote: quoteFromY(details.localPosition.dy),
      );
      onDone();
    }
  }

  /// Draws alignment guides with value and epoch labels
  void _drawAlignmentGuidesWithLabels(
    Canvas canvas,
    Size size,
    Offset pointOffset,
    EpochToX epochToX,
    QuoteToY quoteToY,
    ChartConfig chartConfig,
    ChartTheme chartTheme,
    EpochFromX? epochFromX,
    QuoteFromY? quoteFromY,
  ) {
    // Draw the basic alignment guides
    drawPointAlignmentGuides(canvas, size, pointOffset,
        lineColor: interactableDrawing.config.lineStyle.color);

    if (epochFromX != null && quoteFromY != null) {
      final int epoch = epochFromX(pointOffset.dx);
      final double quote = quoteFromY(pointOffset.dy);

      // Draw value label on the right side
      drawValueLabel(
        canvas: canvas,
        quoteToY: quoteToY,
        value: quote,
        pipSize: chartConfig.pipSize,
        size: size,
        textStyle: TextStyle(
          color: interactableDrawing.config.lineStyle.color,
          fontSize: 12,
          fontWeight: FontWeight.normal,
        ),
        color: interactableDrawing.config.lineStyle.color,
        backgroundColor: chartTheme.backgroundColor,
      );

      // Draw epoch label at the bottom
      drawEpochLabel(
        canvas: canvas,
        epochToX: epochToX,
        epoch: epoch,
        size: size,
        textStyle: TextStyle(
          color: interactableDrawing.config.lineStyle.color,
          fontSize: 12,
          fontWeight: FontWeight.normal,
        ),
        color: interactableDrawing.config.lineStyle.color,
        backgroundColor: chartTheme.backgroundColor,
      );
    }
  }

  @override
  String get id => 'line-adding-preview-desktop';

  @override
  bool hitTest(Offset offset, EpochToX epochToX, QuoteToY quoteToY) => false;
}
