import 'package:deriv_technical_analysis/deriv_technical_analysis.dart';
import 'package:deriv_technical_analysis/src/indicators/calculations/atr_indicator.dart';
import 'package:deriv_technical_analysis/src/indicators/calculations/mma_indicator.dart';
import 'package:deriv_technical_analysis/src/indicators/calculations/negative_dm_indicator.dart';

/// Negative Directional indicator. Part of the Directional Movement System.
class NegativeDIIndicator<T extends IndicatorResult>
    extends CachedIndicator<T> {
  ///Initializes a Negative Directional indicator.
  NegativeDIIndicator(
    IndicatorDataInput input, {
    int period = 14,
  })  : _avgMinusDMIndicator =
            MMAIndicator<T>(NegativeDMIndicator<T>(input), period),
        _atrIndicator = ATRIndicator<T>(input, period: period),
        super(input);

  final MMAIndicator<T> _avgMinusDMIndicator;
  final ATRIndicator<T> _atrIndicator;

  @override
  T calculate(int index) => createResult(
      index: index,
      quote: (_avgMinusDMIndicator.getValue(index).quote /
              _atrIndicator.getValue(index).quote) *
          100);
}
