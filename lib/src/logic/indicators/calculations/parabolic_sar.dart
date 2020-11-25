// **********
// ** NOTE ** Not completed yet. In progress...
// **********

import 'package:deriv_chart/src/models/candle.dart';
import 'package:deriv_chart/src/models/tick.dart';

import '../cached_indicator.dart';
import 'helper_indicators/high_value_inidicator.dart';
import 'helper_indicators/low_value_indicator.dart';
import 'highest_value_indicator.dart';
import 'lowest_value_indicator.dart';

/// Parabolic Sar Indicator
class ParabolicSarIndicator extends CachedIndicator<Candle> {
  /// Initializes
  ParabolicSarIndicator(
    List<Candle> entries, {
    double aF = 0.02,
    double maxA = 0.2,
    double increment = 0.02,
  })  : _highPriceIndicator = HighValueIndicator(entries),
        _lowPriceIndicator = LowValueIndicator(entries),
        _maxAcceleration = maxA,
        _accelerationFactor = aF,
        _accelerationIncrement = increment,
        _accelerationStart = aF,
        super(entries);

  final double _maxAcceleration;
  final double _accelerationIncrement;
  final double _accelerationStart;
  double _accelerationFactor;

  // true if uptrend, false otherwise
  bool _currentTrend;

  // index of start bar of the current trend
  int _startTrendIndex = 0;
  
  final LowValueIndicator _lowPriceIndicator;
  final HighValueIndicator _highPriceIndicator;

  // the extreme point of the current calculation
  double currentExtremePoint;

  // depending on trend the maximum or minimum extreme point value of trend
  double _minMaxExtremePoint;

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
      _currentTrend = entries.first.close < (entries[index].close);
      if (!_currentTrend) {
        // down trend
        sar = _highPriceIndicator
            .getValue(index)
            .quote; // put sar on max price of candlestick
      } else {
        // up trend
        sar = _lowPriceIndicator
            .getValue(index)
            .quote; // put sar on min price of candlestick

      }
      currentExtremePoint = sar;
      _minMaxExtremePoint = currentExtremePoint;
      return Tick(epoch: epoch, quote: sar);
    }

    double priorSar = getValue(index - 1).quote;
    if (_currentTrend) {
      // if up trend
      sar = priorSar +
          (_accelerationFactor * ((currentExtremePoint - (priorSar))));
      _currentTrend = _lowPriceIndicator.getValue(index).quote < sar;
      if (!_currentTrend) {
        // check if sar touches the min price
        sar =
            _minMaxExtremePoint; // sar starts at the highest extreme point of previous up trend
        _currentTrend = false; // switch to down trend and reset values
        _startTrendIndex = index;
        _accelerationFactor = _accelerationStart;
        currentExtremePoint = entries[index].low; // put point on max
        _minMaxExtremePoint = currentExtremePoint;
      } else {
        // up trend is going on
        currentExtremePoint =
            HighestValueIndicator(_highPriceIndicator, index - _startTrendIndex)
                .getValue(index)
                .quote;
        if (currentExtremePoint < _minMaxExtremePoint) {
          incrementAcceleration();
          _minMaxExtremePoint = currentExtremePoint;
        }
      }
    } else {
      // downtrend
      sar = priorSar -
          (_accelerationFactor * (((priorSar - (currentExtremePoint)))));
      _currentTrend = _highPriceIndicator.getValue(index).quote < (sar);
      if (_currentTrend) {
        // check if switch to up trend
        sar =
            _minMaxExtremePoint; // sar starts at the lowest extreme point of previous down trend
        _accelerationFactor = _accelerationStart;
        _startTrendIndex = index;
        currentExtremePoint = entries[index].high;
        _minMaxExtremePoint = currentExtremePoint;
      } else {
        // down trend io going on
        currentExtremePoint =
            LowestValueIndicator(_lowPriceIndicator, index - _startTrendIndex)
                .getValue(index)
                .quote;
        if (currentExtremePoint < (_minMaxExtremePoint)) {
          incrementAcceleration();
          _minMaxExtremePoint = currentExtremePoint;
        }
      }
    }
    return Tick(epoch: epoch, quote: sar);
  }

  ///  Increments the acceleration factor.
  void incrementAcceleration() {
    if (_accelerationFactor >= _maxAcceleration) {
      _accelerationFactor = _maxAcceleration;
    } else {
      _accelerationFactor = _accelerationFactor + _accelerationIncrement;
    }
  }
}
