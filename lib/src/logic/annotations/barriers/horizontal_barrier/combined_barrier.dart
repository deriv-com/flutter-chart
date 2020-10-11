import 'dart:ui';

import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/logic/chart_data.dart';
import 'package:deriv_chart/src/models/animation_info.dart';
import 'package:deriv_chart/src/models/barrier_objects.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:deriv_chart/src/theme/painting_styles/barrier_style.dart';
import 'package:flutter/material.dart';

import 'horizontal_barrier.dart';

class CombinedBarrier extends HorizontalBarrier {
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
        super(tick.quote, id: id, style: style);

  /// For vertical barrier.
  final VerticalBarrier verticalBarrier;

  /// The for epoch and quote.
  final Tick tick;

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
      canvas,
      size,
      epochToX,
      quoteToY,
      animationInfo,
      pipSize,
      granularity,
    );

    verticalBarrier.paint(
      canvas,
      size,
      epochToX,
      quoteToY,
      animationInfo,
      pipSize,
      granularity,
    );

    final int prevEpoch =
        (verticalBarrier.previousObject as VerticalBarrierObject).epoch;

    final prevQuote = (previousObject as HorizontalBarrierObject).value;

    canvas.drawCircle(
      Offset(
          lerpDouble(
            epochToX(prevEpoch),
            epochToX(tick.epoch),
            animationInfo.currentTickPercent,
          ),
          quoteToY(
            lerpDouble(
              prevQuote,
              tick.quote,
              animationInfo.currentTickPercent,
            ),
          )),
      4,
      Paint()..color = Colors.redAccent,
    );
  }
}
