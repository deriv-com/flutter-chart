import 'package:deriv_technical_analysis/src/models/models.dart';

import '../indicator.dart';
import 'ema_indicator.dart';

/// Smoothed Moving Average indicator.
class SMMAIndicator<T extends IndicatorResult> extends AbstractEMAIndicator<T> {
  /// Initialize a Smoothed Moving Average indicator.
  SMMAIndicator(
    Indicator<T> indicator,
    int period,
    double smoothing,
  ) : super(indicator, period, smoothing / period);
}
