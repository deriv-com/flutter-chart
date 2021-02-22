import 'package:deriv_technical_analysis/src/indicators/calculations/arron/aroon_down_indicator.dart';

import '../../../../deriv_technical_analysis.dart';
import 'aroon_up_indicator.dart';

/// Calculates the value for Aroon Oscillator Indicator.
class AroonOscillatorIndicator<T extends IndicatorResult>
    extends CachedIndicator<T> {
  /// Initializes
  AroonOscillatorIndicator.fromIndicator(
      IndicatorDataInput indicatorDataInput, int barCount)
      : upChannel = AroonDownIndicator<T>.fromIndicator(
            LowValueIndicator<T>(indicatorDataInput), barCount),
        downChannel = AroonUpIndicator<T>.fromIndicator(
            HighValueIndicator<T>(indicatorDataInput), barCount),
        super(indicatorDataInput);

  /// Aroon up channel indicator.
  final Indicator<T> upChannel;

  /// Aroon down channel indicator.
  final Indicator<T> downChannel;

  @override
  T calculate(int index) {
    final double upper = upChannel.getValue(index).quote;
    final double lower = downChannel.getValue(index).quote;
    return createResult(
      index: index,
      quote: upper - lower,
    );
  }
}
