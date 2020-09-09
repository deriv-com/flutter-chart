import 'dart:math';
import 'dart:ui';

import 'package:deriv_chart/src/logic/chart_series/renderable.dart';
import 'package:deriv_chart/src/models/animation_info.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:deriv_chart/src/theme/painting_styles/chart_paiting_style.dart';
import 'package:flutter/material.dart';

/// Base class of all chart series
abstract class Series<T extends Tick> {
  /// Initializes
  Series(this.entries, this.id, {this.style});

  /// Responsible for painting a frame on the canvas
  Rendererable<T> rendererable;

  /// The painting style of this series
  final ChartPaintingStyle style;

  /// Series ID
  final String id;

  /// Series entries
  final List<T> entries;

  List<T> _visibleEntries = <T>[];

  /// Series visible entries
  List<T> get visibleEntries => _visibleEntries;

  T _prevLastEntry;

  /// A reference to the last entry from series previous [entries] before update
  T get prevLastEntry => _prevLastEntry;

  double _minValueInFrame;
  double _maxValueInFrame;

  /// Min quote in a frame
  double get minValue => _minValueInFrame ?? double.nan;

  /// Max quote in a frame
  double get maxValue => _maxValueInFrame ?? double.nan;

  /// Updates visible entries for this renderer.
  void update(int leftEpoch, int rightEpoch) {
    if (entries.isEmpty) {
      return;
    }

    final int startIndex = _searchLowerIndex(leftEpoch);
    final int endIndex = _searchUpperIndex(rightEpoch);

    final List<T> visibleCandles = startIndex == -1 || endIndex == -1
        ? <T>[]
        : entries.sublist(startIndex, endIndex);

    _setMinMaxValues(visibleCandles);

    updateRenderable(visibleCandles, leftEpoch, rightEpoch);

    _visibleEntries = visibleCandles;
  }

  void _setMinMaxValues(List<T> visibleEntries) {
    final List<double> minMaxValues = getMinMaxValue(visibleEntries);

    _minValueInFrame = minMaxValues[0];
    _maxValueInFrame = minMaxValues[1];
  }

  /// Gets min and max quotes after updating [visibleEntries] as an array with two elements [min, max].
  ///
  /// Sub-classes of can override this method if the calculate min/max differently.
  List<double> getMinMaxValue(List<T> visibleEntries) {
    final Iterable<double> valuesInAction =
        visibleEntries.where((T t) => !t.quote.isNaN).map((T t) => t.quote);

    if (valuesInAction.isEmpty) {
      return <double>[double.nan, double.nan];
    } else {
      return <double>[valuesInAction.reduce(min), valuesInAction.reduce(max)];
    }
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
        : closest - 1 < 0 ? closest : closest - 1;
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

  /// Will be called by the chart when the it was updated.
  void didUpdateSeries(Series<T> oldSeries) {
    if (oldSeries.entries.isNotEmpty) {
      _prevLastEntry = oldSeries.entries.last;
    }
  }

  /// Updates [rendererable] with the new [visibleEntries].
  void updateRenderable(
    List<T> visibleEntries,
    int leftEpoch,
    int rightEpoch,
  );

  /// Paints [rendererable]'s data on the [canvas]
  /// Will get called after [updateRenderable] method
  void paint(
    Canvas canvas,
    Size size,
    double Function(int) epochToX,
    double Function(double) quoteToY,
    AnimationInfo animationInfo,
    int pipSize,
  ) =>
      rendererable?.paint(
        canvas: canvas,
        size: size,
        epochToX: epochToX,
        quoteToY: quoteToY,
        animationInfo: animationInfo,
        pipSize: pipSize,
      );

  /// Each sub-class should implement and return appropriate cross-hair text based on its own requirements
  Widget getCrossHairInfo(T crossHairTick, int pipSize);
}
