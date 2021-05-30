import 'package:deriv_chart/src/logic/chart_series/indicators_series/abstract_single_indicator_series.dart';
import 'package:deriv_chart/src/logic/chart_series/indicators_series/models/williams_r_options.dart';
import 'package:deriv_chart/src/logic/chart_series/line_series/line_painter.dart';
import 'package:deriv_chart/src/logic/chart_series/series.dart';
import 'package:deriv_chart/src/logic/chart_series/series_painter.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:deriv_technical_analysis/deriv_technical_analysis.dart';

/// WilliamsRSeries
class WilliamsRSeries extends AbstractSingleIndicatorSeries {
  /// Initializes
  WilliamsRSeries(
    this._indicatorDataInput,
    String id,
    this._options,
  ) : super(CloseValueIndicator<Tick>(_indicatorDataInput), id, _options);

  final IndicatorDataInput _indicatorDataInput;

  final WilliamsROptions _options;

  @override
  SeriesPainter<Series> createPainter() => LinePainter(this);

  @override
  CachedIndicator<Tick> initializeIndicator() => WilliamsRIndicator<Tick>(
        _indicatorDataInput,
        _options.period,
      );
}
