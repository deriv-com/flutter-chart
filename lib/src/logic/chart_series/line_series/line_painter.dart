import 'dart:ui' as ui;

import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/logic/chart_series/data_painter.dart';
import 'package:deriv_chart/src/models/animation_info.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:deriv_chart/src/theme/painting_styles/line_style.dart';
import 'package:flutter/material.dart';

import '../../chart_data.dart';
import '../data_series.dart';

/// A [DataPainter] for painting line data.
class LinePainter extends DataPainter<DataSeries<Tick>> {
  /// Initializes
  LinePainter(
    DataSeries<Tick> series, {
    LineStyle horizontalLineStyle,
    List<double> horizontalLines = const <double>[],
  })  : _horizontalLines = horizontalLines,
        _horizontalLineStyle = horizontalLineStyle,
        super(series);

  final List<double> _horizontalLines;
  final LineStyle _horizontalLineStyle;

  double _lastVisibleTickX;

  @override
  void onPaintData(
    Canvas canvas,
    Size size,
    EpochToX epochToX,
    QuoteToY quoteToY,
    AnimationInfo animationInfo,
  ) {
    final LineStyle style =
        series.style ?? theme.lineStyle ?? const LineStyle();

    final Paint linePaint = Paint()
      ..color = style.color
      ..style = PaintingStyle.stroke
      ..strokeWidth = style.thickness;

    final Path path = createPath(epochToX, quoteToY, animationInfo);

    paintHorizontalLines(canvas, quoteToY, size);

    addChannelFill(path);

    canvas.drawPath(path, linePaint);

    if (style.hasArea) {
      _drawArea(
        canvas,
        size,
        path,
        epochToX(series.visibleEntries.first.epoch),
        _lastVisibleTickX,
        style,
      );
    }
  }

  /// Paints the horizontal lines if the [series] have any.
  void paintHorizontalLines(Canvas canvas, QuoteToY quoteToY, Size size) {
    final LineStyle horizontalLineStyle =
        _horizontalLineStyle ?? theme.lineStyle ?? const LineStyle();
    final Paint horizontalLinePaint = Paint()
      ..color = horizontalLineStyle.color
      ..style = PaintingStyle.stroke
      ..strokeWidth = horizontalLineStyle.thickness;

    for (final double line in _horizontalLines) {
      canvas.drawLine(Offset(0, quoteToY(line)),
          Offset(size.width, quoteToY(line)), horizontalLinePaint);
    }
  }

  /// Adds channel fill incase the data series has one.
  void addChannelFill(
    Path path,
  ) {}

  /// Creates the path of the given [series] and returns it.
  Path createPath(
    EpochToX epochToX,
    QuoteToY quoteToY,
    AnimationInfo animationInfo,
  ) {
    final Path path = Path();

    bool isStartPointSet = false;

    // Adding visible entries line to the path except the last which might be animated.
    for (int i = 0; i < series.visibleEntries.length - 1; i++) {
      final Tick tick = series.visibleEntries[i];

      if (!isStartPointSet) {
        isStartPointSet = true;
        path.moveTo(epochToX(getEpochOf(tick)), quoteToY(tick.quote));
        continue;
      }

      final double x = epochToX(getEpochOf(tick));
      final double y = quoteToY(tick.quote);
      path.lineTo(x, y);
    }

    _lastVisibleTickX =
        calculateLastVisibleTick(epochToX, animationInfo, quoteToY, path);

    return path;
  }

  /// calculates the last visible tick's `dx`.
  double calculateLastVisibleTick(EpochToX epochToX,
      AnimationInfo animationInfo, QuoteToY quoteToY, ui.Path path) {
    final Tick lastTick = series.entries.last;
    final Tick lastVisibleTick = series.visibleEntries.last;
    double lastVisibleTickX;

    if (lastTick == lastVisibleTick && series.prevLastEntry != null) {
      lastVisibleTickX = ui.lerpDouble(
        epochToX(getEpochOf(series.prevLastEntry)),
        epochToX(getEpochOf(lastTick)),
        animationInfo.currentTickPercent,
      );

      final double tickY = quoteToY(ui.lerpDouble(
        series.prevLastEntry.quote,
        lastTick.quote,
        animationInfo.currentTickPercent,
      ));

      path.lineTo(lastVisibleTickX, tickY);
    } else {
      lastVisibleTickX = epochToX(getEpochOf(lastVisibleTick));
      path.lineTo(lastVisibleTickX, quoteToY(lastVisibleTick.quote));
    }

    return lastVisibleTickX;
  }

  void _drawArea(
    Canvas canvas,
    Size size,
    Path linePath,
    double lineStartX,
    double lineEndX,
    LineStyle style,
  ) {
    final Paint areaPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = ui.Gradient.linear(
        const Offset(0, 0),
        Offset(0, size.height),
        <Color>[
          style.color.withOpacity(0.2),
          style.color.withOpacity(0.01),
        ],
      );

    linePath
      ..lineTo(
        lineEndX,
        size.height,
      )
      ..lineTo(lineStartX, size.height);

    canvas.drawPath(linePath, areaPaint);
  }
}
