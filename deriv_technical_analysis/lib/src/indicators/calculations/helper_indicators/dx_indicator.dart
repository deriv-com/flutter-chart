import 'package:deriv_technical_analysis/deriv_technical_analysis.dart';
import 'package:deriv_technical_analysis/src/indicators/calculations/adx/negative_di_indicator.dart';
import 'package:deriv_technical_analysis/src/indicators/calculations/adx/positive_di_indicator.dart';
import 'package:flutter/foundation.dart';

/// Directional movement line Indicator.
class DXIndicator<T extends IndicatorResult> extends CachedIndicator<T> {
  /// Initializes a Directional movement line Indicator.
  DXIndicator(
    IndicatorDataInput input, {
    @required int period,
  })  : _positiveDIIndicator = PositiveDIIndicator<T>(input, period: period),
        _negativeDIIndicator = NegativeDIIndicator<T>(input, period: period),
        super(input);

  final PositiveDIIndicator<T> _positiveDIIndicator;
  final NegativeDIIndicator<T> _negativeDIIndicator;

  @override
  T calculate(int index) {
    final double pdiValue = _positiveDIIndicator.getValue(index).quote;
    final double ndiValue = _negativeDIIndicator.getValue(index).quote;
    final double sumDI = pdiValue + ndiValue;
    final double diffDI = (pdiValue - ndiValue).abs();
    if ((pdiValue + ndiValue) == 0) {
      return createResult(index: index, quote: 0);
    }
    return createResult(index: index, quote: (diffDI / sumDI) * 100);
  }
}
