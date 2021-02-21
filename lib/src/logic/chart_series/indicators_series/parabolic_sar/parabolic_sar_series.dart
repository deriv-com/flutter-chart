import 'package:deriv_chart/src/logic/chart_series/indicators_series/models/parabolic_sar_options.dart';
import 'package:deriv_chart/src/logic/chart_series/scatter/scatter_painter.dart';
import 'package:deriv_chart/src/logic/chart_series/series.dart';
import 'package:deriv_chart/src/logic/chart_series/series_painter.dart';
import 'package:deriv_chart/src/models/indicator_input.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:deriv_technical_analysis/deriv_technical_analysis.dart';

import '../abstract_single_indicator_series.dart';
import 'reusable_parabolic_sar.dart';

/// Parabolic SAR series class.
class ParabolicSARSeries extends AbstractSingleIndicatorSeries {
  /// Initializes
  ParabolicSARSeries(
    this._indicatorInput,
    ParabolicSAROptions options, {
    String id,
  })  : _options = options,
        super(CloseValueIndicator<Tick>(_indicatorInput), id, options);

  final IndicatorInput _indicatorInput;

  final ParabolicSAROptions _options;

  @override
  SeriesPainter<Series> createPainter() => ScatterPainter(this);

  @override
  CachedIndicator<Tick> initializeIndicator() => ReusableParabolicSarIndicator(
        _indicatorInput,
        aF: _options.minAccelerationFactor,
        maxA: _options.maxAccelerationFactor,
      );
}
