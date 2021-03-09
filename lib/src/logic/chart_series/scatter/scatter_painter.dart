import 'package:deriv_chart/src/logic/chart_series/data_painter.dart';
import 'package:deriv_chart/src/models/animation_info.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:deriv_chart/src/theme/painting_styles/scatter_style.dart';
import 'package:flutter/material.dart';

import '../../chart_data.dart';
import '../data_series.dart';

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
    final ScatterStyle style = series.style ?? const ScatterStyle();

    final Paint dotPaint = Paint()
      ..color = style.color
      ..style = PaintingStyle.fill;

    for (int i = 0; i < series.visibleEntries.length; i++) {
      final Tick tick = series.visibleEntries[i];

      if (!tick.quote.isNaN) {
        final double x = epochToX(tick.epoch);
        final double y = quoteToY(tick.quote);
        canvas.drawCircle(Offset(x, y), style.radius, dotPaint);
      }
    }
  }
}
