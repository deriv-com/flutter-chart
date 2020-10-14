import 'dart:ui';

import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/logic/chart_data.dart';
import 'package:deriv_chart/src/models/animation_info.dart';
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
    HorizontalBarrierStyle horizontalBarrierStyle,
    VerticalBarrierStyle verticalBarrierStyle,
  })  : verticalBarrier = VerticalBarrier.onTick(
          tick,
          title: title,
          style: verticalBarrierStyle ?? const VerticalBarrierStyle(),
        ),
        super(
          tick.quote,
          id: id,
          style: horizontalBarrierStyle ?? const HorizontalBarrierStyle(),
        );

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
        canvas, size, epochToX, quoteToY, animationInfo, pipSize, granularity);

    verticalBarrier.paint(
        canvas, size, epochToX, quoteToY, animationInfo, pipSize, granularity);
  }
}
