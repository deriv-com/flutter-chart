import 'dart:ui';

import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/logic/chart_data.dart';
import 'package:deriv_chart/src/logic/chart_series/series_painter.dart';
import 'package:deriv_chart/src/models/animation_info.dart';
import 'package:deriv_chart/src/models/barrier_objects.dart';
import 'package:deriv_chart/src/paint/paint_current_tick_dot.dart';
import 'package:deriv_chart/src/paint/paint_current_tick_label.dart';
import 'package:deriv_chart/src/paint/paint_line.dart';
import 'package:deriv_chart/src/theme/painting_styles/barrier_style.dart';
import 'package:flutter/material.dart';

import 'horizontal_barrier.dart';

/// Padding between lines
const double padding = 5;

/// Right margin
const double rightMargin = 5;

/// A class for painting horizontal barriers
class HorizontalBarrierPainter extends SeriesPainter<HorizontalBarrier> {
  /// Initializes [series]
  HorizontalBarrierPainter(HorizontalBarrier series)
      : _paint = Paint()..strokeWidth = 1,
        super(series);

  final Paint _paint;

  @override
  void onPaint({
    Canvas canvas,
    Size size,
    EpochToX epochToX,
    QuoteToY quoteToY,
    AnimationInfo animationInfo,
  }) {
    if (!series.isOnRange) {
      return;
    }

    final HorizontalBarrierStyle style = series.style;

    _paint.color = style.color;

    double animatedValue;

    double dotX;

    if (series.previousObject == null) {
      animatedValue = series.value;
      if (series.epoch != null) {
        dotX = epochToX(series.epoch);
      }
    } else {
      final BarrierObject previousBarrier = series.previousObject;
      animatedValue = lerpDouble(
        previousBarrier.value,
        series.value,
        animationInfo.currentTickPercent,
      );

      if (series.epoch != null && series.previousObject.epoch != null) {
        dotX = lerpDouble(
          epochToX(series.previousObject.epoch),
          epochToX(series.epoch),
          animationInfo.currentTickPercent,
        );
      }
    }

    final double y = quoteToY(animatedValue);

    final TextPainter valuePainter = TextPainter(
      text: TextSpan(
        text: animatedValue.toStringAsFixed(pipSize),
        style: style.textStyle,
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout();

    final double valueStartX =
        size.width - rightMargin - padding - valuePainter.width;
    final double middleLineEndX = valueStartX - padding;
    final double middleLineStartX = middleLineEndX - 12;

    if (style.labelShape == LabelShape.rectangle) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTRB(
              middleLineEndX,
              y - valuePainter.height / 2 - padding,
              size.width - rightMargin,
              y + valuePainter.height / 2 + padding,
            ),
            const Radius.circular(4)),
        _paint,
      );
    } else if (style.labelShape == LabelShape.pentagon) {
      canvas.drawPath(
        getCurrentTickLabelBackgroundPath(
          left: middleLineEndX,
          top: y - valuePainter.height / 2 - padding,
          right: size.width - rightMargin,
          bottom: y + valuePainter.height / 2 + padding,
        ),
        Paint()..color = style.color,
      );
    }

    if (style.arrowType == BarrierArrowType.upward) {
      _paintUpwardArrows(
        canvas,
        valueStartX + valuePainter.width / 2,
        y - valuePainter.height / 2 - padding - 3,
      );
    } else if (style.arrowType == BarrierArrowType.downward) {
      _paintDownwardArrows(
        canvas,
        valueStartX + valuePainter.width / 2,
        y + valuePainter.height / 2 + padding + 3,
      );
    }

    valuePainter.paint(
      canvas,
      Offset(valueStartX, y - valuePainter.height / 2),
    );

    final TextPainter titlePainter = TextPainter(
      text: TextSpan(
        text: series.title,
        style: style.textStyle.copyWith(color: style.color),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout();

    final double titleStartX = middleLineStartX - titlePainter.width - padding;

    titlePainter.paint(
      canvas,
      Offset(titleStartX, y - valuePainter.height / 2),
    );

    if (!style.hasLine) {
      return;
    }

    double mainLineEndX;
    double mainLineStartX = 0;

    if (series.title != null) {
      mainLineEndX = titleStartX - padding;

      // Painting right line
      canvas.drawLine(
        Offset(middleLineStartX, y),
        Offset(middleLineEndX, y),
        _paint,
      );
    } else {
      mainLineEndX = valueStartX;
    }

    if (style.intersectionDotStyle != null && dotX != null) {
      paintIntersectionDot(canvas, dotX, y, style.intersectionDotStyle);

      if (style.intersectionDotStyle.blinking) {
        paintBlinkingDot(
          canvas,
          center: Offset(dotX, y),
          animationProgress: animationInfo.blinkingPercent,
          style: style.intersectionDotStyle,
        );
      }

      if (!series.longLine) {
        mainLineStartX = dotX;
      }
    }

    // Painting main line
    if (style.isDashed) {
      paintHorizontalDashedLine(
          canvas, mainLineStartX, mainLineEndX, y, style.color, 1);
    } else {
      canvas.drawLine(
          Offset(mainLineStartX, y), Offset(mainLineEndX, y), _paint);
    }
  }

  Path _getUpwardArrowPath(
    double middleX,
    double middleY, {
    double thickness = 4,
    double size = 10,
  }) {
    final double halfSize = size / 2;
    final double halfThickness = thickness / 2;

    return Path()
      ..moveTo(middleX, middleY)
      ..lineTo(middleX + halfSize, middleY + halfSize)
      ..quadraticBezierTo(
        middleX + halfSize + halfThickness,
        middleY + halfSize,
        middleX + halfSize + halfThickness,
        middleY + halfSize - halfThickness,
      )
      ..lineTo(middleX + halfThickness, middleY - halfThickness)
      ..quadraticBezierTo(
        middleX,
        middleY - thickness,
        middleX - halfThickness,
        middleY - halfThickness,
      )
      ..lineTo(
        middleX - halfSize - halfThickness,
        middleY + halfSize - halfThickness,
      )
      ..quadraticBezierTo(
        middleX - halfSize - halfThickness,
        middleY + halfSize,
        middleX - halfSize,
        middleY + halfSize,
      );
  }

  Path _getDownArrowPath(
    double middleX,
    double middleY, {
    double thickness = 4,
    double size = 10,
  }) {
    final double halfSize = size / 2;
    final double halfThickness = thickness / 2;

    return Path()
      ..moveTo(middleX, middleY)
      ..lineTo(middleX + halfSize, middleY - halfSize)
      ..quadraticBezierTo(
        middleX + halfSize + halfThickness,
        middleY - halfSize,
        middleX + halfSize + halfThickness,
        middleY - halfSize + halfThickness,
      )
      ..lineTo(middleX + halfThickness, middleY + halfThickness)
      ..quadraticBezierTo(
        middleX,
        middleY + thickness,
        middleX - halfThickness,
        middleY + halfThickness,
      )
      ..lineTo(
        middleX - halfSize - halfThickness,
        middleY - halfSize + halfThickness,
      )
      ..quadraticBezierTo(
        middleX - halfSize - halfThickness,
        middleY - halfSize,
        middleX - halfSize,
        middleY - halfSize,
      );
  }

  void _paintUpwardArrows(
    Canvas canvas,
    double middleX,
    double bottomY, {
    double arrowSize = 10,
    double arrowThickness = 4,
  }) {
    final Paint arrowPaint = Paint()..color = _paint.color;
    final double middleY = bottomY - arrowSize + arrowThickness;

    canvas
      ..drawPath(
          _getUpwardArrowPath(
            middleX,
            middleY,
            size: arrowSize,
            thickness: arrowThickness,
          ),
          arrowPaint)
      ..drawPath(
        _getUpwardArrowPath(
          middleX,
          middleY - arrowSize,
          size: arrowSize,
          thickness: arrowThickness,
        ),
        arrowPaint..color = _paint.color.withOpacity(0.64),
      )
      ..drawPath(
        _getUpwardArrowPath(
          middleX,
          middleY - 2 * arrowSize,
          size: arrowSize,
          thickness: arrowThickness,
        ),
        arrowPaint..color = _paint.color.withOpacity(0.32),
      );
  }

  void _paintDownwardArrows(
    Canvas canvas,
    double middleX,
    double topY, {
    double arrowSize = 10,
    double arrowThickness = 4,
  }) {
    final Paint arrowPaint = Paint()..color = _paint.color;
    final double middleY = topY + arrowSize - arrowThickness;

    canvas
      ..drawPath(
          _getDownArrowPath(
            middleX,
            middleY,
            size: arrowSize,
            thickness: arrowThickness,
          ),
          arrowPaint)
      ..drawPath(
          _getDownArrowPath(
            middleX,
            middleY + arrowSize,
            size: arrowSize,
            thickness: arrowThickness,
          ),
          arrowPaint..color = _paint.color.withOpacity(0.64))
      ..drawPath(
          _getDownArrowPath(
            middleX,
            middleY + 2 * arrowSize,
            size: arrowSize,
            thickness: arrowThickness,
          ),
          arrowPaint..color = _paint.color.withOpacity(0.32));
  }
}
