import 'dart:ui' as ui;

import 'package:deriv_chart/src/logic/chart_series/base_renderable.dart';
import 'package:deriv_chart/src/logic/chart_series/base_series.dart';
import 'package:deriv_chart/src/models/animation_info.dart';
import 'package:deriv_chart/src/models/candle.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:flutter/material.dart';

/// Line renderable
class LineRenderable extends BaseRendererable<Tick> {
  /// Initializes
  LineRenderable(
    BaseSeries<Tick> series,
    List<Tick> visibleEntries,
    Candle prevLastCandle,
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

    bool movedToStartPoint = false;

    for (int i = 0; i < visibleEntries.length - 1; i++) {
      final Tick tick = visibleEntries[i];
      if (tick.quote.isNaN) {
        continue;
      }

      if (!movedToStartPoint) {
        movedToStartPoint = true;
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

    if (prevLastEntry != null &&
        prevLastEntry.epoch == visibleEntries.last.epoch) {
      // Chart's first load
      final Tick lastTick = visibleEntries.last;
      path.lineTo(
          epochToX(lastTick.epoch),
          quoteToY(ui.lerpDouble(
            prevLastEntry.quote,
            lastTick.quote,
            animationInfo.newTickPercent,
          )));
    } else {
      _addNewTickTpPath(path, animationInfo.newTickPercent, epochToX, quoteToY);
    }

    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    _drawArea(
      canvas,
      size,
      path,
      epochToX(visibleEntries.last.epoch),
    );
  }

  void _addNewTickTpPath(
    Path path,
    double newTickAnimationPercent,
    EpochToX epochToX,
    QuoteToY quoteToY,
  ) {
    final Tick lastTick = visibleEntries.last;
    final Tick secondLastTick = visibleEntries[visibleEntries.length - 2];

    if (lastTick.quote.isNaN) {
      return;
    }

    path.lineTo(
      ui.lerpDouble(
        epochToX(secondLastTick.epoch),
        epochToX(lastTick.epoch),
        newTickAnimationPercent,
      ),
      quoteToY(ui.lerpDouble(
        secondLastTick.quote,
        lastTick.quote,
        newTickAnimationPercent,
      )),
    );
  }

  void _drawArea(
    Canvas canvas,
    Size size,
    Path linePath,
    double lineEndX,
  ) {
    final Paint areaPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = ui.Gradient.linear(
        const Offset(0, 0),
        Offset(0, size.height),
        <Color>[
          Colors.white.withOpacity(0.3),
          Colors.white.withOpacity(0.01),
        ],
      );

    linePath
      ..lineTo(
        lineEndX,
        size.height,
      )
      ..lineTo(0, size.height);

    canvas.drawPath(
      linePath,
      areaPaint,
    );
  }
}
