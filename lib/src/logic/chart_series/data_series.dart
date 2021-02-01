import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/logic/annotations/barriers/horizontal_barrier/horizontal_barrier.dart';
import 'package:deriv_chart/src/logic/chart_data.dart';
import 'package:deriv_chart/src/logic/chart_series/series.dart';
import 'package:deriv_chart/src/logic/min_max_calculator.dart';
import 'package:deriv_chart/src/models/animation_info.dart';
import 'package:deriv_chart/src/models/chart_config.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:deriv_chart/src/theme/painting_styles/data_series_style.dart';
import 'package:flutter/material.dart';

/// Series with only a single list of data to show.
abstract class DataSeries<T extends Tick> extends Series {
  /// Initializes
  ///
  /// [entries] is the list of data to show.
  DataSeries(
    this.entries,
    String id, {
    DataSeriesStyle style,
  }) : super(id, style: style) {
    _initLastTickIndicator();
    _minMaxCalculator = MinMaxCalculator(
      minValueOf,
      maxValueOf,
      epochOf: getEpochOf,
    );
  }

  /// Series entries
  final List<T> entries;

  List<T> _visibleEntries = <T>[];

  /// Series visible entries
  List<T> get visibleEntries => _visibleEntries;

  T _prevLastEntry;

  /// A reference to the last entry from series previous [entries] before update
  T get prevLastEntry => _prevLastEntry;

  HorizontalBarrier _lastTickIndicator;

  bool _needsMinMaxUpdate = false;

  /// Utility object to help efficiently calculate new min/max when [visibleEntries] change.
  MinMaxCalculator _minMaxCalculator;

  /// Gets the real epoch for the given [t].
  ///
  /// Real epoch might involve some offsets.
  /// Should use this method here whenever want to get [Tick.epoch].
  int getEpochOf(T t) => t.epoch;

  /// Updates visible entries for this Series.
  @override
  void onUpdate(int leftEpoch, int rightEpoch) {
    _lastTickIndicator?.onUpdate(leftEpoch, rightEpoch);

    if (entries.isEmpty) {
      _visibleEntries = <T>[];
      return;
    }

    final int startIndex = _searchLowerIndex(leftEpoch);
    final int endIndex = _searchUpperIndex(rightEpoch);

    final List<T> newVisibleEntries = startIndex == -1 || endIndex == -1
        ? <T>[]
        : entries.sublist(startIndex, endIndex);

    // Only recalculate min/max if visible entries have changed.
    _needsMinMaxUpdate = newVisibleEntries.isEmpty ||
        _visibleEntries.isEmpty ||
        newVisibleEntries.first != _visibleEntries.first ||
        newVisibleEntries.last != _visibleEntries.last;

    _visibleEntries = newVisibleEntries;
  }

  /// Minimum value in [t].
  double minValueOf(T t);

  /// Maximum value in [t].
  double maxValueOf(T t);

  void _initLastTickIndicator() {
    final DataSeriesStyle style = this.style;
    if (entries.isNotEmpty && style?.lastTickStyle != null ?? false) {
      _lastTickIndicator = HorizontalBarrier(
        entries.last.quote,
        epoch: getEpochOf(entries.last),
        style: style.lastTickStyle,
      );
    }
  }

  /// Gets min and max quotes after updating [visibleEntries] as an array with two elements [min, max].
  ///
  /// Sub-classes can override this method if they calculate [minValue] & [maxValue] differently.
  @override
  List<double> recalculateMinMax() {
    if (!_needsMinMaxUpdate) {
      return <double>[minValue, maxValue];
    }
    _minMaxCalculator.calculate(visibleEntries);
    return <double>[_minMaxCalculator.min, _minMaxCalculator.max];
  }

  int _searchLowerIndex(int leftEpoch) {
    if (leftEpoch < getEpochOf(entries[0])) {
      return 0;
    } else if (leftEpoch > getEpochOf(entries[entries.length - 1])) {
      return -1;
    }

    final int closest = _findClosestIndex(leftEpoch);

    final int index = closest <= leftEpoch
        ? closest
        : closest - 1 < 0
            ? closest
            : closest - 1;
    return index - 1 < 0 ? index : index - 1;
  }

  int _searchUpperIndex(int rightEpoch) {
    if (rightEpoch < getEpochOf(entries[0])) {
      return -1;
    } else if (rightEpoch > getEpochOf(entries[entries.length - 1])) {
      return entries.length;
    }

    final int closest = _findClosestIndex(rightEpoch);

    final int index = closest >= rightEpoch
        ? closest
        : (closest + 1 > entries.length ? closest : closest + 1);
    return index == entries.length ? index : index + 1;
  }

  // Binary search to find closest index to the [epoch].
  int _findClosestIndex(int epoch) {
    int lo = 0;
    int hi = entries.length - 1;

    while (lo <= hi) {
      final int mid = (hi + lo) ~/ 2;

      if (epoch < getEpochOf(entries[mid])) {
        hi = mid - 1;
      } else if (epoch > getEpochOf(entries[mid])) {
        lo = mid + 1;
      } else {
        return mid;
      }
    }

    return (getEpochOf(entries[lo]) - epoch) < (epoch - getEpochOf(entries[hi]))
        ? lo
        : hi;
  }

  /// Will be called by the chart when it was updated.
  @override
  bool didUpdate(ChartData oldData) {
    final DataSeries<T> oldSeries = oldData;

    bool updated = false;

    if (entries.isNotEmpty && oldSeries.entries.isNotEmpty) {
      if (entries.last == oldSeries.entries.last) {
        _prevLastEntry = oldSeries._prevLastEntry;
      } else {
        _prevLastEntry = oldSeries.entries.last;
        updated = true;
      }
    }

    // Preserve old computed values in case recomputation is deemed unnecesary.
    _visibleEntries = oldSeries.visibleEntries;
    minValueInFrame = oldSeries.minValue;
    maxValueInFrame = oldSeries.maxValue;

    _lastTickIndicator?.didUpdate(oldSeries._lastTickIndicator);

    return updated;
  }

  @override
  bool shouldRepaint(ChartData oldDelegate) {
    final DataSeries oldDataSeries = oldDelegate;
    final List<Tick> current = visibleEntries;
    final List<Tick> previous = oldDataSeries.visibleEntries;

    if (current.isEmpty && previous.isEmpty) {
      return false;
    }
    if (current.isEmpty != previous.isEmpty) {
      return true;
    }

    return current.first != previous.first ||
        current.last != previous.last ||
        style != oldDataSeries.style;
  }

  @override
  void paint(
    Canvas canvas,
    Size size,
    EpochToX epochToX,
    QuoteToY quoteToY,
    AnimationInfo animationInfo,
    ChartConfig chartConfig,
    ChartTheme theme,
  ) {
    super.paint(
        canvas, size, epochToX, quoteToY, animationInfo, chartConfig, theme);

    _lastTickIndicator?.paint(
        canvas, size, epochToX, quoteToY, animationInfo, chartConfig, theme);
  }

  /// Each sub-class should implement and return appropriate cross-hair text based on its own requirements.
  Widget getCrossHairInfo(T crossHairTick, int pipSize, ChartTheme theme);
}
