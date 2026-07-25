import 'dart:ui';

import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_data.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/drawing_paint_style.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/edge_point.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/models/animation_info.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/helpers/paint_helpers.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/interactable_drawings/fibfan/helpers.dart';
import 'package:deriv_chart/src/models/chart_config.dart';
import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:deriv_chart/src/theme/painting_styles/line_style.dart';
import 'package:flutter/gestures.dart';

import '../../helpers/types.dart';
import '../../interactive_layer_states/interactive_adding_tool_state.dart';
import '../drawing_adding_preview.dart';
import 'fibfan_interactable_drawing.dart';

/// Desktop-optimized preview handler for Fibonacci Fan creation.
///
/// This class provides a mouse-friendly interface for creating Fibonacci Fan
/// drawings on desktop devices. It implements a two-step creation process
/// that leverages mouse hover and click interactions for precise point placement.
///
/// **Desktop-Specific Features:**
/// - Two-step creation process (first click for start, second for end)
/// - Real-time hover preview showing fan from start point to cursor
/// - Precise mouse-based point placement
/// - Alignment guides during point placement
/// - Axis labels showing exact coordinate values
///
/// **Creation Workflow:**
/// 1. User selects Fibonacci Fan tool
/// 2. First click sets the start point
/// 3. Mouse movement shows live preview fan from start to cursor
/// 4. Second click sets the end point and completes the drawing
///
/// **Visual Feedback:**
/// - Alignment guides appear at hover position and start point
/// - Live preview fan lines follow mouse movement
/// - Coordinate labels on both axes during creation
/// - Smooth transitions between creation states
///
/// **Precision Features:**
/// - Pixel-perfect point placement with mouse precision
/// - Real-time coordinate validation and feedback
/// - Visual guides for accurate technical analysis placement
class FibfanAddingPreviewDesktop
    extends DrawingAddingPreview<FibfanInteractableDrawing> {
  /// Initializes [FibfanAddingPreviewDesktop].
  ///
  /// Creates a desktop-optimized preview handler that manages the two-step
  /// creation process for Fibonacci Fan drawings. The handler tracks mouse
  /// position and manages the creation state transitions.
  ///
  /// **Parameters:**
  /// - [interactiveLayerBehaviour]: Desktop interaction behavior handler
  /// - [interactableDrawing]: The Fibonacci Fan drawing being created
  /// - [onAddingStateChange]: Callback for adding state changes
  FibfanAddingPreviewDesktop({
    required super.interactiveLayerBehaviour,
    required super.interactableDrawing,
    required super.onAddingStateChange,
  });

  /// Current mouse hover position for real-time preview.
  ///
  /// Tracks the mouse cursor position to enable live preview functionality.
  /// When the start point is set but end point is null, a preview fan is
  /// drawn from the start point to this hover position, giving users
  /// immediate visual feedback of the final result.
  ///
  /// **Usage:**
  /// - Updated continuously during mouse movement via [onHover]
  /// - Used in [paint] method to render preview fan lines
  /// - Enables real-time coordinate display on chart axes
  /// - Reset when creation process completes
  Offset? _hoverPosition;

  @override
  bool hitTest(Offset offset, EpochToX epochToX, QuoteToY quoteToY) => false;

  @override
  void onHover(PointerHoverEvent event, EpochFromX epochFromX,
      QuoteFromY quoteFromY, EpochToX epochToX, QuoteToY quoteToY) {
    _hoverPosition = event.localPosition;
  }

  @override
  String get id => 'Fibfan-adding-preview-desktop';

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
    final LineStyle lineStyle = interactableDrawing.config.lineStyle;
    final LineStyle fillStyle = interactableDrawing.config.fillStyle;
    final DrawingPaintStyle paintStyle = DrawingPaintStyle();

    if (interactableDrawing.startPoint == null && _hoverPosition != null) {
      final Offset pointOffset = Offset(
        _hoverPosition!.dx,
        _hoverPosition!.dy,
      );
      // Use the same color for edge points (from level0 which matches level100)
      final Color edgePointColor =
          interactableDrawing.config.fibonacciLevelColors['level0'] ??
              interactableDrawing.config.lineStyle.color;
      final LineStyle edgePointLineStyle =
          interactableDrawing.config.lineStyle.copyWith(color: edgePointColor);

      drawPointAlignmentGuides(canvas, size, pointOffset,
          lineColor: edgePointColor);

      // Draw preview point at hover position
      drawPointOffset(
        pointOffset,
        epochToX,
        quoteToY,
        canvas,
        paintStyle,
        edgePointLineStyle,
        radius: FibfanConstants.pointRadius,
      );
    }

    if (interactableDrawing.startPoint != null && _hoverPosition != null) {
      // Draw preview fan from start point to hover position
      final Offset startOffset = Offset(
        epochToX(interactableDrawing.startPoint!.epoch),
        quoteToY(interactableDrawing.startPoint!.quote),
      );

      // Validate coordinates before proceeding
      if (!FibonacciFanHelpers.areTwoOffsetsValid(
          startOffset, _hoverPosition!)) {
        return;
      }

      final double deltaX = _hoverPosition!.dx - startOffset.dx;
      final double deltaY = _hoverPosition!.dy - startOffset.dy;

      // Only draw if we have meaningful deltas
      if (FibonacciFanHelpers.areDeltasMeaningful(deltaX, deltaY)) {
        // Draw filled areas between fan lines
        FibonacciFanHelpers.drawFanFills(
            canvas, startOffset, deltaX, deltaY, size, paintStyle, fillStyle);
        // Draw fan lines
        FibonacciFanHelpers.drawFanLines(
            canvas, startOffset, deltaX, deltaY, size, paintStyle, lineStyle,
            fibonacciLevelColors:
                interactableDrawing.config.fibonacciLevelColors);
      }
      // Draw labels for the fan lines
      FibonacciFanHelpers.drawFanLabels(
          canvas, startOffset, deltaX, deltaY, size, lineStyle,
          fibonacciLevelColors:
              interactableDrawing.config.fibonacciLevelColors);

      // Use the same color for edge points (from level0 which matches level100)
      final Color edgePointColor =
          interactableDrawing.config.fibonacciLevelColors['level0'] ??
              interactableDrawing.config.lineStyle.color;
      final LineStyle edgePointLineStyle =
          interactableDrawing.config.lineStyle.copyWith(color: edgePointColor);

      // Draw the control points
      // Draw start point (already placed)
      drawPointOffset(
        startOffset,
        epochToX,
        quoteToY,
        canvas,
        paintStyle,
        edgePointLineStyle,
        radius: FibfanConstants.pointRadius,
      );

      // Draw end point at hover position (preview)
      final Offset endPointOffset = Offset(
        _hoverPosition!.dx,
        _hoverPosition!.dy,
      );
      drawPointOffset(
        endPointOffset,
        epochToX,
        quoteToY,
        canvas,
        paintStyle,
        edgePointLineStyle,
        radius: FibfanConstants.pointRadius,
      );

      drawPointAlignmentGuides(canvas, size, endPointOffset,
          lineColor: edgePointColor);
    }
  }

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
    GetDrawingState getDrawingState,
  ) {
    if (_hoverPosition != null) {
      // Use the same color for labels as edge points
      final Color edgePointColor =
          interactableDrawing.config.fibonacciLevelColors['level0'] ??
              interactableDrawing.config.lineStyle.color;

      drawValueLabel(
        canvas: canvas,
        quoteToY: quoteToY,
        value: interactiveLayerBehaviour.interactiveLayer
            .quoteFromY(_hoverPosition!.dy),
        pipSize: chartConfig.pipSize,
        size: size,
        color: edgePointColor,
        backgroundColor: chartTheme.backgroundColor,
        textStyle: interactableDrawing.config.labelStyle,
      );
      drawEpochLabel(
        canvas: canvas,
        epochToX: epochToX,
        epoch: interactiveLayerBehaviour.interactiveLayer
            .epochFromX(_hoverPosition!.dx),
        size: size,
        textStyle: interactableDrawing.config.labelStyle,
        animationProgress: animationInfo.stateChangePercent,
        color: edgePointColor,
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
  ) {
    if (interactableDrawing.startPoint == null) {
      // First tap - set start point
      interactableDrawing.startPoint = EdgePoint(
        epoch: epochFromX(details.localPosition.dx),
        quote: quoteFromY(details.localPosition.dy),
      );
      // Notify that we've completed step 1 of 2
      onAddingStateChange(AddingStateInfo(1, 2));
    } else if (interactableDrawing.endPoint == null) {
      // Second tap - set end point and complete the drawing
      interactableDrawing.endPoint = EdgePoint(
        epoch: epochFromX(details.localPosition.dx),
        quote: quoteFromY(details.localPosition.dy),
      );
      // Notify that we've completed step 2 of 2 (finished)
      onAddingStateChange(AddingStateInfo(2, 2));
    }
  }
}
