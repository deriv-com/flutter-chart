import 'package:deriv_chart/deriv_chart.dart';
import 'package:flutter/material.dart';

import '../data_painter.dart';

/// A [DataPainter] for painting scatter.
class ScatterPainter extends DataPainter<DataSeries<Tick>> {
  /// Initializes
  ScatterPainter(DataSeries<Tick> series) : super(series);

  @override
  void onPaintData(
    Canvas canvas,
    Size size,
    EpochToX epochToX,
    QuoteToY quoteToY,
    AnimationInfo animationInfo,
  ) {
    if (series.entries == null) {
      return;
    }

    final ScatterStyle style =
        series.style as ScatterStyle? ?? const ScatterStyle();

    final Paint dotPaint = Paint()
      ..color = style.color
      ..style = PaintingStyle.fill;

    for (int i = series.visibleEntries.startIndex;
        i < series.visibleEntries.endIndex;
        i++) {
      final Tick tick = series.entries![i];

      if (!tick.quote.isNaN) {
        final double x = epochToX(getEpochOf(tick, i));
        final double y = quoteToY(tick.quote);
        performClipping(canvas, size, () {
          canvas.drawCircle(Offset(x, y), style.radius, dotPaint);
        });
      }
    }
  }
}
