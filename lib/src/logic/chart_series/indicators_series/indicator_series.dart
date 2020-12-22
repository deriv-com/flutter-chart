import 'package:deriv_chart/src/logic/chart_data.dart';
import 'package:deriv_chart/src/logic/chart_series/data_series.dart';
import 'package:deriv_chart/src/logic/indicators/abstract_indicator.dart';
import 'package:deriv_chart/src/logic/indicators/cached_indicator.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/bollinger/bollinger_bands_upper_indicator.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:flutter/material.dart';

import 'models/indicator_options.dart';

/// Base class of indicator series
abstract class SingleIndicatorSeries<T extends Tick> extends DataSeries<T> {
  /// Initializes
  SingleIndicatorSeries(this.inputIndicator, String id, this.options)
      : super(inputIndicator.entries, id);

  /// Input indicator to calculate this indicator value on.
  final AbstractIndicator<Tick> inputIndicator;

  final IndicatorOptions options;

  ///
  CachedIndicator<Tick> resultIndicator;

  @override
  void initialize() {
    super.initialize();

    resultIndicator = initializeIndicator();
    resultIndicator.calculateValues();
    entries = resultIndicator.results;
  }

  ///
  @protected
  CachedIndicator<Tick> initializeIndicator();

  /// Will be called by the chart when it was updated.
  @override
  bool didUpdate(ChartData oldData, {Tick newChartTick}) {
    final SingleIndicatorSeries<Tick> oldSeries = oldData;

    if ((oldSeries?.inputIndicator?.runtimeType == inputIndicator.runtimeType ??
            false) &&
        (oldSeries?.input?.isNotEmpty ?? false) &&
        (oldSeries?.input?.first == input.first ?? false) &&
        (oldSeries?.options == options ?? false) &&
        (oldSeries?.entries?.isNotEmpty ?? false)) {
      prevLastEntry = oldSeries.entries.last;
      updateEntries(oldData, true);
    } else {
      initialize();
    }

    return true;
  }

  /// Updates Indicators results.
  void updateEntries(SingleIndicatorSeries<Tick> oldSeries, bool newTickAdded) {
    if (newTickAdded) {
      resultIndicator = initializeIndicator()
        ..copyValuesFrom(oldSeries.resultIndicator);

      if (oldSeries.input.length == input.length) {
        resultIndicator.invalidate(input.length - 1);
      }

      resultIndicator.getValue(input.length - 1);

      entries = resultIndicator.results;
    } else {
      initialize();
    }
  }

  @override
  Widget getCrossHairInfo(Tick crossHairTick, int pipSize, ChartTheme theme) =>
      Text(
        '${crossHairTick.quote.toStringAsFixed(pipSize)}',
        style: const TextStyle(fontSize: 16),
      );

  @override
  double maxValueOf(Tick t) => t.quote;

  @override
  double minValueOf(Tick t) => t.quote;
}
