import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/logic/chart_series/data_series.dart';
import 'package:deriv_chart/src/models/candle.dart';
import 'package:deriv_chart/src/theme/painting_styles/candle_style.dart';
import 'package:flutter/material.dart';

/// Super-class of series with OHLC data (CandleStick, OHLC, Hollow).
abstract class OHLCTypeSeries extends DataSeries<Candle> {
  ChartTheme _theme;

  /// Initializes
  OHLCTypeSeries(
    List<Candle> entries,
    String id, {
    CandleStyle style,
  }) : super(entries, id, style: style);

  @override
  Widget getCrossHairInfo(Candle crossHairTick, int pipSize, ChartTheme theme) {
    _theme = theme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _buildLabelValue('O', crossHairTick.open, pipSize),
            _buildLabelValue('C', crossHairTick.close, pipSize),
          ],
        ),
        const SizedBox(width: 16),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _buildLabelValue('H', crossHairTick.high, pipSize),
            _buildLabelValue('L', crossHairTick.low, pipSize),
          ],
        ),
      ],
    );
  }

  Widget _buildLabelValue(String label, double value, int pipSize) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(
          children: <Widget>[
            Text(
              label,
              style: _theme.overline,
            ),
            const SizedBox(width: 4),
            _buildValue(value, pipSize),
          ],
        ),
      );

  Text _buildValue(double value, int pipSize) => Text(
        value.toStringAsFixed(pipSize),
        style: _theme.overline,
      );

  @override
  double maxValueOf(Candle t) => t.high;

  @override
  double minValueOf(Candle t) => t.low;
}
