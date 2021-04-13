import 'dart:async';

import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/logic/annotations/barriers/horizontal_barrier/candle_indicator_painter.dart';
import 'package:deriv_chart/src/logic/chart_data.dart';
import 'package:deriv_chart/src/logic/chart_series/series.dart';
import 'package:deriv_chart/src/logic/chart_series/series_painter.dart';
import 'package:deriv_chart/src/models/candle.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:deriv_chart/src/theme/painting_styles/barrier_style.dart';
import 'package:flutter/foundation.dart';

import 'horizontal_barrier.dart';

/// Tick indicator.
class TickIndicator extends HorizontalBarrier {
  /// Initializes a tick indicator.
  TickIndicator(
    Tick tick, {
    String id,
    HorizontalBarrierStyle style,
    HorizontalBarrierVisibility visibility = HorizontalBarrierVisibility.normal,
  }) : super(
          tick.quote,
          epoch: tick.epoch,
          id: id,
          style: style ??
              const HorizontalBarrierStyle(
                labelShape: LabelShape.pentagon,
              ),
          visibility: visibility,
          longLine: false,
        );
}

/// Indicator for showing the candle current value and remaining time (optional).
class CandleIndicator extends HorizontalBarrier {
  /// Initializes a candle indicator.
  CandleIndicator(
    this.candle, {
    @required this.granularity,
    String id,
    HorizontalBarrierStyle style = const HorizontalBarrierStyle(),
    HorizontalBarrierVisibility visibility =
        HorizontalBarrierVisibility.keepBarrierLabelVisible,
  }) : super(
          candle.quote,
          epoch: candle.epoch,
          id: id,
          style: style,
          visibility: visibility,
          longLine: false,
        );

  ///the given candle
  Candle candle;

  /// Average ms difference between two consecutive ticks.
  int granularity;

  Timer _timer;

  Duration timerDuration;

  void _startTimer() {
    timerDuration = Duration(
        milliseconds:
            granularity * 1000 - (candle.currentEpochTime - candle.epoch));
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!timerDuration.inSeconds.isNegative) {
        timerDuration = Duration(seconds: timerDuration.inSeconds - 1);
        _timer.cancel();
      }
    });
  }

  @override
  bool didUpdate(ChartData oldData) {
    if (oldData is CandleIndicator) {
      oldData._timer.cancel();
      _startTimer();
    } else {
      _startTimer();
    }

    return super.didUpdate(oldData);
  }

  @override
  SeriesPainter<Series> createPainter() => CandleIndicatorPainter(
        this,
      );
}
