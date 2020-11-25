import 'package:deriv_chart/src/models/candle.dart';
import 'package:deriv_chart/src/models/tick.dart';

import 'cached_indicator.dart';
import 'helper_indicators/high_value_inidicator.dart';
import 'helper_indicators/low_value_indicator.dart';
import 'highest_value_indicator.dart';
import 'lowest_value_indicator.dart';

/// Parabolic Sar Indicator
class ParabolicSarIndicator extends CachedIndicator<Candle> {
  double maxAcceleration;
  double accelerationIncrement;
  double accelerationStart;
  double accelerationFactor;
  bool currentTrend; // true if uptrend, false otherwise
  int startTrendIndex = 0; // index of start bar of the current trend
  LowValueIndicator lowPriceIndicator;
  HighValueIndicator highPriceIndicator;
  double currentExtremePoint; // the extreme point of the current calculation
  double
      minMaxExtremePoint; // depending on trend the maximum or minimum extreme point value of trend

  /// Initializes
  ParabolicSarIndicator(
    List<Candle> candles, {
    double aF = 0.02,
    double maxA = 0.2,
    double increment = 0.02,
  })  : highPriceIndicator = HighValueIndicator(candles),
        lowPriceIndicator = LowValueIndicator(candles),
        maxAcceleration = maxA,
        accelerationFactor = aF,
        accelerationIncrement = increment,
        accelerationStart = aF,
        super(candles);

  @override
  Tick calculate(int index) {
    final int epoch = entries[index].epoch;
    double sar = double.nan;
    if (index == 0) {
      return Tick(
          epoch: epoch,
          quote: sar); // no trend detection possible for the first value
    } else if (index == 1) {
      // start trend detection
      currentTrend = entries.first.close < (entries[index].close);
      if (!currentTrend) {
        // down trend
        sar = highPriceIndicator
            .getValue(index)
            .quote; // put sar on max price of candlestick
      } else {
        // up trend
        sar = lowPriceIndicator
            .getValue(index)
            .quote; // put sar on min price of candlestick

      }
      currentExtremePoint = sar;
      minMaxExtremePoint = currentExtremePoint;
      return Tick(epoch: epoch, quote: sar);
    }

    double priorSar = getValue(index - 1).quote;
    if (currentTrend) {
      // if up trend
      sar = priorSar +
          (accelerationFactor * ((currentExtremePoint - (priorSar))));
      currentTrend = lowPriceIndicator.getValue(index).quote < sar;
      if (!currentTrend) {
        // check if sar touches the min price
        sar =
            minMaxExtremePoint; // sar starts at the highest extreme point of previous up trend
        currentTrend = false; // switch to down trend and reset values
        startTrendIndex = index;
        accelerationFactor = accelerationStart;
        currentExtremePoint = entries[index].low; // put point on max
        minMaxExtremePoint = currentExtremePoint;
      } else {
        // up trend is going on
        currentExtremePoint =
            HighestValueIndicator(highPriceIndicator, index - startTrendIndex)
                .getValue(index)
                .quote;
        if (currentExtremePoint < minMaxExtremePoint) {
          incrementAcceleration();
          minMaxExtremePoint = currentExtremePoint;
        }
      }
    } else {
      // downtrend
      sar = priorSar -
          (accelerationFactor * (((priorSar - (currentExtremePoint)))));
      currentTrend = highPriceIndicator.getValue(index).quote < (sar);
      if (currentTrend) {
        // check if switch to up trend
        sar =
            minMaxExtremePoint; // sar starts at the lowest extreme point of previous down trend
        accelerationFactor = accelerationStart;
        startTrendIndex = index;
        currentExtremePoint = entries[index].high;
        minMaxExtremePoint = currentExtremePoint;
      } else {
        // down trend io going on
        currentExtremePoint =
            LowestValueIndicator(lowPriceIndicator, index - startTrendIndex)
                .getValue(index)
                .quote;
        if (currentExtremePoint < (minMaxExtremePoint)) {
          incrementAcceleration();
          minMaxExtremePoint = currentExtremePoint;
        }
      }
    }
    return Tick(epoch: epoch, quote: sar);
  }

  ///  Increments the acceleration factor.
  void incrementAcceleration() {
    if (accelerationFactor >= maxAcceleration) {
      accelerationFactor = maxAcceleration;
    } else {
      accelerationFactor = accelerationFactor + accelerationIncrement;
    }
  }
}
