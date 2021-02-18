import 'package:deriv_technical_analysis/src/models/models.dart';

import '../indicator.dart';
import 'ema_indicator.dart';

/// Modified moving average indicator.
class MMAIndicator<T extends IndicatorResult> extends AbstractEMAIndicator<T> {
  /// Initialzes a modifed moving average indicator.
  MMAIndicator(
    Indicator<T> indicator,
    int period,
  ) : super(indicator, period, 1.0 / period);
}
