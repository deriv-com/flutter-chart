import 'package:deriv_chart/src/models/indicator_input.dart';
import 'package:deriv_chart/src/logic/chart_series/line_series/line_painter.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:deriv_chart/src/theme/painting_styles/line_style.dart';
import 'package:deriv_technical_analysis/deriv_technical_analysis.dart';

import '../series.dart';
import '../series_painter.dart';
import 'abstract_single_indicator_series.dart';
import 'models/indicator_options.dart';


/// A function which takes list of ticks and period and creates MA Indicator on it.
typedef MAIndicatorBuilder = CachedIndicator<Tick> Function(
    Indicator<Tick> indicatorInput,
    MAOptions maOptions,
    );
/// A series which shows Moving Average data calculated from [entries].
class MASeries extends AbstractSingleIndicatorSeries {
  /// Initializes a series which shows shows moving Average data calculated from [entries].
  ///
  /// [options]   Options of this [MASeries].
  MASeries(
    IndicatorInput indicatorInput,
    MAOptions options, {
    String id,
    LineStyle style,
    int offset,
  }) : this.fromIndicator(
          CloseValueIndicator<Tick>(indicatorInput),
          id: id,
          options: options,
          style: style,
          offset: offset,
        );

  /// Initializes
  MASeries.fromIndicator(
    Indicator<Tick> indicator, {
    String id,
    LineStyle style,
    MAOptions options,
    int offset,
  }) : super(
          indicator,
          id ?? 'SMASeries-period${options.period}-type${options.type}',
          options,
          style: style ?? const LineStyle(thickness: 0.5),
          offset: offset ?? 0,
        );

  @override
  SeriesPainter<Series> createPainter() => LinePainter(this);

  @override
  CachedIndicator<Tick> initializeIndicator() =>
     supportedMATypes[(options as MAOptions).type](inputIndicator,options);

  /// Indicators supported Moving Average types
  static final Map<String, MAIndicatorBuilder> supportedMATypes =
  <String, MAIndicatorBuilder>{
    'simple': (Indicator<Tick> indicator, MAOptions maOptions) =>
        SMAIndicator<Tick>(indicator, maOptions.period),
    'exponential': (Indicator<Tick> indicator,  MAOptions maOptions) =>
        EMAIndicator<Tick>(indicator, maOptions.period),
    'weighted': (Indicator<Tick> indicator,  MAOptions maOptions) =>
        WMAIndicator<Tick>(indicator, maOptions.period),
    'hull': (Indicator<Tick> indicator,  MAOptions maOptions) =>
        HMAIndicator<Tick>(indicator, maOptions.period),
    'zeroLag': (Indicator<Tick> indicator,  MAOptions maOptions) =>
        ZLEMAIndicator<Tick>(indicator, maOptions.period),
  };
}
