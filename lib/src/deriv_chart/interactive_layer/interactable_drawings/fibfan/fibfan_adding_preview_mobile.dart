import 'dart:ui';

import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_data.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/drawing_paint_style.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/edge_point.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/models/animation_info.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/helpers/paint_helpers.dart';
import 'package:deriv_chart/src/models/chart_config.dart';
import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:flutter/gestures.dart';

import '../../helpers/types.dart';
import '../fibfan/helpers.dart';
import '../drawing_adding_preview.dart';
import 'fibfan_interactable_drawing.dart';

/// Mobile-optimized preview handler for Fibonacci Fan creation.
///
/// This class provides a touch-friendly interface for creating Fibonacci Fan
/// drawings on mobile devices. Unlike desktop behavior that relies on mouse
/// hover and click interactions, mobile behavior pre-positions both points
/// and allows immediate drag-based editing.
///
/// **Mobile-Specific Features:**
/// - Auto-positioning of start and end points for immediate usability
/// - Touch-optimized drag interactions for point adjustment
/// - Dashed line previews to distinguish from final drawings
/// - Single-tap completion (no multi-step creation process)
/// - Larger touch targets for better mobile interaction
///
/// **Positioning Strategy:**
/// The mobile implementation automatically places the fan points in optimal
/// positions based on screen dimensions:
/// - Start point: 6% from left edge, vertically centered (50%)
/// - End point: 65% from left edge, upper portion (30%)
/// - This creates an upward-trending fan suitable for most analysis scenarios
///
/// **User Workflow:**
/// 1. User selects Fibonacci Fan tool
/// 2. Preview appears with pre-positioned points
/// 3. User can drag individual points or entire fan to adjust
/// 4. Single tap completes the drawing
class FibfanAddingPreviewMobile
    extends DrawingAddingPreview<FibfanInteractableDrawing> {
  /// Initializes [FibfanAddingPreviewMobile] with auto-positioned points.
  ///
  /// Creates a mobile-optimized preview that automatically positions the
  /// start and end points in sensible locations based on screen dimensions.
  /// This eliminates the need for multi-step point placement on touch devices.
  ///
  /// **Auto-Positioning Logic:**
  /// - Calculates optimal positions using screen dimension ratios
  /// - Places start point in left-center area for trend origin
  /// - Places end point in upper-right area for upward trend
  /// - Provides fallback coordinates if screen dimensions unavailable
  ///
  /// **Parameters:**
  /// - [interactiveLayerBehaviour]: Mobile interaction behavior handler
  /// - [interactableDrawing]: The Fibonacci Fan drawing being created
  FibfanAddingPreviewMobile({
    required super.interactiveLayerBehaviour,
    required super.interactableDrawing,
  }) {
    if (interactableDrawing.startPoint == null) {
      final interactiveLayer = interactiveLayerBehaviour.interactiveLayer;
      final Size? layerSize = interactiveLayer.drawingContext.fullSize;

      if (layerSize != null) {
        // Position start point around the chart data area (middle-right region)
        final double startX =
            layerSize.width * FibfanConstants.mobileStartXRatio;
        final double startY =
            layerSize.height * FibfanConstants.mobileStartYRatio;

        interactableDrawing.startPoint = EdgePoint(
          epoch: interactiveLayer.epochFromX(startX),
          quote: interactiveLayer.quoteFromY(startY),
        );
      } else {
        // Fallback to center if size is not available
        interactableDrawing.startPoint = EdgePoint(
          epoch: interactiveLayer.epochFromX(0),
          quote: interactiveLayer.quoteFromY(0),
        );
      }
    }

    if (interactableDrawing.endPoint == null) {
      final interactiveLayer = interactiveLayerBehaviour.interactiveLayer;
      final Size? layerSize = interactiveLayer.drawingContext.fullSize;

      if (layerSize != null) {
        // Position end point to the right and above start point
        // This creates a proper upward-oriented Fibonacci fan
        final double endX = layerSize.width * FibfanConstants.mobileEndXRatio;
        final double endY = layerSize.height *
            FibfanConstants.mobileEndYRatio; // Above start point (0.5)

        interactableDrawing.endPoint = EdgePoint(
          epoch: interactiveLayer.epochFromX(endX),
          quote: interactiveLayer.quoteFromY(endY),
        );
      } else {
        // Fallback with proper orientation if size is not available
        const double fallbackX = FibfanConstants.mobileFallbackX;
        const double fallbackY =
            FibfanConstants.mobileFallbackY; // Above start point

        interactableDrawing.endPoint = EdgePoint(
          epoch: interactiveLayer.epochFromX(fallbackX),
          quote: interactiveLayer.quoteFromY(fallbackY),
        );
      }
    }
  }

  /// Track if the drawing is currently being dragged
  bool _isDragging = false;

  @override
  bool hitTest(Offset offset, EpochToX epochToX, QuoteToY quoteToY) {
    return interactableDrawing.hitTest(offset, epochToX, quoteToY);
  }

  @override
  String get id => 'Fibfan-adding-preview-mobile';

  @override
  void onDragStart(DragStartDetails details, EpochFromX epochFromX,
      QuoteFromY quoteFromY, EpochToX epochToX, QuoteToY quoteToY) {
    _isDragging = true;
    interactableDrawing.onDragStart(
        details, epochFromX, quoteFromY, epochToX, quoteToY);
  }

  @override
  void onDragUpdate(DragUpdateDetails details, EpochFromX epochFromX,
      QuoteFromY quoteFromY, EpochToX epochToX, QuoteToY quoteToY) {
    interactableDrawing.onDragUpdate(
      details,
      epochFromX,
      quoteFromY,
      epochToX,
      quoteToY,
    );
  }

  /// Handle drag end to reset drag state
  @override
  void onDragEnd(DragEndDetails details, EpochFromX epochFromX,
      QuoteFromY quoteFromY, EpochToX epochToX, QuoteToY quoteToY) {
    _isDragging = false;
    // Call parent implementation if it exists
    super.onDragEnd(details, epochFromX, quoteFromY, epochToX, quoteToY);
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
    GetDrawingState drawingState,
  ) {
    if (interactableDrawing.startPoint != null &&
        interactableDrawing.endPoint != null) {
      final Offset startOffset = Offset(
        epochToX(interactableDrawing.startPoint!.epoch),
        quoteToY(interactableDrawing.startPoint!.quote),
      );
      final Offset endOffset = Offset(
        epochToX(interactableDrawing.endPoint!.epoch),
        quoteToY(interactableDrawing.endPoint!.quote),
      );

      // Validate coordinates before proceeding
      if (!FibonacciFanHelpers.areTwoOffsetsValid(startOffset, endOffset)) {
        return;
      }

      // Calculate the base vector
      final double deltaX = endOffset.dx - startOffset.dx;
      final double deltaY = endOffset.dy - startOffset.dy;

      // Only draw if we have meaningful deltas
      if (FibonacciFanHelpers.areDeltasMeaningful(deltaX, deltaY)) {
        // Draw preview fan lines with dashed style
        _drawPreviewFanLines(canvas, startOffset, deltaX, deltaY, size);
      }

      // Draw edge points for the preview
      final DrawingPaintStyle paintStyle = DrawingPaintStyle();
      drawPointOffset(
        startOffset,
        epochToX,
        quoteToY,
        canvas,
        paintStyle,
        interactableDrawing.config.lineStyle,
        radius: FibfanConstants.pointRadius,
      );
      drawPointOffset(
        endOffset,
        epochToX,
        quoteToY,
        canvas,
        paintStyle,
        interactableDrawing.config.lineStyle,
        radius: FibfanConstants.pointRadius,
      );

      // Draw alignment guides on each edge point when dragging
      if (_isDragging) {
        drawPointAlignmentGuides(
          canvas,
          size,
          startOffset,
          lineColor: interactableDrawing.config.lineStyle.color,
        );
        drawPointAlignmentGuides(
          canvas,
          size,
          endOffset,
          lineColor: interactableDrawing.config.lineStyle.color,
        );
      }
    }
  }

  /// Draws preview fan lines with dashed style
  void _drawPreviewFanLines(
    Canvas canvas,
    Offset startOffset,
    double deltaX,
    double deltaY,
    Size size,
  ) {
    final Paint dashPaint = Paint()
      ..color = interactableDrawing.config.lineStyle.color
          .withOpacity(FibfanConstants.dashOpacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = interactableDrawing.config.lineStyle.thickness;

    for (final double ratio in FibonacciFanHelpers.fibRatios) {
      final Offset fanPoint = Offset(
        startOffset.dx + deltaX,
        startOffset.dy + deltaY * ratio,
      );

      // Extend line to the edge of the screen
      final double screenWidth = size.width;
      final double deltaXFan = fanPoint.dx - startOffset.dx;

      // Handle vertical lines and avoid division by zero
      Offset extendedPoint;
      if (deltaXFan.abs() < FibfanConstants.verticalLineThreshold) {
        // Vertical line
        extendedPoint = Offset(fanPoint.dx, size.height);
      } else {
        final double slope = (fanPoint.dy - startOffset.dy) / deltaXFan;
        extendedPoint = Offset(
          screenWidth,
          startOffset.dy + slope * (screenWidth - startOffset.dx),
        );
      }

      // Draw dashed line
      _drawDashedLine(canvas, startOffset, extendedPoint, dashPaint);
    }
  }

  /// Draws a dashed line between two points
  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    const double dashWidth = FibfanConstants.dashWidth;
    const double dashSpace = FibfanConstants.dashSpace;
    final double distance = (end - start).distance;

    // Handle edge cases
    if (distance <= 0 || !FibonacciFanHelpers.areTwoOffsetsValid(start, end)) {
      return;
    }

    final Offset direction = (end - start) / distance;

    double currentDistance = 0;
    bool isDash = true;

    while (currentDistance < distance) {
      final double segmentLength = isDash ? dashWidth : dashSpace;
      final double remainingDistance = distance - currentDistance;
      final double actualSegmentLength =
          segmentLength > remainingDistance ? remainingDistance : segmentLength;

      if (isDash && actualSegmentLength > 0) {
        final Offset segmentStart = start + direction * currentDistance;
        final Offset segmentEnd =
            start + direction * (currentDistance + actualSegmentLength);

        // Validate segment points before drawing
        if (FibonacciFanHelpers.areTwoOffsetsValid(segmentStart, segmentEnd)) {
          canvas.drawLine(segmentStart, segmentEnd, paint);
        }
      }

      currentDistance += actualSegmentLength.toDouble();
      isDash = !isDash;
    }
  }

  @override
  void paintOverYAxis(
    Canvas canvas,
    Size size,
    EpochToX epochToX,
    QuoteToY quoteToY,
    AnimationInfo animationInfo,
    ChartConfig chartConfig,
    ChartTheme chartTheme,
    GetDrawingState getDrawingState,
  ) {
    // Draw labels for both edge points when dragging
    if (_isDragging &&
        interactableDrawing.startPoint != null &&
        interactableDrawing.endPoint != null) {
      // Draw labels for start point
      drawValueLabel(
        canvas: canvas,
        quoteToY: quoteToY,
        value: interactableDrawing.startPoint!.quote,
        pipSize: chartConfig.pipSize,
        size: size,
        color: interactableDrawing.config.lineStyle.color,
        backgroundColor: chartTheme.backgroundColor,
        textStyle: interactableDrawing.config.labelStyle,
      );
      drawEpochLabel(
        canvas: canvas,
        epochToX: epochToX,
        epoch: interactableDrawing.startPoint!.epoch,
        size: size,
        textStyle: interactableDrawing.config.labelStyle,
        animationProgress: animationInfo.stateChangePercent,
        color: interactableDrawing.config.lineStyle.color,
        backgroundColor: chartTheme.backgroundColor,
      );

      // Draw labels for end point
      drawValueLabel(
        canvas: canvas,
        quoteToY: quoteToY,
        value: interactableDrawing.endPoint!.quote,
        pipSize: chartConfig.pipSize,
        size: size,
        color: interactableDrawing.config.lineStyle.color,
        backgroundColor: chartTheme.backgroundColor,
        textStyle: interactableDrawing.config.labelStyle,
      );
      drawEpochLabel(
        canvas: canvas,
        epochToX: epochToX,
        epoch: interactableDrawing.endPoint!.epoch,
        size: size,
        textStyle: interactableDrawing.config.labelStyle,
        animationProgress: animationInfo.stateChangePercent,
        color: interactableDrawing.config.lineStyle.color,
        backgroundColor: chartTheme.backgroundColor,
      );
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
    // For mobile, we complete the drawing on first tap since we already have both points
    onDone();
  }
}
