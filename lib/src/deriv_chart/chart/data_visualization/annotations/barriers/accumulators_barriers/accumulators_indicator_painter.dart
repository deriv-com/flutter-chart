import 'dart:ui' as ui;

import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/annotations/barriers/accumulators_barriers/accumulators_indicator.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/annotations/barriers/horizontal_barrier/horizontal_barrier.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_data.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/series_painter.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/models/accumulator_object.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/models/animation_info.dart';
import 'package:deriv_chart/src/deriv_chart/chart/helpers/paint_functions/create_shape_path.dart';
import 'package:deriv_chart/src/deriv_chart/chart/helpers/paint_functions/paint_dot.dart';
import 'package:deriv_chart/src/deriv_chart/chart/helpers/paint_functions/paint_line.dart';
import 'package:deriv_chart/src/deriv_chart/chart/helpers/paint_functions/paint_text.dart';
import 'package:deriv_chart/src/theme/painting_styles/barrier_style.dart';
import 'package:flutter/material.dart';

/// Accumulator barriers painter.
class AccumulatorIndicatorPainter extends SeriesPainter<AccumulatorIndicator> {
  /// Initializes [AccumulatorIndicatorPainter].
  AccumulatorIndicatorPainter(super.series);

  /// Initializes [AccumulatorIndicatorPainter].

  final Paint _linePaint = Paint()
    ..strokeWidth = 1
    ..style = PaintingStyle.stroke;

  final Paint _linePaintFill = Paint()
    ..strokeWidth = 1
    ..style = PaintingStyle.fill;

  final Paint _rectPaint = Paint()..style = PaintingStyle.fill;

  late Paint _paint;

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

    _paint = Paint()
      ..strokeWidth = 1
      ..color = style.color;

    BarrierArrowType arrowType = BarrierArrowType.none;

    // Change the barrier color based on the contract status and tick quote.
    Color color = theme.base03Color;
    if (series.activeContract?.profit != null) {
      if (series.activeContract!.profit! > 0) {
        color = theme.accentGreenColor;
      } else if (series.activeContract!.profit! < 0) {
        color = theme.accentRedColor;
      }
    }

    if (series.tick.quote > series.highBarrier ||
        series.tick.quote < series.lowBarrier) {
      color = theme.accentRedColor;
    }
    _linePaint.color = color;
    _linePaintFill.color = color;
    _rectPaint.color = color.withValues(alpha: 0.08);

    final AccumulatorIndicator indicator = series;

    double barrierX = epochToX(indicator.barrierEpoch);
    double hBarrierQuote = indicator.highBarrier;
    double lBarrierQuote = indicator.lowBarrier;

    double tickX = epochToX(indicator.tick.epoch);
    double tickQuote = indicator.tick.quote;

    double? animatedProfit = indicator.activeContract?.profit;

    if (indicator.previousObject != null) {
      final AccumulatorObject? previousIndicator = indicator.previousObject;

      barrierX = ui.lerpDouble(
            epochToX(previousIndicator!.barrierEpoch),
            epochToX(indicator.barrierEpoch),
            animationInfo.currentTickPercent,
          ) ??
          barrierX;

      hBarrierQuote = ui.lerpDouble(
            previousIndicator.highBarrier,
            indicator.highBarrier,
            animationInfo.currentTickPercent,
          ) ??
          hBarrierQuote;

      lBarrierQuote = ui.lerpDouble(
            previousIndicator.lowBarrier,
            indicator.lowBarrier,
            animationInfo.currentTickPercent,
          ) ??
          lBarrierQuote;

      tickX = ui.lerpDouble(
            epochToX(previousIndicator.tick.epoch),
            epochToX(indicator.tick.epoch),
            animationInfo.currentTickPercent,
          ) ??
          tickX;

      tickQuote = ui.lerpDouble(
            previousIndicator.tick.quote,
            indicator.tick.quote,
            animationInfo.currentTickPercent,
          ) ??
          tickQuote;

      if (indicator.activeContract?.profit != null &&
          previousIndicator.profit != null) {
        animatedProfit = ui.lerpDouble(
              previousIndicator.profit,
              indicator.activeContract?.profit!,
              animationInfo.currentTickPercent,
            ) ??
            animatedProfit;
      }
    }

    final Offset highBarrierPosition = Offset(
      barrierX,
      quoteToY(hBarrierQuote),
    );

    final Offset lowBarrierPosition = Offset(
      barrierX,
      quoteToY(lBarrierQuote),
    );

    final Offset tickPosition = Offset(
      tickX,
      quoteToY(tickQuote),
    );

    final TextPainter valuePainter = makeTextPainter(
      tickQuote.toStringAsFixed(chartConfig.pipSize),
      style.textStyle,
    );

    Offset labelCenterPosition = Offset(
        size.width - rightMargin - padding - valuePainter.width / 2,
        tickPosition.dy);

    final Rect labelArea = Rect.fromCenter(
      center: labelCenterPosition,
      width: valuePainter.width + padding * 2,
      height: style.labelHeight,
    );

    if (series.labelVisibility ==
        HorizontalBarrierVisibility.keepBarrierLabelVisible) {
      final double labelHalfHeight = style.labelHeight / 2;

      if (labelCenterPosition.dy - labelHalfHeight < 0) {
        labelCenterPosition = Offset(labelCenterPosition.dx, labelHalfHeight);
        arrowType = BarrierArrowType.upward;
      } else if (labelCenterPosition.dy + labelHalfHeight > size.height) {
        labelCenterPosition =
            Offset(labelCenterPosition.dx, size.height - labelHalfHeight);
        arrowType = BarrierArrowType.downward;
      }
    }

    // draw the transparent color.
    final Rect rect = Rect.fromPoints(
        highBarrierPosition, Offset(size.width, lowBarrierPosition.dy));
    canvas.drawRect(rect, _rectPaint);

    // Arrows.
    if (style.hasArrow) {
      final double arrowMidX = labelArea.left - style.arrowSize - 6;
      if (arrowType == BarrierArrowType.upward) {
        _paintUpwardArrows(
          canvas,
          center: Offset(arrowMidX, tickPosition.dy),
          arrowSize: style.arrowSize,
        );
      } else if (arrowType == BarrierArrowType.downward) {
        // TODO(Anonymous): Rotate arrows like in `paintMarker` instead of
        // defining two identical paths only different in rotation.
        _paintDownwardArrows(
          canvas,
          center: Offset(arrowMidX, tickPosition.dy),
          arrowSize: style.arrowSize,
        );
      }
    }

    // Line.
    if (arrowType == BarrierArrowType.none) {
      final double lineStartX = tickPosition.dx;
      final double lineEndX = labelArea.left;

      // To erase the line behind profit.
      if (animatedProfit != null && animatedProfit != 0) {
        canvas.saveLayer(
          Rect.fromLTRB(
              lineStartX, tickPosition.dy - 1, lineEndX, tickPosition.dy + 1),
          Paint(),
        );
      }
      if (lineStartX < lineEndX && style.hasLine) {
        _paintLine(canvas, lineStartX, lineEndX, tickPosition.dy, style);
      }
    }

    // profit
    if (animatedProfit != null && animatedProfit != 0) {
      final TextPainter profitPainter = makeTextPainter(
        '${animatedProfit < 0 ? '' : '+'}${animatedProfit.toStringAsFixed(
          indicator.activeContract!.fractionalDigits,
        )}',
        style.textStyle.copyWith(color: color, fontSize: 26),
      );

      final TextPainter currencyPainter = makeTextPainter(
        indicator.activeContract?.profitUnit ?? '',
        style.textStyle.copyWith(color: color, fontSize: 14),
      );

      final double textWidth =
          profitPainter.width + currencyPainter.width + padding;
      final double availableWidth = labelArea.left - tickPosition.dx;
      late final double textStartX;
      if (textWidth + tickTextPadding > availableWidth) {
        textStartX = tickPosition.dx + tickTextPadding;
      } else {
        textStartX = tickPosition.dx + (availableWidth / 2) - (textWidth / 2);
      }
      final Offset profitPosition =
          Offset(textStartX + profitPainter.width / 2, tickPosition.dy);

      final Offset currencyPosition = Offset(
          textStartX +
              profitPainter.width +
              currencyPainter.width / 2 +
              padding,
          tickPosition.dy);

      final Rect profitArea = Rect.fromCenter(
        center: Offset(textStartX + textWidth / 2, tickPosition.dy),
        width: textWidth + padding * 2,
        height: style.labelHeight,
      );

      // Erase the line behind title.
      if (arrowType == BarrierArrowType.none) {
        canvas
          ..drawRect(profitArea, Paint()..blendMode = BlendMode.clear)
          ..restore();
      }
      paintWithTextPainter(
        canvas,
        painter: profitPainter,
        anchor: profitPosition,
      );

      paintWithTextPainter(
        canvas,
        painter: currencyPainter,
        anchor: currencyPosition,
      );
    }

    // Blinking dot.
    if (style.hasBlinkingDot) {
      paintBlinkingDot(canvas, tickPosition.dx, tickPosition.dy, animationInfo,
          style.blinkingDotColor);
    }

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
        Offset(size.width, lowBarrierPosition.dy),
        _linePaint,
      )
      ..drawLine(
        highBarrierPosition,
        Offset(size.width, highBarrierPosition.dy),
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

    // Label.
    paintLabelBackground(canvas, labelArea, style.labelShape, _paint);
    paintWithTextPainter(
      canvas,
      painter: valuePainter,
      anchor: labelArea.center,
    );
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

  /// Paints a background based on the given [LabelShape] for the label text.
  void paintLabelBackground(
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

  void _paintUpwardArrows(
    Canvas canvas, {
    required Offset center,
    required double arrowSize,
  }) {
    final Paint arrowPaint = Paint()
      ..color = _paint.color
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas
      ..drawPath(
          getUpwardArrowPath(
            center.dx,
            center.dy + arrowSize - 1,
            size: arrowSize,
          ),
          arrowPaint)
      ..drawPath(
          getUpwardArrowPath(
            center.dx,
            center.dy,
            size: arrowSize,
          ),
          arrowPaint..color = _paint.color.withValues(alpha: 0.64))
      ..drawPath(
          getUpwardArrowPath(
            center.dx,
            center.dy - arrowSize + 1,
            size: arrowSize,
          ),
          arrowPaint..color = _paint.color.withValues(alpha: 0.32));
  }

  void _paintDownwardArrows(
    Canvas canvas, {
    required Offset center,
    required double arrowSize,
  }) {
    final Paint arrowPaint = Paint()
      ..color = _paint.color
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas
      ..drawPath(
          getDownwardArrowPath(
            center.dx,
            center.dy - arrowSize + 1,
            size: arrowSize,
          ),
          arrowPaint)
      ..drawPath(
          getDownwardArrowPath(
            center.dx,
            center.dy,
            size: arrowSize,
          ),
          arrowPaint..color = _paint.color.withValues(alpha: 0.64))
      ..drawPath(
          getDownwardArrowPath(
            center.dx,
            center.dy + arrowSize - 1,
            size: arrowSize,
          ),
          arrowPaint..color = _paint.color.withValues(alpha: 0.32));
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
}
