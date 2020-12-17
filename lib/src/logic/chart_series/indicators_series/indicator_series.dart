import 'package:deriv_chart/src/logic/chart_data.dart';
import 'package:deriv_chart/src/logic/chart_series/data_series.dart';
import 'package:deriv_chart/src/logic/chart_series/line_series/line_painter.dart';
import 'package:deriv_chart/src/logic/chart_series/series.dart';
import 'package:deriv_chart/src/logic/chart_series/series_painter.dart';
import 'package:deriv_chart/src/logic/indicators/abstract_indicator.dart';
import 'package:deriv_chart/src/logic/indicators/cached_indicator.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import 'ma_series.dart';

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

    resultIndicator = initializeIndicator(null);
    entries = resultIndicator.results;
    print('');
  }

  ///
  @protected
  CachedIndicator<Tick> initializeIndicator(
    CachedIndicator<Tick> previousIndicator,
  );

  /// Will be called by the chart when it was updated.
  @override
  bool didUpdate(ChartData oldData, {Tick newChartTick}) {
    final SingleIndicatorSeries<Tick> oldSeries = oldData;

    if ((oldSeries?.inputIndicator?.runtimeType == inputIndicator.runtimeType ??
            false) &&
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
      if (oldSeries.input.length == input.length) {
        oldSeries.resultIndicator
          ..invalidate(input.length - 1)
          ..replaceLast(input.last);
      } else {
        oldSeries.resultIndicator.push(input.last);
      }
      resultIndicator = oldSeries.resultIndicator;
      entries = resultIndicator.results;
    } else {
      initialize();
    }
  }

  @override
  Widget getCrossHairInfo(Tick crossHairTick, int pipSize) => Text(
        '${crossHairTick.quote.toStringAsFixed(pipSize)}',
        style: const TextStyle(fontSize: 16),
      );

  @override
  double maxValueOf(Tick t) => t.quote;

  @override
  double minValueOf(Tick t) => t.quote;
}

class TestMASeries extends SingleIndicatorSeries<Tick> {
  TestMASeries(
      AbstractIndicator<Tick> inputIndicator, String id, MAOptions options)
      : super(inputIndicator, id, options);

  @override
  SeriesPainter<Series> createPainter() => LinePainter(this);

  @override
  CachedIndicator<Tick> initializeIndicator(
    CachedIndicator<Tick> previousIndicator,
  ) =>
      MASeries.getMAIndicator(inputIndicator, (options as MAOptions).period,
          (options as MAOptions).type);
}

abstract class IndicatorOptions extends Equatable {}

class MAOptions extends IndicatorOptions {
  MAOptions(this.period, this.type);

  final int period;
  final MovingAverageType type;

  @override
  List<Object> get props => [period, type];
}
