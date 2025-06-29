import 'dart:ui' as ui;

import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_data.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/line_series/line_painter.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/helpers/combine_paths.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/models/animation_info.dart';
import 'package:deriv_chart/src/deriv_chart/chart/y_axis/y_axis_config.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:deriv_chart/src/theme/painting_styles/line_style.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../data_painter.dart';
import '../data_series.dart';

/// A [DataPainter] for painting two line data and the channel fill inside
/// of them.
class ChannelFillPainter extends DataPainter<DataSeries<Tick>> {
  /// Initializes
  ChannelFillPainter(
    this.firstSeries,
    this.secondSeries, {
    this.firstUpperChannelFillColor,
    this.secondUpperChannelFillColor,
  })  : _firstLinePainter = LinePainter(firstSeries),
        _secondLinePainter = LinePainter(secondSeries),
        super(firstSeries);

  /// The first line series to be painting.
  final DataSeries<Tick> firstSeries;

  /// The second line series to be painting.
  final DataSeries<Tick> secondSeries;

  /// The color for channel fill when [firstSeries] is the upper series.
  Color? firstUpperChannelFillColor;

  /// The color for channel fill when [secondSeries] is the upper series.
  Color? secondUpperChannelFillColor;

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
      ..color =
          firstUpperChannelFillColor ?? firstLineStyle.color.withOpacity(0.2)
      ..style = PaintingStyle.fill
      ..strokeWidth = 0;

    final Paint secondLinePaint = Paint()
      ..color = secondLineStyle.color
      ..style = PaintingStyle.stroke
      ..strokeWidth = secondLineStyle.thickness;

    final Paint secondChannelFillPaint = Paint()
      ..color =
          secondUpperChannelFillColor ?? secondLineStyle.color.withOpacity(0.2)
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

    final Path firstLineAreaPath = Path.from(firstDataPathInfo.path);

    addAreaPath(canvas, size, firstLineAreaPath,
        firstDataPathInfo.startPosition.dx, firstDataPathInfo.endPosition.dx);

    Path firstUpperChannelFill, secondUpperChannelFill;

    if (kIsWeb) {
      final (Path, Path) paths = combinePaths(
          firstSeries,
          firstSeries.entries ?? <Tick>[],
          secondSeries.entries ?? <Tick>[],
          epochToX,
          quoteToY);

      firstUpperChannelFill = paths.$1;
      secondUpperChannelFill = paths.$2;
    } else {
      firstUpperChannelFill = Path.combine(
          PathOperation.intersect, channelFillPath, firstLineAreaPath);
      secondUpperChannelFill = Path.combine(
          PathOperation.difference, channelFillPath, firstLineAreaPath);
    }

    YAxisConfig.instance.yAxisClipping(canvas, size, () {
      canvas
        ..drawPath(firstDataPathInfo.path, firstLinePaint)
        ..drawPath(secondDataPathInfo.path, secondLinePaint)
        ..drawPath(firstUpperChannelFill, firstChannelFillPaint)
        ..drawPath(secondUpperChannelFill, secondChannelFillPaint);
    });
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

  @override
  List<CustomPainterSemantics> buildSemantics(
      {required ui.Size size,
      required EpochToX epochToX,
      required QuoteToY quoteToY}) {
    return <CustomPainterSemantics>[];
  }
}
