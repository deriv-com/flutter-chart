import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/indicators_series/ma_series.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/indicators_series/models/indicator_options.dart';
import 'package:deriv_chart/src/theme/painting_styles/line_style.dart';

/// SMI Options
class SMIOptions extends IndicatorOptions {
  /// Initializes
  const SMIOptions({
    this.period = 10,
    this.smoothingPeriod = 3,
    this.doubleSmoothingPeriod = 3,
    this.signalOptions = const MAOptions(
      period: 10,
      type: MovingAverageType.exponential,
    ),
    this.lineStyle,
    this.signalLineStyle,
    bool showLastIndicator = false,
    int pipSize = 4,
  }) : super(
          showLastIndicator: showLastIndicator,
          pipSize: pipSize,
        );

  /// Period
  final int period;

  /// Smoothing period
  final int smoothingPeriod;

  /// Double Smoothing period.
  final int doubleSmoothingPeriod;

  /// SMI signal options.
  final MAOptions signalOptions;

  ///  Line style.
  final LineStyle? lineStyle;

  /// Signal line style.
  final LineStyle? signalLineStyle;

  @override
  List<Object> get props => <Object>[
        period,
        smoothingPeriod,
        doubleSmoothingPeriod,
        signalOptions,
      ];
}
