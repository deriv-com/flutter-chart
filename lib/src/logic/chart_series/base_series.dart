import 'dart:math';
import 'dart:ui';

import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/logic/chart_series/base_renderable.dart';
import 'package:flutter/material.dart';

/// Base class of all chart series
abstract class BaseSeries {
  /// Initializes
  BaseSeries(this.entries, this.id);

  /// Paints a frame into canvas
  BaseRendererable rendererable;

  /// Series ID
  final String id;

  ///
  final List<Candle> entries;

  Candle _prevLastCandle;

  /// Setter for [prevLastCandle]
  // ignore: avoid_setters_without_getters
  set prevLast(Candle candle) => _prevLastCandle = candle;

  /// Getter
  Candle get prevLastCandle => _prevLastCandle;

  double _minValueInFrame;
  double _maxValueInFrame;

  /// Min value in frame
  double get minValue => _minValueInFrame ?? double.nan;

  /// Max value in frame
  double get maxValue => _maxValueInFrame ?? double.nan;

  /// Updates visible entries for this renderer
  List<Candle> update(int leftEpoch, int rightEpoch) {
    final int startIndex = _searchLowerIndex(leftEpoch);
    final int endIndex = _searchUpperIndex(rightEpoch);

    final List<Candle> visibleCandles = startIndex == -1 || endIndex == -1
        ? <Candle>[]
        : entries.sublist(startIndex, endIndex);

    _setMinMaxValues(visibleCandles);

    updateRenderable(visibleCandles, leftEpoch, rightEpoch);

    return visibleCandles;
  }

  void _setMinMaxValues(List<Candle> visibleEntries) {
    final List<double> minMaxValues = getMinMaxValue(visibleEntries);

    if (minMaxValues == null) {
      _calculateMinMax(visibleEntries);
    } else {
      _minValueInFrame = minMaxValues[0];
      _maxValueInFrame = minMaxValues[1];
    }
  }

  /// Get min and max values after updating visible candles
  List<double> getMinMaxValue(List<Candle> visibleEntries);

  void _calculateMinMax(List<Candle> visibleEntries) {
    final Iterable<double> valuesInAction = visibleEntries
        .where((Candle candle) => !candle.close.isNaN)
        .map((Candle candle) => candle.close);

    if (valuesInAction.isEmpty) {
      _minValueInFrame = null;
      _maxValueInFrame = null;
    } else {
      _minValueInFrame = valuesInAction.reduce(min);
      _maxValueInFrame = valuesInAction.reduce(max);
    }
  }

  /// Binary search to find closest entry to XFactor
  int _searchLowerIndex(int leftEpoch) {
    if (leftEpoch < entries[0].epoch) {
      return 0;
    }
    if (leftEpoch > entries[entries.length - 1].epoch) {
      return -1;
    }

    int lo = 0;
    int hi = entries.length - 1;

    while (lo <= hi) {
      final int mid = (hi + lo) ~/ 2;

      if (leftEpoch < entries[mid].epoch) {
        hi = mid - 1;
      } else if (leftEpoch > entries[mid].epoch) {
        lo = mid + 1;
      } else {
        return mid;
      }
    }

    final int closest =
        (entries[lo].epoch - leftEpoch) < (leftEpoch - entries[hi].epoch)
            ? lo
            : hi;
    final int index = closest <= leftEpoch
        ? closest
        : closest - 1 < 0 ? closest : closest - 1;
    return index - 1 < 0 ? index : index - 1;
  }

  int _searchUpperIndex(int rightEpoch) {
    if (rightEpoch < entries[0].epoch) {
      return -1;
    }
    if (rightEpoch > entries[entries.length - 1].epoch) {
      return entries.length;
    }

    int lo = 0;
    int hi = entries.length - 1;

    while (lo <= hi) {
      final int mid = (hi + lo) ~/ 2;

      if (rightEpoch < entries[mid].epoch) {
        hi = mid - 1;
      } else if (rightEpoch > entries[mid].epoch) {
        lo = mid + 1;
      } else {
        return mid;
      }
    }

    final int closest =
        (entries[lo].epoch - rightEpoch) < (rightEpoch - entries[hi].epoch)
            ? lo
            : hi;

    final int index = closest >= rightEpoch
        ? closest
        : (closest + 1 > entries.length ? closest : closest + 1);
    return index == entries.length ? index : index + 1;
  }

  /// Updates [rendererable] with the new [visibleEntries] and XFactor boundaries
  void updateRenderable(
    List<Candle> visibleEntries,
    int leftEpoch,
    int rightEpoch,
  );

  /// Paints [rendererable]'s data on the [canvas]
  /// Will get called after [updateRenderable] method
  void paint(
    Canvas canvas,
    Size size,
    double animatingMinValue,
    double animatingMaxValue,
  ) =>
      rendererable?.paint(
        canvas: canvas,
        size: size,
        animatingMinValue: animatingMinValue,
        animatingMaxValue: animatingMaxValue,
      );
}
