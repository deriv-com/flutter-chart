import 'dart:ui' as ui;

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
  LinePainter(DataSeries<Tick> series) : super(series);

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

    final Path path = Path();

    double lastVisibleTickX;
    bool isStartPointSet = false;
    // Adding visible entries line to the path except the last which might be animated.
    for (int i = 0; i < series.visibleEntries.length - 1; i++) {
      final Tick tick = series.visibleEntries[i];
      if (!tick.quote.isNaN) {
        if (!isStartPointSet) {
          isStartPointSet = true;
          path.moveTo(epochToX(tick.epoch), quoteToY(tick.quote));
          continue;
        }
       lastVisibleTickX= epochToX(tick.epoch);
        final double y = quoteToY(tick.quote);
        path.lineTo(lastVisibleTickX, y);
      }
    }

    // Adding last visible entry line to the path
    final Tick lastTick = series.entries.last;
    final Tick lastVisibleTick = series.visibleEntries.last;


    if (lastTick == lastVisibleTick && series.prevLastEntry != null) {
      lastVisibleTickX = ui.lerpDouble(
        epochToX(series.prevLastEntry.epoch),
        epochToX(lastTick.epoch),
        animationInfo.currentTickPercent,
      );

      final double tickY = quoteToY(ui.lerpDouble(
        series.prevLastEntry.quote,
        lastTick.quote,
        animationInfo.currentTickPercent,
      ));

      path.lineTo(lastVisibleTickX, tickY);
    } else {
      lastVisibleTickX = epochToX(lastVisibleTick.epoch);
      path.lineTo(lastVisibleTickX, quoteToY(lastVisibleTick.quote));
    }

    canvas.drawPath(path, linePaint);

    if (style.hasArea) {
      _drawArea(
        canvas,
        size,
        path,
        epochToX(series.visibleEntries.first.epoch),
        lastVisibleTickX,
        style,
      );
    }
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
