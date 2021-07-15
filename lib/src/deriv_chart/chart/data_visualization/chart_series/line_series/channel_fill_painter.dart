import 'dart:ui' as ui;

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
class ChannelFillPainter extends DataPainter<DataSeries<Tick>> {
  /// Initializes
  ChannelFillPainter(
    this.firstSeries,
    this.secondSeries,
  )   : _firstLinePainter = LinePainter(firstSeries),
        _secondLinePainter = LinePainter(secondSeries),
        super(firstSeries);

  /// The first line series to be painting.
  final DataSeries<Tick> firstSeries;

  /// The second line series to be painting.
  final DataSeries<Tick> secondSeries;

  final LinePainter _firstLinePainter;
  final LinePainter _secondLinePainter;

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
        secondSeries.style as LineStyle? ?? theme.lineStyle;

    final Paint firstLinePaint = Paint()
      ..color = firstLineStyle.color
      ..style = PaintingStyle.stroke
      ..strokeWidth = firstLineStyle.thickness;

    final Paint firstChannelFillPaint = Paint()
      ..color = firstLineStyle.color.withOpacity(0.2)
      ..style = PaintingStyle.fill
      ..strokeWidth = 0;

    final Paint secondLinePaint = Paint()
      ..color = secondLineStyle.color
      ..style = PaintingStyle.stroke
      ..strokeWidth = secondLineStyle.thickness;

    final Paint secondChannelFillPaint = Paint()
      ..color = secondLineStyle.color.withOpacity(0.2)
      ..style = PaintingStyle.fill
      ..strokeWidth = 0;

    final DataLinePathInfo firstDataPathInfo =
        _firstLinePainter.createPath(epochToX, quoteToY, animationInfo);
    final DataLinePathInfo secondDataPathInfo =
        _secondLinePainter.createPath(epochToX, quoteToY, animationInfo);

    final Path channelFillPath = Path.from(firstDataPathInfo.path)
      ..lineTo(
          secondDataPathInfo.endPosition.dx, secondDataPathInfo.endPosition.dy);

    _createPathReverse(
        secondSeries, epochToX, quoteToY, animationInfo, channelFillPath);

    channelFillPath.lineTo(
        firstDataPathInfo.startPosition.dx, firstDataPathInfo.startPosition.dy);

    final Path firstLineAreaPath = _firstLinePainter.areaPath(
        canvas,
        size,
        Path.from(firstDataPathInfo.path),
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

  void _createPathReverse(
    DataSeries<Tick> series,
    EpochToX epochToX,
    QuoteToY quoteToY,
    AnimationInfo animationInfo,
    Path path,
  ) {
    double? lastVisibleTickX;
    // Check for animated lower tick.
    final Tick lastLowerTick = series.entries!.last;
    final Tick lastLowerVisibleTick = series.visibleEntries.last;

    if (lastLowerTick == lastLowerVisibleTick && series.prevLastEntry != null) {
      lastVisibleTickX = ui.lerpDouble(
        epochToX(series.getEpochOf(
          series.prevLastEntry!.entry,
          series.prevLastEntry!.index,
        )),
        epochToX(lastLowerTick.epoch),
        animationInfo.currentTickPercent,
      );

      final double tickY = quoteToY(ui.lerpDouble(
        series.prevLastEntry!.entry.quote,
        lastLowerTick.quote,
        animationInfo.currentTickPercent,
      )!);

      path.lineTo(lastVisibleTickX!, tickY);
    } else {
      lastVisibleTickX = epochToX(lastLowerVisibleTick.epoch);
      path.lineTo(lastVisibleTickX, quoteToY(lastLowerVisibleTick.quote));
    }

    for (int i = series.visibleEntries.endIndex - 1;
        i >= series.visibleEntries.startIndex;
        i--) {
      final Tick tick = series.entries![i];
      path.lineTo(
        epochToX(series.getEpochOf(tick, i)),
        quoteToY(tick.quote),
      );
    }

    return;
  }
}
