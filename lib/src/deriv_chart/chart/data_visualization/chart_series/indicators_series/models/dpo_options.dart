import '../ma_series.dart';
import 'indicator_options.dart';

/// Detrended Price Oscillator indicator options.
class DPOOptions extends MAOptions {
  /// Initializes
  const DPOOptions({
    int period = 14,
    MovingAverageType movingAverageType = MovingAverageType.simple,
    this.isCentered = true,
  })  : timeShift = period ~/ 2 + 1,
        super(period: period, type: movingAverageType);

  /// Wether the indicator should be calculated `Centered` or not.
  final bool isCentered;

  /// The shift value for the `PreviousValueIndicator` to calculate the pervious value of.
  ///
  /// It will be calculated this way by using [period]:
  /// ```dart
  /// timeShift = period ~/ 2 + 1
  /// ```
  final int timeShift;
}
