import 'package:deriv_chart/src/deriv_chart/interactive_layer/crosshair/crosshair_behaviour/crosshair_behaviour.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/crosshair/crosshair_behaviour/ohlc_series_crosshair_behaviour.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/crosshair/crosshair_highlight_painter.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/crosshair/crosshair_hollow_candle_highlight_painter.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/crosshair/strategy/crosshair_strategy_context.dart';
import 'package:deriv_chart/src/models/candle.dart';
import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:deriv_chart/src/theme/painting_styles/barrier_style.dart';
import 'package:deriv_chart/src/theme/painting_styles/candle_style.dart';

import '../../data_series.dart';
import '../../series_painter.dart';
import '../ohlc_type_series.dart';
import 'hollow_candle_painter.dart';

/// Hollow CandleStick series
class HollowCandleSeries extends OHLCTypeSeries {
  /// Initializes
  HollowCandleSeries(
    List<Candle> entries, {
    String? id,
    CandleStyle? style,
    HorizontalBarrierStyle? lastTickIndicatorStyle,
  }) : super(
          entries,
          id ?? 'HollowCandleSeries',
          style: style,
          lastTickIndicatorStyle: lastTickIndicatorStyle,
        );

  @override
  SeriesPainter<DataSeries<Candle>> createPainter() =>
      HollowCandlePainter(this);

  @override
  CrosshairHighlightPainter getCrosshairHighlightPainter(
    Candle crosshairTick,
    double Function(double) quoteToY,
    double xCenter,
    double elementWidth,
    ChartTheme theme,
  ) {
    // Check if the current candle is bullish or bearish.
    // Bullish means price went up (close > open)
    final bool isBullishCandle = crosshairTick.close > crosshairTick.open;

    return CrosshairHollowCandleHighlightPainter(
      candle: crosshairTick,
      quoteToY: quoteToY,
      xCenter: xCenter,
      candleWidth: elementWidth,
      bodyHighlightColor: isBullishCandle
          ? theme.candleBullishBodyActive
          : theme.candleBearishBodyActive,
      wickHighlightColor: isBullishCandle
          ? theme.candleBullishWickActive
          : theme.candleBearishWickActive,
    );
  }

  @override
  CrosshairStrategyContext<Candle> getCrosshairStrategyContext() {
    return CrosshairStrategyContext<Candle>(
      smallScreenBehaviourBuilder: () =>
          OHLCSeriesSmallScreenBehaviour<Candle>(),
      largeScreenBehaviourBuilder: () =>
          OHLCSeriesLargeScreenBehaviour<Candle>(),
    );
  }
}
