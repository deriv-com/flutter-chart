import 'dart:ui';

import 'package:deriv_chart/src/logic/chart_series/series_painter.dart';
import 'package:deriv_chart/src/models/animation_info.dart';

import 'barrier.dart';

class BarrierPainter extends SeriesPainter<Barrier> {
  BarrierPainter(Barrier series) : super(series);

  @override
  void onPaint({
    Canvas canvas,
    Size size,
    epochToX,
    quoteToY,
    AnimationInfo animationInfo,
  }) {
    if (series.isOnRange) {
      Paint paint = Paint()
        ..color = const Color(0xFF00A79E)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;
      double animatedValue;

      if (series.previousObject == null) {
        animatedValue = series.value;
      } else {
        final BarrierObject previousBarrier = series.previousObject;
        animatedValue = lerpDouble(
          previousBarrier.value,
          series.value,
          animationInfo.currentTickPercent,
        );
      }

      final double y = quoteToY(animatedValue);
      canvas.drawLine(Offset(0, y), Offset(size.width - 120, y), paint);
      canvas.drawLine(Offset(size.width - 30, y), Offset(size.width, y), paint);
    }
  }
}
