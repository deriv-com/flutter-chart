import 'package:deriv_chart/src/theme/painting_styles/line_style.dart';

import '../ma_series.dart';
import 'indicator_options.dart';

/// Detrended Price Oscillator indicator options.
class DPOOptions extends MAOptions {
  /// Initializes
  const DPOOptions({
    int period = 14,
    MovingAverageType movingAverageType = MovingAverageType.simple,
    this.isCentered = true,
    this.lineStyle,
    bool showLastIndicator = false,
    int pipSize = 4,
  }) : super(
          period: period,
          type: movingAverageType,
          showLastIndicator: showLastIndicator,
          pipSize: pipSize,
        );

  /// Line style.
  final LineStyle? lineStyle;

  /// Wether the indicator should be calculated `Centered` or not.
  final bool isCentered;
}
