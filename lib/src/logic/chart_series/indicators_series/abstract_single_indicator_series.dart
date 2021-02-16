import 'package:deriv_chart/src/logic/chart_series/data_series.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:deriv_chart/src/theme/painting_styles/data_series_style.dart';
import 'package:deriv_technical_analysis/deriv_technical_analysis.dart';
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
    this.offset = 0,
  })  : _inputFirstTick = inputIndicator.entries.isNotEmpty
            ? inputIndicator.entries.first
            : null,
        super(inputIndicator.entries, id, style: style);

  /// Input indicator to calculate this indicator value on.
  ///
  /// Input data might be a result of another [Indicator]. For example [CloseValueIndicator] or [HL2Indicator].
  final Indicator<Tick> inputIndicator;

  /// The offset of this indicator.
  ///
  /// Indicator's data will be shifted by this number of tick while they are being painted.
  /// For example if we consider `*`s as indicator data on the chart below with default [offset] = 0:
  /// |                                 (Tick5)
  /// |    *            (Tick3) (Tick4)    *
  /// | (Tick1)    *             *
  /// |         (Tick2)   *
  ///  ------------------------------------------->
  ///
  /// Indicator's data with [offset] = 1 will be like:
  /// |                                 (Tick5)
  /// |            *    (Tick3) (Tick4)          *
  /// | (Tick1)            *              *
  /// |         (Tick2)           *
  ///  ------------------------------------------->
  final int offset;

  /// Indicator options
  ///
  /// It's used for comparison purpose to check whether this indicator series options has changed and
  /// It needs to recalculate [resultIndicator]'s values.
  final IndicatorOptions options;

  /// Result indicator
  ///
  /// Entries of [resultIndicator] will be the data that will be painted for this series.
  CachedIndicator<Tick> resultIndicator;

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
  CachedIndicator<Tick> initializeIndicator();

  @override
  bool isOldDataAvailable(AbstractSingleIndicatorSeries oldSeries) =>
      super.isOldDataAvailable(oldSeries) &&
      (oldSeries?.inputIndicator?.runtimeType == inputIndicator.runtimeType ??
          false) &&
      (oldSeries?.input?.isNotEmpty ?? false) &&
      (_inputFirstTick != null &&
          oldSeries._inputFirstTick == _inputFirstTick) &&
      (oldSeries?.options == options ?? false);

  @override
  void fillEntriesFromInput(AbstractSingleIndicatorSeries oldSeries) {
    resultIndicator = initializeIndicator()
      ..copyValuesFrom(oldSeries.resultIndicator);

    if (oldSeries.input.length == input.length) {
      if (oldSeries.input.last != input.last) {
        // We're on granularity > 1 tick. Last tick of the input has been updated. Recalculating its indicator value.
        resultIndicator.refreshValueFor(input.length - 1);
      } else {
        // To cover the cases when chart's ticks list has changed but both old ticks and new ticks are to the same reference.
        // And we can't detect if new ticks was added or not. But we calculate indicator's values for those indices that are null.
        for (int i = resultIndicator.lastResultIndex; i < input.length; i++) {
          resultIndicator.refreshValueFor(i);
        }
      }
    } else if (input.length > oldSeries.input.length) {
      // Some new ticks has been added. Calculating indicator's value for new ticks.
      for (int i = oldSeries.input.length; i < input.length; i++) {
        resultIndicator.refreshValueFor(i);
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
