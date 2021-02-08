import 'package:deriv_chart/src/logic/indicators/calculations/ema_indicator.dart';

import '../indicator.dart';

/// Modified moving average indicator.
class MMAIndicator extends AbstractEMAIndicator {
  /// Initialzes a modifed moving average indicator.
  MMAIndicator(
    Indicator indicator,
    int period,
  ) : super(indicator, period, 1.0 / period);
}
