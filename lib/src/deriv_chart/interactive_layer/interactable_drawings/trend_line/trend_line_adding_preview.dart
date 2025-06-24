import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_data.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/drawing_paint_style.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/edge_point.dart';
import 'package:deriv_chart/src/models/chart_config.dart';
import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:deriv_chart/src/theme/painting_styles/line_style.dart';
import 'package:flutter/material.dart';

import '../../helpers/paint_helpers.dart';
import '../drawing_adding_preview.dart';
import 'trend_line_interactable_drawing.dart';

/// Base class for trend line adding preview implementations.
///
/// This class contains shared functionality between desktop and mobile
/// implementations to eliminate code duplication.
abstract class TrendLineAddingPreview
    extends DrawingAddingPreview<TrendLineInteractableDrawing> {
  /// Initializes the base trend line adding preview.
  TrendLineAddingPreview({
    required super.interactiveLayerBehaviour,
    required super.interactableDrawing,
  });

  /// Constants for consistent styling

  /// Default radius for drawing points
  static const double pointRadius = 4;

  /// Outer radius for focused circle effect
  static const double focusedPointOuterRadius = 8;

  /// Inner radius for focused circle effect
  static const double focusedPointInnerRadius = 4;

  /// Shared method to draw a point with consistent styling
  void drawStyledPoint(
    EdgePoint point,
    EpochToX epochToX,
    QuoteToY quoteToY,
    Canvas canvas,
    DrawingPaintStyle paintStyle,
    LineStyle lineStyle, {
    double radius = pointRadius,
  }) {
    drawPoint(point, epochToX, quoteToY, canvas, paintStyle, lineStyle,
        radius: radius);
  }

  /// Shared method to draw a point at a specific offset
  void drawStyledPointOffset(
    Offset offset,
    EpochToX epochToX,
    QuoteToY quoteToY,
    Canvas canvas,
    DrawingPaintStyle paintStyle,
    LineStyle lineStyle, {
    double radius = pointRadius,
  }) {
    drawPointOffset(offset, epochToX, quoteToY, canvas, paintStyle, lineStyle,
        radius: radius);
  }

  /// Shared method to draw focused circle effect
  void drawStyledFocusedCircle(
    DrawingPaintStyle paintStyle,
    LineStyle lineStyle,
    Canvas canvas,
    Offset offset,
    double animationPercent,
  ) {
    drawFocusedCircle(
      paintStyle,
      lineStyle,
      canvas,
      offset,
      focusedPointOuterRadius * animationPercent,
      focusedPointInnerRadius * animationPercent,
    );
  }

  /// Shared method to draw alignment guides with labels
  void drawAlignmentGuidesWithLabels(
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
    drawPointAlignmentGuides(
      canvas,
      size,
      pointOffset,
      lineColor: interactableDrawing.config.lineStyle.color,
    );

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
        textStyle: interactableDrawing.config.labelStyle,
        color: interactableDrawing.config.lineStyle.color,
        backgroundColor: chartTheme.backgroundColor,
      );

      // Draw epoch label at the bottom
      drawEpochLabel(
        canvas: canvas,
        epochToX: epochToX,
        epoch: epoch,
        size: size,
        textStyle: interactableDrawing.config.labelStyle,
        color: interactableDrawing.config.lineStyle.color,
        backgroundColor: chartTheme.backgroundColor,
      );
    }
  }

  /// Shared method to draw a preview line
  void drawPreviewLine(
    Canvas canvas,
    Offset startPosition,
    Offset endPosition,
    DrawingPaintStyle paintStyle,
    LineStyle lineStyle, {
    bool isDashed = false,
  }) {
    final Paint paint =
        paintStyle.linePaintStyle(lineStyle.color, lineStyle.thickness);

    if (isDashed) {
      final Path linePath = Path()
        ..moveTo(startPosition.dx, startPosition.dy)
        ..lineTo(endPosition.dx, endPosition.dy);

      canvas.drawPath(
        dashPath(linePath, dashArray: CircularIntervalList([4, 4])),
        Paint()
          ..color = paint.color
          ..style = PaintingStyle.stroke
          ..strokeWidth = paint.strokeWidth,
      );
    } else {
      canvas.drawLine(startPosition, endPosition, paint);
    }
  }

  /// Shared method to get paint style and line style
  (DrawingPaintStyle, LineStyle) getStyles() {
    return (DrawingPaintStyle(), interactableDrawing.config.lineStyle);
  }

  /// Shared method to convert EdgePoint to Offset
  Offset edgePointToOffset(
      EdgePoint point, EpochToX epochToX, QuoteToY quoteToY) {
    return Offset(epochToX(point.epoch), quoteToY(point.quote));
  }

  /// Shared method to convert Offset to EdgePoint
  EdgePoint offsetToEdgePoint(
      Offset offset, EpochFromX epochFromX, QuoteFromY quoteFromY) {
    return EdgePoint(
      epoch: epochFromX(offset.dx),
      quote: quoteFromY(offset.dy),
    );
  }

  /// Shared validation method
  bool isValidPoint(EdgePoint? point) {
    return point != null;
  }

  /// Shared method to handle point creation
  void createPoint(
    Offset position,
    EpochFromX epochFromX,
    QuoteFromY quoteFromY,
    VoidCallback onDone,
  ) {
    if (interactableDrawing.startPoint == null) {
      interactableDrawing.startPoint =
          offsetToEdgePoint(position, epochFromX, quoteFromY);
    } else {
      interactableDrawing.endPoint ??=
          offsetToEdgePoint(position, epochFromX, quoteFromY);
      onDone();
    }
  }
}
