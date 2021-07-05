import 'dart:ui' as ui;

import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/models/animation_info.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:deriv_chart/src/theme/painting_styles/line_style.dart';
import 'package:flutter/material.dart';

import '../../chart_data.dart';
import '../data_painter.dart';
import '../data_series.dart';

/// A [DataPainter] for painting line data.
class LinePainter extends DataPainter<DataSeries<Tick>> {
  /// Initializes
  LinePainter(
    DataSeries<Tick> series,
  ) : super(series);

  @override
  void onPaintData(
    Canvas canvas,
    Size size,
    EpochToX epochToX,
    QuoteToY quoteToY,
    AnimationInfo animationInfo,
  ) {
    final List<DataPathInfo> paths =
        createPath(epochToX, quoteToY, animationInfo, size);

    paintLines(canvas, paths);
  }

  /// Paints the line on the given canvas.
  /// We can add channel fill here in the subclasses.
  void paintLines(Canvas canvas, List<DataPathInfo> paths) {
    for (final DataPathInfo pathInfo in paths) {
      canvas.drawPath(pathInfo.path, pathInfo.paint);
    }
  }

  /// Creates the path of the given [series] and returns it.
  List<DataPathInfo> createPath(
    EpochToX epochToX,
    QuoteToY quoteToY,
    AnimationInfo animationInfo,
    Size size,
  ) {
    final List<DataPathInfo> paths = <DataPathInfo>[];
    final Path dataLinePath = Path();

    late double lastVisibleTickX;
    bool isStartPointSet = false;

    // Adding visible entries line to the path except the last which might be animated.
    for (int i = series.visibleEntries.startIndex;
        i < series.visibleEntries.endIndex - 1;
        i++) {
      final Tick tick = series.entries![i];

      if (!tick.quote.isNaN) {
        lastVisibleTickX = epochToX(getEpochOf(tick, i));

        if (!isStartPointSet) {
          isStartPointSet = true;
          dataLinePath.moveTo(
            lastVisibleTickX,
            quoteToY(tick.quote),
          );
          continue;
        }

        final double y = quoteToY(tick.quote);
        dataLinePath.lineTo(lastVisibleTickX, y);
      }
    }

    final Offset? lastVisibleTickPosition = calculateLastVisibleTickPosition(
        epochToX, animationInfo, quoteToY, dataLinePath);

    if (lastVisibleTickPosition != null) {
      dataLinePath.lineTo(
          lastVisibleTickPosition.dx, lastVisibleTickPosition.dy);

      lastVisibleTickX = lastVisibleTickPosition.dx;
    }

    final LineStyle style = series.style as LineStyle? ?? theme.lineStyle;

    final Paint linePaint = Paint()
      ..color = style.color
      ..style = PaintingStyle.stroke
      ..strokeWidth = style.thickness;

    paths.add(DataPathInfo(dataLinePath, linePaint));

    if (style.hasArea) {
      final DataPathInfo areaPath = _getArea(
        size,
        dataLinePath,
        epochToX(series.visibleEntries.first.epoch),
        lastVisibleTickX,
        style,
      );
      paths.add(areaPath);
    }

    return paths;
  }

  /// calculates the last visible tick's position.
  @protected
  Offset? calculateLastVisibleTickPosition(
    EpochToX epochToX,
    AnimationInfo animationInfo,
    QuoteToY quoteToY,
    ui.Path path,
  ) {
    final Tick lastTick = series.entries!.last;
    final Tick lastVisibleTick = series.visibleEntries.last;
    late double lastVisibleTickX;

    if (!lastVisibleTick.quote.isNaN) {
      if (lastTick == lastVisibleTick && series.prevLastEntry != null) {
        lastVisibleTickX = ui.lerpDouble(
          epochToX(
            getEpochOf(
                series.prevLastEntry!.entry, series.prevLastEntry!.index),
          ),
          epochToX(getEpochOf(lastTick, series.entries!.length - 1)),
          animationInfo.currentTickPercent,
        )!;

        final double tickY = quoteToY(ui.lerpDouble(
          series.prevLastEntry!.entry.quote,
          lastTick.quote,
          animationInfo.currentTickPercent,
        )!);

        return Offset(lastVisibleTickX, tickY);
      } else {
        lastVisibleTickX = epochToX(
            getEpochOf(lastVisibleTick, series.visibleEntries.endIndex - 1));
        return Offset(lastVisibleTickX, quoteToY(lastVisibleTick.quote));
      }
    }

    return null;
  }

  DataPathInfo _getArea(
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

    final Path areaPath = Path.from(linePath)
      ..lineTo(
        lineEndX,
        size.height,
      )
      ..lineTo(lineStartX, size.height);

    return DataPathInfo(areaPath, areaPaint);
  }
}

/// A class for holding the information required to paint a path.
///
/// this information can represent a line data or a fill area on an indicator.
class DataPathInfo {
  /// Initializes
  DataPathInfo(this.path, this.paint);

  /// The Path
  final Path path;

  /// Paint object which describes how this [path] is going to be painted.
  final Paint paint;
}
