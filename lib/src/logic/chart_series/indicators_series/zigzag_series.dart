import 'package:deriv_chart/src/logic/chart_series/line_series/line_painter.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/zigzag/zigzag_indicator.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/zigzag/zigzag_painter.dart';
import 'package:deriv_chart/src/logic/indicators/indicator.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/helper_indicators/close_value_inidicator.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:deriv_chart/src/theme/painting_styles/line_style.dart';
import 'package:flutter/material.dart';

import '../data_series.dart';
import '../line_series/line_series.dart';
import '../series_painter.dart';

/// A series which shows Moving Average data calculated from [entries].
class ZigZagSeries extends LineSeries {
  /// Initializes a series which shows shows moving Average data calculated from [entries].
  ///
  /// [period] is the average of this number of past data which will be calculated as MA value
  /// [type] The type of moving average.
  ZigZagSeries(List<Tick> entries, {
    String id,
    LineStyle style,
    int distance = 10,
  }) : this.fromIndicator(
    CloseValueIndicator(entries),
    id: id,
    style: style,
    distance: distance,
  );

  @override
  SeriesPainter<DataSeries<Tick>> createPainter() => ZigZagPainter(this);


  /// Initializes
  ZigZagSeries.fromIndicator(Indicator indicator, {
    String id,
    LineStyle style,
    int distance = 10
  }) : super(
   ZigZagIndicator(indicator, distance).results,
    id: id ?? 'Zigzag Indicaator',
    style: style ?? const LineStyle(thickness: 0.9,color: Colors.blue),
  );

}
