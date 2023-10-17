import 'package:flutter/foundation.dart';

/// Default top bound quote.
const double defaultTopBoundQuote = 60;

/// Default bottom bound quote.
const double defaultBottomBoundQuote = 30;

/// Configuration for the chart axis.
@immutable
class ChartAxisConfig {
  /// Initializes the chart axis configuration.
  const ChartAxisConfig({
    this.initialTopBoundQuote = defaultTopBoundQuote,
    this.initialBottomBoundQuote = defaultBottomBoundQuote,
  });

  /// Top quote bound target for animated transition.
  final double initialTopBoundQuote;

  /// Bottom quote bound target for animated transition.
  final double initialBottomBoundQuote;

  /// Creates a copy of this ChartAxisConfig but with the given fields replaced.
  ChartAxisConfig copyWith({
    double? initialTopBoundQuote,
    double? initialBottomBoundQuote,
  }) =>
      ChartAxisConfig(
        initialTopBoundQuote: initialTopBoundQuote ?? this.initialTopBoundQuote,
        initialBottomBoundQuote:
            initialBottomBoundQuote ?? this.initialBottomBoundQuote,
      );
}
