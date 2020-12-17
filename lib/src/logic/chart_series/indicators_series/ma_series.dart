import 'package:deriv_chart/src/logic/chart_data.dart';
import 'package:deriv_chart/src/logic/chart_series/line_series/line_painter.dart';
import 'package:deriv_chart/src/logic/indicators/abstract_indicator.dart';
import 'package:deriv_chart/src/logic/indicators/cached_indicator.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/ema_indicator.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/helper_indicators/close_value_inidicator.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/hma_indicator.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/sma_indicator.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/wma_indicator.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/zelma_indicator.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:deriv_chart/src/theme/painting_styles/line_style.dart';

import '../line_series/line_series.dart';
import '../series.dart';
import '../series_painter.dart';
import 'indicator_series.dart';
import 'models/indicator_options.dart';

/// A series which shows Moving Average data calculated from [entries].
class MASeries extends LineSeries {
  /// Initializes
  ///
  /// [period] is the average of this number of past data which will be calculated as MA value
  /// [type] The type of moving average.
  MASeries(
    List<Tick> entries, {
    String id,
    LineStyle style,
    int period = 15,
    MovingAverageType type = MovingAverageType.simple,
  }) : this.fromIndicator(
          CloseValueIndicator(entries),
          id: id,
          style: style,
          period: period,
          type: type,
        );

  /// Initializes
  MASeries.fromIndicator(
    this.indicator, {
    String id,
    LineStyle style,
    this.period = 15,
    this.type = MovingAverageType.simple,
  }) : super(
          indicator.entries,
          id: id ?? 'SMASeries-period$period-type$type',
          style: style ?? const LineStyle(thickness: 0.5),
        ) {
    print('');
  }

  final int period;

  final MovingAverageType type;

  final AbstractIndicator indicator;

  @override
  void initialize() {
    super.initialize();

    entries = getMAIndicator(indicator, period, type).results;
  }

  // TODO(Ramin): Should be handled in SingleIndicatorSeries.
  void updateEntries(ChartData oldData, bool newTickAdded) {
    final MASeries oldSeries = oldData;
    if (newTickAdded) {
      entries = oldSeries.entries;
    } else {
      initialize();
    }
  }

  static CachedIndicator getMAIndicator(
    AbstractIndicator indicator,
    int period,
    MovingAverageType type,
  ) {
    switch (type) {
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
}

class TestMASeries extends SingleIndicatorSeries<Tick> {
  TestMASeries(
      AbstractIndicator<Tick> inputIndicator, String id, MAOptions options)
      : super(inputIndicator, id, options);

  @override
  SeriesPainter<Series> createPainter() => LinePainter(this);

  @override
  CachedIndicator<Tick> initializeIndicator(
    CachedIndicator<Tick> previousIndicator,
  ) =>
      MASeries.getMAIndicator(inputIndicator, (options as MAOptions).period,
          (options as MAOptions).type);
}
