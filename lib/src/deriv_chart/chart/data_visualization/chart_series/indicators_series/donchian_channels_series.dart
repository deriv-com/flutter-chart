import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/indicators_series/single_indicator_series.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/line_series/channel_fill_painter.dart';
import 'package:deriv_chart/src/deriv_chart/chart/helpers/indicator.dart';
import 'package:deriv_chart/src/models/chart_config.dart';
import 'package:deriv_technical_analysis/deriv_technical_analysis.dart';
import 'package:flutter/material.dart';

/// Donchian Channels series
class DonchianChannelsSeries extends Series {
  /// Initializes
  DonchianChannelsSeries(
    IndicatorInput indicatorInput, {
    String? id,
  }) : this.fromIndicator(
          HighValueIndicator<Tick>(indicatorInput),
          LowValueIndicator<Tick>(indicatorInput),
          const DonchianChannelIndicatorConfig(),
          id: id,
        );

  /// Initializes
  DonchianChannelsSeries.fromIndicator(
    HighValueIndicator<Tick> highIndicator,
    LowValueIndicator<Tick> lowIndicator,
    this.config, {
    String? id,
  })  : _highIndicator = highIndicator,
        _lowIndicator = lowIndicator,
        // TODO(Ramin): define DonchianChannelOptions class
        super(id ?? 'Donchian$config');

  /// Upper channel series.
  late SingleIndicatorSeries upperChannelSeries;

  /// Middle channel series.
  late SingleIndicatorSeries middleChannelSeries;

  /// Lower channel series.
  late SingleIndicatorSeries lowerChannelSeries;

  final HighValueIndicator<Tick> _highIndicator;
  final LowValueIndicator<Tick> _lowIndicator;

  /// Configuration of donchian channels.
  final DonchianChannelIndicatorConfig config;

  @override
  SeriesPainter<Series>? createPainter() {
    final HighestValueIndicator<Tick> upperChannelIndicator =
        HighestValueIndicator<Tick>(
      _highIndicator,
      config.highPeriod,
    );

    final LowestValueIndicator<Tick> lowerChannelIndicator =
        LowestValueIndicator<Tick>(
      _lowIndicator,
      config.lowPeriod,
    );

    final DonchianMiddleChannelIndicator<Tick> middleChannelIndicator =
        DonchianMiddleChannelIndicator<Tick>(
      upperChannelIndicator,
      lowerChannelIndicator,
    );

    upperChannelSeries = SingleIndicatorSeries(
      painterCreator: (Series series) =>
          LinePainter(series as DataSeries<Tick>),
      inputIndicator: _highIndicator,
      style: config.upperLineStyle,
      lastTickIndicatorStyle: getLastIndicatorStyle(
        config.upperLineStyle.color,
        showLastIndicator: config.showLastIndicator,
      ),
      indicatorCreator: () => upperChannelIndicator,
    );

    lowerChannelSeries = SingleIndicatorSeries(
      inputIndicator: _lowIndicator,
      painterCreator: (Series series) =>
          LinePainter(series as DataSeries<Tick>),
      indicatorCreator: () => lowerChannelIndicator,
      style: config.lowerLineStyle,
      lastTickIndicatorStyle: getLastIndicatorStyle(
        config.lowerLineStyle.color,
        showLastIndicator: config.showLastIndicator,
      ),
    );

    middleChannelSeries = SingleIndicatorSeries(
      inputIndicator: _lowIndicator,
      painterCreator: (Series series) =>
          LinePainter(series as DataSeries<Tick>),
      indicatorCreator: () => middleChannelIndicator,
      style: config.middleLineStyle,
      lastTickIndicatorStyle: getLastIndicatorStyle(
        config.middleLineStyle.color,
        showLastIndicator: config.showLastIndicator,
      ),
    );

    if (config.showChannelFill) {
      return ChannelFillPainter(
        upperChannelSeries,
        lowerChannelSeries,
        firstUpperChannelFillColor: config.fillColor.withOpacity(0.2),
        secondUpperChannelFillColor: config.fillColor.withOpacity(0.2),
      );
    }

    return null;
  }

  @override
  bool shouldRepaint(ChartData? previous) {
    if (previous == null) {
      return true;
    }

    final DonchianChannelsSeries oldSeries = previous as DonchianChannelsSeries;
    return config.toJson().toString() != oldSeries.config.toJson().toString();
  }

  @override
  bool didUpdate(ChartData? oldData) {
    final DonchianChannelsSeries? oldSeries =
        oldData as DonchianChannelsSeries?;

    final bool upperUpdated =
        upperChannelSeries.didUpdate(oldSeries?.upperChannelSeries);
    final bool middleUpdated =
        middleChannelSeries.didUpdate(oldSeries?.middleChannelSeries);
    final bool lowerUpdated =
        lowerChannelSeries.didUpdate(oldSeries?.lowerChannelSeries);

    return upperUpdated || middleUpdated || lowerUpdated;
  }

  @override
  void onUpdate(int leftEpoch, int rightEpoch) {
    upperChannelSeries.update(leftEpoch, rightEpoch);
    middleChannelSeries.update(leftEpoch, rightEpoch);
    lowerChannelSeries.update(leftEpoch, rightEpoch);
  }

  @override
  List<double> recalculateMinMax() => <double>[
        lowerChannelSeries.minValue,
        upperChannelSeries.maxValue,
      ];

  @override
  void paint(
    Canvas canvas,
    Size size,
    EpochToX epochToX,
    QuoteToY quoteToY,
    AnimationInfo animationInfo,
    ChartConfig chartConfig,
    ChartTheme theme,
    ChartController controller,
  ) {
    upperChannelSeries.paint(
        canvas, size, epochToX, quoteToY, animationInfo, chartConfig, theme, controller);
    middleChannelSeries.paint(
        canvas, size, epochToX, quoteToY, animationInfo, chartConfig, theme, controller);
    lowerChannelSeries.paint(
        canvas, size, epochToX, quoteToY, animationInfo, chartConfig, theme, controller);

    if (config.showChannelFill &&
        upperChannelSeries.visibleEntries.isNotEmpty &&
        lowerChannelSeries.visibleEntries.isNotEmpty) {
      super.paint(
          canvas, size, epochToX, quoteToY, animationInfo, chartConfig, theme, controller);
    }
  }

  // min/max epoch for all 3 channels are equal, using only `_loweChannelSeries` min/max.
  @override
  int? getMaxEpoch() => lowerChannelSeries.getMaxEpoch();

  @override
  int? getMinEpoch() => lowerChannelSeries.getMinEpoch();
}
