import 'package:deriv_technical_analysis/deriv_technical_analysis.dart';

import '../ma_series.dart';
import 'indicator_options.dart';

/// Rainbow indicator options.
class FractalChaosBandOptions extends IndicatorOptions {
  /// Initializes
  const FractalChaosBandOptions({
    this.channelFill =false,
  }) : super();

  /// number of rainbow bands
  final bool channelFill;

  @override
  List<Object> get props => <Object>[channelFill];
}
