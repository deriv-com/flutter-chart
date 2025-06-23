import 'dart:ui' as ui;

import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_data.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/models/animation_info.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:deriv_chart/src/theme/painting_styles/line_style.dart';
import 'package:flutter/material.dart';

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
    final LineStyle style = series.style as LineStyle? ?? theme.lineStyle;

    final Paint linePaint = Paint()
      ..color = style.color
      ..style = PaintingStyle.stroke
      ..strokeWidth = style.thickness;

    final DataLinePathInfo path = createPath(epochToX, quoteToY, animationInfo);

    paintLines(canvas, path.path, linePaint);

    if (style.hasArea) {
      final Paint areaPaint = Paint()
        ..style = PaintingStyle.fill
        ..shader = ui.Gradient.linear(
          const Offset(0, 0),
          Offset(0, size.height),
          <Color>[
            style.areaGradientColors.start,
            style.areaGradientColors.end,
          ],
        );

      addAreaPath(
        canvas,
        size,
        path.path,
        path.startPosition.dx,
        path.endPosition.dx,
      );

      canvas.drawPath(path.path, areaPaint);
    }
  }

  /// Paints the line on the given canvas.
  /// We can add channel fill here in the subclasses.
  void paintLines(
    Canvas canvas,
    Path path,
    Paint linePaint,
  ) {
    canvas.drawPath(path, linePaint);
  }

  /// Creates the path of the given [series] and returns it.
  DataLinePathInfo createPath(
    EpochToX epochToX,
    QuoteToY quoteToY,
    AnimationInfo animationInfo,
  ) {
    final Path path = Path();

    if (series.entries == null) {
      return DataLinePathInfo(path, Offset.zero, Offset.zero);
    }

    Offset? startPosition, endPosition;

    // Adding visible entries line to the path except the last which might
    //be animated.
    for (int i = series.visibleEntries.startIndex;
        i < series.visibleEntries.endIndex - 1;
        i++) {
      final Tick tick = series.entries![i];

      if (!tick.quote.isNaN) {
        endPosition =
            Offset(epochToX(getEpochOf(tick, i)), quoteToY(tick.quote));

        if (startPosition == null) {
          startPosition = endPosition;
          path.moveTo(startPosition.dx, startPosition.dy);
          continue;
        }

        path.lineTo(endPosition.dx, endPosition.dy);
      }
    }

    endPosition = _addLastVisibleTick(epochToX, animationInfo, quoteToY, path);

    return startPosition != null && endPosition != null
        ? DataLinePathInfo(path, startPosition, endPosition)
        : DataLinePathInfo(path, Offset.zero, Offset.zero);
  }

  /// Adds the line to the last visible tick's position regarding the
  /// `animationInfo.currentTickPercent` animation.
  ///
  /// Returns the position of the last visible tick.
  Offset? _addLastVisibleTick(
    EpochToX epochToX,
    AnimationInfo animationInfo,
    QuoteToY quoteToY,
    ui.Path path,
  ) {
    final Tick lastTick = series.entries!.last;
    final Tick lastVisibleTick = series.visibleEntries.last;
    Offset? lastVisibleTickPosition;

    if (!lastVisibleTick.quote.isNaN) {
      if (lastTick == lastVisibleTick && series.prevLastEntry != null) {
        final double tickX = ui.lerpDouble(
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

        lastVisibleTickPosition = Offset(tickX, tickY);

        path.lineTo(lastVisibleTickPosition.dx, lastVisibleTickPosition.dy);
      } else {
        lastVisibleTickPosition = Offset(
          epochToX(
              getEpochOf(lastVisibleTick, series.visibleEntries.endIndex - 1)),
          quoteToY(lastVisibleTick.quote),
        );
        path.lineTo(lastVisibleTickPosition.dx, lastVisibleTickPosition.dy);
      }
    }

    return lastVisibleTickPosition;
  }
}

/// Returns the area paint of the given [Path].
void addAreaPath(
  Canvas canvas,
  Size size,
  Path linePath,
  double lineStartX,
  double lineEndX,
) {
  linePath
    ..lineTo(
      lineEndX,
      size.height,
    )
    ..lineTo(lineStartX, size.height);
  return;
}

/// A class for holding the information of a [DataSeries] line path.
class DataLinePathInfo {
  /// Initializes.
  DataLinePathInfo(this.path, this.startPosition, this.endPosition);

  /// The path of the line data.
  final Path path;

  /// The left-most visible tick's position.
  final Offset startPosition;

  /// The right-most visible tick's position.
  final Offset endPosition;
}
