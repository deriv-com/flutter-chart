import 'package:deriv_chart/src/logic/chart_data.dart';
import 'package:deriv_chart/src/logic/chart_series/data_series.dart';
import 'package:deriv_chart/src/logic/indicators/cached_indicator.dart';
import 'package:deriv_chart/src/logic/indicators/indicator.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:deriv_chart/src/theme/painting_styles/data_series_style.dart';
import 'package:flutter/material.dart';

import 'models/indicator_options.dart';

/// Base class of indicator series with a single indicator.
///
/// Handles reusing result of previous indicator of the series. The decision to whether it can
/// use the result of the old series calculated values is made inside [didUpdate] method.
abstract class AbstractSingleIndicatorSeries extends DataSeries<Tick> {
  /// Initializes
  AbstractSingleIndicatorSeries(
    this.inputIndicator,
    String id,
    this.options, {
    DataSeriesStyle style,
  })  : _inputFirstTick = inputIndicator.entries.isNotEmpty
            ? inputIndicator.entries.first
            : null,
        super(inputIndicator.entries, id, style: style);

  /// Input indicator to calculate this indicator value on.
  final Indicator inputIndicator;

  /// Indicator options
  final IndicatorOptions options;

  /// Result indicator
  CachedIndicator resultIndicator;

  /// For comparison purposes.
  /// To check whether series input list has changed entirely or not.
  final Tick _inputFirstTick;

  @override
  void initialize() {
    super.initialize();

    resultIndicator = initializeIndicator()..calculateValues();
    entries = resultIndicator.results;
  }

  /// Initializes the [resultIndicator].
  ///
  /// Will be called whenever [resultIndicator]'s previous values are not available
  /// or its results can't be used (Like when the [input] list changes entirely).
  @protected
  CachedIndicator initializeIndicator();

  /// Will be called by the chart when it was updated.
  @override
  bool didUpdate(ChartData oldData) {
    final AbstractSingleIndicatorSeries oldSeries = oldData;

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

  void _reuseOldSeriesResult(AbstractSingleIndicatorSeries oldSeries) {
    resultIndicator = initializeIndicator()
      ..copyValuesFrom(oldSeries.resultIndicator);

    if (oldSeries.input.length == input.length &&
        oldSeries.input.last != input.last) {
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
