import 'package:deriv_chart/src/logic/chart_data.dart';
import 'package:deriv_chart/src/logic/chart_series/data_series.dart';
import 'package:deriv_chart/src/logic/indicators/cached_indicator.dart';
import 'package:deriv_chart/src/logic/indicators/indicator.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:flutter/material.dart';

import 'models/indicator_options.dart';

/// Base class of indicator series.
///
/// Handles reusing result of previous indicator of the series.
abstract class SingleIndicatorSeries<T extends Tick> extends DataSeries<T> {
  /// Initializes
  SingleIndicatorSeries(this.inputIndicator, String id, this.options)
      : _inputFirstTick = inputIndicator.entries.isNotEmpty
            ? inputIndicator.entries.first
            : null,
        super(inputIndicator.entries, id);

  /// Input indicator to calculate this indicator value on.
  final Indicator<Tick> inputIndicator;

  /// Indicator options
  final IndicatorOptions options;

  /// Result indicator
  CachedIndicator<Tick> resultIndicator;

  /// For comparison purposes.
  /// To check whether series input list has changed entirely or not.
  final T _inputFirstTick;

  @override
  void initialize() {
    super.initialize();

    resultIndicator = initializeIndicator()..calculateValues();
    entries = resultIndicator.results;
  }

  /// Initializes the [resultIndicator] whenever needed.
  ///
  /// Will be called whenever [resultIndicator]'s previous values are not available or can't be used.
  @protected
  CachedIndicator<Tick> initializeIndicator();

  /// Will be called by the chart when it was updated.
  @override
  bool didUpdate(ChartData oldData) {
    final SingleIndicatorSeries<Tick> oldSeries = oldData;

    if ((oldSeries?.inputIndicator?.runtimeType == inputIndicator.runtimeType ??
            false) &&
        (oldSeries?.input?.isNotEmpty ?? false) &&
        (_inputFirstTick != null &&
            oldSeries._inputFirstTick == _inputFirstTick) &&
        (oldSeries?.options == options ?? false) &&
        (oldSeries?.entries?.isNotEmpty ?? false)) {
      prevLastEntry = oldSeries.entries.last;
      _reuseOldSeriesResult(oldSeries);
    } else {
      initialize();
    }

    return true;
  }

  void _reuseOldSeriesResult(SingleIndicatorSeries<Tick> oldSeries) {
    resultIndicator = initializeIndicator()
      ..copyValuesFrom(oldSeries.resultIndicator);

    if (oldSeries.input.length == input.length) {
      resultIndicator
        ..invalidate(input.length - 1)
        ..getValue(input.length - 1);
    } else if (input.length > oldSeries.input.length) {
      for (int i = oldSeries.input.length; i < input.length; i++) {
        resultIndicator
          ..invalidate(i)
          ..getValue(i);
      }
    }

    entries = resultIndicator.results;
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
