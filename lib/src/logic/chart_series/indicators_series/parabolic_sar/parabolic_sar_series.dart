import 'package:deriv_chart/src/logic/chart_series/data_painters/scatter_painter.dart';
import 'package:deriv_chart/src/logic/chart_series/indicators_series/models/parabolic_sar_options.dart';
import 'package:deriv_chart/src/logic/chart_series/series.dart';
import 'package:deriv_chart/src/logic/chart_series/series_painter.dart';
import 'package:deriv_chart/src/models/indicator_input.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:deriv_chart/src/theme/painting_styles/scatter_style.dart';
import 'package:deriv_technical_analysis/deriv_technical_analysis.dart';

import '../abstract_single_indicator_series.dart';
import 'custom_parabolic_sar_indicator.dart';

/// Parabolic SAR series class.
class ParabolicSARSeries extends AbstractSingleIndicatorSeries {
  /// Initializes
  ParabolicSARSeries(
    this._indicatorInput,
    ParabolicSAROptions options, {
    ScatterStyle style,
    String id,
  })  : _options = options,
        super(
          CloseValueIndicator<Tick>(_indicatorInput),
          id,
          options,
          style: style,
        );

  final IndicatorInput _indicatorInput;

  final ParabolicSAROptions _options;

  @override
  SeriesPainter<Series> createPainter() => ScatterPainter(this);

  @override
  CachedIndicator<Tick> initializeIndicator() => CustomParabolicSarIndicator(
        _indicatorInput,
        accelerationStart: _options.minAccelerationFactor,
        maxAcceleration: _options.maxAccelerationFactor,
      );
}
