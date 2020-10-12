import 'dart:ui';

import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/logic/chart_data.dart';
import 'package:deriv_chart/src/models/animation_info.dart';
import 'package:deriv_chart/src/models/barrier_objects.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:deriv_chart/src/theme/painting_styles/barrier_style.dart';
import 'package:flutter/material.dart';

import 'horizontal_barrier.dart';

/// A barrier with both horizontal and vertical barriers.
class CombinedBarrier extends HorizontalBarrier {
  /// Initializes
  CombinedBarrier(
    this.tick, {
    String id,
    String title,
    BarrierStyle style,
  })  : verticalBarrier = VerticalBarrier(
          tick.epoch,
          title: title,
          style: style,
        ),
        _dotPaint = Paint()
          ..color = Colors.redAccent
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
        super(tick.quote, id: id, style: style);

  /// For vertical barrier.
  final VerticalBarrier verticalBarrier;

  /// The for epoch and quote.
  final Tick tick;

  final Paint _dotPaint;

  @override
  void update(int leftEpoch, int rightEpoch) {
    super.update(leftEpoch, rightEpoch);

    verticalBarrier.update(leftEpoch, rightEpoch);
  }

  @override
  void didUpdate(ChartData oldData) {
    super.didUpdate(oldData);

    final CombinedBarrier combinedBarrier = oldData;
    verticalBarrier.didUpdate(combinedBarrier.verticalBarrier);
  }

  @override
  void paint(
    Canvas canvas,
    Size size,
    EpochToX epochToX,
    QuoteToY quoteToY,
    AnimationInfo animationInfo,
    int pipSize,
    int granularity,
  ) {
    super.paint(
        canvas, size, epochToX, quoteToY, animationInfo, pipSize, granularity);

    verticalBarrier.paint(
        canvas, size, epochToX, quoteToY, animationInfo, pipSize, granularity);

    _paintCircleOnIntersection(canvas, epochToX, quoteToY, animationInfo);
  }

  void _paintCircleOnIntersection(
    Canvas canvas,
    EpochToX epochToX,
    QuoteToY quoteToY,
    AnimationInfo animationInfo,
  ) {
    final VerticalBarrierObject prevVerticalObject =
        verticalBarrier.previousObject;

    final HorizontalBarrierObject prevHorizontalObject = previousObject;

    canvas.drawCircle(
      Offset(
          prevVerticalObject == null
              ? epochToX(tick.epoch)
              : lerpDouble(
                  epochToX(prevVerticalObject.epoch),
                  epochToX(tick.epoch),
                  animationInfo.currentTickPercent,
                ),
          quoteToY(
            prevHorizontalObject == null
                ? tick.quote
                : lerpDouble(
                    prevHorizontalObject.value,
                    tick.quote,
                    animationInfo.currentTickPercent,
                  ),
          )),
      3,
      _dotPaint,
    );
  }
}
