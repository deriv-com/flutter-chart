import 'package:deriv_chart/src/theme/painting_styles/line_style.dart';
import 'indicator_options.dart';

/// Balance of Power (BOP) indicator options.
class BOPOptions extends IndicatorOptions {
  @override
  List<Object?> get props => [period, lineStyle, showLastIndicator, pipSize];

  /// Initializes
  const BOPOptions({
    this.period = 14,
    this.lineStyle,
    bool showLastIndicator = false,
    int pipSize = 4,
  }) : super(
          showLastIndicator: showLastIndicator,
          pipSize: pipSize,
        );

  /// Period for the BOP calculation
  final int period;

  /// Line style for the BOP line
  final LineStyle? lineStyle;
}
