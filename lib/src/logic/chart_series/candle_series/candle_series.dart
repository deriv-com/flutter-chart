import 'dart:math';
import 'dart:ui';

import 'package:deriv_chart/src/logic/chart_series/base_series.dart';
import 'package:deriv_chart/src/logic/chart_series/candle_series/candle_renderable.dart';
import 'package:deriv_chart/src/models/candle.dart';
import 'package:deriv_chart/src/theme/painting_styles/candle_style.dart';
import 'package:flutter/material.dart';

/// Line series
class CandleSeries extends BaseSeries<Candle> {
  /// Initializes
  CandleSeries(
    List<Candle> entries,
    String id, {
    CandleStyle style,
  }) : super(entries, id, style: style ?? CandleStyle());

  @override
  List<double> getMinMaxValue(List<Candle> visibleEntries) {
    final Iterable<double> maxValuesInAction = visibleEntries
        .where((Candle candle) => !candle.high.isNaN)
        .map((Candle candle) => candle.high);

    if (maxValuesInAction.isEmpty) {
      return [double.nan, double.nan];
    }

    final Iterable<double> minValuesInAction = visibleEntries
        .where((Candle candle) => !candle.low.isNaN)
        .map((Candle candle) => candle.low);

    if (minValuesInAction.isEmpty) {
      return [double.nan, double.nan];
    }

    return <double>[
      minValuesInAction.reduce(min),
      maxValuesInAction.reduce(max)
    ];
  }

  @override
  void updateRenderable(
    List<Candle> visibleEntries,
    int leftEpoch,
    int rightEpoch,
  ) =>
      rendererable = CandleRenderable(this, visibleEntries, prevLastEntry);

  @override
  Widget getCrossHairInfo(Candle crossHairTick, int pipSize) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Column(
            children: <Widget>[
              _buildLabelValue('O', crossHairTick.open, pipSize),
              _buildLabelValue('C', crossHairTick.close, pipSize),
            ],
          ),
          const SizedBox(width: 16),
          Column(
            children: <Widget>[
              _buildLabelValue('H', crossHairTick.high, pipSize),
              _buildLabelValue('L', crossHairTick.low, pipSize),
            ],
          ),
        ],
      );

  Widget _buildLabelValue(String label, double value, int pipSize) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(
          children: <Widget>[
            _buildLabel(label),
            const SizedBox(width: 4),
            _buildValue(value, pipSize),
          ],
        ),
      );

  // TODO(Ramin): Add style for cross-hair when design updated
  Text _buildLabel(String label) => Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          color: Colors.white70,
          fontFeatures: [const FontFeature.tabularFigures()],
        ),
      );

  // TODO(Ramin): Add style for cross-hair when design updated
  Text _buildValue(double value, int pipSize) => Text(
        value.toStringAsFixed(pipSize),
        style: const TextStyle(
          fontSize: 12,
          color: Colors.white,
          fontFeatures: [const FontFeature.tabularFigures()],
        ),
      );
}
