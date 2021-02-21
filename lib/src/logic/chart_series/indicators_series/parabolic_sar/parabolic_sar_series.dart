import 'package:deriv_chart/src/logic/chart_series/indicators_series/models/indicator_options.dart';
import 'package:deriv_chart/src/logic/chart_series/line_series/line_painter.dart';
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
    String id,
    IndicatorOptions options,
  ) : super(CloseValueIndicator<Tick>(_indicatorInput), id, options);

  final IndicatorInput _indicatorInput;

  @override
  SeriesPainter<Series> createPainter() => LinePainter(this);

  @override
  CachedIndicator<Tick> initializeIndicator() =>
      ReusableParabolicSarIndicator(_indicatorInput);
}
