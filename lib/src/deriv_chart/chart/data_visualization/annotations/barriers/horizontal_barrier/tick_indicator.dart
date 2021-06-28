import 'dart:async';

import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_data.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/series.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/series_painter.dart';
import 'package:deriv_chart/src/models/candle.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:deriv_chart/src/theme/painting_styles/barrier_style.dart';

import 'candle_indicator_painter.dart';
import 'horizontal_barrier.dart';

/// Tick indicator.
class TickIndicator extends HorizontalBarrier {
  /// Initializes a tick indicator.
  TickIndicator(
    Tick tick, {
    String? id,
    HorizontalBarrierStyle? style,
    HorizontalBarrierVisibility visibility = HorizontalBarrierVisibility.normal,
  }) : super(
          tick.quote,
          epoch: tick.epoch,
          id: id,
          style: style ??
              const HorizontalBarrierStyle(labelShape: LabelShape.pentagon),
          visibility: visibility,
          longLine: false,
        );
}

/// Indicator for showing the candle current value and remaining time (optional).
class CandleIndicator extends HorizontalBarrier {
  /// Initializes a candle indicator.
  CandleIndicator(
    this.candle, {
    required this.granularity,
    required this.serverTime,
    this.showTimer = false,
    String? id,
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
        ) {
    _startTimer();
  }

  /// The given candle.
  final Candle candle;

  /// The current time of the server.
  final DateTime serverTime;

  /// Average ms difference between two consecutive ticks.
  final int granularity;

  /// The time duration left on the timer to show.
  Duration? timerDuration;

  /// Wether to show the candle close time timer or not.
  final bool showTimer;

  Timer? _timer;

  void _startTimer() {
    if (serverTime.millisecondsSinceEpoch - candle.epoch >= granularity) {
      timerDuration = null;
      return;
    }

    timerDuration = Duration(
        milliseconds:
            granularity - (serverTime.millisecondsSinceEpoch - candle.epoch));

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (timerDuration!.inSeconds > 0) {
        timerDuration = Duration(seconds: timerDuration!.inSeconds - 1);
      }
    });
  }

  @override
  bool didUpdate(ChartData? oldData) {
    if (oldData is CandleIndicator) {
      oldData._timer?.cancel();
    }

    return super.didUpdate(oldData);
  }

  @override
  SeriesPainter<Series> createPainter() => CandleIndicatorPainter(this);
}
