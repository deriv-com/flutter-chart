import 'package:deriv_technical_analysis/deriv_technical_analysis.dart';
import 'package:deriv_technical_analysis/src/indicators/calculations/helper_indicators/tr_indicator.dart';
import 'package:deriv_technical_analysis/src/indicators/calculations/mma_indicator.dart';
import 'package:flutter/foundation.dart';

/// Average true range indicator.
class ATRIndicator<T extends IndicatorResult> extends CachedIndicator<T> {
  /// Initializes an average true range indicator.
  ATRIndicator(
    IndicatorDataInput input, {
    @required int period,
  })  : _averageTrueRangeIndicator =
            MMAIndicator<T>(TRIndicator<T>(input), period),
        super(input);

  final MMAIndicator<T> _averageTrueRangeIndicator;

  @override
  T calculate(int index) => _averageTrueRangeIndicator.getValue(index);
}
