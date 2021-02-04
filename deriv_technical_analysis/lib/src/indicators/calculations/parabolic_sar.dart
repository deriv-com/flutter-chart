// **********
// ** NOTE ** Not completed yet. In progress...
// **********

import 'package:deriv_technical_analysis/src/models/data_input.dart';

import '../../models/models.dart';
import '../cached_indicator.dart';
import 'helper_indicators/high_value_inidicator.dart';
import 'helper_indicators/low_value_indicator.dart';
import 'highest_value_indicator.dart';
import 'lowest_value_indicator.dart';

/// Parabolic Sar Indicator
class ParabolicSarIndicator<T extends Result> extends CachedIndicator<T> {
  /// Initializes
  ParabolicSarIndicator(
    DataInput input, {
    double aF = 0.02,
    double maxA = 0.2,
    double increment = 0.02,
  })  : _highPriceIndicator = HighValueIndicator<T>(input),
        _lowPriceIndicator = LowValueIndicator<T>(input),
        _maxAcceleration = maxA,
        _accelerationFactor = aF,
        _accelerationIncrement = increment,
        _accelerationStart = aF,
        super(input);

  final double _maxAcceleration;
  final double _accelerationIncrement;
  final double _accelerationStart;
  double _accelerationFactor;

  // true if uptrend, false otherwise
  bool _currentTrend;

  // index of start bar of the current trend
  int _startTrendIndex = 0;

  final LowValueIndicator<T> _lowPriceIndicator;
  final HighValueIndicator<T> _highPriceIndicator;

  // the extreme point of the current calculation
  double _currentExtremePoint;

  // depending on trend the maximum or minimum extreme point value of trend
  double _minMaxExtremePoint;

  @override
  T calculate(int index) {
    double sar = double.nan;
    if (index == 0) {
      // no trend detection possible for the first value
      return createResult(index: index, quote: sar);
    } else if (index == 1) {
      // start trend detection
      _currentTrend = entries.first.close < (entries[index].close);
      if (!_currentTrend) {
        // down trend
        // put sar on max price of candlestick
        sar = _highPriceIndicator.getValue(index).quote;
      } else {
        // up trend
        // put sar on min price of candlestick
        sar = _lowPriceIndicator.getValue(index).quote;
      }
      _currentExtremePoint = sar;
      _minMaxExtremePoint = _currentExtremePoint;
      return createResult(index: index, quote: sar);
    }

    final double priorSar = getValue(index - 1).quote;
    if (_currentTrend) {
      // if up trend
      sar =
          priorSar + (_accelerationFactor * (_currentExtremePoint - priorSar));
      _currentTrend = _lowPriceIndicator.getValue(index).quote > sar;
      if (!_currentTrend) {
        // check if sar touches the min price
        // sar starts at the highest extreme point of previous up trend
        sar = _minMaxExtremePoint;
        // switch to down trend and reset values
        _currentTrend = false;
        _startTrendIndex = index;
        _accelerationFactor = _accelerationStart;
        // put point on max
        _currentExtremePoint = entries[index].low;
        _minMaxExtremePoint = _currentExtremePoint;
      } else {
        // up trend is going on
        _currentExtremePoint = HighestValueIndicator<T>(
          _highPriceIndicator,
          index - _startTrendIndex,
        ).getValue(index).quote;
        if (_currentExtremePoint > _minMaxExtremePoint) {
          incrementAcceleration();
          _minMaxExtremePoint = _currentExtremePoint;
        }
      }
    } else {
      // downtrend
      sar =
          priorSar - (_accelerationFactor * (priorSar - _currentExtremePoint));
      _currentTrend = _highPriceIndicator.getValue(index).quote >= sar;
      if (_currentTrend) {
        // check if switch to up trend
        // sar starts at the lowest extreme point of previous down trend
        sar = _minMaxExtremePoint;
        _accelerationFactor = _accelerationStart;
        _startTrendIndex = index;
        _currentExtremePoint = entries[index].high;
        _minMaxExtremePoint = _currentExtremePoint;
      } else {
        // down trend io going on
        _currentExtremePoint = LowestValueIndicator<T>(
          _lowPriceIndicator,
          index - _startTrendIndex,
        ).getValue(index).quote;
        if (_currentExtremePoint < _minMaxExtremePoint) {
          incrementAcceleration();
          _minMaxExtremePoint = _currentExtremePoint;
        }
      }
    }
    return createResult(index: index, quote: sar);
  }

  ///  Increments the acceleration factor.
  void incrementAcceleration() {
    if (_accelerationFactor >= _maxAcceleration) {
      _accelerationFactor = _maxAcceleration;
    } else {
      _accelerationFactor = _accelerationFactor + _accelerationIncrement;
    }
  }

  @override
  void copyValuesFrom(covariant ParabolicSarIndicator<T> other) {
    super.copyValuesFrom(other);

    _currentTrend = other._currentTrend;
    _accelerationFactor = other._accelerationFactor;
    _startTrendIndex = other._startTrendIndex;
    _currentExtremePoint = other._currentExtremePoint;
    _minMaxExtremePoint = other._minMaxExtremePoint;
  }

  @override
  void invalidate(int index) {}
}
