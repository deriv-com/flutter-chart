import 'dart:ui';

import 'package:deriv_chart/src/logic/chart_data.dart';
import 'package:deriv_chart/src/logic/chart_series/series_painter.dart';
import 'package:deriv_chart/src/models/animation_info.dart';
import 'package:deriv_chart/src/models/barrier_objects.dart';
import 'package:deriv_chart/src/paint/create_shape_path.dart';
import 'package:deriv_chart/src/paint/paint_dot.dart';
import 'package:deriv_chart/src/paint/paint_line.dart';
import 'package:deriv_chart/src/paint/paint_text.dart';
import 'package:deriv_chart/src/theme/painting_styles/barrier_style.dart';
import 'package:flutter/material.dart';

import 'horizontal_barrier.dart';

/// A class for painting horizontal barriers.
class HorizontalBarrierPainter extends SeriesPainter<HorizontalBarrier> {
  /// Initializes [series].
  HorizontalBarrierPainter(HorizontalBarrier series) : super(series);

  Paint _paint;

  /// Padding between lines.
  static const double padding = 4;

  /// Right margin.
  static const double rightMargin = 4;

  /// Distance between title area and label area.
  static const double _distanceBetweenTitleAndLabel = 16;

  /// Padding on both sides of the title (so that barrier line doesn't touch title text).
  static const double _titleHorizontalPadding = 2;

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

    final HorizontalBarrierStyle style = series.style ??
        theme.horizontalBarrierStyle ??
        const HorizontalBarrierStyle();

    _paint = Paint()
      ..strokeWidth = 1
      ..color = style.color;

    BarrierArrowType arrowType = BarrierArrowType.none;

    double animatedValue;

    double dotX;

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

    // Blinking dot.
    if (style.hasBlinkingDot && dotX != null) {
      _paintBlinkingDot(canvas, dotX, y, animationInfo);
    }

    final TextPainter valuePainter = makeTextPainter(
      animatedValue.toStringAsFixed(chartConfig.pipSize),
      style.textStyle,
    );
    final Rect labelArea = Rect.fromCenter(
      center: Offset(
          size.width - rightMargin - padding - valuePainter.width / 2, y),
      width: valuePainter.width + padding * 2,
      height: style.labelHeight,
    );

    // Line.
    if (arrowType == BarrierArrowType.none) {
      final double lineStartX = series.longLine ? 0 : (dotX ?? 0);
      final double lineEndX = labelArea.left;

      // To erase the line behind title.
      if (series.title != null) {
        canvas.saveLayer(
          Rect.fromLTRB(lineStartX, y - 1, lineEndX, y + 1),
          Paint(),
        );
      }

      if (lineStartX < lineEndX && style.hasLine) {
        _paintLine(canvas, lineStartX, lineEndX, y, style);
      }
    }

    // Title.
    if (series.title != null) {
      final TextPainter titlePainter = makeTextPainter(
        series.title,
        style.textStyle.copyWith(color: style.color),
      );
      final double titleEndX = labelArea.left - _distanceBetweenTitleAndLabel;
      final double titleAreaWidth =
          titlePainter.width + _titleHorizontalPadding * 2;
      final Rect titleArea = Rect.fromCenter(
        center: Offset(titleEndX - titleAreaWidth / 2, y),
        width: titleAreaWidth,
        height: titlePainter.height,
      );

      // Erase the line behind title.
      if (arrowType == BarrierArrowType.none) {
        canvas
          ..drawRect(titleArea, Paint()..blendMode = BlendMode.clear)
          ..restore();
      }

      paintWithTextPainter(
        canvas,
        painter: titlePainter,
        anchor: titleArea.center,
      );
    }

    // Label.
    paintLabelBackground(canvas, labelArea, style.labelShape, _paint);
    paintWithTextPainter(
      canvas,
      painter: valuePainter,
      anchor: labelArea.center,
    );

    // Arrows.
    if (style.hasArrow) {
      final double arrowMidX = labelArea.left - style.arrowSize - 6;
      if (arrowType == BarrierArrowType.upward) {
        _paintUpwardArrows(
          canvas,
          center: Offset(arrowMidX, y),
          arrowSize: style.arrowSize,
        );
      } else if (arrowType == BarrierArrowType.downward) {
        // TODO: Rotate arrows like in `paintMarker` instead of defining two identical paths only different in rotation.
        _paintDownwardArrows(
          canvas,
          center: Offset(arrowMidX, y),
          arrowSize: style.arrowSize,
        );
      }
    }
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

  void _paintBlinkingDot(
    Canvas canvas,
    double dotX,
    double y,
    AnimationInfo animationInfo,
  ) {
    paintDot(canvas, Offset(dotX, y), Colors.redAccent);

    paintBlinkingGlow(
      canvas,
      Offset(dotX, y),
      animationInfo.blinkingPercent,
      Colors.redAccent,
    );
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

  void _paintUpwardArrows(
    Canvas canvas, {
    Offset center,
    double arrowSize,
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
          arrowPaint..color = _paint.color.withOpacity(0.64))
      ..drawPath(
          getUpwardArrowPath(
            center.dx,
            center.dy - arrowSize + 1,
            size: arrowSize,
          ),
          arrowPaint..color = _paint.color.withOpacity(0.32));
  }

  void _paintDownwardArrows(
    Canvas canvas, {
    Offset center,
    double arrowSize,
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
          arrowPaint..color = _paint.color.withOpacity(0.64))
      ..drawPath(
          getDownwardArrowPath(
            center.dx,
            center.dy + arrowSize - 1,
            size: arrowSize,
          ),
          arrowPaint..color = _paint.color.withOpacity(0.32));
  }
}
