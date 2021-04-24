// @dart=2.9

import 'package:deriv_technical_analysis/deriv_technical_analysis.dart';

import '../ma_series.dart';
import 'indicator_options.dart';

/// Rainbow indicator options.
class RainbowOptions extends MAOptions {
  /// Initializes
  const RainbowOptions({
    this.bandsCount = 10,
    int period,
    MovingAverageType movingAverageType,
  }) : super(period: period, type: movingAverageType);

  /// number of rainbow bands
  final int bandsCount;

  @override
  List<Object> get props => super.props..add(bandsCount);
}
