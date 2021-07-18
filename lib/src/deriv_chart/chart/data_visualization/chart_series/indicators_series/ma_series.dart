import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/line_series/line_painter.dart';
import 'package:deriv_chart/src/deriv_chart/chart/helpers/functions/helper_functions.dart';
import 'package:deriv_chart/src/models/indicator_input.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:deriv_chart/src/theme/painting_styles/line_style.dart';
import 'package:deriv_technical_analysis/deriv_technical_analysis.dart';

import '../series.dart';
import '../series_painter.dart';
import 'abstract_single_indicator_series.dart';
import 'models/indicator_options.dart';

/// A series which shows Moving Average data calculated from [entries].
class MASeries extends AbstractSingleIndicatorSeries {
  /// Initializes a series which shows shows moving Average data calculated from [entries].
  ///
  /// [options]   Options of this [MASeries].
  MASeries(
    IndicatorInput indicatorInput,
    MAOptions options, {
    String? id,
    LineStyle? style,
    int offset = 0,
  }) : this.fromIndicator(
          CloseValueIndicator<Tick>(indicatorInput),
          options,
          id: id,
          style: style,
          offset: offset,
        );

  /// Initializes
  MASeries.fromIndicator(
    Indicator<Tick> indicator,
    MAOptions options, {
    String? id,
    LineStyle? style,
    int offset = 0,
  }) : super(
          indicator,
          id ?? 'SMASeries-period${options.period}-type${options.type}',
          options,
          style: style ?? const LineStyle(thickness: 0.5),
          offset: offset,
        );

  @override
  SeriesPainter<Series> createPainter() => LinePainter(this);

  @override
  CachedIndicator<Tick> initializeIndicator() =>
      MASeries.getMAIndicator(inputIndicator, options as MAOptions);

  /// Returns a moving average indicator based on [maOptions] values.
  static CachedIndicator<Tick> getMAIndicator(
    Indicator<Tick> indicator,
    MAOptions maOptions,
  ) {
    switch (maOptions.type) {
      case MovingAverageType.exponential:
        return EMAIndicator<Tick>(indicator, maOptions.period);
      case MovingAverageType.weighted:
        return WMAIndicator<Tick>(indicator, maOptions.period);
      case MovingAverageType.hull:
        return HMAIndicator<Tick>(indicator, maOptions.period);
      case MovingAverageType.zeroLag:
        return ZLEMAIndicator<Tick>(indicator, maOptions.period);
      case MovingAverageType.doubleExponential:
        return DEMAIndicator<Tick>(indicator, maOptions.period);
      case MovingAverageType.tripleExponential:
        return TEMAIndicator<Tick>(indicator, maOptions.period);
      case MovingAverageType.wellesWilder:
        return WWSMAIndicator<Tick>(indicator, maOptions.period);
      default:
        return SMAIndicator<Tick>(indicator, maOptions.period);
    }
  }
}

/// Supported types of moving average.
enum MovingAverageType {
  /// Simple
  simple,

  /// Exponential
  exponential,

  /// Weighted
  weighted,

  /// Hull
  hull,

  /// Zero-lag exponential
  zeroLag,

  /// Welles Wilder
  wellesWilder,

  /// Double Exponential Moving Average
  doubleExponential,

  /// Triple Exponential Moving Average
  tripleExponential,
}

/// Moving Average types extension.
extension MATypesExtension on MovingAverageType {
  /// Exceptional titles.
  static const Map<MovingAverageType, String> exceptionalTitles =
      <MovingAverageType, String>{
    MovingAverageType.doubleExponential: '2-Exponential',
    MovingAverageType.tripleExponential: '3-Exponential',
  };

  /// Gets the title of enum.
  String get title => exceptionalTitles[this] ?? _getCapitalizedTitle();

  String _getCapitalizedTitle() {
    final String titleText = getEnumValue(this);
    return '${titleText[0].toUpperCase()}${titleText.substring(1)}';
  }
}
