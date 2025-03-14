import 'dart:ui' as ui;
import 'package:deriv_chart/src/add_ons/drawing_tools_ui/line/line_drawing_tool_config.dart';
import 'package:deriv_chart/src/theme/painting_styles/line_style.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

import '../../chart/data_visualization/chart_data.dart';
import '../../chart/data_visualization/drawing_tools/data_model/drawing_paint_style.dart';
import '../../chart/data_visualization/drawing_tools/data_model/edge_point.dart';
import '../../chart/data_visualization/models/animation_info.dart';
import '../interactable_drawing_custom_painter.dart';
import 'interactable_drawing.dart';

/// Interactable drawing for line drawing tool.
class LineInteractableDrawing
    extends InteractableDrawing<LineDrawingToolConfig> {
  /// Initializes [LineInteractableDrawing].
  LineInteractableDrawing({
    required LineDrawingToolConfig config,
    required this.startPoint,
    required this.endPoint,
  }) : super(config: config);

  /// Start point of the line.
  EdgePoint? startPoint;

  /// End point of the line.
  EdgePoint? endPoint;

  // Tracks which point is being dragged, if any
  // null: dragging the whole line
  // true: dragging the start point
  // false: dragging the end point
  bool? _isDraggingStartPoint;

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

    // Reset the dragging flag
    _isDraggingStartPoint = null;

    // Convert start and end points from epoch/quote to screen coordinates
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
      _isDraggingStartPoint = true;
      return;
    }

    // If the drag is starting on the end point
    if (endDistance <= hitTestMargin) {
      _isDraggingStartPoint = false;
      return;
    }

    // If we reach here, the drag is on the line itself, not on a specific point
    // _isDraggingStartPoint remains null, indicating we're dragging the whole line
  }

  @override
  bool hitTest(Offset offset, EpochToX epochToX, QuoteToY quoteToY) {
    if (startPoint == null || endPoint == null) {
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
    // Use a slightly larger margin for the endpoints to make them easier to hit
    final double startDistance = (offset - startOffset).distance;
    final double endDistance = (offset - endOffset).distance;

    if (startDistance <= hitTestMargin || endDistance <= hitTestMargin) {
      return true;
    }

    // Calculate line length
    final double lineLength = (endOffset - startOffset).distance;

    // If line length is too small, treat it as a point
    if (lineLength < 1) {
      return (offset - startOffset).distance <= hitTestMargin;
    }

    // Calculate perpendicular distance from point to line
    // Formula: |((y2-y1)x - (x2-x1)y + x2y1 - y2x1)| / sqrt((y2-y1)² + (x2-x1)²)
    final double distance = ((endOffset.dy - startOffset.dy) * offset.dx -
                (endOffset.dx - startOffset.dx) * offset.dy +
                endOffset.dx * startOffset.dy -
                endOffset.dy * startOffset.dx)
            .abs() /
        lineLength;

    // Check if point is within the line segment (not just the infinite line)
    final double dotProduct =
        (offset.dx - startOffset.dx) * (endOffset.dx - startOffset.dx) +
            (offset.dy - startOffset.dy) * (endOffset.dy - startOffset.dy);

    final bool isWithinRange =
        dotProduct >= 0 && dotProduct <= lineLength * lineLength;

    final result = isWithinRange && distance <= hitTestMargin;
    return result;
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
    // Check if this drawing is selected
    final Set<DrawingToolState> state = getDrawingState(this);

    if (startPoint != null && endPoint != null) {
      final Offset startOffset =
          Offset(epochToX(startPoint!.epoch), quoteToY(startPoint!.quote));
      final Offset endOffset =
          Offset(epochToX(endPoint!.epoch), quoteToY(endPoint!.quote));

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
        _drawAlignmentGuides(canvas, size, startOffset, endOffset, paintStyle);
      }
    } else if (state.contains(DrawingToolState.adding)) {
      if (startPoint != null) {
        _drawPoint(
            startPoint!, epochToX, quoteToY, canvas, paintStyle, lineStyle);
        _drawPointAlignmentGuides(canvas, size,
            Offset(epochToX(startPoint!.epoch), quoteToY(startPoint!.quote)));

        if (_hoverPosition != null) {
          // endPoint doesn't exist yet and it means we're creating this line.
          // Drawing preview line from startPoint to hoverPosition.
          final Offset startPosition = Offset(
            epochToX(startPoint!.epoch),
            quoteToY(startPoint!.quote),
          );
          canvas.drawLine(startPosition, _hoverPosition!,
              paintStyle.linePaintStyle(lineStyle.color, lineStyle.thickness));
          _drawPointAlignmentGuides(canvas, size, _hoverPosition!);
        }
      }

      if (endPoint != null) {
        _drawPoint(
            endPoint!, epochToX, quoteToY, canvas, paintStyle, lineStyle);
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

  /// Draws alignment guides (horizontal and vertical lines) from the points
  void _drawAlignmentGuides(Canvas canvas, Size size, Offset startOffset,
      Offset endOffset, DrawingPaintStyle paintStyle) {
    // Draw alignment guides for both start and end points
    _drawPointAlignmentGuides(canvas, size, startOffset);
    _drawPointAlignmentGuides(canvas, size, endOffset);
  }

  /// Draws alignment guides (horizontal and vertical lines) for a single point
  void _drawPointAlignmentGuides(Canvas canvas, Size size, Offset pointOffset) {
    // Create a dashed paint style for the alignment guides
    final Paint guidesPaint = Paint()
      ..color = const Color(0x80FFFFFF) // Semi-transparent white
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // Create paths for horizontal and vertical guides
    final Path horizontalPath = Path();
    final Path verticalPath = Path();

    // Draw horizontal and vertical guides from the point
    horizontalPath
      ..moveTo(0, pointOffset.dy)
      ..lineTo(size.width, pointOffset.dy);

    verticalPath
      ..moveTo(pointOffset.dx, 0)
      ..lineTo(pointOffset.dx, size.height);

    // Draw the dashed lines
    canvas
      ..drawPath(
        _dashPath(horizontalPath,
            dashArray: _CircularIntervalList<double>(<double>[5, 5])),
        guidesPaint,
      )
      ..drawPath(
        _dashPath(verticalPath,
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

  void _drawPoint(
    EdgePoint point,
    EpochToX epochToX,
    QuoteToY quoteToY,
    Canvas canvas,
    DrawingPaintStyle paintStyle,
    LineStyle lineStyle,
  ) {
    canvas.drawCircle(
      Offset(epochToX(point.epoch), quoteToY(point.quote)),
      5,
      paintStyle.glowyCirclePaintStyle(lineStyle.color),
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
      startPoint = EdgePoint(
        epoch: epochFromX(details.localPosition.dx),
        quote: quoteFromY(details.localPosition.dy),
      );
    } else {
      endPoint ??= EdgePoint(
        epoch: epochFromX(details.localPosition.dx),
        quote: quoteFromY(details.localPosition.dy),
      );
      onDone();
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
    if (startPoint == null || endPoint == null) {
      return;
    }

    // Get the drag delta in screen coordinates
    final Offset delta = details.delta;

    // If we're dragging a specific point (start or end point)
    if (_isDraggingStartPoint != null) {
      // Get the current point being dragged
      final EdgePoint pointBeingDragged =
          _isDraggingStartPoint! ? startPoint! : endPoint!;

      // Get the current screen position of the point
      final Offset currentOffset = Offset(
        epochToX(pointBeingDragged.epoch),
        quoteToY(pointBeingDragged.quote),
      );

      // Apply the delta to get the new screen position
      final Offset newOffset = currentOffset + delta;

      // Convert back to epoch and quote coordinates
      final int newEpoch = epochFromX(newOffset.dx);
      final double newQuote = quoteFromY(newOffset.dy);

      // Create updated point
      final EdgePoint updatedPoint = EdgePoint(
        epoch: newEpoch,
        quote: newQuote,
      );

      // Update the appropriate point
      if (_isDraggingStartPoint!) {
        startPoint = updatedPoint;
      } else {
        endPoint = updatedPoint;
      }
    } else {
      // We're dragging the whole line
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
    // Reset the dragging flag when drag is complete
    _isDraggingStartPoint = null;
  }

  @override
  LineDrawingToolConfig getUpdatedConfig() =>
      config.copyWith(edgePoints: <EdgePoint>[
        if (startPoint != null) startPoint!,
        if (endPoint != null) endPoint!
      ]);
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
