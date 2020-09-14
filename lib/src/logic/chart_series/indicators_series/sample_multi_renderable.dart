import 'dart:ui';

import 'package:deriv_chart/src/logic/chart_series/renderable.dart';
import 'package:deriv_chart/src/logic/chart_series/series.dart';
import 'package:deriv_chart/src/models/animation_info.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:flutter/material.dart';

import '../../chart_data.dart';
import 'sample_multi_series.dart';

/// A sample class just to represent how a custom indicator with multiple data-series can be implemented.
class SampleMultiRenderable extends Rendererable<SampleMultiSeries> {
  /// Initializes
  SampleMultiRenderable(Series<Tick> series) : super(series);

  @override
  void onPaint({
    Canvas canvas,
    Size size,
    EpochToX epochToX,
    QuoteToY quoteToY,
    AnimationInfo animationInfo,
  }) {
    // Painting red lines in-between two lines of series showing an area.
    for (int i = 0;
        i < series.series1.visibleEntries.length &&
            i < series.series2.visibleEntries.length;
        i++) {
      final Tick s1Entry = series.series1.visibleEntries[i];
      final Tick s2Entry = series.series2.visibleEntries[i];
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
