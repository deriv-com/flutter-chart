import 'dart:ui' as ui;

import 'package:deriv_chart/src/logic/chart_series/data_series.dart';
import 'package:deriv_chart/src/logic/chart_series/renderable.dart';
import 'package:deriv_chart/src/logic/chart_series/series.dart';
import 'package:deriv_chart/src/models/animation_info.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:deriv_chart/src/theme/painting_styles/line_style.dart';
import 'package:flutter/material.dart';

import '../../chart_data.dart';
import 'line_series.dart';

/// Line renderable for painting line data.
class LineRenderable extends Rendererable<LineSeries> {
  /// Initializes
  LineRenderable(LineSeries series) : super(series);

  @override
  void onPaint({
    Canvas canvas,
    Size size,
    EpochToX epochToX,
    QuoteToY quoteToY,
    AnimationInfo animationInfo,
  }) {
    final Path path = Path();

    bool isStartPointSet = false;

    for (int i = 0; i < series.visibleEntries.length - 1; i++) {
      final Tick tick = series.visibleEntries[i];

      if (!isStartPointSet) {
        isStartPointSet = true;
        path.moveTo(epochToX(tick.epoch), quoteToY(tick.quote));
        continue;
      }

      final double x = epochToX(tick.epoch);
      final double y = quoteToY(tick.quote);
      path.lineTo(x, y);
    }

    // Last visible Tick
    final Tick lastTick = series.entries.last;
    final Tick lastVisibleTick = series.visibleEntries.last;
    double lastVisibleTickX;

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

    final LineStyle style = series.style;

    canvas.drawPath(
      path,
      Paint()
        ..color = style.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = style.thickness,
    );

    if ((series.style as LineStyle).hasArea) {
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
