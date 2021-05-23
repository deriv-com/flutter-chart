import 'dart:ui';

import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/series_painter.dart';
import 'package:deriv_chart/src/helpers/paint_functions/paint_line.dart';
import 'package:deriv_chart/src/logic/chart_data.dart';
import 'package:deriv_chart/src/models/animation_info.dart';
import 'package:deriv_chart/src/models/barrier_objects.dart';
import 'package:deriv_chart/src/theme/painting_styles/barrier_style.dart';
import 'package:flutter/material.dart';

import 'vertical_barrier.dart';

/// A class for painting horizontal barriers.
class VerticalBarrierPainter extends SeriesPainter<VerticalBarrier> {
  /// Initializes [series].
  VerticalBarrierPainter(VerticalBarrier series) : super(series);

  @override
  void onPaint({
    Canvas canvas,
    Size size,
    EpochToX epochToX,
    QuoteToY quoteToY,
    AnimationInfo animationInfo,
  }) {
    if (series.isOnRange) {
      final BarrierStyle style = series.style ??
          theme.verticalBarrierStyle ??
          const VerticalBarrierStyle();

      final Paint paint = Paint()
        ..color = style.color
        ..strokeWidth = 1
        ..style = PaintingStyle.stroke;

      int animatedEpoch;
      double lineStartY = 0;
      double dotY;

      if (series.previousObject == null) {
        animatedEpoch = series.epoch;
        if (series.value != null) {
          dotY = quoteToY(series.value);
        }
      } else {
        final VerticalBarrierObject prevObject = series.previousObject;
        animatedEpoch = lerpDouble(prevObject.epoch.toDouble(), series.epoch,
                animationInfo.currentTickPercent)
            .toInt();

        if (series.annotationObject.value != null && prevObject.value != null) {
          dotY = quoteToY(lerpDouble(prevObject.value,
              series.annotationObject.value, animationInfo.currentTickPercent));
        }
      }

      final double lineX = epochToX(animatedEpoch);
      final double lineEndY = size.height - 20;

      if (dotY != null && !series.longLine) {
        lineStartY = dotY;
      }

      if (style.isDashed) {
        paintVerticalDashedLine(
            canvas, lineX, lineStartY, lineEndY, style.color, 1);
      } else {
        canvas.drawLine(
            Offset(lineX, lineStartY), Offset(lineX, lineEndY), paint);
      }

      _paintLineLabel(canvas, lineX, lineEndY, style);
    }
  }

  void _paintLineLabel(
    Canvas canvas,
    double lineX,
    double lineEndY,
    BarrierStyle style,
  ) {
    final TextPainter titlePainter = TextPainter(
      text: TextSpan(
        text: series.title,
        style: style.textStyle.copyWith(color: style.color),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout();

    double titleStartX = lineX - titlePainter.width - 5;

    if (titleStartX < 0) {
      titleStartX = lineX + 5;
    }

    titlePainter.paint(
      canvas,
      Offset(titleStartX, lineEndY - titlePainter.height),
    );
  }
}
