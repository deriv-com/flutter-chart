import 'package:deriv_technical_analysis/deriv_technical_analysis.dart';
import 'package:deriv_technical_analysis/src/indicators/calculations/atr_indicator.dart';
import 'package:deriv_technical_analysis/src/indicators/calculations/helper_indicators/positive_dm_indicator.dart';
import 'package:deriv_technical_analysis/src/indicators/calculations/mma_indicator.dart';

/// Negative Directional indicator. Part of the Directional Movement System.
class PositiveDIIndicator<T extends IndicatorResult>
    extends CachedIndicator<T> {
  /// Initializes Negative Directional indicator.
  PositiveDIIndicator(
    IndicatorDataInput input, {
    int period = 14,
  })  : _avgPositiveDMIndicator =
            MMAIndicator<T>(PositiveDMIndicator<T>(input), period),
        _atrIndicator = ATRIndicator<T>(input, period: period),
        super(input);

  final MMAIndicator<T> _avgPositiveDMIndicator;
  final ATRIndicator<T> _atrIndicator;

  @override
  T calculate(int index) => createResult(
        index: index,
        quote: (_avgPositiveDMIndicator.getValue(index).quote /
                _atrIndicator.getValue(index).quote) *
            100,
      );
}
