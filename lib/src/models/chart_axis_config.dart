import 'package:flutter/foundation.dart';

/// Default top bound quote.
const double defaultTopBoundQuote = 60;

/// Default bottom bound quote.
const double defaultBottomBoundQuote = 30;

/// Default Max distance between [rightBoundEpoch] and [_nowEpoch] in pixels.
/// Limits panning to the right.
const double defaultMaxCurrentTickOffset = 150;

/// Configuration for the chart axis.
@immutable
class ChartAxisConfig {
  /// Initializes the chart axis configuration.
  const ChartAxisConfig({
    this.initialTopBoundQuote = defaultTopBoundQuote,
    this.initialBottomBoundQuote = defaultBottomBoundQuote,
    this.maxCurrentTickOffset = defaultMaxCurrentTickOffset,
    this.defaultIntervalWidth = 20,
    this.showQuoteGrid = true,
    this.showEpochGrid = true,
  });

  /// Top quote bound target for animated transition.
  final double initialTopBoundQuote;

  /// Bottom quote bound target for animated transition.
  final double initialBottomBoundQuote;

  /// Max distance between [rightBoundEpoch] and [_nowEpoch] in pixels.
  /// Limits panning to the right.
  final double maxCurrentTickOffset;

  /// Show Quote Grid lines and labels.
  final bool showQuoteGrid;

  /// Show Epoch Grid lines and labels.
  final bool showEpochGrid;

  /// The default distance between two ticks in pixels.
  ///
  /// Default to this interval width on granularity change.
  final double defaultIntervalWidth;

  /// Creates a copy of this ChartAxisConfig but with the given fields replaced.
  ChartAxisConfig copyWith({
    double? initialTopBoundQuote,
    double? initialBottomBoundQuote,
    double? maxCurrentTickOffset,
  }) =>
      ChartAxisConfig(
        initialTopBoundQuote: initialTopBoundQuote ?? this.initialTopBoundQuote,
        initialBottomBoundQuote:
            initialBottomBoundQuote ?? this.initialBottomBoundQuote,
        maxCurrentTickOffset: maxCurrentTickOffset ?? this.maxCurrentTickOffset,
      );
}
