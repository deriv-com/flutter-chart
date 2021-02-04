import 'package:deriv_chart/src/logic/chart_series/line_series/line_painter.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/helper_indicators/close_value_inidicator.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/zigzag_indicator.dart';
import 'package:deriv_chart/src/logic/indicators/indicator.dart';
import 'package:deriv_chart/src/models/ohlc.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:deriv_chart/src/theme/painting_styles/line_style.dart';
import 'package:flutter/material.dart';

import '../data_series.dart';
import '../line_series/line_series.dart';
import '../series_painter.dart';

/// A series which shows ZigZag data calculated from [entries].
class ZigZagSeries extends LineSeries {
  /// Initializes a series which shows shows ZigZag data calculated from [entries].
  ///
  /// [distance] The minimum distance in percent between two zigzag points.
  ZigZagSeries(
    List<Tick> entries, {
    String id,
    LineStyle style,
    double distance = 10,
  }) : this.fromIndicator(
          CloseValueIndicator(entries),
          id: id,
          style: style,
          distance: distance,
        );

  @override
  SeriesPainter<DataSeries<Tick>> createPainter() => LinePainter(this);

  /// Initializes
  ZigZagSeries.fromIndicator(Indicator indicator,
      {String id, LineStyle style, double distance = 10})
      : super(
          ZigZagIndicator(indicator, distance).results,
          id: id ?? 'Zigzag Indicator',
          style: style ?? const LineStyle(thickness: 0.9, color: Colors.blue),
        );

  @override
  void onUpdate(int leftEpoch, int rightEpoch) {
    super.onUpdate(leftEpoch, rightEpoch);

    if (visibleEntries.isNotEmpty && visibleEntries != null) {
      if (visibleEntries.first.quote.isNaN) {
        final int index = entries.indexOf(visibleEntries.first);
        for (int i = index - 1; i >= 0; i--) {
          if (!entries[i].quote.isNaN) {
            visibleEntries.first = entries[i];
            break;
          }
        }
      }
      if (visibleEntries.last.quote.isNaN) {
        final int index = entries.indexOf(visibleEntries.last);
        for (int i = index + 1; i <= entries.length; i++) {
          if (!entries[i].quote.isNaN) {
            visibleEntries.last = entries[i];
            break;
          }
        }
      }
    }
  }
}
