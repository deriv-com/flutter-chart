import 'package:flutter/foundation.dart';

/// Configuration for the chart axis.
@immutable
class ChartAxisConfig {
  /// Initializes the chart axis configuration.
  const ChartAxisConfig({
    this.topBoundQuoteTarget = 60.0,
    this.bottomBoundQuoteTarget = 30.0,
  });

  /// Top quote bound target for animated transition.
  final double topBoundQuoteTarget;

  /// Bottom quote bound target for animated transition.
  final double bottomBoundQuoteTarget;

  /// Creates a copy of this ChartAxisConfig but with the given fields replaced.
  ChartAxisConfig copyWith({
    double? topBoundQuoteTarget,
    double? bottomBoundQuoteTarget,
  }) =>
      ChartAxisConfig(
        topBoundQuoteTarget: topBoundQuoteTarget ?? this.topBoundQuoteTarget,
        bottomBoundQuoteTarget:
            bottomBoundQuoteTarget ?? this.bottomBoundQuoteTarget,
      );
}
