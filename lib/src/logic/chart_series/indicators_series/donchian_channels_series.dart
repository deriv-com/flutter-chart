import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/deriv_chart/indicators_ui/donchian_channel/donchian_channel_indicator_config.dart';
import 'package:deriv_chart/src/logic/chart_data.dart';
import 'package:deriv_chart/src/logic/chart_series/line_series/line_series.dart';
import 'package:deriv_chart/src/logic/chart_series/series.dart';
import 'package:deriv_chart/src/logic/chart_series/series_painter.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/donchian/donchian_middle_channel_indicator.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/helper_indicators/high_value_inidicator.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/helper_indicators/low_value_indicator.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/highest_value_indicator.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/lowest_value_indicator.dart';
import 'package:deriv_chart/src/models/animation_info.dart';
import 'package:deriv_chart/src/models/chart_config.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:flutter/material.dart';

/// Donchian Channels series
class DonchianChannelsSeries extends Series {
  /// Initializes
  DonchianChannelsSeries(
    List<Tick> ticks, {
    String id,
  }) : this.fromIndicator(
          HighValueIndicator(ticks),
          LowValueIndicator(ticks),
          const DonchianChannelIndicatorConfig(
            highPeriod: 10,
            lowPeriod: 10,
          ),
          id: id,
        );

  /// Initializes
  DonchianChannelsSeries.fromIndicator(
    HighValueIndicator highIndicator,
    LowValueIndicator lowIndicator,
    this.config, {
    String id,
  })  : _highIndicator = highIndicator,
        _lowIndicator = lowIndicator,
        super(id);

  LineSeries _upperChannelSeries;
  LineSeries _middleChannelSeries;
  LineSeries _lowerChannelSeries;

  final HighValueIndicator _highIndicator;
  final LowValueIndicator _lowIndicator;

  /// Configuration of donchian channels.
  final DonchianChannelIndicatorConfig config;

  @override
  SeriesPainter<Series> createPainter() {
    final HighestValueIndicator upperChannelIndicator = HighestValueIndicator(
      _highIndicator,
      config.highPeriod,
    );

    final LowestValueIndicator lowerChannelIndicator = LowestValueIndicator(
      _lowIndicator,
      config.lowPeriod,
    );

    final DonchianMiddleChannelIndicator middleChannelIndicator =
        DonchianMiddleChannelIndicator(
            upperChannelIndicator, lowerChannelIndicator);

    _upperChannelSeries = LineSeries(
      upperChannelIndicator.results,
      style: config.upperLineStyle,
    );

    _lowerChannelSeries = LineSeries(
      lowerChannelIndicator.results,
      style: config.lowerLineStyle,
    );

    _middleChannelSeries = LineSeries(
      middleChannelIndicator.results,
      style: config.middleLineStyle,
    );

    return null; // TODO(ramin): return the painter that paints Channel Fill between bands
  }

  @override
  bool didUpdate(ChartData oldData) {
    final DonchianChannelsSeries series = oldData;

    final bool _upperChannelUpdated =
        _upperChannelSeries.didUpdate(series._upperChannelSeries);
    final bool _middleChannelUpdated =
        _middleChannelSeries.didUpdate(series._middleChannelSeries);
    final bool _lowerChannelUpdated =
        _lowerChannelSeries.didUpdate(series._lowerChannelSeries);

    return _upperChannelUpdated ||
        _middleChannelUpdated ||
        _lowerChannelUpdated;
  }

  @override
  void onUpdate(int leftEpoch, int rightEpoch) {
    _upperChannelSeries.update(leftEpoch, rightEpoch);
    _middleChannelSeries.update(leftEpoch, rightEpoch);
    _lowerChannelSeries.update(leftEpoch, rightEpoch);
  }

  @override
  List<double> recalculateMinMax() => <double>[
        _lowerChannelSeries.minValue,
        _upperChannelSeries.maxValue,
      ];

  @override
  void paint(
    Canvas canvas,
    Size size,
    double Function(int) epochToX,
    double Function(double) quoteToY,
    AnimationInfo animationInfo,
    ChartConfig chartConfig,
    ChartTheme theme,
  ) {
    _upperChannelSeries.paint(
        canvas, size, epochToX, quoteToY, animationInfo, chartConfig, theme);
    _middleChannelSeries.paint(
        canvas, size, epochToX, quoteToY, animationInfo, chartConfig, theme);
    _lowerChannelSeries.paint(
        canvas, size, epochToX, quoteToY, animationInfo, chartConfig, theme);

    // TODO(ramin): call super.paint to paint the Channels fill.
  }
}
