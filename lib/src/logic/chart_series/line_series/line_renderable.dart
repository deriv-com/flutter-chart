import 'dart:ui';

import 'package:deriv_chart/src/logic/chart_series/base_renderable.dart';
import 'package:deriv_chart/src/logic/chart_series/base_series.dart';
import 'package:deriv_chart/src/models/animation_info.dart';
import 'package:deriv_chart/src/models/candle.dart';
import 'package:flutter/material.dart';

/// Line renderable
class LineRenderable extends BaseRendererable {
  /// Initializes
  LineRenderable(
    BaseSeries series,
    List<Candle> visibleEntries,
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
    Path path = Path();

    bool movedToStartPoint = false;

    for (int i = 0; i < visibleEntries.length - 1; i++) {
      final item = visibleEntries[i];
      if (item.close.isNaN) continue;

      if (!movedToStartPoint) {
        movedToStartPoint = true;
        path.moveTo(
          epochToX(item.epoch),
          quoteToY(item.close),
        );
        continue;
      }

      final x = epochToX(item.epoch);
      final y = quoteToY(item.close);
      path.lineTo(x, y);
    }

    if (prevLastEntry != null &&
        prevLastEntry.epoch == visibleEntries.last.epoch) {
      // Chart's first load
      final lastEntry = visibleEntries.last;
      path.lineTo(
          epochToX(lastEntry.epoch),
          quoteToY(lerpDouble(
            prevLastEntry.close,
            lastEntry.close,
            animationInfo.newTickPercent,
          )));
    } else {
      _addNewTickTpPath(path, animationInfo.newTickPercent, epochToX, quoteToY);
    }

    canvas.drawPath(path, Paint()..color = Colors.white12);
  }

  void _addNewTickTpPath(
    Path path,
    double newTickAnimationPercent,
    EpochToX epochToX,
    QuoteToY quoteToY,
  ) {
    final lastEntry = visibleEntries.last;
    final preLastEntry = visibleEntries[visibleEntries.length - 2];

    if (lastEntry.close.isNaN) return;

    path.lineTo(
      lerpDouble(
        epochToX(preLastEntry.epoch),
        epochToX(lastEntry.epoch),
        newTickAnimationPercent,
      ),
      quoteToY(lerpDouble(
        preLastEntry.close,
        lastEntry.close,
        newTickAnimationPercent,
      )),
    );
  }
}
