import 'package:deriv_technical_analysis/src/models/data_input.dart';
import 'package:flutter/foundation.dart';

import '../../models/models.dart';
import '../cached_indicator.dart';
import 'helper_indicators/high_value_inidicator.dart';
import 'helper_indicators/low_value_indicator.dart';
import 'highest_value_indicator.dart';
import 'lowest_value_indicator.dart';

/// Parabolic Sar Indicator
class ParabolicSarIndicator<T extends IndicatorResult>
    extends CachedIndicator<T> {
  /// Initializes
  ParabolicSarIndicator(
    IndicatorDataInput input, {
    double aF = 0.02,
    double maxA = 0.2,
    double increment = 0.02,
  })  : _highPriceIndicator = HighValueIndicator<T>(input),
        _lowPriceIndicator = LowValueIndicator<T>(input),
        _maxAcceleration = maxA,
        accelerationFactor = aF,
        _accelerationIncrement = increment,
        _accelerationStart = aF,
        super(input);

  final double _maxAcceleration;
  final double _accelerationIncrement;
  final double _accelerationStart;

  /// Acceleration Factor
  @protected
  double accelerationFactor;

  /// true if uptrend, false otherwise
  @protected
  bool currentTrend;

  /// index of start bar of the current trend
  @protected
  int startTrendIndex = 0;

  final LowValueIndicator<T> _lowPriceIndicator;
  final HighValueIndicator<T> _highPriceIndicator;

  /// the extreme point of the current calculation
  @protected
  double currentExtremePoint;

  /// depending on trend the maximum or minimum extreme point value of trend
  @protected
  double minMaxExtremePoint;

  @override
  T calculate(int index) {
    double sar = double.nan;
    if (index == 0) {
      // no trend detection possible for the first value
      return createResult(index: index, quote: sar);
    } else if (index == 1) {
      // start trend detection
      currentTrend = entries.first.close < (entries[index].close);
      if (!currentTrend) {
        // down trend
        // put sar on max price of candlestick
        sar = _highPriceIndicator.getValue(index).quote;
      } else {
        // up trend
        // put sar on min price of candlestick
        sar = _lowPriceIndicator.getValue(index).quote;
      }
      currentExtremePoint = sar;
      minMaxExtremePoint = currentExtremePoint;
      return createResult(index: index, quote: sar);
    }

    final double priorSar = getValue(index - 1).quote;
    if (currentTrend) {
      // if up trend
      sar = priorSar + (accelerationFactor * (currentExtremePoint - priorSar));
      currentTrend = _lowPriceIndicator.getValue(index).quote > sar;
      if (!currentTrend) {
        // check if sar touches the min price
        // sar starts at the highest extreme point of previous up trend
        sar = minMaxExtremePoint;
        // switch to down trend and reset values
        currentTrend = false;
        startTrendIndex = index;
        accelerationFactor = _accelerationStart;
        // put point on max
        currentExtremePoint = entries[index].low;
        minMaxExtremePoint = currentExtremePoint;
      } else {
        // up trend is going on
        currentExtremePoint = HighestValueIndicator<T>(
          _highPriceIndicator,
          index - startTrendIndex,
        ).getValue(index).quote;
        if (currentExtremePoint > minMaxExtremePoint) {
          incrementAcceleration();
          minMaxExtremePoint = currentExtremePoint;
        }
      }
    } else {
      // downtrend
      sar = priorSar - (accelerationFactor * (priorSar - currentExtremePoint));
      currentTrend = _highPriceIndicator.getValue(index).quote >= sar;
      if (currentTrend) {
        // check if switch to up trend
        // sar starts at the lowest extreme point of previous down trend
        sar = minMaxExtremePoint;
        accelerationFactor = _accelerationStart;
        startTrendIndex = index;
        currentExtremePoint = entries[index].high;
        minMaxExtremePoint = currentExtremePoint;
      } else {
        // down trend io going on
        currentExtremePoint = LowestValueIndicator<T>(
          _lowPriceIndicator,
          index - startTrendIndex,
        ).getValue(index).quote;
        if (currentExtremePoint < minMaxExtremePoint) {
          incrementAcceleration();
          minMaxExtremePoint = currentExtremePoint;
        }
      }
    }
    return createResult(index: index, quote: sar);
  }

  ///  Increments the acceleration factor.
  void incrementAcceleration() {
    if (accelerationFactor >= _maxAcceleration) {
      accelerationFactor = _maxAcceleration;
    } else {
      accelerationFactor = accelerationFactor + _accelerationIncrement;
    }
  }

  @override
  void copyValuesFrom(covariant ParabolicSarIndicator<T> other) {
    super.copyValuesFrom(other);

    currentTrend = other.currentTrend;
    accelerationFactor = other.accelerationFactor;
    startTrendIndex = other.startTrendIndex;
    currentExtremePoint = other.currentExtremePoint;
    minMaxExtremePoint = other.minMaxExtremePoint;
  }
}
