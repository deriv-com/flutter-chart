import 'package:deriv_chart/src/deriv_chart/interactive_layer/crosshair/crosshair_dot_painter.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/crosshair/crosshair_highlight_painter.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/crosshair/crosshair_line_highlight_painter.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/crosshair/crosshair_variant.dart';
import 'package:deriv_chart/src/models/indicator_input.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:deriv_chart/src/theme/painting_styles/barrier_style.dart';
import 'package:deriv_chart/src/theme/painting_styles/data_series_style.dart';
import 'package:deriv_technical_analysis/deriv_technical_analysis.dart';
import 'package:flutter/material.dart';

import '../data_series.dart';
import 'models/indicator_options.dart';

/// Base class of indicator series with a single indicator.
///
/// Handles reusing result of previous indicator of the series. The decision to
/// whether it can use the result of the old series calculated values is made
/// inside [didUpdate] method.
abstract class AbstractSingleIndicatorSeries extends DataSeries<Tick> {
  /// Initializes
  AbstractSingleIndicatorSeries(
    this.inputIndicator,
    String id, {
    this.options,
    DataSeriesStyle? style,
    this.offset = 0,
    HorizontalBarrierStyle? lastTickIndicatorStyle,
  })  : _inputFirstTick = inputIndicator.entries.isNotEmpty
            ? inputIndicator.entries.first as Tick
            : null,
        _inputIndicatorData = inputIndicator.input as IndicatorInput,
        super(
          inputIndicator.entries as List<Tick>,
          id: id,
          style: style,
          lastTickIndicatorStyle: lastTickIndicatorStyle,
        );

  /// Input indicator to calculate this indicator value on.
  ///
  /// Input data might be a result of another [Indicator]. For example
  /// [CloseValueIndicator] or [HL2Indicator].
  final Indicator<Tick> inputIndicator;

  /// The offset of this indicator.
  ///
  /// Indicator's data will be shifted by this number of tick while they are
  /// being painted. For example if we consider `*`s as indicator data on the
  /// chart below with default [offset] = 0:
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
  /// It's used for comparison purpose to check whether this indicator series
  /// options has changed and it needs to recalculate [_resultIndicator]'s
  /// values.
  final IndicatorOptions? options;

  /// Result indicator
  ///
  /// Entries of [_resultIndicator] will be the data that will be painted for
  /// this series.
  late CachedIndicator<Tick> _resultIndicator;

  /// For comparison purposes.
  /// To check whether series input list has changed entirely or not.
  final Tick? _inputFirstTick;

  final IndicatorInput _inputIndicatorData;

  @override
  int getEpochOf(Tick t, int index) {
    if (entries != null) {
      final int targetIndex = index + offset;

      if (targetIndex >= 0 && targetIndex < entries!.length) {
        // Instead of doing `epoch + offset * granularity` for all indices, for
        // those that are in the range of `entries` we should use the epoch of
        // `index + offset`. Meaning that if the offset was `2`, for the tick in
        // index `1`, we should use the epoch of index 3. This is because of
        // time gaps that some chart data might have,
        return entries![targetIndex].epoch;
      } else if (targetIndex >= entries!.length) {
        // Sometimes there might be market gaps even between entry in this index
        // and first/last index. In these cases `epoch + offset * granularity`
        // will be still wrong. Instead we use the epoch of the last/first index +/-
        // the estimation of remaining offset in epoch, using `first/lastEpoch + remainingOffset * granularity`.
        final int remainingOffset = targetIndex - entries!.length + 1;
        return entries!.last.epoch +
            remainingOffset * _inputIndicatorData.granularity;
      } else {
        return entries!.first.epoch +
            targetIndex * _inputIndicatorData.granularity;
      }
    }

    // Default calculation using `epoch + offset * granularity`.
    return super.getEpochOf(t, index) +
        offset * _inputIndicatorData.granularity;
  }

  @override
  void initialize() {
    super.initialize();

    _resultIndicator = initializeIndicator()..calculateValues();
    entries = _resultIndicator.results;
  }

  /// Initializes the [_resultIndicator].
  ///
  /// Will be called whenever [_resultIndicator]'s previous values are not
  /// available or its results can't be used (Like when the [input] list changes
  /// entirely).
  @protected
  CachedIndicator<Tick> initializeIndicator();

  @override
  bool isOldDataAvailable(covariant AbstractSingleIndicatorSeries? oldSeries) =>
      super.isOldDataAvailable(oldSeries) &&
      (oldSeries != null) &&
      (oldSeries.inputIndicator.runtimeType == inputIndicator.runtimeType) &&
      (oldSeries.input.isNotEmpty) &&
      (_inputFirstTick != null &&
          oldSeries._inputFirstTick == _inputFirstTick) &&
      oldSeries.options == options;

  @override
  void fillEntriesFromInput(covariant AbstractSingleIndicatorSeries oldSeries) {
    _resultIndicator = initializeIndicator()
      ..copyValuesFrom(oldSeries._resultIndicator);

    if (oldSeries.input.length == input.length) {
      if (oldSeries.input.last != input.last) {
        // We're on granularity > 1 tick. Last tick of the input has been
        // updated. Recalculating its indicator value.
        _resultIndicator.refreshValueFor(input.length - 1);
      } else {
        // To cover the cases when chart's ticks list has changed but both old
        // ticks and new ticks are to the same reference.
        // And we can't detect if new ticks was added or not. But we calculate
        // indicator's values for those indices that are null.
        for (int i = _resultIndicator.lastResultIndex; i < input.length; i++) {
          _resultIndicator.refreshValueFor(i);
        }
      }
    } else if (input.length > oldSeries.input.length) {
      // Some new ticks has been added. Calculating indicator's value for new
      // ticks.
      for (int i = oldSeries.input.length; i < input.length; i++) {
        _resultIndicator.refreshValueFor(i);
      }
    }

    entries = _resultIndicator.results;
  }

  @override
  Widget getCrossHairInfo(Tick crossHairTick, int pipSize, ChartTheme theme,
          CrosshairVariant crosshairVariant) =>
      Text(
        '${crossHairTick.quote.toStringAsFixed(pipSize)}',
        style: const TextStyle(fontSize: 16),
      );

  @override
  double maxValueOf(Tick t) => t.quote;

  @override
  double minValueOf(Tick t) => t.quote;

  @override
  CrosshairHighlightPainter getCrosshairHighlightPainter(
      Tick crosshairTick,
      double Function(double p1) quoteToY,
      double xCenter,
      int granularity,
      double Function(int p1) xFromEpoch,
      ChartTheme theme) {
    // Return a CrosshairLineHighlightPainter with transparent colors
    // This effectively creates a "no-op" painter that doesn't paint anything visible
    return CrosshairLineHighlightPainter(
      tick: crosshairTick,
      quoteToY: quoteToY,
      xCenter: xCenter,
      pointColor: Colors.transparent,
      pointSize: 0,
    );
  }

  @override
  CrosshairDotPainter getCrosshairDotPainter(
    ChartTheme theme,
  ) {
    // Indicator series support dots, so return a CrosshairDotPainter
    // with colors from the theme
    return CrosshairDotPainter(
      dotColor: theme.currentSpotDotColor,
      dotBorderColor: theme.currentSpotDotEffect,
    );
  }

  @override
  double getCrosshairDetailsBoxHeight() {
    return 50;
  }

  @override
  Tick createVirtualTick(int epoch, double quote) {
    return Tick(
      epoch: epoch,
      quote: quote,
    );
  }
}
