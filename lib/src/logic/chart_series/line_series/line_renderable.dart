import 'dart:ui' as ui;

import 'package:deriv_chart/src/logic/chart_series/base_renderable.dart';
import 'package:deriv_chart/src/logic/chart_series/base_series.dart';
import 'package:deriv_chart/src/models/animation_info.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:deriv_chart/src/theme/painting_styles/line_style.dart';
import 'package:flutter/material.dart';

/// Line renderable
class LineRenderable extends BaseRendererable<Tick> {
  /// Initializes
  LineRenderable(
    BaseSeries<Tick> series,
    List<Tick> visibleEntries,
    Tick prevLastCandle,
  ) : super(series, visibleEntries, prevLastCandle);

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

    for (int i = 0; i < visibleEntries.length - 1; i++) {
      final Tick tick = visibleEntries[i];

      if (!isStartPointSet) {
        isStartPointSet = true;
        path.moveTo(
          epochToX(tick.epoch),
          quoteToY(tick.quote),
        );
        continue;
      }

      final double x = epochToX(tick.epoch);
      final double y = quoteToY(tick.quote);
      path.lineTo(x, y);
    }

    // Last visible Tick
    final Tick lastTick = series.entries.last;
    final Tick lastVisibleTick = visibleEntries.last;
    double lastVisibleTickX;

    if (lastTick == lastVisibleTick && prevLastEntry != null) {
      lastVisibleTickX = ui.lerpDouble(
        epochToX(prevLastEntry.epoch),
        epochToX(lastTick.epoch),
        animationInfo.newTickPercent,
      );

      final double tickY = quoteToY(ui.lerpDouble(
        prevLastEntry.quote,
        lastTick.quote,
        animationInfo.newTickPercent,
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

    _drawArea(
      canvas,
      size,
      path,
      epochToX(visibleEntries.first.epoch),
      lastVisibleTickX,
      style,
    );
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

    canvas.drawPath(
      linePath,
      areaPaint,
    );
  }
}
