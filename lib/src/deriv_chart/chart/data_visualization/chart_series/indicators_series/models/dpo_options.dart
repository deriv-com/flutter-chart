import '../ma_series.dart';
import 'indicator_options.dart';

/// Detrended Price Oscillator indicator options.
class DPOOptions extends MAOptions {
  /// Initializes
  const DPOOptions({
    int period = 14,
    MovingAverageType movingAverageType = MovingAverageType.simple,
  }) : super(period: period, type: movingAverageType);
}
