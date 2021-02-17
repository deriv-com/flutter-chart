import 'package:deriv_technical_analysis/deriv_technical_analysis.dart';

import '../ma_series.dart';
import 'indicator_options.dart';

/// Moving Average Envelope indicator options.
class RainbowOptions extends MAOptions {
  /// Initializes
  const RainbowOptions({
    this.bandsCount = 10,
    int period,
    MovingAverageType movingAverageType,
  }) : super(period: period, type: movingAverageType);

  /// Shift value
  final int bandsCount;

  @override
  List<Object> get props => super.props..add(bandsCount);
}
