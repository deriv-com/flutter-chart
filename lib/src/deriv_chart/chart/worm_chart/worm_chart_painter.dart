import 'dart:ui' as ui;
import 'dart:ui';
import 'package:deriv_chart/src/deriv_chart/chart/helpers/functions/conversion.dart';
import 'package:deriv_chart/src/deriv_chart/chart/helpers/functions/helper_functions.dart';
import 'package:deriv_chart/src/deriv_chart/chart/helpers/paint_functions/paint_text.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:deriv_chart/src/theme/painting_styles/line_style.dart';
import 'package:deriv_chart/src/theme/painting_styles/scatter_style.dart';
import 'package:flutter/material.dart';

import 'worm_chart.dart';

/// The custom painter for [WormChart].
class WormChartPainter extends CustomPainter {
  /// Initializes.
  WormChartPainter(
    this.ticks, {
    required this.lineStyle,
    required this.highestTickStyle,
    required this.lowestTickStyle,
    required this.indexToX,
    required this.startIndex,
    required this.endIndex,
    this.crossHairIndex,
    this.lastTickStyle,
    this.topPadding = 0,
    this.bottomPadding = 0,
  })  : _linePaint = Paint()
          ..color = lineStyle.color
          ..style = PaintingStyle.stroke
          ..strokeWidth = lineStyle.thickness,
        _highestCirclePaint = Paint()
          ..color = highestTickStyle.color
          ..style = PaintingStyle.fill,
        _lowestCirclePaint = Paint()
          ..color = lowestTickStyle.color
          ..style = PaintingStyle.fill;

  /// Input ticks.
  ///
  /// This should be the whole list of [Tick]. since [WormChart] works with indices
  /// visible ticks of the chart is defined with [startIndex] and [endIndex].
  final List<Tick> ticks;

  /// first visible tick in the chart's visible area.
  final int startIndex;

  /// last visible tick in the chart's visible area.
  final int endIndex;

  final Paint _linePaint;

  final Paint _highestCirclePaint;
  final Paint _lowestCirclePaint;

  /// The style of the tick indicator dot for the tick with highest [Tick.quote]
  /// inside the chart's visible area.
  ///
  /// If there were two or more ticks with highest quote, the one in the left will
  /// be chosen.
  final ScatterStyle highestTickStyle;

  /// The style of the tick indicator dot for the tick with lowest [Tick.quote]
  /// inside the chart's visible area.
  ///
  /// If there were two or more ticks with highest quote, the one in the left will
  /// be chosen.
  final ScatterStyle lowestTickStyle;

  /// The style of the tick indicator dot for the last tick inside the chart's visible area.
  final ScatterStyle? lastTickStyle;

  /// The index the tick which the cross-hair is going to point at.
  ///
  /// Being `null` means that the cross-hair is disabled.
  final int? crossHairIndex;

  /// The line style of the [WormChart].
  final LineStyle lineStyle;

  /// The top padding which is considered in [Tick.quote] to Y position and vice versa.
  final double topPadding;

  /// The bottom padding which is considered in [Tick.quote] to Y position and vice versa.
  final double bottomPadding;

  /// The conversion function to convert index to [Canvas]'s X position.
  final double Function(int) indexToX;

  @override
  void paint(Canvas canvas, Size size) {
    assert(topPadding + bottomPadding < 0.9 * size.height);

    if (endIndex - startIndex <= 2 ||
        startIndex < 0 ||
        endIndex >= ticks.length) {
      return;
    }

    final List<_TickIndicatorModel> tickIndicators = <_TickIndicatorModel>[];

    final MinMaxIndices minMax = getMinMaxIndex(ticks, startIndex, endIndex);

    final int minIndex = minMax.minIndex;
    final int maxIndex = minMax.maxIndex;
    final double min = ticks[minIndex].quote;
    final double max = ticks[maxIndex].quote;

    Path? linePath;
    late Offset currentPosition;

    for (int i = startIndex; i <= endIndex; i++) {
      final Tick tick = ticks[i];

      final double x = indexToX(i);
      final double y = _quoteToY(
        tick.quote,
        max,
        min,
        size.height,
        topPadding: topPadding,
        bottomPadding: bottomPadding,
      );
      currentPosition = Offset(x, y);

      if (i == ticks.length - 1 && lastTickStyle != null) {
        _drawLastTickCircle(canvas, currentPosition, tickIndicators);
      }

      _drawCircleIfMinMax(
        currentPosition,
        i,
        minIndex,
        maxIndex,
        canvas,
        tickIndicators,
      );

      if (linePath == null) {
        linePath = Path()..moveTo(x, y);
        continue;
      }

      linePath.lineTo(x, y);

      if (i == crossHairIndex) {
        canvas.drawLine(Offset(x, 0), Offset(x, size.height), _linePaint);
        // canvas.drawCircle(Offset(indexToX(i), dy), radius, paint)
        paintText(
          canvas,
          text: tick.quote.toString(),
          anchor: Offset(x, 10),
          style: const TextStyle(),
        );
      }
    }

    canvas
      ..saveLayer(Rect.fromLTRB(0, 0, size.width, size.height), Paint())
      ..drawPath(linePath!, _linePaint);

    if (lineStyle.hasArea) {
      linePath
        ..lineTo(currentPosition.dx, size.height)
        ..lineTo(linePath.getBounds().left, size.height);
      _drawArea(canvas, size, linePath, lineStyle);
    }

    for (final _TickIndicatorModel tickIndicator in tickIndicators) {
      canvas
        ..drawCircle(
          tickIndicator.position,
          tickIndicator.style.radius + 4,
          Paint()..blendMode = BlendMode.clear,
        )
        ..drawCircle(
          tickIndicator.position,
          tickIndicator.style.radius,
          tickIndicator.paint,
        );
    }

    canvas.restore();
  }

  void _drawLastTickCircle(ui.Canvas canvas, ui.Offset currentPosition,
      List<_TickIndicatorModel> tickIndicators) {
    // dotsPath.addOval(
    //     Rect.fromCenter(center: currentPosition, width: 20, height: 20));
    tickIndicators.add(
      _TickIndicatorModel(
        currentPosition,
        lastTickStyle!,
        Paint()
          ..color = lastTickStyle!.color
          ..style = PaintingStyle.fill,
      ),
    );
    canvas.drawCircle(
        currentPosition,
        lastTickStyle!.radius,
        Paint()
          ..color = lastTickStyle!.color
          ..style = PaintingStyle.fill);
  }

  void _drawArea(
    Canvas canvas,
    Size size,
    Path linePath,
    LineStyle style,
  ) {
    final Paint areaPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = ui.Gradient.linear(
        const Offset(0, 0),
        Offset(0, size.height),
        <Color>[
          style.color.withOpacity(0.2),
          style.color.withOpacity(0.001),
        ],
      );

    canvas.drawPath(linePath, areaPaint);
  }

  void _drawCircleIfMinMax(
    Offset position,
    int index,
    int minIndex,
    int maxIndex,
    Canvas canvas,
    List<_TickIndicatorModel> tickIndicators,
  ) {
    if (index == maxIndex) {
      tickIndicators.add(
          _TickIndicatorModel(position, highestTickStyle, _highestCirclePaint));
    }

    if (index == minIndex) {
      tickIndicators.add(
          _TickIndicatorModel(position, lowestTickStyle, _lowestCirclePaint));
    }
  }

  @override
  bool shouldRepaint(covariant WormChartPainter oldDelegate) => true;
}

// TODO(NA): Extract X-Axis conversions later to be able to support both epoch and index
double _quoteToY(
  double quote,
  double max,
  double min,
  double height, {
  double topPadding = 0,
  double bottomPadding = 0,
}) =>
    quoteToCanvasY(
      quote: quote,
      topBoundQuote: max,
      bottomBoundQuote: min,
      canvasHeight: height,
      topPadding: topPadding,
      bottomPadding: bottomPadding,
    );

/// A model class to hod the information needed to paint a [Tick] indicator on the
/// chart's canvas.
class _TickIndicatorModel {
  /// Initializes
  const _TickIndicatorModel(this.position, this.style, this.paint);

  /// The position of this tick indicator.
  final Offset position;

  /// The style which has the information of how this tick indicator should look like.
  final ScatterStyle style;

  /// The paint object which is used for painting on the canvas.
  final Paint paint;
}
