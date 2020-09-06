import 'dart:ui' as ui;

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
          quoteToY(ui.lerpDouble(
            prevLastEntry.close,
            lastEntry.close,
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
          ..strokeWidth = 1);

    _drawArea(
      canvas,
      size,
      linePath: path,
      lineEndX: epochToX(visibleEntries.last.epoch),
    );
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
      ui.lerpDouble(
        epochToX(preLastEntry.epoch),
        epochToX(lastEntry.epoch),
        newTickAnimationPercent,
      ),
      quoteToY(ui.lerpDouble(
        preLastEntry.close,
        lastEntry.close,
        newTickAnimationPercent,
      )),
    );
  }

  void _drawArea(
    Canvas canvas,
    Size size, {
    Path linePath,
    double lineEndX,
  }) {
    final areaPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = ui.Gradient.linear(
        Offset(0, 0),
        Offset(0, size.height),
        [
          Colors.white.withOpacity(0.3),
          Colors.white.withOpacity(0.01),
        ],
      );

    linePath.lineTo(
      lineEndX,
      size.height,
    );
    linePath.lineTo(0, size.height);

    canvas.drawPath(
      linePath,
      areaPaint,
    );
  }
}
