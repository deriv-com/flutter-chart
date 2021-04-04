import 'dart:ui';

import 'package:deriv_chart/src/models/animation_info.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:flutter/material.dart';

import '../chart_data.dart';
import 'data_series.dart';
import 'series_painter.dart';

/// A class to paint common option of [DataSeries] data.
abstract class DataPainter<S extends DataSeries<Tick>>
    extends SeriesPainter<S> {
  /// Initializes series for sub-class.
  DataPainter(DataSeries<Tick> series) : _dataSeries = series, super(series);

  final DataSeries<Tick> _dataSeries;

  /// Paints [DataSeries.visibleEntries] on the [canvas].
  @override
  void onPaint({
    Canvas canvas,
    Size size,
    EpochToX epochToX,
    QuoteToY quoteToY,
    AnimationInfo animationInfo,
  }) {
    final DataSeries<Tick> series = this.series;

    if (series.visibleEntries.isEmpty) {
      return;
    }

    onPaintData(canvas, size, epochToX, quoteToY, animationInfo);
  }

  /// Gets the real epoch value for the given [tick].
  ///
  /// Real epoch might be shifted forward or backward because of offset.
  int getEpochOf(Tick tick, int index) => _dataSeries.getEpochOf(tick, index);

  /// Paints [DataSeries.visibleEntries].
  void onPaintData(
    Canvas canvas,
    Size size,
    EpochToX epochToX,
    QuoteToY quoteToY,
    AnimationInfo animationInfo,
  );
}
