import 'package:deriv_technical_analysis/src/indicators/calculations/sma_indicator.dart';
import 'package:deriv_technical_analysis/src/models/models.dart';

import '../cached_indicator.dart';
import '../indicator.dart';

/// Detrended Price Oscillator Indicator
class DPOIndicator<T extends IndicatorResult> extends CachedIndicator<T> {
  /// Initializes
  DPOIndicator(this.indicator, this.barCount)
      : sma = SMAIndicator<T>(indicator, barCount),
        timeShift = (barCount ~/ 2) + 1,
        super.fromIndicator(indicator);

  /// Indicator to calculate SMA on
  final Indicator<T> indicator;

  /// Simple Moving Average Indicator
  final SMAIndicator<T> sma;

  /// Bar count
  final int barCount;

  /// time shift of sma
  final int timeShift;

  @override
  T calculate(int index) => createResult(
      index: index,
      quote: indicator.getValue(index).quote -
          sma.getValue(index - timeShift).quote);
}
