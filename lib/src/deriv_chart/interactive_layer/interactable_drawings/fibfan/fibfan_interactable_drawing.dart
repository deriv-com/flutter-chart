import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:deriv_chart/src/add_ons/drawing_tools_ui/callbacks.dart';
import 'package:deriv_chart/src/add_ons/drawing_tools_ui/drawing_tool_config.dart';
import 'package:deriv_chart/src/add_ons/drawing_tools_ui/fibfan/fibfan_drawing_tool_config.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_data.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/drawing_paint_style.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/edge_point.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/extensions/extensions.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/models/animation_info.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/interactable_drawings/drawing_adding_preview.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/interactable_drawings/fibfan/drag_state.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/interactable_drawings/fibfan/helpers.dart';
import 'package:deriv_chart/src/models/axis_range.dart';
import 'package:deriv_chart/src/models/chart_config.dart';
import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:deriv_chart/src/theme/painting_styles/line_style.dart';
import 'package:deriv_chart/src/widgets/color_picker/color_picker_dropdown_button.dart';
import 'package:deriv_chart/src/widgets/dropdown/line_thickness/line_thickness_dropdown_button.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../enums/drawing_tool_state.dart';
import '../../helpers/paint_helpers.dart';
import '../../helpers/types.dart';
import '../../interactive_layer_behaviours/interactive_layer_desktop_behaviour.dart';
import '../../interactive_layer_behaviours/interactive_layer_mobile_behaviour.dart';
import '../../interactive_layer_states/interactive_adding_tool_state.dart';
import '../drawing_v2.dart';
import '../interactable_drawing.dart';
import 'fibfan_adding_preview_desktop.dart';
import 'fibfan_adding_preview_mobile.dart';

/// Interactable drawing for Fibonacci Fan drawing tool.
///
/// This class implements a complete Fibonacci Fan technical analysis tool that allows
/// users to draw, interact with, and customize fan lines based on Fibonacci ratios.
/// The fan consists of multiple trend lines emanating from a start point, each
/// representing different Fibonacci retracement levels (0%, 38.2%, 50%, 61.8%, 100%).
///
/// **Key Features:**
/// - Interactive creation with two-point definition (start and end points)
/// - Real-time preview during creation and editing
/// - Drag support for individual points or entire fan
/// - Hit testing for precise user interaction
/// - Customizable colors and styling
/// - Mobile and desktop optimized behaviors
/// - Automatic label display with percentage values
/// - Fill areas between fan lines for visual clarity
///
/// **Usage in Technical Analysis:**
/// Fibonacci fans help traders identify potential support and resistance levels
/// by projecting Fibonacci ratios from a significant price movement. The fan
/// lines act as dynamic trend lines that can guide trading decisions.
///
/// **Interaction States:**
/// - **Creating**: User is placing the start and end points
/// - **Selected**: Fan is selected and shows all visual elements
/// - **Dragging**: User is moving points or the entire fan
/// - **Hovered**: Mouse is over the fan (desktop only)
class FibfanInteractableDrawing
    extends InteractableDrawing<FibfanDrawingToolConfig> {
  /// Initializes [FibfanInteractableDrawing].
  ///
  /// Creates a new Fibonacci Fan drawing with the specified configuration
  /// and initial points. The drawing can be created with null points for
  /// interactive creation or with predefined points for loading saved drawings.
  ///
  /// **Parameters:**
  /// - [config]: Drawing configuration including colors, styles, and Fibonacci levels
  /// - [startPoint]: Initial start point of the fan (can be null for interactive creation)
  /// - [endPoint]: Initial end point of the fan (can be null for interactive creation)
  /// - [drawingContext]: Context providing canvas dimensions and coordinate conversion
  /// - [getDrawingState]: Function to retrieve current drawing state (selected, dragging, etc.)
  FibfanInteractableDrawing({
    required FibfanDrawingToolConfig config,
    required this.startPoint,
    required this.endPoint,
    required super.drawingContext,
    required super.getDrawingState,
  }) : super(drawingConfig: config);

  /// Start point of the fan in epoch/quote coordinates.
  ///
  /// This point serves as the origin for all fan lines. In technical analysis,
  /// this is typically placed at a significant price level (support, resistance,
  /// or pivot point) from which Fibonacci projections are calculated.
  EdgePoint? startPoint;

  /// End point of the fan in epoch/quote coordinates.
  ///
  /// This point defines the direction and scale of the fan. The vector from
  /// start to end point determines the base angle and magnitude for calculating
  /// all Fibonacci fan lines. Each fan line uses this vector multiplied by
  /// its respective Fibonacci ratio.
  EdgePoint? endPoint;

  /// Tracks the current drag state during user interaction.
  ///
  /// This state variable enables precise drag behavior by distinguishing between:
  /// - `null`: No dragging is currently active
  /// - `FibfanDragState.draggingStartPoint`: User is dragging only the start point
  /// - `FibfanDragState.draggingEndPoint`: User is dragging only the end point
  /// - `FibfanDragState.draggingEntireFan`: User is dragging the entire fan (both points move together)
  ///
  /// The value is set during [onDragStart] based on hit testing and cleared
  /// during [onDragEnd] to reset the interaction state.
  FibfanDragState? _dragState;

  /// Current hover position for desktop interactions.
  ///
  /// Stores the mouse position during hover events to enable real-time
  /// preview functionality. This is used primarily during the creation
  /// process to show a preview fan from the start point to the cursor.
  ///
  /// **Note:** This is only used on desktop platforms where hover events
  /// are available. Mobile platforms use touch-based interactions instead.
  Offset? _hoverPosition;

  @override
  void onHover(PointerHoverEvent event, EpochFromX epochFromX,
      QuoteFromY quoteFromY, EpochToX epochToX, QuoteToY quoteToY) {
    _hoverPosition = event.localPosition;
  }

  @override
  void onDragStart(
    DragStartDetails details,
    EpochFromX epochFromX,
    QuoteFromY quoteFromY,
    EpochToX epochToX,
    QuoteToY quoteToY,
  ) {
    if (startPoint == null || endPoint == null) {
      return;
    }

    final Offset startOffset = Offset(
      epochToX(startPoint!.epoch),
      quoteToY(startPoint!.quote),
    );

    final Offset endOffset = Offset(
      epochToX(endPoint!.epoch),
      quoteToY(endPoint!.quote),
    );

    // Check if the drag is starting on one of the endpoints
    final double startDistance = (details.localPosition - startOffset).distance;
    final double endDistance = (details.localPosition - endOffset).distance;

    // If the drag is starting on the start point
    if (startDistance <= hitTestMargin) {
      _dragState = FibfanDragState.draggingStartPoint;
      return;
    }

    // If the drag is starting on the end point
    if (endDistance <= hitTestMargin) {
      _dragState = FibfanDragState.draggingEndPoint;
      return;
    }

    // Check if the drag is on any of the fan lines
    if (_hitTestFanLines(details.localPosition, epochToX, quoteToY)) {
      _dragState = FibfanDragState.draggingEntireFan;
      return;
    }

    // Check if the drag is anywhere within the fan area
    if (_hitTestFanArea(details.localPosition, epochToX, quoteToY)) {
      _dragState = FibfanDragState.draggingEntireFan;
      return;
    }
  }

  @override
  bool hitTest(Offset offset, EpochToX epochToX, QuoteToY quoteToY) {
    if (startPoint == null || endPoint == null) {
      return false;
    }

    final isNotSelected = !state.contains(DrawingToolState.selected);
    final isOutsideContent = offset.dx > drawingContext.contentSize.width;

    if (isNotSelected && isOutsideContent) {
      return false;
    }

    // Convert start and end points from epoch/quote to screen coordinates
    final Offset startOffset = Offset(
      epochToX(startPoint!.epoch),
      quoteToY(startPoint!.quote),
    );
    final Offset endOffset = Offset(
      epochToX(endPoint!.epoch),
      quoteToY(endPoint!.quote),
    );

    // Check if the pointer is near either endpoint
    final double startDistance = (offset - startOffset).distance;
    final double endDistance = (offset - endOffset).distance;

    if (startDistance <= hitTestMargin || endDistance <= hitTestMargin) {
      return true;
    }

    // Check if the pointer is near any of the fan lines
    if (_hitTestFanLines(offset, epochToX, quoteToY)) {
      return true;
    }

    // Check if the pointer is within the fan area (between the fan lines)
    return _hitTestFanArea(offset, epochToX, quoteToY);
  }

  /// Helper method to test if a point hits any of the fan lines using angle-based calculations
  bool _hitTestFanLines(Offset offset, EpochToX epochToX, QuoteToY quoteToY) {
    if (startPoint == null || endPoint == null) {
      return false;
    }

    final Offset startOffset = Offset(
      epochToX(startPoint!.epoch),
      quoteToY(startPoint!.quote),
    );
    final Offset endOffset = Offset(
      epochToX(endPoint!.epoch),
      quoteToY(endPoint!.quote),
    );

    // Calculate the base vector and angle
    final double deltaX = endOffset.dx - startOffset.dx;
    final double deltaY = endOffset.dy - startOffset.dy;
    final double baseAngle = math.atan2(deltaY, deltaX);

    // Check each fan line using angle-based calculations
    for (final FibonacciLevel level in FibonacciFanHelpers.fibonacciLevels) {
      // Calculate angle: 0% should point to end point, 100% should be horizontal (0 degrees)
      // Interpolate between the end angle (baseAngle) and horizontal reference (0 degrees)
      const double horizontalAngle = 0; // Horizontal reference
      final double fanAngle =
          baseAngle + (horizontalAngle - baseAngle) * level.ratio;

      // Extend the line to the edge of the screen using trigonometry
      final double screenWidth = drawingContext.contentSize.width;
      final double distanceToEdge = screenWidth - startOffset.dx;

      final Offset extendedEndPoint = Offset(
        screenWidth,
        startOffset.dy + distanceToEdge * math.tan(fanAngle),
      );

      // Calculate perpendicular distance from point to line
      final double lineLength = (extendedEndPoint - startOffset).distance;
      if (lineLength < FibfanConstants.minLineLength) {
        continue;
      }

      final double distance =
          ((extendedEndPoint.dy - startOffset.dy) * offset.dx -
                      (extendedEndPoint.dx - startOffset.dx) * offset.dy +
                      extendedEndPoint.dx * startOffset.dy -
                      extendedEndPoint.dy * startOffset.dx)
                  .abs() /
              lineLength;

      // Check if point is within the line segment
      final double dotProduct = (offset.dx - startOffset.dx) *
              (extendedEndPoint.dx - startOffset.dx) +
          (offset.dy - startOffset.dy) * (extendedEndPoint.dy - startOffset.dy);

      final bool isWithinRange =
          dotProduct >= 0 && dotProduct <= lineLength * lineLength;

      if (isWithinRange && distance <= hitTestMargin) {
        return true;
      }
    }

    return false;
  }

  /// Helper method to test if a point is within the fan area (between the fan lines)
  /// Uses the same logic as drawFanFills to ensure perfect coverage
  bool _hitTestFanArea(Offset offset, EpochToX epochToX, QuoteToY quoteToY) {
    if (startPoint == null || endPoint == null) {
      return false;
    }

    final Offset startOffset = Offset(
      epochToX(startPoint!.epoch),
      quoteToY(startPoint!.quote),
    );
    final Offset endOffset = Offset(
      epochToX(endPoint!.epoch),
      quoteToY(endPoint!.quote),
    );

    final double deltaX = endOffset.dx - startOffset.dx;
    final double deltaY = endOffset.dy - startOffset.dy;

    // Use shared calculation method for perfect consistency with drawFanFills
    final List<List<Offset>> fanPolygons =
        FibonacciFanHelpers.calculateFanAreaPolygons(
      startOffset: startOffset,
      deltaX: deltaX,
      deltaY: deltaY,
      size: drawingContext.contentSize,
    );

    // Test if point is in any of the calculated polygons
    for (final List<Offset> polygon in fanPolygons) {
      if (_isPointInTriangle(offset, polygon[0], polygon[1], polygon[2])) {
        return true;
      }
    }

    return false;
  }

  /// Helper method to test if a point is inside a triangle using barycentric coordinates
  bool _isPointInTriangle(Offset point, Offset a, Offset b, Offset c) {
    // Calculate vectors
    final double v0x = c.dx - a.dx;
    final double v0y = c.dy - a.dy;
    final double v1x = b.dx - a.dx;
    final double v1y = b.dy - a.dy;
    final double v2x = point.dx - a.dx;
    final double v2y = point.dy - a.dy;

    // Calculate dot products
    final double dot00 = v0x * v0x + v0y * v0y;
    final double dot01 = v0x * v1x + v0y * v1y;
    final double dot02 = v0x * v2x + v0y * v2y;
    final double dot11 = v1x * v1x + v1y * v1y;
    final double dot12 = v1x * v2x + v1y * v2y;

    // Calculate barycentric coordinates
    final double invDenom = 1 / (dot00 * dot11 - dot01 * dot01);
    final double u = (dot11 * dot02 - dot01 * dot12) * invDenom;
    final double v = (dot00 * dot12 - dot01 * dot02) * invDenom;

    // Check if point is in triangle
    return (u >= 0) && (v >= 0) && (u + v <= 1);
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
  ) {
    final LineStyle lineStyle = config.lineStyle;
    final LineStyle fillStyle = config.fillStyle;
    final DrawingPaintStyle paintStyle = DrawingPaintStyle();
    final drawingState = getDrawingState(this);

    // Handle configuration changes for automatic cache management
    final int configHash = _calculateConfigHash();
    FibonacciFanHelpers.handleConfigurationChange(configHash);

    if (startPoint != null && endPoint != null) {
      final Offset startOffset = Offset(
        epochToX(startPoint!.epoch),
        quoteToY(startPoint!.quote),
      );
      final Offset endOffset = Offset(
        epochToX(endPoint!.epoch),
        quoteToY(endPoint!.quote),
      );

      // Calculate the base vector
      final double deltaX = endOffset.dx - startOffset.dx;
      final double deltaY = endOffset.dy - startOffset.dy;

      // Draw fan lines
      FibonacciFanHelpers.drawFanLines(
          canvas, startOffset, deltaX, deltaY, size, paintStyle, lineStyle,
          fibonacciLevelColors: config.fibonacciLevelColors);

      // Draw labels
      if (drawingState.contains(DrawingToolState.selected)) {
        // Draw filled areas between fan lines
        FibonacciFanHelpers.drawFanFills(
            canvas, startOffset, deltaX, deltaY, size, paintStyle, fillStyle,
            fibonacciLevelColors: config.fibonacciLevelColors);
        FibonacciFanHelpers.drawFanLabels(
            canvas, startOffset, deltaX, deltaY, size, lineStyle,
            fibonacciLevelColors: config.fibonacciLevelColors);
      }

      // Draw endpoints with appropriate visual feedback based on interaction state
      if (drawingState.contains(DrawingToolState.selected) ||
          drawingState.contains(DrawingToolState.dragging)) {
        // Use the same color for both edge points (from level0 which matches level100)
        final Color edgePointColor =
            config.fibonacciLevelColors['level0'] ?? config.lineStyle.color;
        final LineStyle edgePointLineStyle =
            config.lineStyle.copyWith(color: edgePointColor);

        // Handle individual point dragging with differentiated visual feedback
        if (drawingState.contains(DrawingToolState.dragging) &&
            (_dragState == FibfanDragState.draggingStartPoint ||
                _dragState == FibfanDragState.draggingEndPoint)) {
          // Draw focused circle (glowing effect) only on the point being dragged
          // This provides clear visual feedback about which point is actively being manipulated
          drawFocusedCircle(
            paintStyle,
            edgePointLineStyle,
            canvas,
            _dragState == FibfanDragState.draggingStartPoint
                ? startOffset
                : endOffset,
            FibfanConstants.focusedCircleRadius *
                animationInfo.stateChangePercent,
            FibfanConstants.focusedCircleStroke *
                animationInfo.stateChangePercent,
          );

          // Draw regular point (non-glowing) on the point that is NOT being dragged
          // This maintains visibility of the stationary point while clearly distinguishing
          // it from the actively dragged point
          drawPoint(
            _dragState == FibfanDragState.draggingStartPoint
                ? endPoint!
                : startPoint!,
            epochToX,
            quoteToY,
            canvas,
            paintStyle,
            edgePointLineStyle,
            radius: FibfanConstants.pointRadius,
          );
        } else {
          // When not dragging individual points (selected state or dragging entire fan),
          // show focused circles on both points for general selection feedback
          drawPointsFocusedCircle(
            paintStyle,
            edgePointLineStyle,
            canvas,
            startOffset,
            FibfanConstants.focusedCircleRadius *
                animationInfo.stateChangePercent,
            FibfanConstants.focusedCircleStroke *
                animationInfo.stateChangePercent,
            endOffset,
          );
        }
      } else if (drawingState.contains(DrawingToolState.hovered)) {
        // Use the same color for both edge points (from level0 which matches level100)
        final Color edgePointColor =
            config.fibonacciLevelColors['level0'] ?? config.lineStyle.color;
        final LineStyle edgePointLineStyle =
            config.lineStyle.copyWith(color: edgePointColor);

        drawPointsFocusedCircle(
            paintStyle,
            edgePointLineStyle,
            canvas,
            startOffset,
            FibfanConstants.focusedCircleRadius,
            FibfanConstants.focusedCircleStroke,
            endOffset);
      }

      // Draw alignment guides when dragging
      if (drawingState.contains(DrawingToolState.dragging)) {
        // Use the same color for alignment guides as edge points
        final Color edgePointColor =
            config.fibonacciLevelColors['level0'] ?? config.lineStyle.color;

        switch (_dragState) {
          case FibfanDragState.draggingStartPoint:
            drawPointAlignmentGuides(canvas, size, startOffset,
                lineColor: edgePointColor);
            break;
          case FibfanDragState.draggingEndPoint:
            drawPointAlignmentGuides(canvas, size, endOffset,
                lineColor: edgePointColor);
            break;
          case FibfanDragState.draggingEntireFan:
            drawPointAlignmentGuides(canvas, size, startOffset,
                lineColor: edgePointColor);
            drawPointAlignmentGuides(canvas, size, endOffset,
                lineColor: edgePointColor);
            break;
          case null:
            // No specific drag state, don't draw alignment guides
            break;
        }
      }
    } else if (startPoint != null && _hoverPosition != null) {
      // Preview mode - draw fan from start point to hover position
      final Offset startOffset = Offset(
        epochToX(startPoint!.epoch),
        quoteToY(startPoint!.quote),
      );

      final double deltaX = _hoverPosition!.dx - startOffset.dx;
      final double deltaY = _hoverPosition!.dy - startOffset.dy;

      FibonacciFanHelpers.drawFanLines(
          canvas, startOffset, deltaX, deltaY, size, paintStyle, lineStyle);

      // Draw the control points during preview
      // Draw start point (already placed)
      drawPoint(
        startPoint!,
        epochToX,
        quoteToY,
        canvas,
        paintStyle,
        config.lineStyle,
        radius: FibfanConstants.pointRadius,
      );

      // Draw preview end point at hover position
      final Offset hoverPointOffset = Offset(
        _hoverPosition!.dx,
        _hoverPosition!.dy,
      );
      drawPointOffset(
        hoverPointOffset,
        epochToX,
        quoteToY,
        canvas,
        paintStyle,
        config.lineStyle,
        radius: FibfanConstants.pointRadius,
      );

      // Use the same color for alignment guides as edge points
      final Color edgePointColor =
          config.fibonacciLevelColors['level0'] ?? config.lineStyle.color;
      drawPointAlignmentGuides(canvas, size, startOffset,
          lineColor: edgePointColor);
    }
  }

  @override
  void paintOverYAxis(
    ui.Canvas canvas,
    ui.Size size,
    EpochToX epochToX,
    QuoteToY quoteToY,
    int Function(double)? epochFromX,
    double Function(double)? quoteFromY,
    AnimationInfo animationInfo,
    ChartConfig chartConfig,
    ChartTheme chartTheme,
    GetDrawingState getDrawingState,
  ) {
    drawLabelsWithZIndex(
      canvas: canvas,
      size: size,
      animationInfo: animationInfo,
      chartConfig: chartConfig,
      chartTheme: chartTheme,
      getDrawingState: getDrawingState,
      drawing: this,
      isDraggingStartPoint: _dragState == FibfanDragState.draggingStartPoint,
      isDraggingEndPoint: _dragState == FibfanDragState.draggingEndPoint,
      drawStartPointLabel: () {
        if (startPoint != null) {
          // Use the same color for labels as edge points
          final Color edgePointColor =
              config.fibonacciLevelColors['level0'] ?? config.lineStyle.color;
          drawValueLabel(
            canvas: canvas,
            quoteToY: quoteToY,
            value: startPoint!.quote,
            pipSize: chartConfig.pipSize,
            animationProgress: animationInfo.stateChangePercent,
            size: size,
            textStyle: config.labelStyle,
            color: edgePointColor,
            backgroundColor: chartTheme.backgroundColor,
          );
        }
      },
      drawEndPointLabel: () {
        if (endPoint != null &&
            startPoint != null &&
            endPoint!.quote != startPoint!.quote) {
          // Use the same color for labels as edge points
          final Color edgePointColor =
              config.fibonacciLevelColors['level0'] ?? config.lineStyle.color;
          drawValueLabel(
            canvas: canvas,
            quoteToY: quoteToY,
            value: endPoint!.quote,
            pipSize: chartConfig.pipSize,
            animationProgress: animationInfo.stateChangePercent,
            size: size,
            textStyle: config.labelStyle,
            color: edgePointColor,
            backgroundColor: chartTheme.backgroundColor,
          );
        }
      },
    );

    paintXAxisLabels(
      canvas,
      size,
      epochToX,
      quoteToY,
      animationInfo,
      chartConfig,
      chartTheme,
      getDrawingState,
    );
  }

  /// Paints epoch labels on the X-axis.
  void paintXAxisLabels(
    ui.Canvas canvas,
    ui.Size size,
    EpochToX epochToX,
    QuoteToY quoteToY,
    AnimationInfo animationInfo,
    ChartConfig chartConfig,
    ChartTheme chartTheme,
    GetDrawingState getDrawingState,
  ) {
    drawLabelsWithZIndex(
      canvas: canvas,
      size: size,
      animationInfo: animationInfo,
      chartConfig: chartConfig,
      chartTheme: chartTheme,
      getDrawingState: getDrawingState,
      drawing: this,
      isDraggingStartPoint: _dragState == FibfanDragState.draggingStartPoint,
      isDraggingEndPoint: _dragState == FibfanDragState.draggingEndPoint,
      drawStartPointLabel: () {
        if (startPoint != null) {
          // Use the same color for labels as edge points
          final Color edgePointColor =
              config.fibonacciLevelColors['level0'] ?? config.lineStyle.color;
          drawEpochLabel(
            canvas: canvas,
            epochToX: epochToX,
            epoch: startPoint!.epoch,
            size: size,
            textStyle: config.labelStyle,
            animationProgress: animationInfo.stateChangePercent,
            color: edgePointColor,
            backgroundColor: chartTheme.backgroundColor,
          );
        }
      },
      drawEndPointLabel: () {
        if (endPoint != null &&
            startPoint != null &&
            endPoint!.epoch != startPoint!.epoch) {
          // Use the same color for labels as edge points
          final Color edgePointColor =
              config.fibonacciLevelColors['level0'] ?? config.lineStyle.color;
          drawEpochLabel(
            canvas: canvas,
            epochToX: epochToX,
            epoch: endPoint!.epoch,
            size: size,
            textStyle: config.labelStyle,
            animationProgress: animationInfo.stateChangePercent,
            color: edgePointColor,
            backgroundColor: chartTheme.backgroundColor,
          );
        }
      },
    );
  }

  @override
  void onDragUpdate(
    DragUpdateDetails details,
    EpochFromX epochFromX,
    QuoteFromY quoteFromY,
    EpochToX epochToX,
    QuoteToY quoteToY,
  ) {
    if (startPoint == null || endPoint == null) {
      return;
    }

    // Get the drag delta in screen coordinates
    final Offset delta = details.delta;

    // Handle different drag states
    switch (_dragState) {
      case FibfanDragState.draggingStartPoint:
        // Get the current screen position of the start point
        final Offset currentOffset = Offset(
          epochToX(startPoint!.epoch),
          quoteToY(startPoint!.quote),
        );

        // Apply the delta to get the new screen position
        final Offset newOffset = currentOffset + delta;

        // Convert back to epoch and quote coordinates
        final int newEpoch = epochFromX(newOffset.dx);
        final double newQuote = quoteFromY(newOffset.dy);

        // Update the start point
        startPoint = EdgePoint(
          epoch: newEpoch,
          quote: newQuote,
        );
        break;

      case FibfanDragState.draggingEndPoint:
        // Get the current screen position of the end point
        final Offset currentOffset = Offset(
          epochToX(endPoint!.epoch),
          quoteToY(endPoint!.quote),
        );

        // Apply the delta to get the new screen position
        final Offset newOffset = currentOffset + delta;

        // Convert back to epoch and quote coordinates
        final int newEpoch = epochFromX(newOffset.dx);
        final double newQuote = quoteFromY(newOffset.dy);

        // Update the end point
        endPoint = EdgePoint(
          epoch: newEpoch,
          quote: newQuote,
        );
        break;

      case FibfanDragState.draggingEntireFan:
      case null:
        // We're dragging the whole fan
        // Convert start and end points to screen coordinates
        final Offset startOffset = Offset(
          epochToX(startPoint!.epoch),
          quoteToY(startPoint!.quote),
        );
        final Offset endOffset = Offset(
          epochToX(endPoint!.epoch),
          quoteToY(endPoint!.quote),
        );

        // Apply the delta to get new screen coordinates
        final Offset newStartOffset = startOffset + delta;
        final Offset newEndOffset = endOffset + delta;

        // Convert back to epoch and quote coordinates
        final int newStartEpoch = epochFromX(newStartOffset.dx);
        final double newStartQuote = quoteFromY(newStartOffset.dy);
        final int newEndEpoch = epochFromX(newEndOffset.dx);
        final double newEndQuote = quoteFromY(newEndOffset.dy);

        // Update the start and end points
        startPoint = EdgePoint(
          epoch: newStartEpoch,
          quote: newStartQuote,
        );
        endPoint = EdgePoint(
          epoch: newEndEpoch,
          quote: newEndQuote,
        );
    }
  }

  @override
  void onDragEnd(
    DragEndDetails details,
    EpochFromX epochFromX,
    QuoteFromY quoteFromY,
    EpochToX epochToX,
    QuoteToY quoteToY,
  ) {
    // Reset the drag state when drag is complete
    _dragState = null;
  }

  @override
  FibfanDrawingToolConfig getUpdatedConfig() =>
      config.copyWith(edgePoints: <EdgePoint>[
        if (startPoint != null) startPoint!,
        if (endPoint != null) endPoint!
      ]);

  @override
  bool isInViewPort(EpochRange epochRange, QuoteRange quoteRange) =>
      (startPoint?.isInEpochRange(
            epochRange.leftEpoch,
            epochRange.rightEpoch,
          ) ??
          true) ||
      (endPoint?.isInEpochRange(
            epochRange.leftEpoch,
            epochRange.rightEpoch,
          ) ??
          true);

  @override
  DrawingAddingPreview<InteractableDrawing<DrawingToolConfig>>
      getAddingPreviewForDesktopBehaviour(
    InteractiveLayerDesktopBehaviour layerBehaviour,
    Function(AddingStateInfo) onAddingStateChange,
  ) =>
          FibfanAddingPreviewDesktop(
            interactiveLayerBehaviour: layerBehaviour,
            interactableDrawing: this,
            onAddingStateChange: onAddingStateChange,
          );

  @override
  DrawingAddingPreview<InteractableDrawing<DrawingToolConfig>>
      getAddingPreviewForMobileBehaviour(
    InteractiveLayerMobileBehaviour layerBehaviour,
    Function(AddingStateInfo) onAddingStateChange,
  ) =>
          FibfanAddingPreviewMobile(
            interactiveLayerBehaviour: layerBehaviour,
            interactableDrawing: this,
            onAddingStateChange: onAddingStateChange,
          );

  @override
  Widget buildDrawingToolBarMenu(UpdateDrawingTool onUpdate) => Row(
        children: <Widget>[
          _buildLineThicknessIcon(onUpdate),
          const SizedBox(width: 4),
          _buildFibonacciLevelColorPicker('level0', 'level100', onUpdate),
          const SizedBox(width: 4),
          _buildFibonacciLevelColorPicker('level38_2', null, onUpdate),
          const SizedBox(width: 4),
          _buildFibonacciLevelColorPicker('level50', null, onUpdate),
          const SizedBox(width: 4),
          _buildFibonacciLevelColorPicker('level61_8', null, onUpdate),
        ],
      );

  Widget _buildFibonacciLevelColorPicker(String levelKey,
          String? secondLevelKey, UpdateDrawingTool onUpdate) =>
      SizedBox(
        width: 32,
        height: 32,
        child: ColorPickerDropdownButton(
          currentColor: config.fibonacciLevelColors[levelKey]!,
          onColorChanged: (newColor) {
            final Map<String, Color> updatedColors =
                Map<String, Color>.from(config.fibonacciLevelColors);
            updatedColors[levelKey] = newColor;

            // If a second level key is provided, update it as well (for top & bottom lines)
            if (secondLevelKey != null) {
              updatedColors[secondLevelKey] = newColor;
            }

            onUpdate(config.copyWith(
              fibonacciLevelColors: updatedColors,
            ));
          },
        ),
      );

  Widget _buildLineThicknessIcon(UpdateDrawingTool onUpdate) =>
      LineThicknessDropdownButton(
        thickness: config.lineStyle.thickness,
        onValueChanged: (double newValue) {
          onUpdate(config.copyWith(
            lineStyle: config.lineStyle.copyWith(thickness: newValue),
          ));
        },
      );

  /// Calculates a hash of the current configuration for change detection.
  ///
  /// This method creates a hash based on the drawing configuration properties
  /// that affect visual rendering. When the configuration changes, the hash
  /// will change, triggering automatic cache management to ensure cached
  /// paint objects reflect the latest styling.
  ///
  /// **Included Properties:**
  /// - Line style (color, thickness)
  /// - Fill style (color, thickness)
  /// - Fibonacci level colors
  /// - Label style (color, font size)
  ///
  /// **Returns:** Integer hash representing the current configuration state
  int _calculateConfigHash() {
    return Object.hash(
      config.lineStyle.color.value,
      config.lineStyle.thickness,
      config.fillStyle.color.value,
      config.fillStyle.thickness,
      config.labelStyle.color?.value ?? 0,
      config.labelStyle.fontSize,
      config.fibonacciLevelColors.entries
          .map((e) => Object.hash(e.key, e.value.value))
          .fold<int>(0, (prev, hash) => prev ^ hash),
    );
  }
}
