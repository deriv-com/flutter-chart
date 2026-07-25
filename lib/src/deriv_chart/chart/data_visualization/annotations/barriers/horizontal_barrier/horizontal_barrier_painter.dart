import 'dart:ui' as ui;

import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_data.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/series_painter.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/models/animation_info.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/models/barrier_objects.dart';
import 'package:deriv_chart/src/deriv_chart/chart/helpers/paint_functions/create_shape_path.dart';
import 'package:deriv_chart/src/deriv_chart/chart/helpers/paint_functions/paint_dot.dart';
import 'package:deriv_chart/src/deriv_chart/chart/helpers/paint_functions/paint_line.dart';
import 'package:deriv_chart/src/deriv_chart/chart/helpers/paint_functions/paint_text.dart';
import 'package:deriv_chart/src/deriv_chart/chart/y_axis/y_axis_config.dart';
import 'package:deriv_chart/src/theme/painting_styles/barrier_style.dart';
import 'package:flutter/material.dart';

import 'horizontal_barrier.dart';
import 'tick_indicator.dart';

/// A class for painting horizontal barriers.
class HorizontalBarrierPainter<T extends HorizontalBarrier>
    extends SeriesPainter<T> {
  /// Initializes [series].
  HorizontalBarrierPainter(T series) : super(series);

  late Paint _paint;

  /// Right margin.
  static const double rightMargin = 4;

  /// Distance between title area and label area.
  static const double _distanceBetweenTitleAndLabel = 16;

  /// Padding on both sides of the title (so that barrier line doesn't touch
  /// title text).
  static const double _titleHorizontalPadding = 2;

  /// Barrier position which is calculated on painting the barrier.
  // TODO(Ramin): Breakdown paintings into smaller classes and find a way to
  //  make them reusable.
  // Proposal: Return useful PaintInfo in the [paint] method to be used by other
  // painters
  Offset? _barrierPosition;

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

    _paint = Paint()
      ..style = PaintingStyle.fill
      ..strokeWidth = 1
      ..color = style.color;

    BarrierArrowType arrowType = BarrierArrowType.none;

    double? animatedValue;

    double? dotX;

    // If previous object is null then its first load and no need to perform
    // transition animation from previousObject to new object.
    if (series.previousObject == null) {
      animatedValue = series.quote;
      if (series.epoch != null) {
        dotX = epochToX(series.epoch!);
      }
    } else {
      final BarrierObject previousBarrier = series.previousObject!;
      // Calculating animated values regarding `currentTickPercent` in
      // transition animation
      // from previousObject to new object
      animatedValue = ui.lerpDouble(
        previousBarrier.quote,
        series.quote,
        animationInfo.currentTickPercent,
      );

      if (series.epoch != null && series.previousObject!.leftEpoch != null) {
        dotX = ui.lerpDouble(
          epochToX(series.previousObject!.leftEpoch!),
          epochToX(series.epoch!),
          animationInfo.currentTickPercent,
        );
      }
    }

    double y = quoteToY(animatedValue!);

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
      // to hide the blinking spot on yAxis
      YAxisConfig.instance.yAxisClipping(canvas, size, () {
        paintBlinkingDot(
            canvas, dotX!, y, animationInfo, style.blinkingDotColor);
      });
    }

    final TextPainter valuePainter = makeTextPainter(
      animatedValue.toStringAsFixed(chartConfig.pipSize),
      style.textStyle,
    );
    final Rect labelArea = Rect.fromCenter(
      center: Offset(
          size.width -
              rightMargin -
              style.labelPadding -
              valuePainter.width / 2,
          y),
      width: valuePainter.width + style.labelPadding * 2,
      height: style.labelHeight,
    );

    // Title.
    Rect? titleArea;
    if (series.title != null) {
      final TextPainter titlePainter = makeTextPainter(
        series.title!,
        style.textStyle.copyWith(color: style.color),
      );
      final double titleEndX = labelArea.left - _distanceBetweenTitleAndLabel;
      final double titleAreaWidth =
          titlePainter.width + _titleHorizontalPadding * 2;
      titleArea = Rect.fromCenter(
        center: Offset(titleEndX - titleAreaWidth / 2, y),
        width: titleAreaWidth,
        height: titlePainter.height,
      );

      // Paint the title text
      paintWithTextPainter(
        canvas,
        painter: titlePainter,
        anchor: titleArea.center,
      );
    }

    // Draw the horizontal line, splitting it into segments to avoid
    // overlapping with the title text if present
    if (arrowType == BarrierArrowType.none && style.hasLine) {
      final double lineStartX = series.longLine ? 0 : (dotX ?? 0);
      final double lineEndX = labelArea.left;

      if (lineStartX < lineEndX) {
        if (titleArea != null) {
          // Draw line in two segments - before and after the title
          // First segment: from lineStartX to left of title
          if (lineStartX < titleArea.left) {
            _paintLine(canvas, lineStartX, titleArea.left, y, style);
          }

          // Second segment: from right of title to lineEndX
          if (titleArea.right < lineEndX) {
            _paintLine(canvas, titleArea.right, lineEndX, y, style);
          }
        } else {
          // Draw a continuous line
          _paintLine(canvas, lineStartX, lineEndX, y, style);
        }
      }
    }

    // Label.
    paintLabelBackground(canvas, labelArea, style.labelShape, _paint,
        labelBackgroundColor: style.labelShapeBackgroundColor);
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
        // TODO(Anonymous): Rotate arrows like in `paintMarker` instead of
        // defining two identical paths only different in rotation.
        _paintDownwardArrows(
          canvas,
          center: Offset(arrowMidX, y),
          arrowSize: style.arrowSize,
        );
      }
    }

    if (dotX != null) {
      _barrierPosition = Offset(dotX, y);
    }
  }

  /// Paints a background based on the given [LabelShape] for the label text.
  void paintLabelBackground(
      Canvas canvas, Rect rect, LabelShape shape, Paint paint,
      {double radius = 4, Color? labelBackgroundColor}) {
    paint.color = labelBackgroundColor ?? paint.color;

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
        style.lineColor,
        1,
      );
    } else {
      _paint.color = style.lineColor;
      canvas.drawLine(
          Offset(mainLineStartX, y), Offset(mainLineEndX, y), _paint);
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
          arrowPaint..color = _paint.color.withOpacity(0.64))
      ..drawPath(
          getDownwardArrowPath(
            center.dx,
            center.dy + arrowSize - 1,
            size: arrowSize,
          ),
          arrowPaint..color = _paint.color.withOpacity(0.32));
  }

  @override
  List<CustomPainterSemantics> buildSemantics({
    required Size size,
    required EpochToX epochToX,
    required QuoteToY quoteToY,
  }) {
    return <CustomPainterSemantics>[];
  }
}

/// The painter for the [IconTickIndicator] which paints the icon on the
/// barrier's tick position.
class IconBarrierPainter extends HorizontalBarrierPainter<IconTickIndicator> {
  /// Initializes [IconBarrierPainter].
  IconBarrierPainter(IconTickIndicator series) : super(series);

  @override
  void onPaint({
    required Canvas canvas,
    required Size size,
    required EpochToX epochToX,
    required QuoteToY quoteToY,
    required AnimationInfo animationInfo,
  }) {
    super.onPaint(
      canvas: canvas,
      size: size,
      epochToX: epochToX,
      quoteToY: quoteToY,
      animationInfo: animationInfo,
    );

    if (_barrierPosition != null) {
      _paintIcon(canvas);
    }
  }

  void _paintIcon(ui.Canvas canvas) {
    final Icon icon = series.icon;

    final double iconSize = icon.size!;
    final double innerIconSize = iconSize * 0.6;

    canvas
      ..drawCircle(
        _barrierPosition!,
        iconSize / 2,
        _paint,
      )
      ..drawCircle(
        _barrierPosition!,
        (iconSize / 2) - 2,
        Paint()..color = Colors.black.withOpacity(0.32),
      );

    TextPainter(textDirection: TextDirection.ltr)
      ..text = TextSpan(
        text: String.fromCharCode(icon.icon!.codePoint),
        style: TextStyle(
          fontSize: innerIconSize,
          fontFamily: icon.icon!.fontFamily,
        ),
      )
      ..layout()
      ..paint(
        canvas,
        _barrierPosition! - Offset(innerIconSize / 2, innerIconSize / 2),
      );
  }

  @override
  List<CustomPainterSemantics> buildSemantics({
    required Size size,
    required EpochToX epochToX,
    required QuoteToY quoteToY,
  }) {
    return <CustomPainterSemantics>[];
  }
}
