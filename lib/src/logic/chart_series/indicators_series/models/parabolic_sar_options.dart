// @dart=2.9

import 'package:deriv_chart/src/logic/chart_series/indicators_series/models/indicator_options.dart';

/// PSAR options
class ParabolicSAROptions extends IndicatorOptions {
  /// Initializes
  const ParabolicSAROptions(
    this.minAccelerationFactor,
    this.maxAccelerationFactor,
  );

  /// Min AccelerationFactor
  final double minAccelerationFactor;

  /// Max AccelerationFactor
  final double maxAccelerationFactor;

  @override
  List<Object> get props =>
      <Object>[minAccelerationFactor, maxAccelerationFactor];
}
