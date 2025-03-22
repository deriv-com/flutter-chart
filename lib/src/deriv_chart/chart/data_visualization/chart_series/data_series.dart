import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/functions/min_max_calculator.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/models/animation_info.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/models/chart_scale_model.dart';
import 'package:deriv_chart/src/deriv_chart/chart/y_axis/y_axis_config.dart';
import 'package:deriv_chart/src/models/chart_config.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:deriv_chart/src/theme/painting_styles/barrier_style.dart';
import 'package:deriv_chart/src/theme/painting_styles/data_series_style.dart';
import 'package:flutter/material.dart';

import '../annotations/barriers/horizontal_barrier/horizontal_barrier.dart';
import '../chart_data.dart';
import 'indexed_entry.dart';
import 'series.dart';
import 'visible_entries.dart';

/// Series with only a single list of data to paint.
abstract class DataSeries<T extends Tick> extends Series {
  /// Initializes
  ///
  /// [entries] is the list of data to show.
  DataSeries(
    this.input, {
    required String id,
    DataSeriesStyle? style,
    this.lastTickIndicatorStyle,
  }) : super(id, style: style) {
    _minMaxCalculator = MinMaxCalculator(
      minValueOf as double Function(Tick),
      maxValueOf as double Function(Tick),
    );
  }

  /// Series input list.
  ///
  /// This is not the list that eventually will be painted. Sub-classes have
  /// the option to prepare their [entries] list which is the one that is
  /// painted from the [input].
  final List<T> input;

  /// The list of this class that will be painted on the canvas.
  List<T>? entries;

  /// List of visible entries at a specific epoch range of the chart X-Axis.
  ///
  /// Will be updated when the epoch boundaries of the chart changes and
  /// [onUpdate] gets called.
  VisibleEntries<T> _visibleEntries = VisibleEntries<T>.empty();

  /// Series visible entries
  VisibleEntries<T> get visibleEntries => _visibleEntries;

  /// A reference to the last element of the previous version of this
  /// [DataSeries].
  ///
  /// Most of the times updating a [DataSeries] class is when the last tick is
  /// changed. It can be just updating the last tick of the old [DataSeries]
  /// object, or adding a new tick to the end of the list. In these cases we can
  /// do an animation from [prevLastEntry] to the last tick of the new
  /// [DataSeries]. like a transition animation from the old tick to the new
  /// tick in a line chart or updating the height of the candle in a candlestick
  /// chart.
  ///
  /// In other cases like in the first run or when the [input] list changes
  /// entirely, [prevLastEntry] will be `null` and there will be no animations.
  IndexedEntry<T>? prevLastEntry;

  /// Style of a last tick indicator.
  /// `null` if indicator is absent.
  final HorizontalBarrierStyle? lastTickIndicatorStyle;

  HorizontalBarrier? _lastTickIndicator;

  /// Initializes [entries] from the [input].
  void initialize() => entries = input;

  bool _needsMinMaxUpdate = false;

  /// Utility object to help efficiently calculate new min/max when [visibleEntries] change.
  late MinMaxCalculator _minMaxCalculator;

  @override
  int? getMinEpoch() => input.isNotEmpty ? getEpochOf(input.first, 0) : null;

  @override
  int? getMaxEpoch() =>
      input.isNotEmpty ? getEpochOf(input.last, input.length - 1) : null;

  /// Gets the real epoch for the given [t].
  ///
  /// Real epoch might involve some offsets.
  /// Should use this method here whenever want to get the epoch of a [T].
  ///
  /// [index] should the index of [t] in [entries].
  int getEpochOf(T t, int index) => t.epoch;

  /// Updates visible entries for this Series.
  @override
  void onUpdate(int leftEpoch, int rightEpoch) {
    if (entries == null) {
      initialize();
      _initLastTickIndicator();
    }

    _lastTickIndicator?.onUpdate(leftEpoch, rightEpoch);

    if (entries!.isEmpty) {
      _visibleEntries = VisibleEntries<T>.empty();
      return;
    }

    final int startIndex = _searchLowerIndex(leftEpoch, entries!);
    final int endIndex = _searchUpperIndex(rightEpoch, entries!);

    final VisibleEntries<T> newVisibleEntries =
        getVisibleEntries(startIndex, endIndex);

    // Only recalculate min/max if visible entries have changed.
    _needsMinMaxUpdate = newVisibleEntries.isEmpty ||
        _visibleEntries.isEmpty ||
        newVisibleEntries.first != _visibleEntries.first ||
        newVisibleEntries.last != _visibleEntries.last;

    _visibleEntries = newVisibleEntries;
  }

  /// Creates visible entries based on [startIndex] and [endIndex].
  @protected
  VisibleEntries<T> getVisibleEntries(int startIndex, int endIndex) =>
      entries == null || startIndex == -1 || endIndex == -1
          ? VisibleEntries<T>.empty()
          : VisibleEntries<T>(
              entries!.sublist(startIndex, endIndex),
              startIndex,
              endIndex,
            );

  /// Minimum value in [t].
  ///
  /// sub-classes can decide what will be the min/max value of a [T], this way a
  /// candlestick series can use (high, low) values as max and min and a line
  /// chart just use the close value and then a line chart can expand as much as
  /// it can in the vertical space since it just shows close values.
  double minValueOf(T t);

  /// Maximum value in [t].
  double maxValueOf(T t);

  void _initLastTickIndicator() {
    if ((entries?.isNotEmpty ?? false) && lastTickIndicatorStyle != null) {
      _lastTickIndicator = HorizontalBarrier(
        entries!.last.quote,
        epoch: getEpochOf(entries!.last, entries!.length - 1),
        style: lastTickIndicatorStyle,
        longLine: false,
      );
    }
  }

  /// Gets min and max quotes after updating [visibleEntries] as an array with
  /// two elements [min, max].
  ///
  /// Sub-classes can override this method if they calculate [minValue] &
  /// [maxValue] differently.
  @override
  List<double> recalculateMinMax() {
    if (!_needsMinMaxUpdate) {
      return <double>[minValue, maxValue];
    }
    _minMaxCalculator.calculate(visibleEntries.entries);
    return <double>[_minMaxCalculator.min, _minMaxCalculator.max];
  }

  int _searchLowerIndex(int leftEpoch, List<T> entries) {
    if (leftEpoch < getEpochOf(entries[0], 0)) {
      return 0;
    } else if (leftEpoch >
        getEpochOf(entries[entries.length - 1], entries.length - 1)) {
      return -1;
    }

    final int closest = _findClosestIndex(leftEpoch, entries);

    final int index = closest <= leftEpoch
        ? closest
        : closest - 1 < 0
            ? closest
            : closest - 1;
    return index - 1 < 0 ? index : index - 1;
  }

  int _searchUpperIndex(int rightEpoch, List<T> entries) {
    if (rightEpoch < getEpochOf(entries[0], 0)) {
      return -1;
    } else if (rightEpoch >
        getEpochOf(entries[entries.length - 1], entries.length - 1)) {
      return entries.length;
    }

    final int closest = _findClosestIndex(rightEpoch, entries);

    final int index = closest >= rightEpoch
        ? closest
        : (closest + 1 > entries.length ? closest : closest + 1);
    return index == entries.length ? index : index + 1;
  }

  // Binary search to find closest index to the [epoch].
  int _findClosestIndex(int epoch, List<T> entries) {
    int lo = 0;
    int hi = entries.length - 1;

    while (lo <= hi) {
      final int mid = (hi + lo) ~/ 2;

      if (epoch < getEpochOf(entries[mid], mid)) {
        hi = mid - 1;
      } else if (epoch > getEpochOf(entries[mid], mid)) {
        lo = mid + 1;
      } else {
        return mid;
      }
    }

    return (getEpochOf(entries[lo], lo) - epoch) <
            (epoch - getEpochOf(entries[hi], hi))
        ? lo
        : hi;
  }

  /// Will be called by the chart when it was updated.
  @override
  bool didUpdate(ChartData? oldData) {
    final DataSeries<Tick>? oldSeries = oldData as DataSeries<Tick>?;

    bool updated = false;
    if (oldSeries != null &&
        input.isNotEmpty &&
        isOldDataAvailable(oldSeries)) {
      fillEntriesFromInput(oldSeries);

      // Preserve old computed values in case recomputation is
      // deemed unnecessary.
      _visibleEntries = oldSeries.visibleEntries as VisibleEntries<T>;
      minValueInFrame = oldSeries.minValue;
      maxValueInFrame = oldSeries.maxValue;

      if (entries != null &&
          oldSeries.entries != null &&
          entries!.last == oldSeries.entries!.last) {
        prevLastEntry = oldSeries.prevLastEntry as IndexedEntry<T>?;
      } else if (oldSeries.entries != null) {
        prevLastEntry = IndexedEntry<T>(
          oldSeries.entries!.last as T,
          oldSeries.entries!.length - 1,
        );
        updated = true;
      }
    } else {
      initialize();
      updated = true;
    }

    _initLastTickIndicator();
    _lastTickIndicator?.didUpdate(oldSeries?._lastTickIndicator);

    return updated;
  }

  /// Fills the entries that are about to be painted based on [input] and
  /// [oldSeries]
  ///
  /// [oldSeries] is provided so this [DataSeries] class get the option to reuse
  /// it's previous data.
  ///
  /// Here we just assign [input] to [entries] as a normal [DataSeries] class.
  @protected
  void fillEntriesFromInput(covariant DataSeries<Tick> oldSeries) =>
      entries = input;

  /// Checks whether the old data of the series is available to use
  @protected
  bool isOldDataAvailable(covariant DataSeries<Tick>? oldSeries) =>
      oldSeries?.entries?.isNotEmpty ?? false;

  @override
  // ignore: avoid_renaming_method_parameters
  bool shouldRepaint(ChartData? oldDelegate) {
    final DataSeries<T> oldDataSeries = oldDelegate as DataSeries<T>;
    final VisibleEntries<Tick> current = visibleEntries;
    final VisibleEntries<Tick> previous = oldDataSeries.visibleEntries;

    if (current.isEmpty && previous.isEmpty) {
      return false;
    }
    if (current.isEmpty != previous.isEmpty) {
      return true;
    }

    return current.first != previous.first ||
        current.last != previous.last ||
        style != oldDataSeries.style ||
        ((entries?.isNotEmpty ?? false) &&
            visibleEntries.isNotEmpty &&
            entries?.last == visibleEntries.last);
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
    ChartScaleModel chartScaleModel,
  ) {
    YAxisConfig.instance.yAxisClipping(canvas, size, () {
      super.paint(canvas, size, epochToX, quoteToY, animationInfo, chartConfig,
          theme, chartScaleModel);
    });

    _lastTickIndicator?.paint(canvas, size, epochToX, quoteToY, animationInfo,
        chartConfig, theme, chartScaleModel);

    // Prevent re-animating indicators that haven't changed.
    if (animationInfo.currentTickPercent == 1) {
      resetLastEntryAnimation();
    }
  }

  /// Use this to reset last tick in [entries] animation by setting
  /// [prevLastEntry] to `null`.
  void resetLastEntryAnimation() => prevLastEntry = null;

  /// Each sub-class should implement and return appropriate cross-hair text
  /// based on its own requirements.
  Widget getCrossHairInfo(T crossHairTick, int pipSize, ChartTheme theme);
}
