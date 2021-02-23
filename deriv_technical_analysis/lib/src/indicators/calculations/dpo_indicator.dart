import 'package:deriv_technical_analysis/src/indicators/calculations/sma_indicator.dart';
import 'package:deriv_technical_analysis/src/models/models.dart';

import '../cached_indicator.dart';
import '../indicator.dart';

/// Detrended Price Oscillator Indicator
class DPOIndicator<T extends IndicatorResult> extends CachedIndicator<T> {
  /// Initializes
  DPOIndicator(this.indicator, {int period = 14})
      : _sma = SMAIndicator<T>(indicator, period),
        _timeShift = (period ~/ 2) + 1,
        super.fromIndicator(indicator);

  /// Indicator to calculate SMA on
  final Indicator<T> indicator;

  /// Simple Moving Average Indicator
  final SMAIndicator<T> _sma;

  /// time shift of sma
  final int _timeShift;

  @override
  T calculate(int index) => createResult(
      index: index,
      quote: indicator.getValue(index).quote -
          _sma.getValue(index - _timeShift).quote);
}
