import 'indicator_options.dart';

/// PSAR options
class WilliamsROptions extends IndicatorOptions {
  /// Initializes
  const WilliamsROptions(
    this.period, {
    bool showLastIndicator = false,
    int pipSize = 4,
  }) : super(
          pipSize: pipSize,
          showLastIndicator: showLastIndicator,
        );

  /// Period
  final int period;

  @override
  List<Object> get props => <Object>[period];
}
