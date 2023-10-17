import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/models/animation_info.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:flutter/material.dart';

import '../../chart_data.dart';
import '../series.dart';
import '../series_painter.dart';
import 'sample_multi_series.dart';

/// A sample class just to represent how a custom indicator with multiple
/// data-series can be implemented.
///
/// This class is created to examine painting some additional things between
/// [SampleMultiSeries] different series. Like area color between Ichimoku
/// clouds leading spans A and B.
///
/// In this example we only paint red lines between [SampleMultiSeries.series1]
/// and [SampleMultiSeries.series2] entries.
class SampleMultiPainter extends SeriesPainter<SampleMultiSeries> {
  /// Initializes a sample class just to represent how a custom indicator with
  /// multiple data-series can be implemented.
  SampleMultiPainter(Series series) : super(series as SampleMultiSeries);

  @override
  void onPaint({
    required Canvas canvas,
    required Size size,
    required EpochToX epochToX,
    required QuoteToY quoteToY,
    required AnimationInfo animationInfo,
  }) {
    // Painting red lines in-between two lines of series showing an area.
    for (int i = 0;
        i < series.series1.visibleEntries.length &&
            i < series.series2.visibleEntries.length;
        i++) {
      final Tick s1Entry = series.series1.visibleEntries.entries[i];
      final Tick s2Entry = series.series2.visibleEntries.entries[i];
      canvas.drawLine(
          Offset(epochToX(s1Entry.epoch), quoteToY(s1Entry.quote)),
          Offset(epochToX(s2Entry.epoch), quoteToY(s2Entry.quote)),
          Paint()
            ..color = Colors.red
            ..strokeWidth = 1
            ..style = PaintingStyle.stroke);
    }
  }
}
