import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/annotations/barriers/accumulators_barriers/accumulators_recently_closed_indicator.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_data.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/series_painter.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/models/animation_info.dart';
import 'package:deriv_chart/src/deriv_chart/chart/helpers/paint_functions/paint_dot.dart';
import 'package:deriv_chart/src/deriv_chart/chart/helpers/paint_functions/paint_text.dart';
import 'package:deriv_chart/src/theme/painting_styles/barrier_style.dart';
import 'package:flutter/material.dart';

/// Accumulator barriers painter.
class AccumulatorsRecentlyClosedIndicatorPainter
    extends SeriesPainter<AccumulatorsRecentlyClosedIndicator> {
  /// Initializes [AccumulatorsRecentlyClosedIndicatorPainter].
  AccumulatorsRecentlyClosedIndicatorPainter(super.series);

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

    final AccumulatorsRecentlyClosedIndicator indicator = series;

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
      Offset(epochToX(series.barrierEndEpoch), lowBarrierPosition.dy),
    );
    canvas.drawRect(rect, _rectPaint);

    final double barrierEndX = epochToX(series.barrierEndEpoch);

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

    // Draw exit tick position.
    paintDotWithGlow(canvas, exitTickPosition, color: color);

    // draw dialog
    const double dotPadding = 5;
    const int dialogTriangleEdge = 6;
    const int dialogTriangleHeight = 4;

    final Path dialogTrianglePath = Path()
      ..moveTo(
        exitTickPosition.dx - dotPadding,
        exitTickPosition.dy,
      )
      ..lineTo(
        exitTickPosition.dx - dotPadding - dialogTriangleHeight,
        exitTickPosition.dy - dialogTriangleEdge / 2,
      )
      ..lineTo(
        exitTickPosition.dx - dotPadding - dialogTriangleHeight,
        exitTickPosition.dy + dialogTriangleEdge / 2,
      )
      ..lineTo(
        exitTickPosition.dx - dotPadding,
        exitTickPosition.dy,
      )
      ..close();

    canvas
      ..drawPath(dialogTrianglePath, _linePaintFill)
      ..drawPath(dialogTrianglePath, _linePaint);

    if (indicator.activeContract?.profit != null) {
      final double profit = indicator.activeContract!.profit!;
      final String profitText =
          '${profit < 0 ? '' : '+'}${profit.toStringAsFixed(
        indicator.activeContract!.fractionalDigits,
      )}';
      final String currencyText =
          '${indicator.activeContract?.profitUnit ?? ''}';
      final TextPainter profitPainter = makeTextPainter(
        '$profitText $currencyText',
        style.textStyle.copyWith(
            color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
      );

      final TextPainter winLossPainter = makeTextPainter(
        indicator.activeContract!.profit! > 0 ? 'Won:' : 'Loss:',
        style.textStyle.copyWith(
            color: Colors.white, fontSize: 10, fontWeight: FontWeight.w400),
      );

      final double textHeight = profitPainter.height + winLossPainter.height;
      final double textWidth = profitPainter.width;

      final double dialogRightSide =
          exitTickPosition.dx - dotPadding - dialogTriangleHeight - padding;
      final double dialogLeftSide = dialogRightSide - textWidth;

      final double dialogDownSide = exitTickPosition.dy + textHeight / 2;
      final double dialogUpSide = exitTickPosition.dy - textHeight / 2;

      final Rect dialogRect = Rect.fromLTRB(
        dialogLeftSide - padding,
        dialogUpSide - padding,
        dialogRightSide + padding,
        dialogDownSide + padding,
      );
      final RRect rRect =
          RRect.fromRectAndRadius(dialogRect, const Radius.circular(4));

      _rectPaint.color = color.withOpacity(1);
      canvas.drawRRect(rRect, _rectPaint);

      final Offset winLossPosition = Offset(
        dialogLeftSide + winLossPainter.width / 2,
        exitTickPosition.dy - textHeight / 2 + winLossPainter.height / 2,
      );

      paintWithTextPainter(
        canvas,
        painter: winLossPainter,
        anchor: winLossPosition,
      );

      final Offset profitPosition = Offset(
        dialogLeftSide + profitPainter.width / 2,
        exitTickPosition.dy -
            textHeight / 2 +
            profitPainter.height / 2 +
            winLossPainter.height,
      );

      paintWithTextPainter(
        canvas,
        painter: profitPainter,
        anchor: profitPosition,
      );
    }
  }
}
