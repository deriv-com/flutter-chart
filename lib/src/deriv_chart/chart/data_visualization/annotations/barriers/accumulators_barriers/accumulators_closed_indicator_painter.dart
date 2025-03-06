import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/annotations/barriers/accumulators_barriers/accumulators_closed_indicator.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_data.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/series_painter.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/models/animation_info.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/models/chart_scale_model.dart';
import 'package:deriv_chart/src/deriv_chart/chart/helpers/paint_functions/paint_dot.dart';
import 'package:deriv_chart/src/deriv_chart/chart/helpers/paint_functions/paint_text.dart';
import 'package:deriv_chart/src/theme/painting_styles/barrier_style.dart';
import 'package:flutter/material.dart';

/// Accumulator barriers painter.
class AccumulatorsClosedIndicatorPainter
    extends SeriesPainter<AccumulatorsClosedIndicator> {
  /// Initializes [AccumulatorsClosedIndicatorPainter].
  AccumulatorsClosedIndicatorPainter(super.series);

  final Paint _linePaint = Paint()
    ..strokeWidth = 1
    ..style = PaintingStyle.stroke;

  final Paint _linePaintFill = Paint()
    ..strokeWidth = 1
    ..style = PaintingStyle.fill;

  final Paint _rectPaint = Paint()..style = PaintingStyle.fill;

  /// Padding between lines.
  static const double padding = 4;

  /// Padding between tick and text.
  static const double tickTextPadding = 12;

  /// Right margin.
  static const double rightMargin = 4;

  @override
  void onPaint({
    required Canvas canvas,
    required Size size,
    required EpochToX epochToX,
    required QuoteToY quoteToY,
    required AnimationInfo animationInfo,
    required ChartScaleModel chartScaleModel,
  }) {
    final HorizontalBarrierStyle style =
        series.style as HorizontalBarrierStyle? ?? theme.horizontalBarrierStyle;

    // Change the barrier color based on the contract status and tick quote.
    Color color = theme.base03Color;
    if (series.activeContract?.profit != null) {
      if (series.activeContract!.profit! > 0) {
        color = theme.accentGreenColor;
      } else if (series.activeContract!.profit! < 0) {
        color = theme.accentRedColor;
      }
    }

    if (series.exitTick.quote > series.highBarrier ||
        series.exitTick.quote < series.lowBarrier) {
      color = theme.accentRedColor;
    }
    _linePaint.color = color;
    _linePaintFill.color = color;
    _rectPaint.color = color.withOpacity(0.08);

    final AccumulatorsClosedIndicator indicator = series;

    final double barrierX = epochToX(indicator.barrierEpoch);
    final double hBarrierQuote = indicator.highBarrier;
    final double lBarrierQuote = indicator.lowBarrier;

    final Offset highBarrierPosition = Offset(
      barrierX,
      quoteToY(hBarrierQuote),
    );

    final Offset lowBarrierPosition = Offset(
      barrierX,
      quoteToY(lBarrierQuote),
    );

    final Offset exitTickPosition = Offset(
      epochToX(indicator.exitTick.epoch),
      quoteToY(indicator.exitTick.quote),
    );

    // draw the transparent color.
    final Rect rect = Rect.fromPoints(
      highBarrierPosition,
      Offset(size.width, lowBarrierPosition.dy),
    );
    canvas.drawRect(rect, _rectPaint);

    // Barriers and barriers value labels.
    final TextPainter highBarrierLabelPainter = makeTextPainter(
      indicator.highBarrierDisplay,
      style.textStyle.copyWith(
        color: Colors.white,
      ),
    );

    final TextPainter lowBarrierLabelPainter = makeTextPainter(
      indicator.lowBarrierDisplay,
      style.textStyle.copyWith(
        color: Colors.white,
      ),
    );

    final Offset highBarrierLabelAnchor = Offset(
        size.width - (highBarrierLabelPainter.width / 2) - 2 * padding,
        highBarrierPosition.dy);

    final Offset lowBarrierLabelAnchor = Offset(
        size.width - (lowBarrierLabelPainter.width / 2) - 2 * padding,
        lowBarrierPosition.dy);

    final double barrierEndX = highBarrierLabelAnchor.dx;

    const int triangleEdge = 4;
    const int triangleHeight = 5;

    final Path upperTrianglePath = Path()
      ..moveTo(
        highBarrierPosition.dx,
        highBarrierPosition.dy,
      )
      ..lineTo(
        highBarrierPosition.dx + triangleEdge,
        highBarrierPosition.dy,
      )
      ..lineTo(
        highBarrierPosition.dx,
        highBarrierPosition.dy + triangleHeight,
      )
      ..lineTo(
        highBarrierPosition.dx + -triangleEdge,
        highBarrierPosition.dy,
      )
      ..close();

    final Path lowerTrianglePath = Path()
      ..moveTo(
        lowBarrierPosition.dx,
        lowBarrierPosition.dy,
      )
      ..lineTo(
        lowBarrierPosition.dx + triangleEdge,
        lowBarrierPosition.dy,
      )
      ..lineTo(
        lowBarrierPosition.dx,
        lowBarrierPosition.dy - triangleHeight,
      )
      ..lineTo(
        lowBarrierPosition.dx + -triangleEdge,
        lowBarrierPosition.dy,
      )
      ..close();

    canvas
      ..drawLine(
        lowBarrierPosition,
        Offset(barrierEndX, lowBarrierPosition.dy),
        _linePaint,
      )
      ..drawLine(
        highBarrierPosition,
        Offset(barrierEndX, highBarrierPosition.dy),
        _linePaint,
      )
      ..drawPath(upperTrianglePath, _linePaint)
      ..drawPath(lowerTrianglePath, _linePaint)
      ..drawPath(upperTrianglePath, _linePaintFill)
      ..drawPath(lowerTrianglePath, _linePaintFill);

    final Rect highBarrierLabelRect = Rect.fromCenter(
      center: highBarrierLabelAnchor,
      height: highBarrierLabelPainter.height + padding * 2,
      width: highBarrierLabelPainter.width + padding * 2,
    );

    final Rect lowBarrierLabelRect = Rect.fromCenter(
      center: lowBarrierLabelAnchor,
      height: lowBarrierLabelPainter.height + padding * 2,
      width: lowBarrierLabelPainter.width + padding * 2,
    );
    late RRect rRect;
    rRect =
        RRect.fromRectAndRadius(highBarrierLabelRect, const Radius.circular(4));
    canvas.drawRRect(rRect, _linePaintFill);
    rRect =
        RRect.fromRectAndRadius(lowBarrierLabelRect, const Radius.circular(4));
    canvas.drawRRect(rRect, _linePaintFill);

    paintWithTextPainter(canvas,
        painter: highBarrierLabelPainter, anchor: highBarrierLabelAnchor);

    paintWithTextPainter(canvas,
        painter: lowBarrierLabelPainter, anchor: lowBarrierLabelAnchor);

    // Draw exit tick position.
    paintDotWithGlow(canvas, exitTickPosition, color: color);
  }
}
