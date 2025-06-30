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
/// This abstract class provides shared functionality between desktop and mobile
/// implementations to eliminate code duplication and ensure consistent behavior.
/// It follows the Template Method pattern where platform-specific implementations
/// override abstract methods while sharing common drawing and interaction logic.
///
/// ## Responsibilities:
/// - Consistent point drawing and styling across platforms
/// - Shared coordinate transformations between screen and chart coordinates
/// - Common validation logic for points and line segments
/// - Unified alignment guide rendering with labels
/// - Standardized preview line drawing with optional dashing
///
/// ## Usage:
/// This class should not be instantiated directly. Instead, use platform-specific
/// implementations:
/// - [TrendLineAddingPreviewDesktop] for desktop interactions
/// - [TrendLineAddingPreviewMobile] for mobile/touch interactions
///
/// ## Architecture:
/// The class maintains shared constants for consistent styling and provides
/// utility methods that both desktop and mobile implementations can use.
/// Platform-specific behavior is implemented in the concrete classes through
/// method overrides.
///
/// ## Example:
/// ```dart
/// // Desktop implementation
/// final desktopPreview = TrendLineAddingPreviewDesktop(
///   interactiveLayerBehaviour: desktopBehaviour,
///   interactableDrawing: trendLine,
/// );
///
/// // Mobile implementation
/// final mobilePreview = TrendLineAddingPreviewMobile(
///   interactiveLayerBehaviour: mobileBehaviour,
///   interactableDrawing: trendLine,
/// );
/// ```
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

  /// Draws a trend line point with consistent styling across platforms.
  ///
  /// This method provides a standardized way to draw trend line endpoints
  /// using the shared [pointRadius] constant. It converts the [EdgePoint]
  /// to screen coordinates and renders a styled circle.
  ///
  /// Parameters:
  /// - [point]: The chart coordinate point to draw
  /// - [epochToX]: Function to convert epoch to screen X coordinate
  /// - [quoteToY]: Function to convert quote to screen Y coordinate
  /// - [canvas]: The canvas to draw on
  /// - [paintStyle]: Drawing paint configuration
  /// - [lineStyle]: Line styling configuration
  /// - [radius]: Optional custom radius (defaults to [pointRadius])
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

  /// Draws a trend line point at a specific screen offset with consistent styling.
  ///
  /// This method is useful when you already have screen coordinates and want
  /// to draw a point without coordinate conversion. It maintains consistent
  /// styling with other trend line points.
  ///
  /// Parameters:
  /// - [offset]: The screen coordinate position to draw the point
  /// - [epochToX]: Function to convert epoch to screen X coordinate (for consistency)
  /// - [quoteToY]: Function to convert quote to screen Y coordinate (for consistency)
  /// - [canvas]: The canvas to draw on
  /// - [paintStyle]: Drawing paint configuration
  /// - [lineStyle]: Line styling configuration
  /// - [radius]: Optional custom radius (defaults to [pointRadius])
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

  /// Draws a focused circle effect around a point during interactions.
  ///
  /// This method creates a glowing circle effect that appears when a point
  /// is being dragged or is in focus. The effect scales with the animation
  /// percentage to provide smooth visual feedback.
  ///
  /// The focused circle consists of:
  /// - An outer circle with radius [focusedPointOuterRadius] * [animationPercent]
  /// - An inner circle with radius [focusedPointInnerRadius] * [animationPercent]
  ///
  /// Parameters:
  /// - [paintStyle]: Drawing paint configuration
  /// - [lineStyle]: Line styling configuration for colors
  /// - [canvas]: The canvas to draw on
  /// - [offset]: Screen position where to draw the focused effect
  /// - [animationPercent]: Animation progress (0.0 to 1.0) for scaling effect
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

  /// Draws alignment guides with coordinate labels for enhanced user feedback.
  ///
  /// This method provides visual assistance during trend line creation by drawing:
  /// - Horizontal and vertical alignment guides through the point
  /// - Value label on the right Y-axis showing the quote price
  /// - Epoch label on the bottom X-axis showing the time coordinate
  ///
  /// The guides help users precisely position trend line points by showing
  /// exact coordinate values and visual alignment references.
  ///
  /// Parameters:
  /// - [canvas]: The canvas to draw on
  /// - [size]: Size of the drawing area
  /// - [pointOffset]: Screen position where guides should intersect
  /// - [epochToX]: Function to convert epoch to screen X coordinate
  /// - [quoteToY]: Function to convert quote to screen Y coordinate
  /// - [chartConfig]: Chart configuration for formatting (pip size, etc.)
  /// - [chartTheme]: Theme configuration for colors and styling
  /// - [epochFromX]: Optional function to convert screen X to epoch (for labels)
  /// - [quoteFromY]: Optional function to convert screen Y to quote (for labels)
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

  /// Draws a preview line between two points with optional dashed styling.
  ///
  /// This method renders the trend line preview during creation, allowing users
  /// to see how the line will appear before finalizing it. The line can be
  /// drawn as either solid or dashed based on the platform requirements.
  ///
  /// Features:
  /// - Solid line drawing for desktop hover previews
  /// - Dashed line drawing for mobile touch previews
  /// - Consistent styling with the configured line properties
  /// - Efficient path-based rendering for dashed lines
  ///
  /// Parameters:
  /// - [canvas]: The canvas to draw on
  /// - [startPosition]: Screen coordinate of the line start
  /// - [endPosition]: Screen coordinate of the line end
  /// - [paintStyle]: Drawing paint configuration
  /// - [lineStyle]: Line styling (color, thickness)
  /// - [isDashed]: Whether to draw a dashed line (default: false)
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

  /// Retrieves the current drawing paint style and line style configuration.
  ///
  /// This utility method provides a convenient way to get both the paint style
  /// and line style needed for drawing operations. It returns a record tuple
  /// for easy destructuring in calling code.
  ///
  /// Returns:
  /// A record containing:
  /// - [DrawingPaintStyle]: Default paint style for drawing operations
  /// - [LineStyle]: The configured line style from the interactable drawing
  ///
  /// Example usage:
  /// ```dart
  /// final (paintStyle, lineStyle) = getStyles();
  /// ```
  (DrawingPaintStyle, LineStyle) getStyles() {
    return (DrawingPaintStyle(), interactableDrawing.config.lineStyle);
  }

  /// Converts a chart coordinate point to screen coordinates.
  ///
  /// This utility method transforms an [EdgePoint] containing epoch and quote
  /// values into screen pixel coordinates using the provided transformation
  /// functions. This is essential for rendering chart elements at the correct
  /// screen positions.
  ///
  /// Parameters:
  /// - [point]: The chart coordinate point to convert
  /// - [epochToX]: Function to convert epoch to screen X coordinate
  /// - [quoteToY]: Function to convert quote to screen Y coordinate
  ///
  /// Returns:
  /// An [Offset] representing the screen coordinates
  Offset edgePointToOffset(
      EdgePoint point, EpochToX epochToX, QuoteToY quoteToY) {
    return Offset(epochToX(point.epoch), quoteToY(point.quote));
  }

  /// Converts screen coordinates to a chart coordinate point.
  ///
  /// This utility method transforms screen pixel coordinates into an [EdgePoint]
  /// containing epoch and quote values using the provided inverse transformation
  /// functions. This is essential for handling user interactions and converting
  /// screen touches/clicks to chart coordinates.
  ///
  /// Parameters:
  /// - [offset]: The screen coordinate position to convert
  /// - [epochFromX]: Function to convert screen X coordinate to epoch
  /// - [quoteFromY]: Function to convert screen Y coordinate to quote
  ///
  /// Returns:
  /// An [EdgePoint] representing the chart coordinates
  EdgePoint offsetToEdgePoint(
      Offset offset, EpochFromX epochFromX, QuoteFromY quoteFromY) {
    return EdgePoint(
      epoch: epochFromX(offset.dx),
      quote: quoteFromY(offset.dy),
    );
  }

  /// Validates whether a point is valid and can be used for drawing.
  ///
  /// This simple validation method checks if an [EdgePoint] is not null.
  /// It can be extended in the future to include additional validation
  /// logic such as coordinate range checks or data validity.
  ///
  /// Parameters:
  /// - [point]: The point to validate
  ///
  /// Returns:
  /// `true` if the point is valid (not null), `false` otherwise
  bool isValidPoint(EdgePoint? point) {
    return point != null;
  }

  /// Handles the creation of trend line points during the drawing process.
  ///
  /// This method manages the two-step process of creating a trend line:
  /// 1. First click/tap creates the start point
  /// 2. Second click/tap creates the end point and completes the line
  ///
  /// The method automatically determines which point to create based on the
  /// current state of the trend line and calls the completion callback when
  /// both points are set.
  ///
  /// Parameters:
  /// - [position]: Screen position where the user clicked/tapped
  /// - [epochFromX]: Function to convert screen X coordinate to epoch
  /// - [quoteFromY]: Function to convert screen Y coordinate to quote
  /// - [onDone]: Callback to execute when the trend line is complete
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
