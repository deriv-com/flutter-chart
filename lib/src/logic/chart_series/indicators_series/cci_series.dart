import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/logic/chart_series/indicators_series/abstract_single_indicator_series.dart';
import 'package:deriv_chart/src/logic/chart_series/indicators_series/models/cci_options.dart';
import 'package:deriv_chart/src/logic/chart_series/line_series/line_painter.dart';
import 'package:deriv_chart/src/logic/chart_series/series.dart';
import 'package:deriv_chart/src/logic/chart_series/series_painter.dart';
import 'package:deriv_chart/src/models/indicator_input.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:deriv_technical_analysis/deriv_technical_analysis.dart';

/// Commodity Channel Index series.
class CCISeries extends AbstractSingleIndicatorSeries {
  /// Initializes
  CCISeries(
    this._indicatorInput,
    CCIOptions options, {
    LineStyle style,
    String id,
  })  : _options = options,
        super(
          CloseValueIndicator<Tick>(_indicatorInput),
          id,
          options,
          style: style,
        );

  final IndicatorInput _indicatorInput;

  final CCIOptions _options;

  @override
  SeriesPainter<Series> createPainter() => LinePainter(this);

  @override
  CachedIndicator<Tick> initializeIndicator() =>
      CommodityChannelIndexIndicator<Tick>(_indicatorInput, _options.period);
}
