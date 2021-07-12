import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/line_series/line_painter.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/models/animation_info.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:deriv_chart/src/theme/painting_styles/line_style.dart';
import 'package:flutter/material.dart';

import '../../chart_data.dart';
import '../data_painter.dart';
import '../data_series.dart';

/// A [DataPainter] for painting two line data and the channel fill inside of them.
class ChannelFillPainter extends LinePainter {
  /// Initializes
  ChannelFillPainter(
    this.firstSeries,
    this.secondSeries,
  ) : super(firstSeries);

  /// The first line series to be painting.
  final DataSeries<Tick> firstSeries;

  /// The second line series to be painting.
  final DataSeries<Tick> secondSeries;

  @override
  void onPaintData(
    Canvas canvas,
    Size size,
    EpochToX epochToX,
    QuoteToY quoteToY,
    AnimationInfo animationInfo,
  ) {
    final LineStyle firstLineStyle =
        firstSeries.style as LineStyle? ?? theme.lineStyle;
    final LineStyle secondLineStyle =
        firstSeries.style as LineStyle? ?? theme.lineStyle;

    final Paint firstLinePaint = Paint()
      ..color = firstLineStyle.color
      ..style = PaintingStyle.stroke
      ..strokeWidth = firstLineStyle.thickness;

    final Paint firstChannelFillPaint = Paint()
      ..color = firstLineStyle.color
      ..style = PaintingStyle.fill
      ..strokeWidth = 0;

    final Paint secondLinePaint = Paint()
      ..color = secondLineStyle.color
      ..style = PaintingStyle.stroke
      ..strokeWidth = firstLineStyle.thickness;

    final Paint secondChannelFillPaint = Paint()
      ..color = secondLineStyle.color
      ..style = PaintingStyle.fill
      ..strokeWidth = 0;

    final DataLinePathInfo firstDataPathInfo =
        createPath(firstSeries, epochToX, quoteToY, animationInfo);
    final DataLinePathInfo secondDataPathInfo =
        createPath(secondSeries, epochToX, quoteToY, animationInfo);

    final Path channelFillPath = firstDataPathInfo.path
      ..moveTo(
          firstDataPathInfo.endPosition.dx, firstDataPathInfo.endPosition.dy)
      ..lineTo(
          secondDataPathInfo.endPosition.dx, secondDataPathInfo.endPosition.dy)
      ..moveTo(firstDataPathInfo.startPosition.dx,
          firstDataPathInfo.startPosition.dy)
      ..lineTo(secondDataPathInfo.startPosition.dx,
          secondDataPathInfo.startPosition.dy)
      ..addPath(secondDataPathInfo.path, Offset.zero);

    final Path firstLineAreaPath = areaPath(
        canvas,
        size,
        firstDataPathInfo.path,
        firstDataPathInfo.startPosition.dx,
        firstDataPathInfo.endPosition.dx);

    final Path firstUpperChannelFill = Path.combine(
        PathOperation.intersect, channelFillPath, firstLineAreaPath);
    final Path secondUpperChannelFill = Path.combine(
        PathOperation.difference, channelFillPath, firstLineAreaPath);

    canvas
      ..drawPath(firstDataPathInfo.path, firstLinePaint)
      ..drawPath(secondDataPathInfo.path, secondLinePaint)
      ..drawPath(firstUpperChannelFill, firstChannelFillPaint)
      ..drawPath(secondUpperChannelFill, secondChannelFillPaint);
  }
}
