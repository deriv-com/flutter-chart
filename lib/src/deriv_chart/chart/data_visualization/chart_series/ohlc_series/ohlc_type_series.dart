import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:deriv_chart/src/models/candle.dart';
import 'package:deriv_chart/src/theme/painting_styles/candle_style.dart';
import 'package:flutter/material.dart';

import '../data_series.dart';

/// Super-class of series with OHLC data (CandleStick, OHLC, Hollow).
abstract class OHLCTypeSeries extends DataSeries<Candle> {
  /// Initializes
  OHLCTypeSeries(
    List<Candle> entries,
    String id, {
    CandleStyle style,
  }) : super(entries, id, style: style);

  @override
  Widget getCrossHairInfo(
          Candle crossHairTick, int pipSize, ChartTheme theme) =>
      Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _buildLabelValue('O', crossHairTick.open, pipSize, theme),
              _buildLabelValue('C', crossHairTick.close, pipSize, theme),
            ],
          ),
          const SizedBox(width: 16),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _buildLabelValue('H', crossHairTick.high, pipSize, theme),
              _buildLabelValue('L', crossHairTick.low, pipSize, theme),
            ],
          ),
        ],
      );

  Widget _buildLabelValue(
          String label, double value, int pipSize, ChartTheme theme) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(
          children: <Widget>[
            Text(
              label,
              style: theme.overLine,
              textAlign: TextAlign.center,
            ),
            const SizedBox(width: 4),
            Text(
              value.toStringAsFixed(pipSize),
              style: theme.overLine,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );

  @override
  double maxValueOf(Candle t) => t.high;

  @override
  double minValueOf(Candle t) => t.low;
}
