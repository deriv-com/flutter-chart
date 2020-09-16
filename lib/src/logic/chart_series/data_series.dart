import 'package:deriv_chart/src/logic/chart_series/entry_series.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:deriv_chart/src/theme/painting_styles/chart_paiting_style.dart';
import 'package:flutter/material.dart';

/// Series with only a single list of data to show like Line, CandleStick, OHLC.
abstract class DataSeries<T extends Tick> extends EntrySeries<T> {
  /// Initializes
  ///
  /// [entries] is the list of data to show.
  DataSeries(
    List<T> entries,
    String id, {
    ChartPaintingStyle style,
  }) : super(entries, id, style: style);

  /// Each sub-class should implement and return appropriate cross-hair text based on its own requirements
  Widget getCrossHairInfo(T crossHairTick, int pipSize);
}
