import 'package:deriv_chart/src/deriv_chart/indicators_ui/aroon/aroon_indicator_config.dart';
import 'package:deriv_chart/src/logic/chart_series/indicators_series/single_indicator_series.dart';
import 'package:deriv_chart/src/logic/chart_series/line_series/line_painter.dart';
import 'package:deriv_chart/src/models/animation_info.dart';
import 'package:deriv_chart/src/models/chart_config.dart';
import 'package:deriv_chart/src/models/indicator_input.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:deriv_chart/src/theme/painting_styles/line_style.dart';
import 'package:deriv_technical_analysis/deriv_technical_analysis.dart';
import 'package:flutter/material.dart';

import '../../chart_data.dart';
import '../series.dart';
import '../series_painter.dart';

/// A series which shows Fractal Chaos Band Series data calculated from 'entries'.
class AroonSeries extends Series {
  /// Initializes

  AroonSeries(
    this.indicatorInput, {
    String id,
   this.indicatorConfig,
  }) : super(id);

  ///input data
  final IndicatorInput indicatorInput;
  final AroonIndicatorConfig indicatorConfig;

  SingleIndicatorSeries _aroonUpSeries;
  SingleIndicatorSeries _aroonDownSeries;

  @override
  SeriesPainter<Series> createPainter() {
    _aroonUpSeries = SingleIndicatorSeries(
      painterCreator: (Series series) => LinePainter(series),
      indicatorCreator: () => AroonUpIndicator<Tick>(indicatorInput,),
      inputIndicator: CloseValueIndicator<Tick>(indicatorInput),
      style: const LineStyle(color: Colors.blue),
    );
    _aroonDownSeries = SingleIndicatorSeries(
      painterCreator: (Series series) => LinePainter(series),
      indicatorCreator: () => FCBLowIndicator<Tick>(indicatorInput),
      inputIndicator: CloseValueIndicator<Tick>(indicatorInput),
      style: const LineStyle(color: Colors.blue),
    );

    return null;
  }

  @override
  bool didUpdate(ChartData oldData) {
    final FractalChaosBandSeries series = oldData;
    final bool _fcbHighUpdated =
        _aroonUpSeries.didUpdate(series?._aroonUpSeries);
    final bool _fcbLowUpdated = _aroonDownSeries.didUpdate(series?._aroonDownSeries);
    return _fcbHighUpdated || _fcbLowUpdated;
  }

  @override
  void onUpdate(int leftEpoch, int rightEpoch) {
    _aroonUpSeries.update(leftEpoch, rightEpoch);
    _aroonDownSeries.update(leftEpoch, rightEpoch);
  }

  @override
  List<double> recalculateMinMax() => <double>[
        <ChartData>[
          _aroonUpSeries,
          _aroonDownSeries,
        ].getMinValue(),
        <ChartData>[
          _aroonUpSeries,
          _aroonDownSeries,
        ].getMaxValue()
      ];

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
    _aroonDownSeries.paint(
        canvas, size, epochToX, quoteToY, animationInfo, chartConfig, theme);
    _aroonUpSeries.paint(
        canvas, size, epochToX, quoteToY, animationInfo, chartConfig, theme);
  }

  @override
  int getMaxEpoch() => <ChartData>[
        _aroonDownSeries,
        _aroonUpSeries,
      ].getMaxEpoch();

  @override
  int getMinEpoch() => <ChartData>[
        _aroonDownSeries,
        _aroonUpSeries,
      ].getMinEpoch();
}
