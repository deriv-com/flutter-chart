import 'dart:ui';

import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/logic/chart_data.dart';
import 'package:deriv_chart/src/logic/chart_series/series_painter.dart';
import 'package:deriv_chart/src/models/animation_info.dart';
import 'package:deriv_chart/src/models/barrier_objects.dart';
import 'package:deriv_chart/src/paint/paint_dot.dart';
import 'package:deriv_chart/src/paint/create_shape_path.dart';
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
    BarrierArrowType arrowType = BarrierArrowType.none;

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

      if (series.epoch != null && series.previousObject.leftEpoch != null) {
        dotX = lerpDouble(
          epochToX(series.previousObject.leftEpoch),
          epochToX(series.epoch),
          animationInfo.currentTickPercent,
        );
      }
    }

    double y = quoteToY(animatedValue);

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

    final double labelHalfHeight = valuePainter.height / 2 + padding;

    if (series.visibility == HorizontalBarrierVisibility.alwaysVisible) {
      if (y - labelHalfHeight < 0) {
        y = labelHalfHeight;
        arrowType = BarrierArrowType.upward;
      } else if (y + labelHalfHeight > size.height) {
        y = size.height - labelHalfHeight;
        arrowType = BarrierArrowType.downward;
      }
    }

    _paintLabelBackground(canvas, size, middleLineEndX, y, valuePainter, style);

    if (arrowType != BarrierArrowType.none) {
      final double labelMidX = valueStartX + valuePainter.width / 2;
      double arrowY;

      if (arrowType == BarrierArrowType.upward) {
        arrowY = y - labelHalfHeight - 3;
        _paintUpwardArrows(canvas, labelMidX, arrowY);
      } else if (arrowType == BarrierArrowType.downward) {
        arrowY = y + labelHalfHeight + 3;
        _paintDownwardArrows(canvas, labelMidX, arrowY);
      }
    }

    valuePainter.paint(
      canvas,
      Offset(valueStartX, y - valuePainter.height / 2),
    );

    final TextPainter titlePainter = TextPainter(
      text: TextSpan(
        text: series.title,
        style: style.textStyle.copyWith(
          color: style.color,
          backgroundColor: style.titleBackgroundColor,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout();

    final double titleStartX = middleLineStartX - titlePainter.width - padding;

    titlePainter.paint(
      canvas,
      Offset(titleStartX, y - valuePainter.height / 2),
    );

    if (arrowType != BarrierArrowType.none) {
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

    if (dotX != null) {
      if (style.hasBlinkingDot) {
        _paintBlinkingDot(canvas, dotX, y, animationInfo);
      }

      if (!series.longLine) {
        mainLineStartX = dotX;
      }
    }

    _paintMainLine(canvas, mainLineStartX, mainLineEndX, y, style);
  }

  void _paintLabelBackground(
    Canvas canvas,
    Size size,
    double middleLineEndX,
    double y,
    TextPainter valuePainter,
    HorizontalBarrierStyle style,
  ) {
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
        _paint,
      );
    }
  }

  void _paintBlinkingDot(
    Canvas canvas,
    double dotX,
    double y,
    AnimationInfo animationInfo,
  ) {
    paintIntersectionDot(canvas, Offset(dotX, y), Colors.redAccent);

    paintBlinkingDot(
      canvas,
      Offset(dotX, y),
      animationInfo.blinkingPercent,
      Colors.redAccent,
    );
  }

  void _paintMainLine(
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
          getUpwardArrowPath(
            middleX,
            middleY,
            size: arrowSize,
            thickness: arrowThickness,
          ),
          arrowPaint)
      ..drawPath(
        getUpwardArrowPath(
          middleX,
          middleY - arrowSize,
          size: arrowSize,
          thickness: arrowThickness,
        ),
        arrowPaint..color = _paint.color.withOpacity(0.64),
      )
      ..drawPath(
        getUpwardArrowPath(
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
          getDownArrowPath(
            middleX,
            middleY,
            size: arrowSize,
            thickness: arrowThickness,
          ),
          arrowPaint)
      ..drawPath(
          getDownArrowPath(
            middleX,
            middleY + arrowSize,
            size: arrowSize,
            thickness: arrowThickness,
          ),
          arrowPaint..color = _paint.color.withOpacity(0.64))
      ..drawPath(
          getDownArrowPath(
            middleX,
            middleY + 2 * arrowSize,
            size: arrowSize,
            thickness: arrowThickness,
          ),
          arrowPaint..color = _paint.color.withOpacity(0.32));
  }
}
