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

/// Series with only a single list of data to paint.
abstract class DataSeries<T extends Tick> extends Series {
  /// Initializes
  ///
  /// [entries] is the list of data to show.
  DataSeries(
    this.input,
    String id, {
    DataSeriesStyle style,
  }) : super(id, style: style) {
    _minMaxCalculator = MinMaxCalculator(minValueOf, maxValueOf);
  }

  /// Series input list.
  ///
  /// This is not the list that eventually will be painted. Sub-classes have the option
  /// to prepare their [entries] list which is the one that is painted from the [input].
  final List<T> input;

  /// The list of this class that will be painted on the canvas.
  List<T> entries;

  /// List of visible entries at a specific epoch range of the chart X-Axis.
  ///
  /// Will be updated when the epoch bounderies of the chart changes and [onUpdate] gets called.
  List<T> _visibleEntries = <T>[];

  /// Series visible entries
  List<T> get visibleEntries => _visibleEntries;

  /// A reference to the last element of the old series of this [DataSeries] object.
  ///
  /// Most of the times updating a [DataSeries] class is when a new tick is added to it.
  /// It can be updating just the last tick of the old [DataSeries] class, or adding a new tick
  /// at the end of the list of tick. In these cases we can do animation from [prevLastEntry] to the
  /// last tick of the new [DataSeries]. like transition from old tick to new tick in a line chart
  /// or updating the height of candle in a candlestick chart.
  ///
  /// In other cases like in the first run or when the [input] list changes entirely [prevLastEntry]
  /// will ne `null` and there will be no animation.
  T prevLastEntry;

  HorizontalBarrier _lastTickIndicator;

  /// Initializes [entries] from the [input].
  void initialize() {
    entries = input;
    _initLastTickIndicator();
  }

  bool _needsMinMaxUpdate = false;

  /// Utility object to help efficiently calculate new min/max when [visibleEntries] change.
  MinMaxCalculator _minMaxCalculator;

  /// Updates visible entries for this Series.
  @override
  void onUpdate(int leftEpoch, int rightEpoch) {
    if (entries == null) {
      initialize();
    }

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
  ///
  /// sub-classes can decide what will be the min/max value of a [T], this way a candlestick series
  /// can use (high, low) values as max and min and a line chart just use the close value and then a line
  /// chart can expand as much as it can in the vertical space since it just shows close values.
  double minValueOf(T t);

  /// Maximum value in [t].
  double maxValueOf(T t);

  void _initLastTickIndicator() {
    final DataSeriesStyle style = this.style;

    if (entries.isNotEmpty && style?.lastTickStyle != null ?? false) {
      _lastTickIndicator = HorizontalBarrier(
        entries.last.quote,
        epoch: entries.last.epoch,
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
    if (leftEpoch < entries[0].epoch) {
      return 0;
    } else if (leftEpoch > entries[entries.length - 1].epoch) {
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
    if (rightEpoch < entries[0].epoch) {
      return -1;
    } else if (rightEpoch > entries[entries.length - 1].epoch) {
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

      if (epoch < entries[mid].epoch) {
        hi = mid - 1;
      } else if (epoch > entries[mid].epoch) {
        lo = mid + 1;
      } else {
        return mid;
      }
    }

    return (entries[lo].epoch - epoch) < (epoch - entries[hi].epoch) ? lo : hi;
  }

  /// Will be called by the chart when it was updated.
  @override
  bool didUpdate(ChartData oldData) {
    final DataSeries<Tick> oldSeries = oldData;

    bool updated = false;
    if (input.isNotEmpty && isOldDataAvailable(oldSeries)) {
      fillEntriesFromInput(oldSeries);

      // Preserve old computed values in case recomputation is deemed unnecesary.
      _visibleEntries = oldSeries.visibleEntries;
      minValueInFrame = oldSeries.minValue;
      maxValueInFrame = oldSeries.maxValue;

      if (entries != null && entries.last == oldSeries.entries.last) {
        prevLastEntry = oldSeries.prevLastEntry;
      } else {
        prevLastEntry = oldSeries.entries.last;
        updated = true;
      }
    } else {
      initialize();
      updated = true;
    }

    _lastTickIndicator?.didUpdate(oldSeries._lastTickIndicator);

    return updated;
  }

  /// Fills the entries that are about to be painted based on [input] and [oldSeries]
  ///
  /// [oldSeries] is provided so this [DataSeries] class get the option to reuse it's previous data.
  ///
  /// Here we just assign [input] to [entries] as a normal [DataSeries] class.
  @protected
  void fillEntriesFromInput(covariant DataSeries<Tick> oldSeries) =>
      entries = input;

  /// Checks whether the old data of the series is available to use
  @protected
  bool isOldDataAvailable(covariant DataSeries<Tick> oldSeries) =>
      oldSeries?.entries?.isNotEmpty ?? false;

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
