import 'dart:ui';

import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/annotations/barriers/vertical_barrier/vertical_barrier.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/models/animation_info.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/models/chart_scale_model.dart';
import 'package:deriv_chart/src/models/chart_config.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:deriv_chart/src/theme/painting_styles/barrier_style.dart';
import 'package:flutter/material.dart';

import '../../../chart_data.dart';
import 'horizontal_barrier.dart';

/// A barrier with both horizontal and vertical barriers.
class CombinedBarrier extends HorizontalBarrier {
  /// Initializes a barrier with both horizontal and vertical barriers.
  CombinedBarrier(
    this.tick, {
    String? id,
    String? title,
    bool verticalLongLine = true,
    bool horizontalLongLine = false,
    HorizontalBarrierStyle? horizontalBarrierStyle,
    VerticalBarrierStyle? verticalBarrierStyle,
    HorizontalBarrierVisibility visibility = HorizontalBarrierVisibility.normal,
  })  : verticalBarrier = VerticalBarrier.onTick(
          tick,
          title: title,
          longLine: verticalLongLine,
          style: verticalBarrierStyle,
        ),
        super(
          tick.quote,
          epoch: tick.epoch,
          id: id,
          longLine: horizontalLongLine,
          style: horizontalBarrierStyle,
          visibility: visibility,
        );

  /// For vertical barrier.
  final VerticalBarrier verticalBarrier;

  /// The tick this barrier points to.
  final Tick tick;

  @override
  void update(int leftEpoch, int rightEpoch) {
    super.update(leftEpoch, rightEpoch);

    verticalBarrier.update(leftEpoch, rightEpoch);
  }

  @override
  bool didUpdate(ChartData? oldData) {
    if (oldData == null) {
      return super.didUpdate(oldData);
    }

    final bool superDidUpdated = super.didUpdate(oldData);

    final CombinedBarrier combinedBarrier = oldData as CombinedBarrier;

    final bool verticalBarrierDidUpdated =
        verticalBarrier.didUpdate(combinedBarrier.verticalBarrier);

    return superDidUpdated || verticalBarrierDidUpdated;
  }

  @override
  void paint(
    Canvas canvas,
    Size size,
    EpochToX epochToX,
    QuoteToY quoteToY,
    AnimationInfo animationInfo,
    ChartConfig chartConfig,
    ChartTheme theme,
    ChartScaleModel chartScaleModel,
  ) {
    super.paint(canvas, size, epochToX, quoteToY, animationInfo, chartConfig,
        theme, chartScaleModel);

    verticalBarrier.paint(canvas, size, epochToX, quoteToY, animationInfo,
        chartConfig, theme, chartScaleModel);
  }
}
