import '../ma_series.dart';
import 'indicator_options.dart';

/// Bollinger Bands indicator options.
class BollingerBandsOptions extends MAOptions {
  /// Initializes
  const BollingerBandsOptions({
    this.standardDeviationFactor = 2,
    int period,
    MovingAverageType movingAverageType,
  }) : super(period: period, type: movingAverageType);

  /// Standard Deviation value
  final double standardDeviationFactor;

  @override
  List<Object> get props => super.props..add(standardDeviationFactor);
}
