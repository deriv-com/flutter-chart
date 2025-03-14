import 'dart:ui' as ui;
import 'package:deriv_chart/src/add_ons/drawing_tools_ui/horizontal/horizontal_drawing_tool_config.dart';
import 'package:deriv_chart/src/theme/painting_styles/line_style.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

import '../../chart/data_visualization/chart_data.dart';
import '../../chart/data_visualization/drawing_tools/data_model/drawing_paint_style.dart';
import '../../chart/data_visualization/drawing_tools/data_model/edge_point.dart';
import '../../chart/data_visualization/models/animation_info.dart';
import '../interactable_drawing_custom_painter.dart';
import 'interactable_drawing.dart';

/// Interactable drawing for horizontal line drawing tool.
class HorizontalLineInteractableDrawing
    extends InteractableDrawing<HorizontalDrawingToolConfig> {
  /// Initializes [HorizontalLineInteractableDrawing].
  HorizontalLineInteractableDrawing({
    required HorizontalDrawingToolConfig config,
    required this.startPoint,
  }) : super(config: config);

  /// Start point of the line.
  EdgePoint? startPoint;

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
    if (startPoint == null) {
      return;
    }

    // Convert start and end points from epoch/quote to screen coordinates
    final Offset startOffset = Offset(
      epochToX(startPoint!.epoch),
      quoteToY(startPoint!.quote),
    );

    // For horizontal line, we only need to check if the drag is near the line
    final double distance = (details.localPosition.dy - startOffset.dy).abs();
    if (distance > hitTestMargin) {
      return;
    }
  }

  @override
  bool hitTest(Offset offset, EpochToX epochToX, QuoteToY quoteToY) {
    if (startPoint == null) {
      return false;
    }

    // Convert start and end points from epoch/quote to screen coordinates
    final Offset startOffset = Offset(
      epochToX(startPoint!.epoch),
      quoteToY(startPoint!.quote),
    );

    // For horizontal line, we only need to check if the point is near the line's y-coordinate
    final double distance = (offset.dy - startOffset.dy).abs();
    return distance <= hitTestMargin;
  }

  @override
  void paint(
    Canvas canvas,
    Size size,
    EpochToX epochToX,
    QuoteToY quoteToY,
    AnimationInfo animationInfo,
    GetDrawingState getDrawingState,
  ) {
    final LineStyle lineStyle = config.lineStyle;
    final DrawingPaintStyle paintStyle = DrawingPaintStyle();

    if (startPoint != null) {
      final Offset startOffset =
          Offset(0, quoteToY(startPoint!.quote)); // Start from left edge
      final Offset endOffset =
          Offset(size.width, quoteToY(startPoint!.quote)); // End at right edge

      // Check if this drawing is selected
      final Set<DrawingToolState> state = getDrawingState(this);

      // Use glowy paint style if selected, otherwise use normal paint style
      final Paint paint = state.contains(DrawingToolState.selected) ||
              state.contains(DrawingToolState.dragging)
          ? paintStyle.linePaintStyle(
              lineStyle.color, 1 + 1 * animationInfo.stateChangePercent)
          : paintStyle.linePaintStyle(lineStyle.color, lineStyle.thickness);

      canvas.drawLine(startOffset, endOffset, paint);

      // Draw endpoints with glowy effect if selected
      if (state.contains(DrawingToolState.selected) ||
          state.contains(DrawingToolState.dragging)) {
        _drawPointsFocusedCircle(
          paintStyle,
          lineStyle,
          canvas,
          startOffset,
          10 * animationInfo.stateChangePercent,
          3 * animationInfo.stateChangePercent,
          endOffset,
        );
      } else if (state.contains(DrawingToolState.hovered)) {
        _drawPointsFocusedCircle(
            paintStyle, lineStyle, canvas, startOffset, 10, 3, endOffset);
      }

      // Draw alignment guides when dragging
      if (state.contains(DrawingToolState.dragging)) {
        _drawAlignmentGuides(canvas, size, startOffset);
      }
    } else {
      if (startPoint == null && _hoverPosition != null) {
        // endPoint doesn't exist yet and it means we're creating this line.
        // Drawing preview horizontal line from startPoint's y-coordinate
        final Offset startPosition = Offset(
          0,
          _hoverPosition!.dy,
        );
        final Offset endPosition = Offset(
          size.width,
          _hoverPosition!.dy,
        );
        canvas.drawLine(startPosition, endPosition,
            paintStyle.linePaintStyle(lineStyle.color, lineStyle.thickness));
        _drawPointAlignmentGuides(canvas, size, startPosition);
      }
    }
  }

  void _drawPointsFocusedCircle(
      DrawingPaintStyle paintStyle,
      LineStyle lineStyle,
      ui.Canvas canvas,
      ui.Offset startOffset,
      double outerCircleRadius,
      double innerCircleRadius,
      ui.Offset endOffset) {
    final normalPaintStyle = paintStyle.glowyCirclePaintStyle(lineStyle.color);
    final glowyPaintStyle =
        paintStyle.glowyCirclePaintStyle(lineStyle.color.withOpacity(0.3));
    canvas
      ..drawCircle(
        startOffset,
        outerCircleRadius,
        glowyPaintStyle,
      )
      ..drawCircle(
        startOffset,
        innerCircleRadius,
        normalPaintStyle,
      )
      ..drawCircle(
        endOffset,
        outerCircleRadius,
        glowyPaintStyle,
      )
      ..drawCircle(
        endOffset,
        innerCircleRadius,
        normalPaintStyle,
      );
  }

  /// Draws alignment guides (horizontal lines) for the point
  void _drawAlignmentGuides(Canvas canvas, Size size, Offset pointOffset) {
    // Create a dashed paint style for the alignment guides
    final Paint guidesPaint = Paint()
      ..color = const Color(0x80FFFFFF) // Semi-transparent white
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // Create path for horizontal guide
    final Path horizontalPath = Path()
      ..moveTo(0, pointOffset.dy)
      ..lineTo(size.width, pointOffset.dy);

    // Draw the dashed line
    canvas.drawPath(
      _dashPath(horizontalPath,
          dashArray: _CircularIntervalList<double>(<double>[5, 5])),
      guidesPaint,
    );
  }

  /// Creates a dashed path from a regular path
  Path _dashPath(
    Path source, {
    required _CircularIntervalList<double> dashArray,
  }) {
    final Path dest = Path();
    for (final ui.PathMetric metric in source.computeMetrics()) {
      double distance = 0;
      bool draw = true;
      while (distance < metric.length) {
        final double len = dashArray.next;
        if (draw) {
          dest.addPath(
            metric.extractPath(distance, distance + len),
            Offset.zero,
          );
        }
        distance += len;
        draw = !draw;
      }
    }
    return dest;
  }

  void _drawPointAlignmentGuides(Canvas canvas, Size size, Offset pointOffset) {
    // Create a dashed paint style for the alignment guides
    final Paint guidesPaint = Paint()
      ..color = const Color(0x80FFFFFF) // Semi-transparent white
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // Create path for horizontal guide
    final Path horizontalPath = Path()
      ..moveTo(0, pointOffset.dy)
      ..lineTo(size.width, pointOffset.dy);

    // Draw the dashed line
    canvas.drawPath(
      _dashPath(horizontalPath,
          dashArray: _CircularIntervalList<double>(<double>[5, 5])),
      guidesPaint,
    );
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
    if (startPoint == null) {
      final quote = quoteFromY(details.localPosition.dy);
      startPoint = EdgePoint(
        epoch: epochFromX(0), // Start from left edge
        quote: quote,
      );
      onDone(); // Complete immediately since we don't need a second tap
    }
  }

  @override
  void onDragUpdate(
    DragUpdateDetails details,
    EpochFromX epochFromX,
    QuoteFromY quoteFromY,
    EpochToX epochToX,
    QuoteToY quoteToY,
  ) {
    if (startPoint == null) {
      return;
    }

    // Get the drag delta in screen coordinates
    final double deltaY = details.delta.dy;

    // Get the current screen position
    final double currentY = quoteToY(startPoint!.quote);

    // Apply the delta to get the new screen position
    final double newY = currentY + deltaY;

    // Convert back to quote coordinate
    final double newQuote = quoteFromY(newY);

    // Update both points to maintain horizontal line
    startPoint = EdgePoint(
      epoch: startPoint!.epoch,
      quote: newQuote,
    );
  }

  @override
  void onDragEnd(
    DragEndDetails details,
    EpochFromX epochFromX,
    QuoteFromY quoteFromY,
    EpochToX epochToX,
    QuoteToY quoteToY,
  ) {
    // No special handling needed for drag end
  }

  @override
  HorizontalDrawingToolConfig getUpdatedConfig() => config
      .copyWith(edgePoints: <EdgePoint>[if (startPoint != null) startPoint!]);
}

/// A circular array for dash patterns
class _CircularIntervalList<T> {
  _CircularIntervalList(this._values);

  final List<T> _values;
  int _index = 0;

  T get next {
    if (_index >= _values.length) {
      _index = 0;
    }
    return _values[_index++];
  }
}
