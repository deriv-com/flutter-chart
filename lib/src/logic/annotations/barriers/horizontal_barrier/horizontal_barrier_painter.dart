import 'dart:ui';

import 'package:deriv_chart/src/logic/chart_data.dart';
import 'package:deriv_chart/src/logic/chart_series/series_painter.dart';
import 'package:deriv_chart/src/models/animation_info.dart';
import 'package:deriv_chart/src/models/barrier_objects.dart';
import 'package:deriv_chart/src/paint/paint_dot.dart';
import 'package:deriv_chart/src/paint/create_shape_path.dart';
import 'package:deriv_chart/src/paint/paint_line.dart';
import 'package:deriv_chart/src/paint/paint_text.dart';
import 'package:deriv_chart/src/theme/painting_styles/barrier_style.dart';
import 'package:flutter/material.dart';

import 'horizontal_barrier.dart';

/// A class for painting horizontal barriers
class HorizontalBarrierPainter extends SeriesPainter<HorizontalBarrier> {
  /// Initializes [series]
  HorizontalBarrierPainter(HorizontalBarrier series)
      : _paint = Paint()..strokeWidth = 1,
        super(series);

  final Paint _paint;

  /// Padding between lines
  static const double padding = 5;

  /// Right margin
  static const double rightMargin = 5;

  /// Arrow size
  static const double _arrowSize = 5;

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

    Rect titleArea;

    // If previous object is null then its first load and no need to perform
    // transition animation from previousObject to new object.
    if (series.previousObject == null) {
      animatedValue = series.value;
      if (series.epoch != null) {
        dotX = epochToX(series.epoch);
      }
    } else {
      final BarrierObject previousBarrier = series.previousObject;
      // Calculating animated values regarding `currentTickPercent` in transition animation
      // from previousObject to new object
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

    if (series.visibility ==
        HorizontalBarrierVisibility.keepBarrierLabelVisible) {
      final double labelHalfHeight = style.labelHeight / 2;

      if (y - labelHalfHeight < 0) {
        y = labelHalfHeight;
        arrowType = BarrierArrowType.upward;
      } else if (y + labelHalfHeight > size.height) {
        y = size.height - labelHalfHeight;
        arrowType = BarrierArrowType.downward;
      }
    }

    if (style.hasBlinkingDot && dotX != null) {
      _paintBlinkingDot(canvas, dotX, y, animationInfo);
    }

    final TextPainter valuePainter = makeTextPainter(
      animatedValue.toStringAsFixed(pipSize),
      style.textStyle,
    );
    final Rect labelArea = Rect.fromCenter(
      center: Offset(
          size.width - rightMargin - padding - valuePainter.width / 2, y),
      width: valuePainter.width + padding * 2,
      height: style.labelHeight,
    );

    if (arrowType == BarrierArrowType.none) {
      final double mainLineStartX = series.longLine ? 0 : (dotX ?? 0);
      final double mainLineEndX = labelArea.left;
      _paintMainLine(canvas, mainLineStartX, mainLineEndX, y, style);
    }

    if (series.title != null) {
      final TextPainter titlePainter = makeTextPainter(
        series.title,
        style.textStyle.copyWith(
          color: style.color,
          backgroundColor: style.titleBackgroundColor,
        ),
      );
      titleArea = Rect.fromCenter(
        center:
            Offset(labelArea.left - 12 - padding - titlePainter.width / 2, y),
        width: titlePainter.width + padding * 2,
        height: titlePainter.height,
      );
      canvas.drawRect(titleArea, Paint()..blendMode = BlendMode.clear);
      paintWithTextPainter(
        canvas,
        painter: titlePainter,
        anchor: titleArea.center,
      );
    }

    _paintLabelBackground(canvas, labelArea, style.labelShape);
    paintWithTextPainter(
      canvas,
      painter: valuePainter,
      anchor: labelArea.center,
    );

    if (arrowType == BarrierArrowType.upward) {
      _paintUpwardArrows(
        canvas,
        (titleArea?.left ?? labelArea.left) - _arrowSize - padding,
        y,
        arrowSize: _arrowSize,
      );
    } else if (arrowType == BarrierArrowType.downward) {
      _paintDownwardArrows(
        canvas,
        (titleArea?.left ?? labelArea.left) - _arrowSize - padding,
        y,
        arrowSize: _arrowSize,
      );
    }
  }

  void _paintLabelBackground(
    Canvas canvas,
    Rect rect,
    LabelShape shape,
  ) {
    if (shape == LabelShape.rectangle) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(4)),
        _paint,
      );
    } else if (shape == LabelShape.pentagon) {
      canvas.drawPath(
        getCurrentTickLabelBackgroundPath(
          left: rect.left,
          top: rect.top,
          right: rect.right,
          bottom: rect.bottom,
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
    double middleY, {
    double arrowSize = 10,
    double arrowThickness = 4,
  }) {
    final Paint arrowPaint = Paint()..color = _paint.color;

    canvas
      ..drawPath(
          getUpwardArrowPath(
            middleX,
            middleY + arrowSize,
            size: arrowSize,
            thickness: arrowThickness,
          ),
          arrowPaint)
      ..drawPath(
        getUpwardArrowPath(
          middleX,
          middleY,
          size: arrowSize,
          thickness: arrowThickness,
        ),
        arrowPaint..color = _paint.color.withOpacity(0.64),
      )
      ..drawPath(
        getUpwardArrowPath(
          middleX,
          middleY - arrowSize,
          size: arrowSize,
          thickness: arrowThickness,
        ),
        arrowPaint..color = _paint.color.withOpacity(0.32),
      );
  }

  void _paintDownwardArrows(
    Canvas canvas,
    double middleX,
    double middleY, {
    double arrowSize = 10,
    double arrowThickness = 4,
  }) {
    final Paint arrowPaint = Paint()..color = _paint.color;

    canvas
      ..drawPath(
          getDownwardArrowPath(
            middleX,
            middleY - arrowSize,
            size: arrowSize,
            thickness: arrowThickness,
          ),
          arrowPaint)
      ..drawPath(
          getDownwardArrowPath(
            middleX,
            middleY,
            size: arrowSize,
            thickness: arrowThickness,
          ),
          arrowPaint..color = _paint.color.withOpacity(0.64))
      ..drawPath(
          getDownwardArrowPath(
            middleX,
            middleY + arrowSize,
            size: arrowSize,
            thickness: arrowThickness,
          ),
          arrowPaint..color = _paint.color.withOpacity(0.32));
  }
}
