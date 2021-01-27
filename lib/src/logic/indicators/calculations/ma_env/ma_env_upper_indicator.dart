import 'package:deriv_chart/src/logic/chart_series/indicators_series/ma_env_series.dart';
import 'package:deriv_chart/src/models/tick.dart';

import '../../cached_indicator.dart';
import '../../indicator.dart';

/// Moving Average Envelope upper indicator
class MAEnvUpperIndicator extends CachedIndicator {
  /// Initializes.
  ///
  ///  [maEnvMiddleIndicator]       the middle band Indicator. Typically an SMAIndicator is
  ///                  used.
  ///  [shift]         the value that shows upper and lower indicator how much shifted from middle indicator
  ///  [shiftType]      type of the shift could be in percent or point
  MAEnvUpperIndicator(this.maEnvMiddleIndicator,
      this.shiftType,
      this.shift) :
        super.fromIndicator(maEnvMiddleIndicator);

  /// The middle indicator of the Moving Average Envelope
  final Indicator maEnvMiddleIndicator;

  /// Moving Average Envelope indicator shift
  final double shift;

  /// Moving Average Envelope indicator shift type
  final ShiftType shiftType;

  @override
  Tick calculate(int index) =>
      Tick(
        epoch: getEpochOfIndex(index),
        quote: getShiftedValue(maEnvMiddleIndicator
            .getValue(index)
            .quote),
      );

  /// Calculate shifted value based on shiftType
  double getShiftedValue(double value) =>
      shiftType == ShiftType.percent ? value * (1 + (shift / 100)) : value +
          shift;
}
