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
import 'package:deriv_chart/src/theme/colors.dart';
import 'package:deriv_chart/src/theme/painting_styles/barrier_style.dart';
import 'package:flutter/material.dart';

import 'accumulator_barrier_drag_controller.dart';
import 'accumulator_barrier_geometry.dart';
import 'accumulator_barrier_grip_style.dart';
import 'accumulator_barrier_side.dart';
import 'accumulator_barrier_tap_guide.dart';
import 'accumulator_growth_rate_step.dart';

/// Size of a barrier's ± label at rest.
const double _restingLabelFontSize = 12;

/// Size it grows to while the growth rate is being changed.
///
/// Well clear of the resting size — the two numbers the user is choosing
/// between should be the loudest thing on the chart while they scroll, and a
/// few points of growth read as a rendering wobble rather than as the values
/// responding — but short of double, which crowds the band on a phone.
const double _emphasisedLabelFontSize = 22;

/// Where to draw a barrier's ± label so that emphasising it moves it away from
/// its own barrier line.
///
/// [restingCenter] is where the label sits when nothing is emphasised, so with
/// [painter] still at the resting size this returns exactly what centring the
/// text there would. What differs is where the extra size goes once [painter]
/// is larger: centring spends half the growth walking the text onto the barrier
/// it labels, and half of it leftwards over the band. Here the two edges facing
/// the chart's empty space are the ones that move.
///
/// [growsUpwards] says which side of its barrier the label is on — `+` sits
/// above the high barrier, `-` below the low one — so whichever edge faces the
/// line is the one pinned.
@visibleForTesting
Offset barrierLabelTopLeft({
  required TextPainter resting,
  required TextPainter painter,
  required Offset restingCenter,
  required bool growsUpwards,
}) {
  final double restingTop = restingCenter.dy - resting.height / 2;

  final double top;
  if (growsUpwards) {
    // The baseline, not the box's bottom edge. A larger font has a deeper
    // descender, and these values are all digits, so pinning the box would
    // visibly lift the numerals away from the line as they grew.
    final double restingBaseline = restingTop +
        resting.computeDistanceToActualBaseline(TextBaseline.alphabetic);
    top = restingBaseline -
        painter.computeDistanceToActualBaseline(TextBaseline.alphabetic);
  } else {
    // Below its barrier, so it is the top edge that faces the line.
    top = restingTop;
  }

  // Left edge pinned either way, so the growth runs right into the empty chart.
  return Offset(restingCenter.dx - resting.width / 2, top);
}

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
        color = LegacyLightThemeColors.accentGreen;
      } else if (series.activeContract!.profit! < 0) {
        color = LegacyLightThemeColors.accentRed;
      }
    }

    if (series.tick.quote > series.highBarrier ||
        series.tick.quote < series.lowBarrier) {
      color = LegacyLightThemeColors.accentRed;
    }
    final AccumulatorBarrierDragController? drag = series.dragController;
    final bool isInteractive =
        (drag?.enabled ?? false) && series.activeContract == null;
    final AccumulatorBarrierGripStyle gripStyle =
        drag?.gripStyle ?? const AccumulatorBarrierGripStyle();
    final bool isHighlighted = isInteractive && drag!.isHighlighted;

    _linePaint
      ..color = color
      ..strokeWidth =
          isHighlighted ? gripStyle.highlightLineWidth : gripStyle.lineWidth;
    _linePaintFill.color = color;
    _rectPaint.color = color.withOpacity(
      isHighlighted ? gripStyle.highlightBandOpacity : gripStyle.bandOpacity,
    );

    final AccumulatorIndicator indicator = series;

    // The band the model currently commits to, independent of any drag
    // preview. The drag maps pointer positions to a distance from this centre,
    // and the commit latch compares incoming barriers against this distance.
    final double committedCenterQuote =
        (indicator.highBarrier + indicator.lowBarrier) / 2;
    final double committedSpotDistance =
        (indicator.highBarrier - indicator.lowBarrier).abs() / 2;
    final AccumulatorGrowthRateStep? previewStep = indicator.previewStep;

    double barrierX = epochToX(indicator.barrierEpoch);
    double hBarrierQuote = indicator.highBarrier;
    double lBarrierQuote = indicator.lowBarrier;

    /// Where the band sits right now, as opposed to where the model settles it.
    ///
    /// A preview owns the band's *width*, never its position: the spot keeps
    /// moving while the growth rate is being picked, and the band has to follow
    /// it as smoothly as it does the rest of the time.
    double animatedCenterQuote = committedCenterQuote;

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

      // Animated whether or not a rung is being previewed. Only the two
      // barriers below are the preview's to own; the centre tracks the spot,
      // and leaving it on the incoming model made the band jump a whole tick
      // vertically while `barrierX` glided beside it.
      animatedCenterQuote = ui.lerpDouble(
            (previousIndicator.highBarrier + previousIndicator.lowBarrier) / 2,
            committedCenterQuote,
            animationInfo.currentTickPercent,
          ) ??
          animatedCenterQuote;

      // Skipped while previewing: the preview is authoritative on width, and
      // lerping towards the stale model would fight it.
      if (previewStep == null) {
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
      }

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

    if (previewStep != null) {
      // Glide between rungs rather than stepping, matching how the band already
      // moves when the growth rate is changed from the trade params.
      final double? from = drag?.previewTransitionFrom;
      final double previewDistance = from == null
          ? previewStep.barrierSpotDistance
          : ui.lerpDouble(
                from,
                previewStep.barrierSpotDistance,
                animationInfo.accumulatorPreviewPercent,
              ) ??
              previewStep.barrierSpotDistance;

      hBarrierQuote = animatedCenterQuote + previewDistance;
      lBarrierQuote = animatedCenterQuote - previewDistance;

      // Lets the next rung change pick up from where the band actually is.
      drag?.publishRenderedPreviewDistance(previewDistance);
    } else {
      drag?.publishRenderedPreviewDistance(null);
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

    // Calculate profit area if needed
    Rect? profitArea;
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

      profitArea = Rect.fromCenter(
        center: Offset(textStartX + textWidth / 2, tickPosition.dy),
        width: textWidth + padding * 2,
        height: style.labelHeight,
      );

      // Draw profit text
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

    // Draw line in segments, splitting around profit text area if present
    // to avoid overlapping
    if (arrowType == BarrierArrowType.none && style.hasLine) {
      final double lineStartX = tickPosition.dx;
      final double lineEndX = labelArea.left;

      if (lineStartX < lineEndX) {
        if (profitArea != null) {
          // Draw line in two segments - before and after the profit text
          // First segment: from lineStartX to left of profit area
          if (lineStartX < profitArea.left) {
            _paintLine(
                canvas, lineStartX, profitArea.left, tickPosition.dy, style);
          }

          // Second segment: from right of profit area to lineEndX
          if (profitArea.right < lineEndX) {
            _paintLine(
                canvas, lineEndX, profitArea.right, tickPosition.dy, style);
          }
        } else {
          // Draw a continuous line
          _paintLine(canvas, lineStartX, lineEndX, tickPosition.dy, style);
        }
      }
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

    final String spotDistanceDisplay =
        previewStep?.barrierSpotDistanceDisplay ??
            indicator.barrierSpotDistance;

    // These two are the values a growth-rate change actually moves, so they
    // grow and thicken while one is in flight and settle back afterwards.
    final double emphasis = animationInfo.accumulatorLabelEmphasis;
    final TextStyle restingLabelStyle = TextStyle(
      color: color,
      fontSize: _restingLabelFontSize,
    );
    final TextStyle barrierLabelStyle = TextStyle(
      color: color,
      fontSize: ui.lerpDouble(
        _restingLabelFontSize,
        _emphasisedLabelFontSize,
        emphasis,
      ),
      fontWeight: FontWeight.lerp(
        FontWeight.normal,
        FontWeight.bold,
        emphasis,
      ),
    );

    _paintBarrierLabel(
      canvas,
      text: '-$spotDistanceDisplay',
      restingCenter: lowBarrierPosition + const Offset(30, 10),
      restingStyle: restingLabelStyle,
      style: barrierLabelStyle,
      growsUpwards: false,
    );

    _paintBarrierLabel(
      canvas,
      text: '+$spotDistanceDisplay',
      restingCenter: highBarrierPosition + const Offset(30, -10),
      restingStyle: restingLabelStyle,
      style: barrierLabelStyle,
      growsUpwards: true,
    );

    // Drag grips, and the geometry the drag overlay hit-tests against.
    //
    // Pinned to the right of the plotting area rather than centred in the band,
    // so a finger on a grip never covers the barrier value it is changing. The
    // Y-axis label strip is excluded, and the grip is kept from spilling past
    // the left edge of a very narrow band.
    final double rightEdgeX = drag?.graphAreaWidth ?? size.width;
    final double gripCenterX = AccumulatorBarrierGeometry.gripCenterX(
      barrierX: barrierX,
      rightEdgeX: rightEdgeX,
      style: gripStyle,
    );
    final Rect highGripRect = Rect.fromCenter(
      center: Offset(gripCenterX, highBarrierPosition.dy),
      width: gripStyle.size.width,
      height: gripStyle.size.height,
    );
    final Rect lowGripRect = Rect.fromCenter(
      center: Offset(gripCenterX, lowBarrierPosition.dy),
      width: gripStyle.size.width,
      height: gripStyle.size.height,
    );

    if (isInteractive && drag!.dragEnabled) {
      _paintGrip(
        canvas,
        rect: highGripRect,
        color: color,
        fillColor: gripStyle.fillColor ?? theme.backgroundColor,
        style: gripStyle,
        isEmphasized: drag.hoveredSide == AccumulatorBarrierSide.high ||
            drag.draggedSide == AccumulatorBarrierSide.high,
      );
      _paintGrip(
        canvas,
        rect: lowGripRect,
        color: color,
        fillColor: gripStyle.fillColor ?? theme.backgroundColor,
        style: gripStyle,
        isEmphasized: drag.hoveredSide == AccumulatorBarrierSide.low ||
            drag.draggedSide == AccumulatorBarrierSide.low,
      );
    }

    // Painted after the grips and before the geometry is published, so it sits
    // over the band without taking part in hit-testing — the whole band is the
    // target, and the hint only says so.
    if (isInteractive && drag!.showTapGuide) {
      paintAccumulatorTapGuide(
        canvas,
        center: accumulatorTapGuideCenter(
          bandLeft: barrierX,
          bandTop: highBarrierPosition.dy,
          bandBottom: lowBarrierPosition.dy,
        ),
        color: color,
        pulse: animationInfo.accumulatorGuidePulse,
      );
    }

    drag?.publishGeometry(AccumulatorBarrierGeometry(
      barrierX: barrierX,
      rightEdgeX: size.width,
      highBarrierY: highBarrierPosition.dy,
      lowBarrierY: lowBarrierPosition.dy,
      highGripRect: highGripRect,
      lowGripRect: lowGripRect,
      bandCenterQuote: committedCenterQuote,
      committedBarrierSpotDistance: committedSpotDistance,
    ));

    // Label.
    paintLabelBackground(canvas, labelArea, style.labelShape, _paint);
    paintWithTextPainter(
      canvas,
      painter: valuePainter,
      anchor: labelArea.center,
    );
  }

  /// Paints a barrier's ± value, growing it away from its own barrier line.
  ///
  /// See [barrierLabelTopLeft] for where it lands and why.
  void _paintBarrierLabel(
    Canvas canvas, {
    required String text,
    required Offset restingCenter,
    required TextStyle restingStyle,
    required TextStyle style,
    required bool growsUpwards,
  }) {
    final TextPainter resting = makeTextPainter(text, restingStyle);
    // Reused rather than laid out twice: at rest the two styles are equal, and
    // this runs on every frame of every tick, not just while emphasised.
    final TextPainter painter =
        style == restingStyle ? resting : makeTextPainter(text, style);

    paintWithTextPainter(
      canvas,
      painter: painter,
      anchor: barrierLabelTopLeft(
        resting: resting,
        painter: painter,
        restingCenter: restingCenter,
        growsUpwards: growsUpwards,
      ),
      anchorAlignment: Alignment.topLeft,
    );
  }

  /// Paints one drag grip: a rounded pill straddling the barrier line, with a
  /// few horizontal rules inside it to read as a grab handle.
  void _paintGrip(
    Canvas canvas, {
    required Rect rect,
    required Color color,
    required Color fillColor,
    required AccumulatorBarrierGripStyle style,
    required bool isEmphasized,
  }) {
    final RRect body = RRect.fromRectAndRadius(
      rect,
      Radius.circular(style.borderRadius),
    );

    canvas
      ..drawRRect(
        body,
        Paint()
          ..color = fillColor
          ..style = PaintingStyle.fill,
      )
      ..drawRRect(
        body,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth =
              isEmphasized ? style.borderWidth * 2 : style.borderWidth,
      );

    final Paint innerLinePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = style.borderWidth;

    final double span = style.innerLineSpacing * (style.innerLineCount - 1);
    double lineY = rect.center.dy - span / 2;

    for (int i = 0; i < style.innerLineCount; i++) {
      canvas.drawLine(
        Offset(rect.left + style.innerLineInset, lineY),
        Offset(rect.right - style.innerLineInset, lineY),
        innerLinePaint,
      );
      lineY += style.innerLineSpacing;
    }
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
