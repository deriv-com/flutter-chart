import 'dart:ui' as ui;

import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/logic/chart_series/line_series/line_painter.dart';
import 'package:deriv_chart/src/models/animation_info.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:deriv_chart/src/theme/painting_styles/line_style.dart';
import 'package:flutter/material.dart';

import '../../chart_data.dart';
import '../data_series.dart';

/// A [LinePainter] for painting line data.
class ChannelFillPainter extends LinePainter {
  /// Initializes.
  ChannelFillPainter(
    this.firstSeries,
    this.secondSeries, {
    this.fillColor = Colors.transparent,
  }) : super(firstSeries);

  double _lastVisibleTickX;

  /// The series to paint on the top side of the canvas.
  DataSeries<Tick> firstSeries;

  /// The series to paint on the bottom side of the canvas.
  DataSeries<Tick> secondSeries;

  /// The color used to fill the space between the two lines.
  ///
  /// The default is set to [Colors.transparent].
  Color fillColor;

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
      ..style = PaintingStyle.fill
      ..strokeWidth = style.thickness;

    final Path firstPath =
        createPath(firstSeries, epochToX, quoteToY, animationInfo);
    final Path secondPath =
        createPath(secondSeries, epochToX, quoteToY, animationInfo);

    paintLines(canvas, firstPath, linePaint);
    paintLines(canvas, secondPath, linePaint);
  }
}
