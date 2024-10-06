import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/models/line_barrier_object.dart';
import 'package:deriv_chart/src/deriv_chart/chart/helpers/paint_functions/create_shape_path.dart';
import 'package:flutter/material.dart';

/// Line Barrier Painter to paint the line barrier on the chart.
class LineBarrierPainter extends SeriesPainter<LineBarrier> {
  /// Initializes a line barrier painter.
  LineBarrierPainter(LineBarrier series) : super(series);

  late Paint _paint;

  /// Padding between lines.
  static const double padding = 4;

  /// Right margin.
  static const double rightMargin = 4;

  @override
  void onPaint({
    required Canvas canvas,
    required Size size,
    required EpochToX epochToX,
    required QuoteToY quoteToY,
    required AnimationInfo animationInfo,
  }) {
    if (!series.isOnRange) {
      return;
    }

    final HorizontalBarrierStyle style =
        series.style as HorizontalBarrierStyle? ?? theme.horizontalBarrierStyle;

    final LineBarrierObject object = series.annotationObject;
    final double startQuoteToY = quoteToY(object.startBarrier);
    final double endQuoteToY = quoteToY(object.endBarrier);
    final double startXCoord = epochToX(object.barrierStartEpoch);
    final double endXCoord = epochToX(object.barrierEndEpoch);

    _paint = Paint()
      ..color = style.color
      ..strokeWidth = 1;

    final Paint _rectPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = style.color.withOpacity(0.2);

    if (style.hasLine) {
      _paintLine(canvas, startXCoord, size.width, startQuoteToY, style);
      _paintLine(canvas, endXCoord, size.width, endQuoteToY, style);
    }

    /// ------------------------------------------------------------------------
    /// Paint the quote labels and barrier on vertical axis
    /// ------------------------------------------------------------------------

    // Create the start quote's label.
    final TextPainter startValuePainter = makeTextPainter(
      object.startBarrier.toStringAsFixed(chartConfig.pipSize),
      style.textStyle,
    );

    // Create the end quote's label.
    final TextPainter endValuePainter = makeTextPainter(
      object.endBarrier.toStringAsFixed(chartConfig.pipSize),
      style.textStyle,
    );

    // Create the rectangle background for the start quote's label.
    final Rect startLabelArea = Rect.fromCenter(
      center: Offset(
          size.width - rightMargin - padding - startValuePainter.width / 2,
          startQuoteToY),
      width: startValuePainter.width + padding * 2,
      height: style.labelHeight,
    );

    // Create the rectangle background for the end quote's label.
    final Rect endLabelArea = Rect.fromCenter(
      center: Offset(
          size.width - rightMargin - padding - endValuePainter.width / 2,
          endQuoteToY),
      width: endValuePainter.width + padding * 2,
      height: style.labelHeight,
    );

    // Create the horizontal barrier rectangle.
    final Rect horizontalBarrierRectangle = Rect.fromPoints(
      Offset(size.width - startLabelArea.width - padding, startQuoteToY),
      Offset(size.width, endQuoteToY),
    );

    // Draw horizontal barrier layer between the two quotes.
    canvas.drawRect(horizontalBarrierRectangle, _rectPaint);

    // Draw the start quote's label with background.
    _paintLabelBackground(canvas, startLabelArea, style.labelShape, _paint);
    paintWithTextPainter(
      canvas,
      painter: startValuePainter,
      anchor: startLabelArea.center,
    );

    // Draw the end quote's label with background.
    _paintLabelBackground(canvas, endLabelArea, style.labelShape, _paint);
    paintWithTextPainter(
      canvas,
      painter: endValuePainter,
      anchor: endLabelArea.center,
    );

    /// ------------------------------------------------------------------------

    ///-------------------------------------------------------------------------
    /// Paint the epoch labels and barrier on horizontal axis
    /// ------------------------------------------------------------------------

    // Date time formatted start epoch value.
    final String startEpochLabel = DateTime.fromMillisecondsSinceEpoch(
      object.barrierStartEpoch,
    ).toLocal().toString();

    // Date time formatted end epoch value.
    final String endEpochLabel = DateTime.fromMillisecondsSinceEpoch(
      object.barrierEndEpoch,
    ).toLocal().toString();

    // Create the start epoch label.
    final TextPainter startEpochPainter = makeTextPainter(
      startEpochLabel,
      style.textStyle,
    );

    // Create the end epoch label.
    final TextPainter endEpochPainter = makeTextPainter(
      endEpochLabel,
      style.textStyle,
    );

    // Create the rectangle background for the start epoch label.
    final Rect startEpochLabelArea = Rect.fromCenter(
      center:
          Offset(startXCoord, size.height - startEpochPainter.height - padding),
      width: startEpochPainter.width + padding * 2,
      height: style.labelHeight,
    );

    // Create the rectangle background for the end epoch label.
    final Rect endEpochLabelArea = Rect.fromCenter(
      center: Offset(endXCoord, size.height - endEpochPainter.height - padding),
      width: endEpochPainter.width + padding * 2,
      height: style.labelHeight,
    );

    // Create the vertical barrier rectangle.
    final Rect verticalBarrierRectangle = Rect.fromPoints(
      Offset(startEpochLabelArea.right,
          size.height - startEpochLabelArea.height - padding - 2),
      Offset(endEpochLabelArea.left, size.height - padding - 2),
    );

    // Draw the start epoch label with background.
    _paintLabelBackground(
        canvas, startEpochLabelArea, style.labelShape, _paint);
    paintWithTextPainter(
      canvas,
      painter: startEpochPainter,
      anchor: startEpochLabelArea.center,
    );

    // Draw the end epoch label with background.
    _paintLabelBackground(canvas, endEpochLabelArea, style.labelShape, _paint);
    paintWithTextPainter(
      canvas,
      painter: endEpochPainter,
      anchor: endEpochLabelArea.center,
    );

    // Draw vertical barrier layer between the two epochs.
    canvas.drawRect(verticalBarrierRectangle, _rectPaint);

    /// ------------------------------------------------------------------------
  }

  void _paintLine(
    Canvas canvas,
    double mainLineStartX,
    double mainLineEndX,
    double y,
    HorizontalBarrierStyle style,
  ) {
    if (style.isDashed) {
      paintHorizontalDashedLine(
        canvas,
        mainLineEndX,
        mainLineStartX,
        y,
        style.color,
        1,
      );
    } else {
      canvas.drawLine(
          Offset(mainLineStartX, y), Offset(mainLineEndX, y), _paint);
    }
  }

  /// Paints a background based on the given [LabelShape] for the label text.
  void _paintLabelBackground(
      Canvas canvas, Rect rect, LabelShape shape, Paint paint,
      {double radius = 4}) {
    if (shape == LabelShape.rectangle) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, Radius.elliptical(radius, 4)),
        paint,
      );
    } else if (shape == LabelShape.pentagon) {
      canvas.drawPath(
        getCurrentTickLabelBackgroundPath(
          left: rect.left,
          top: rect.top,
          right: rect.right,
          bottom: rect.bottom,
        ),
        paint,
      );
    }
  }
}
