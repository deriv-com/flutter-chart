import 'package:deriv_technical_analysis/src/models/models.dart';

import '../../cached_indicator.dart';
import '../../indicator.dart';
import 'ma_env_shift_typs.dart';

/// Moving Average Envelope upper indicator
class MAEnvUpperIndicator<T extends IndicatorResult>
    extends CachedIndicator<T> {
  /// Initializes.
  ///
  ///  [maEnvMiddleIndicator]       the middle band Indicator. Typically an SMAIndicator is
  ///                  used.
  ///  [shift]         the value that shows upper and lower indicator how much shifted from middle indicator
  ///  [shiftType]      type of the shift could be in percent or point
  MAEnvUpperIndicator(this.maEnvMiddleIndicator, this.shiftType, this.shift)
      : super.fromIndicator(maEnvMiddleIndicator);

  /// The middle indicator of the Moving Average Envelope
  final Indicator<T> maEnvMiddleIndicator;

  /// Moving Average Envelope indicator shift
  final double shift;

  /// Moving Average Envelope indicator shift type
  final ShiftType shiftType;

  @override
  T calculate(int index) => createResult(
        index: index,
        quote: _getShiftedValue(maEnvMiddleIndicator.getValue(index).quote),
      );

  /// Calculate shifted value based on shiftType
  double _getShiftedValue(double value) => shiftType == ShiftType.percent
      ? value * (1 + (shift / 100))
      : value + shift;
}
