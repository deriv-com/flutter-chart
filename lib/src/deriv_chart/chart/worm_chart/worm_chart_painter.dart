import 'dart:ui' as ui;
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_data.dart';
import 'package:deriv_chart/src/deriv_chart/chart/helpers/functions/helper_functions.dart';
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
    required this.quoteToY,
    required this.startIndex,
    required this.endIndex,
    required this.minMax,
    this.applyTickIndicatorsPadding = false,
    this.lastTickStyle,
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
  /// This should be the whole list of [Tick].
  /// since [WormChart] works with indices visible ticks of the chart is
  /// defined with [startIndex] and [endIndex].
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
  /// If there were two or more ticks with highest quote, the one in the left
  /// will be chosen.
  final ScatterStyle highestTickStyle;

  /// The style of the tick indicator dot for the tick with lowest [Tick.quote]
  /// inside the chart's visible area.
  ///
  /// If there were two or more ticks with highest quote, the one in the left
  /// will be chosen.
  final ScatterStyle lowestTickStyle;

  /// The style of the tick indicator dot for the last tick inside the chart's
  /// visible area.
  final ScatterStyle? lastTickStyle;

  /// The line style of the [WormChart].
  final LineStyle lineStyle;

  /// The conversion function to convert index to [Canvas]'s X position.
  final double Function(int) indexToX;

  /// The conversion function to convert quote to [Canvas]'s Y position.
  final QuoteToY quoteToY;

  /// MinMax indices.
  final MinMaxIndices minMax;

  /// Whether to apply padding around tick indicator dots (highest, lowest,
  /// last tick).
  final bool applyTickIndicatorsPadding;

  @override
  void paint(Canvas canvas, Size size) {
    if (endIndex - startIndex <= 2 ||
        startIndex < 0 ||
        endIndex >= ticks.length) {
      return;
    }

    final List<_TickIndicatorModel> tickIndicators = <_TickIndicatorModel>[];

    final int minIndex = minMax.minIndex;
    final int maxIndex = minMax.maxIndex;

    Path? linePath;
    late Offset currentPosition;

    for (int i = startIndex; i <= endIndex; i++) {
      final Tick tick = ticks[i];

      final double x = indexToX(i);
      final double y = quoteToY(tick.quote);
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
    }

    if (applyTickIndicatorsPadding) {
      canvas.saveLayer(Rect.fromLTRB(0, 0, size.width, size.height), Paint());
    }
    canvas.drawPath(linePath!, _linePaint);

    if (lineStyle.hasArea) {
      linePath
        ..lineTo(currentPosition.dx, size.height)
        ..lineTo(linePath.getBounds().left, size.height);
      _drawArea(canvas, size, linePath, lineStyle);
    }

    for (final _TickIndicatorModel tickIndicator in tickIndicators) {
      if (applyTickIndicatorsPadding) {
        canvas.drawCircle(
          tickIndicator.position,
          tickIndicator.style.radius + 2,
          Paint()..blendMode = BlendMode.clear,
        );
      }
      canvas.drawCircle(
        tickIndicator.position,
        tickIndicator.style.radius,
        tickIndicator.paint,
      );
    }

    if (applyTickIndicatorsPadding) {
      canvas.restore();
    }
  }

  void _drawLastTickCircle(ui.Canvas canvas, ui.Offset currentPosition,
      List<_TickIndicatorModel> tickIndicators) {
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
          style.color.withValues(alpha: 0.2),
          style.color.withValues(alpha: 0.001),
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

/// A model class to hod the information needed to paint a [Tick] indicator on
/// the chart's canvas.
class _TickIndicatorModel {
  /// Initializes
  const _TickIndicatorModel(this.position, this.style, this.paint);

  /// The position of this tick indicator.
  final Offset position;

  /// The style which has the information of how this tick indicator should
  /// look like.
  final ScatterStyle style;

  /// The paint object which is used for painting on the canvas.
  final Paint paint;
}
