import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/logic/chart_series/indicators_series/abstract_single_indicator_series.dart';
import 'package:deriv_chart/src/logic/chart_series/indicators_series/models/cci_options.dart';
import 'package:deriv_chart/src/logic/chart_series/line_series/oscillator_line_painter.dart';
import 'package:deriv_chart/src/logic/chart_series/series.dart';
import 'package:deriv_chart/src/logic/chart_series/series_painter.dart';
import 'package:deriv_chart/src/models/indicator_input.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:deriv_technical_analysis/deriv_technical_analysis.dart';

/// Commodity Channel Index series.
class CCISeries extends AbstractSingleIndicatorSeries {
  /// Initializes
  ///
  /// [options]      options of the [CCISeries] which by changing the CCI
  ///                indicators result will be calculated again.
  /// [cciLineStyle] The style of the Commodity Channel Index line chart.
  /// [id]           The id of this series class. Mostly helpful when there is
  ///                more than one series of the same type.
  CCISeries(
    this._indicatorInput,
    CCIOptions options, {
    this.overboughtValue = 100,
    this.oversoldValue = -100,
    this.overBoughtLineStyle = const LineStyle(),
    this.oversoldLineStyle = const LineStyle(),
    LineStyle cciLineStyle = const LineStyle(),
    String id,
  })  : _options = options,
        super(
          CloseValueIndicator<Tick>(_indicatorInput),
          id,
          options,
          style: cciLineStyle,
        );

  final IndicatorInput _indicatorInput;

  final CCIOptions _options;

  /// Overbought line value.
  final double overboughtValue;

  /// Oversold line value.
  final double oversoldValue;

  /// LineStyle of overbought line
  final LineStyle overBoughtLineStyle;

  /// LineStyle of oversold line
  final LineStyle oversoldLineStyle;

  @override
  SeriesPainter<Series> createPainter() => OscillatorLinePainter(
        this,
        topHorizontalLine: overboughtValue,
        bottomHorizontalLine: oversoldValue,
        mainHorizontalLinesStyle: oversoldLineStyle,
        secondaryHorizontalLinesStyle: oversoldLineStyle,
      );

  @override
  CachedIndicator<Tick> initializeIndicator() =>
      CommodityChannelIndexIndicator<Tick>(_indicatorInput, _options.period);
}
