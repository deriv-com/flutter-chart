import 'dart:ui';

import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/series_painter.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/models/animation_info.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/models/barrier_objects.dart';
import 'package:deriv_chart/src/deriv_chart/chart/helpers/paint_functions/paint_line.dart';
import 'package:deriv_chart/src/theme/painting_styles/barrier_style.dart';
import 'package:flutter/material.dart';

import '../../../chart_data.dart';
import 'vertical_barrier.dart';

/// A class for painting horizontal barriers.
class VerticalBarrierPainter extends SeriesPainter<VerticalBarrier> {
  /// Initializes [series].
  VerticalBarrierPainter(VerticalBarrier series) : super(series);

  @override
  void onPaint({
    required Canvas canvas,
    required Size size,
    required EpochToX epochToX,
    required QuoteToY quoteToY,
    required AnimationInfo animationInfo,
  }) {
    if (series.isOnRange) {
      final VerticalBarrierStyle style =
          series.style as VerticalBarrierStyle? ?? theme.verticalBarrierStyle;

      final Paint paint = Paint()
        ..color = style.color
        ..strokeWidth = 1
        ..style = PaintingStyle.stroke;

      int? animatedEpoch;
      double lineStartY = 0;
      double? dotY;

      if (series.previousObject == null) {
        animatedEpoch = series.epoch;
        if (series.quote != null) {
          dotY = quoteToY(series.quote!);
        }
      } else {
        final VerticalBarrierObject prevObject =
            series.previousObject as VerticalBarrierObject;
        animatedEpoch = lerpDouble(prevObject.epoch.toDouble(), series.epoch,
                animationInfo.currentTickPercent)!
            .toInt();

        if (series.annotationObject.quote != null && prevObject.quote != null) {
          dotY = quoteToY(lerpDouble(
              prevObject.quote,
              series.annotationObject.quote,
              animationInfo.currentTickPercent)!);
        }
      }

      final double lineX = epochToX(animatedEpoch!);
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
    VerticalBarrierStyle style,
  ) {
    final TextPainter titlePainter = TextPainter(
      text: TextSpan(
        text: series.title,
        style: style.textStyle.copyWith(color: style.color),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout();

    late double titleStartX;

    switch (style.labelPosition) {
      case VerticalBarrierLabelPosition.auto:
        titleStartX = lineX - titlePainter.width - 5;
        if (titleStartX < 0) {
          titleStartX = lineX + 5;
        }
        break;
      case VerticalBarrierLabelPosition.right:
        titleStartX = lineX + 5;
        break;
      case VerticalBarrierLabelPosition.left:
        titleStartX = lineX - titlePainter.width - 5;
        break;
    }

    titlePainter.paint(
      canvas,
      Offset(titleStartX, lineEndY - titlePainter.height),
    );
  }
}
