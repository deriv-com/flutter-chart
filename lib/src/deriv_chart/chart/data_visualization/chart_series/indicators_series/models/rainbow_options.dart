import '../ma_series.dart';
import 'indicator_options.dart';

/// Rainbow indicator options.
class RainbowOptions extends MAOptions {
  /// Initializes
  const RainbowOptions({
    this.bandsCount = 10,
    int period = 50,
    MovingAverageType movingAverageType = MovingAverageType.simple,
    bool showLastIndicator = false,
  }) : super(
          period: period,
          type: movingAverageType,
          showLastIndicator: showLastIndicator,
        );

  /// number of rainbow bands
  final int bandsCount;

  @override
  List<Object> get props => super.props..add(bandsCount);
}
