import 'dart:math';

import 'package:deriv_chart/src/logic/chart_data.dart';
import 'package:deriv_chart/src/logic/chart_series/indicators_series/fractals_series/arrow_painter.dart';
import 'package:deriv_chart/src/logic/chart_series/indicators_series/single_indicator_series.dart';
import 'package:deriv_chart/src/logic/chart_series/series.dart';
import 'package:deriv_chart/src/logic/chart_series/series_painter.dart';
import 'package:deriv_chart/src/models/animation_info.dart';
import 'package:deriv_chart/src/models/chart_config.dart';
import 'package:deriv_chart/src/models/indicator_input.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:deriv_technical_analysis/deriv_technical_analysis.dart';
import 'package:flutter/material.dart';



/// Fractal series
class FractalSeries extends Series {
  /// Initializes
  ///
  /// Close values will be chosen by default.
  FractalSeries(
    this.indicatorInput, {
    String id,
  }) : super(id);

  SingleIndicatorSeries _bullishSeries;
  SingleIndicatorSeries _bearishSeries;

///
  IndicatorInput indicatorInput;

  @override
  SeriesPainter<Series> createPainter() {


    _bullishSeries = SingleIndicatorSeries(
      painterCreator: (Series series) => ArrowPainter(series,false),
      indicatorCreator: () => BullishIndicator<Tick>(indicatorInput),
      inputIndicator:CloseValueIndicator<Tick>(indicatorInput),
    );

    _bullishSeries = SingleIndicatorSeries(
      painterCreator: (Series series) => ArrowPainter(series,true),
      indicatorCreator: () => BearishIndicator<Tick>(indicatorInput),
      inputIndicator:CloseValueIndicator<Tick>(indicatorInput) ,
    );


    return null; // TODO(ramin): return the painter that paints Channel Fill between bands
  }

  @override
  bool didUpdate(ChartData oldData) {
    final FractalSeries series = oldData;

    final bool bullishUpdated = _bullishSeries?.didUpdate(series?._bullishSeries);
    final bool bearishUpdated = _bearishSeries?.didUpdate(series?._bearishSeries);


    return bullishUpdated || bearishUpdated;
  }

  @override
  void onUpdate(int leftEpoch, int rightEpoch) {
    if(  _bearishSeries!=null && _bullishSeries!=null ){
    _bullishSeries.update(leftEpoch, rightEpoch);
    _bearishSeries.update(leftEpoch, rightEpoch);}
  }

  @override
  List<double> recalculateMinMax() =>   _bearishSeries!=null && _bullishSeries!=null ?
      // Can just use _lowerSeries minValue for min and _upperSeries maxValue for max.
      // But to be safe we calculate min and max. from all three series.
      <double>[
          min(_bearishSeries.minValue, _bullishSeries.minValue),


          max(_bearishSeries.maxValue, _bullishSeries.maxValue),

      ]: <double>[double.nan,double.nan];

  @override
  void paint(
    Canvas canvas,
    Size size,
    double Function(int) epochToX,
    double Function(double) quoteToY,
    AnimationInfo animationInfo,
    ChartConfig chartConfig,
    ChartTheme theme,
  ) {
    _bearishSeries?.paint(
        canvas, size, epochToX, quoteToY, animationInfo, chartConfig, theme);
    _bullishSeries?.paint(
        canvas, size, epochToX, quoteToY, animationInfo, chartConfig, theme);

    // TODO(ramin): call super.paint to paint the Channels fill.
  }

  @override
  int getMinEpoch() =>
      _bearishSeries!=null && _bullishSeries!=null ?
      min(_bearishSeries?.getMinEpoch(), _bullishSeries?.getMinEpoch()):null;

  @override
  int getMaxEpoch() => _bearishSeries!=null && _bullishSeries!=null ?
      max(_bearishSeries?.getMaxEpoch(), _bullishSeries?.getMaxEpoch()):null;
}
