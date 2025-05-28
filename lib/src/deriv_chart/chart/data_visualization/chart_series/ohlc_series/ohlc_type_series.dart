import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:deriv_chart/src/models/candle.dart';
import 'package:deriv_chart/src/theme/painting_styles/barrier_style.dart';
import 'package:deriv_chart/src/theme/painting_styles/candle_style.dart';
import 'package:flutter/material.dart';

import '../data_series.dart';

/// Super-class of series with OHLC data (CandleStick, OHLC, Hollow).
abstract class OHLCTypeSeries extends DataSeries<Candle> {
  /// Initializes
  OHLCTypeSeries(
    List<Candle> entries,
    String id, {
    CandleStyle? style,
    HorizontalBarrierStyle? lastTickIndicatorStyle,
  }) : super(
          entries,
          id: id,
          style: style,
          lastTickIndicatorStyle: lastTickIndicatorStyle,
        );

  @override
  Widget getCrossHairInfo(Candle crossHairTick, int pipSize, ChartTheme theme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _buildLabelValue('O', crossHairTick.open, pipSize, theme),
              _buildLabelValue('L', crossHairTick.low, pipSize, theme),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _buildLabelValue('H', crossHairTick.high, pipSize, theme),
              _buildLabelValue('C', crossHairTick.close, pipSize, theme),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget getDetailedCrossHairInfo(
      {required Candle crosshairTick,
      required int pipSize,
      required ChartTheme theme}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _buildLabelValue('Open', crosshairTick.open, pipSize, theme),
        _buildLabelValue('High', crosshairTick.high, pipSize, theme),
        _buildLabelValue('Low', crosshairTick.low, pipSize, theme),
        _buildLabelValue('Close', crosshairTick.close, pipSize, theme),
      ],
    );
  }

  Widget _buildLabelValue(
          String label, double value, int pipSize, ChartTheme theme) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              label,
              style: theme.crosshairInformationBoxQuoteStyle.copyWith(
                color: theme.crosshairInformationBoxTextDefault,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(width: 4),
            Text(
              value.toStringAsFixed(pipSize),
              style: theme.crosshairInformationBoxQuoteStyle.copyWith(
                color: theme.crosshairInformationBoxTextDefault,
              ),
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
