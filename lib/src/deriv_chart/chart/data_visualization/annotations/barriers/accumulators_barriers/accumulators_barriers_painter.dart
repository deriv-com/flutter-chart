import 'dart:ui' as ui;

import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_data.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/series_painter.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/models/accumulator_object.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/models/animation_info.dart';
import 'package:deriv_chart/src/deriv_chart/chart/helpers/paint_functions/paint_dot.dart';
import 'package:deriv_chart/src/deriv_chart/chart/helpers/paint_functions/paint_text.dart';
import 'package:flutter/material.dart';

/// Accumulator barriers painter.
class AccumulatorBarriersPainter extends SeriesPainter<AccumulatorIndicator> {
  /// Initializes [AccumulatorBarriersPainter].
  AccumulatorBarriersPainter(super.series);

  /// Initializes [AccumulatorBarriersPainter].

  final Paint _linePaint = Paint()
    ..strokeWidth = 1
    ..color = Colors.grey
    ..style = PaintingStyle.stroke;

  final Paint _linePaintFill = Paint()
    ..strokeWidth = 1
    ..color = Colors.grey
    ..style = PaintingStyle.fill;

  final Paint _rectPaint = Paint()
    ..color =
        Colors.grey.withOpacity(0.08) // Set the alpha value for transparency
    ..style = PaintingStyle.fill;

  @override
  void onPaint({
    required Canvas canvas,
    required Size size,
    required EpochToX epochToX,
    required QuoteToY quoteToY,
    required AnimationInfo animationInfo,
  }) {
    // Change the barrier color based on the contract status and tick quote.

    Color color = theme.base03Color;
    if (series.activeContract != null) {
      color = theme.accentGreenColor;
    }

    if (series.tick.quote > series.highBarrier ||
        series.tick.quote < series.lowBarrier) {
      color = theme.accentRedColor;
    }
    _linePaint.color = color;
    _linePaintFill.color = color;
    _rectPaint.color = color.withOpacity(0.08);

    final AccumulatorIndicator indicator = series;

    double barrierX = epochToX(indicator.barrierEpoch);
    double hBarrierY = indicator.highBarrier;
    double lBarrierY = indicator.lowBarrier;

    if (indicator.previousObject != null) {
      final AccumulatorObject? previousIndicator = indicator.previousObject;

      barrierX = ui.lerpDouble(
            epochToX(previousIndicator!.barrierEpoch),
            epochToX(indicator.barrierEpoch),
            animationInfo.currentTickPercent,
          ) ??
          barrierX;

      hBarrierY = ui.lerpDouble(
            previousIndicator.highBarrier,
            indicator.highBarrier,
            animationInfo.currentTickPercent,
          ) ??
          hBarrierY;

      lBarrierY = ui.lerpDouble(
            previousIndicator.lowBarrier,
            indicator.lowBarrier,
            animationInfo.currentTickPercent,
          ) ??
          lBarrierY;
    }
    final Offset highBarrierPosition = Offset(
      barrierX,
      quoteToY(hBarrierY),
    );

    final Offset lowBarrierPosition = Offset(
      barrierX,
      quoteToY(lBarrierY),
    );

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

    final double endX = size.width;

    canvas
      ..drawLine(
        lowBarrierPosition,
        Offset(endX, lowBarrierPosition.dy),
        _linePaint,
      )
      ..drawLine(
        highBarrierPosition,
        Offset(endX, highBarrierPosition.dy),
        _linePaint,
      );

    if (indicator.tick.epoch != indicator.barrierEpoch) {
      _paintBlinkingGlow(
        canvas,
        epochToX(indicator.barrierEpoch),
        quoteToY(indicator.lowBarrier +
            ((indicator.highBarrier - indicator.lowBarrier) / 2)),
        animationInfo,
        Colors.grey,
      );
    }

    canvas
      ..drawPath(upperTrianglePath, _linePaint)
      ..drawPath(lowerTrianglePath, _linePaint)
      ..drawPath(upperTrianglePath, _linePaintFill)
      ..drawPath(lowerTrianglePath, _linePaintFill);

    paintText(
      canvas,
      text: '-${indicator.barrierSpotDistance}',
      anchor: lowBarrierPosition + const Offset(30, 10),
      style: TextStyle(color: color, fontSize: 12),
    );

    paintText(
      canvas,
      text: '+${indicator.barrierSpotDistance}',
      anchor: highBarrierPosition + const Offset(30, -10),
      style: TextStyle(color: color, fontSize: 12),
    );

    final Rect rect = Rect.fromPoints(
        highBarrierPosition, Offset(size.width, lowBarrierPosition.dy));
    canvas.drawRect(rect, _rectPaint);
  }

  void _paintBlinkingGlow(
    Canvas canvas,
    double dotX,
    double y,
    AnimationInfo animationInfo,
    Color color,
  ) {
    paintBlinkingGlow(
      canvas,
      Offset(dotX, y),
      animationInfo.blinkingPercent,
      color,
    );
    paintBlinkingGlow(
      canvas,
      Offset(dotX, y),
      animationInfo.blinkingPercent,
      color,
      fullSize: 6,
    );
  }
}
