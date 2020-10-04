import 'dart:ui';

import 'package:deriv_chart/src/logic/annotations/chart_annotation.dart';
import 'package:deriv_chart/src/models/animation_info.dart';
import 'package:deriv_chart/src/models/chart_object.dart';
import 'package:flutter/material.dart';

class BarrierObject extends ChartObject {
  BarrierObject(this.value) : super(null, null, value, value);

  final double value;
}

class Barrier extends ChartAnnotation<BarrierObject> {
  Barrier(
    this.value, {
    String id,
    String title,
  }) : super(id) {
    annotationObject = BarrierObject(value);
  }

  final double value;

  @override
  void paint(
    Canvas canvas,
    Size size,
    epochToX,
    quoteToY,
    AnimationInfo animationInfo,
    int pipSize,
    int granularity,
  ) {
    if (isOnRange) {
      Paint paint = Paint()
        ..color = const Color(0xFF00A79E)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;
      double animatedValue;

      if (previousObject == null) {
        animatedValue = value;
      } else {
        final BarrierObject previousBarrier = previousObject;
        animatedValue = lerpDouble(
          previousBarrier.value,
          value,
          animationInfo.currentTickPercent,
        );
      }

      final double y = quoteToY(animatedValue);
      canvas.drawLine(Offset(0, y), Offset(size.width - 120, y), paint);
      canvas.drawLine(Offset(size.width - 30, y), Offset(size.width, y), paint);
    }
  }
}
