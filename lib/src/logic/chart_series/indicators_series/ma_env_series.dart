import 'package:deriv_chart/src/logic/indicators/indicator.dart';
import 'package:deriv_chart/src/logic/indicators/cached_indicator.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/ema_indicator.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/helper_indicators/close_value_inidicator.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/hma_indicator.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/sma_indicator.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/wma_indicator.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/zelma_indicator.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:deriv_chart/src/theme/painting_styles/line_style.dart';

import '../../../../deriv_chart.dart';
import '../line_series/line_series.dart';
import '../series_painter.dart';

/// A series which shows Moving Average data calculated from [entries].
class MAEnvSeries extends Series {
  /// Initializes a series which shows shows moving Average data calculated from [entries].
  ///
  /// [period] is the average of this number of past data which will be calculated as MA value
  /// [type] The type of moving average.
  MAEnvSeries(
    List<Tick> entries, {
    String id,
    LineStyle style,
    int period = 50,
    int shift = 5,
    ShiftType shiftType = ShiftType.percent,
    MovingAverageType movingAverageType = MovingAverageType.simple,
  }) : this.fromIndicator(
          CloseValueIndicator(entries),
          id: id,
          style: style,
          period: period,
          movingAverageType: movingAverageType,
          shift: shift,
        );

  /// Initializes
  MAEnvSeries.fromIndicator(
    Indicator indicator, {
    String id,
    LineStyle style,
    int period = 50,
    MovingAverageType movingAverageType = MovingAverageType.simple,
    int shift = 5,
    ShiftType shiftType = ShiftType.percent,
  }) : super(
          getMAIndicator(indicator, period, movingAverageType),
          id: id ?? 'SMASeries-period$period-type$movingAverageType',
          style: style ?? const LineStyle(thickness: 0.5),
        );

  static CachedIndicator getMAIndicator(
    Indicator indicator,
    int period,
    MovingAverageType movingAverageType,
  ) {
    switch (movingAverageType) {
      case MovingAverageType.exponential:
        return EMAIndicator(indicator, period);
      case MovingAverageType.weighted:
        return WMAIndicator(indicator, period);
      case MovingAverageType.hull:
        return HMAIndicator(indicator, period);
      case MovingAverageType.zeroLag:
        return ZLEMAIndicator(indicator, period);
      default:
        return SMAIndicator(indicator, period);
    }
  }



  @override
  SeriesPainter<Series> createPainter() {
    final StandardDeviationIndicator standardDeviation =
    StandardDeviationIndicator(_fieldIndicator, period);

    final CachedIndicator bbmSMA =
    MASeries.getMAIndicator(_fieldIndicator, period, movingAverageType);

    final BollingerBandsLowerIndicator bblSMA = BollingerBandsLowerIndicator(
      bbmSMA,
      standardDeviation,
      k: standardDeviationFactor,
    );

    final BollingerBandsUpperIndicator bbuSMA = BollingerBandsUpperIndicator(
      bbmSMA,
      standardDeviation,
      k: standardDeviationFactor,
    );

    _lowerSeries = LineSeries(bblSMA.results,
        style: const LineStyle(color: Colors.redAccent));
    _middleSeries =
        LineSeries(bbmSMA.results, style: const LineStyle(color: Colors.white));
    _upperSeries = LineSeries(bbuSMA.results,
        style: const LineStyle(color: Colors.lightGreen));

    return null; // TODO(ramin): return the painter that paints Channel Fill between bands
  }

  @override
  bool didUpdate(ChartData oldData) {
    final BollingerBandSeries series = oldData;

    final bool _lowerUpdated = _lowerSeries.didUpdate(series._lowerSeries);
    final bool _middleUpdated = _middleSeries.didUpdate(series._middleSeries);
    final bool _upperUpdated = _upperSeries.didUpdate(series._upperSeries);

    return _lowerUpdated || _middleUpdated || _upperUpdated;
  }

  @override
  void onUpdate(int leftEpoch, int rightEpoch) {
    _lowerSeries.update(leftEpoch, rightEpoch);
    _middleSeries.update(leftEpoch, rightEpoch);
    _upperSeries.update(leftEpoch, rightEpoch);
  }

  @override
  List<double> recalculateMinMax() =>
      // Can just use _lowerSeries minValue for min and _upperSeries maxValue for max.
  // But to be safe we calculate min and max. from all three series.
  <double>[
    min(
      min(_lowerSeries.minValue, _middleSeries.minValue),
      _upperSeries.minValue,
    ),
    max(
      max(_lowerSeries.maxValue, _middleSeries.maxValue),
      _upperSeries.maxValue,
    ),
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
    _lowerSeries.paint(
        canvas, size, epochToX, quoteToY, animationInfo, chartConfig, theme);
    _middleSeries.paint(
        canvas, size, epochToX, quoteToY, animationInfo, chartConfig, theme);
    _upperSeries.paint(
        canvas, size, epochToX, quoteToY, animationInfo, chartConfig, theme);

    // TODO(ramin): call super.paint to paint the Channels fill.
  }
}



}

/// Supported types of shift.
enum ShiftType {
  /// Percent
  percent,

  /// Point
  point,
}
