import 'package:flutter/foundation.dart';

/// Default top bound quote.
const double defaultTopBoundQuote = 60;

/// Default bottom bound quote.
const double defaultBottomBoundQuote = 30;

/// Default Max distance between [rightBoundEpoch] and [_nowEpoch] in pixels.
/// Limits panning to the right.
const double defaultMaxCurrentTickOffset = 150;

/// Configuration for auto-interval zoom ranges.
/// Maps granularity (in milliseconds) to the optimal pixel range for that interval.
@immutable
class AutoIntervalZoomRange {
  const AutoIntervalZoomRange({
    required this.granularity,
    required this.minPixelsPerInterval,
    required this.maxPixelsPerInterval,
    this.optimalPixelsPerInterval = 40.0,
  });

  /// The granularity in milliseconds (e.g., 60000 for 1-minute candles)
  final int granularity;

  /// Minimum pixels per interval before switching to smaller granularity
  final double minPixelsPerInterval;

  /// Maximum pixels per interval before switching to larger granularity
  final double maxPixelsPerInterval;

  /// Optimal pixels per interval for this granularity
  final double optimalPixelsPerInterval;
}

/// Default auto-interval configuration for trading timeframes
const List<AutoIntervalZoomRange> defaultAutoIntervalRanges = [
  AutoIntervalZoomRange(
    granularity: 60000,
    minPixelsPerInterval: 10,
    maxPixelsPerInterval: 1000,
  ), // 1 minute - _msPerPx range: ( - 6000)
  AutoIntervalZoomRange(
    granularity: 120000,
    minPixelsPerInterval: 10,
    maxPixelsPerInterval: 40,
  ), // 2 minutes - _msPerPx range: (3000 - 12000)
  AutoIntervalZoomRange(
    granularity: 180000,
    minPixelsPerInterval: 10,
    maxPixelsPerInterval: 30,
  ), // 3 minutes - _msPerPx range: (6000 - 18000)
  AutoIntervalZoomRange(
    granularity: 300000,
    minPixelsPerInterval: 10,
    maxPixelsPerInterval: 25,
  ), // 5 minutes - _msPerPx range: (12000 - 30000)
  AutoIntervalZoomRange(
    granularity: 600000,
    minPixelsPerInterval: 10,
    maxPixelsPerInterval: 33,
  ), // 10 minutes - _msPerPx range: (18000 - 60000)
  AutoIntervalZoomRange(
    granularity: 900000,
    minPixelsPerInterval: 10,
    maxPixelsPerInterval: 30,
  ), // 15 minutes - _msPerPx range: (30000 - 90000)
  AutoIntervalZoomRange(
    granularity: 1800000,
    minPixelsPerInterval: 10,
    maxPixelsPerInterval: 30,
  ), // 30 minutes - _msPerPx range: (60000 - 180000)
  AutoIntervalZoomRange(
    granularity: 3600000,
    minPixelsPerInterval: 10,
    maxPixelsPerInterval: 40,
  ), // 1 hour - _msPerPx range: (90000 - 360000)
  AutoIntervalZoomRange(
    granularity: 7200000,
    minPixelsPerInterval: 10,
    maxPixelsPerInterval: 40,
  ), // 2 hours - _msPerPx range: (180000 - 720000)
  AutoIntervalZoomRange(
    granularity: 14400000,
    minPixelsPerInterval: 10,
    maxPixelsPerInterval: 40,
  ), // 4 hours - _msPerPx range: (360000 - 1440000)
  AutoIntervalZoomRange(
    granularity: 28800000,
    minPixelsPerInterval: 10,
    maxPixelsPerInterval: 40,
  ), // 8 hours - _msPerPx range: (720000 - 2880000)
  AutoIntervalZoomRange(
    granularity: 86400000,
    minPixelsPerInterval: 1,
    maxPixelsPerInterval: 30,
  ), // 1 day - _msPerPx range: (2880000 - )
];

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
    this.showFrame = false,
    this.smoothScrolling = true,
    this.autoIntervalEnabled = false,
    this.autoIntervalZoomRanges = defaultAutoIntervalRanges,
    this.autoIntervalTransitionDuration = const Duration(milliseconds: 480),
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

  /// Show the chart frame and indicators dividers.
  ///
  /// Used in the mobile chart.
  final bool showFrame;

  /// The default distance between two ticks in pixels.
  ///
  /// Default to this interval width on granularity change.
  final double defaultIntervalWidth;

  /// Whether the chart should scroll smoothly.
  /// If `true`, the chart will smoothly adjust the scroll position
  /// (if the last tick is visible) to the right to continuously show new ticks.
  /// If `false`, the chart will only auto-scroll to keep the new tick visible
  /// after receiving a new tick.
  ///
  /// Default is `true`.
  final bool smoothScrolling;

  /// Whether auto-interval adjustment is enabled.
  /// When enabled, the chart will automatically suggest granularity changes
  /// based on zoom level to maintain optimal readability.
  final bool autoIntervalEnabled;

  /// Configuration for auto-interval zoom ranges.
  /// Each range defines the optimal pixel range for a specific granularity.
  final List<AutoIntervalZoomRange> autoIntervalZoomRanges;

  /// Duration of the granularity transition animation.
  final Duration autoIntervalTransitionDuration;

  /// Creates a copy of this ChartAxisConfig but with the given fields replaced.
  ChartAxisConfig copyWith({
    double? initialTopBoundQuote,
    double? initialBottomBoundQuote,
    double? maxCurrentTickOffset,
    bool? autoIntervalEnabled,
    List<AutoIntervalZoomRange>? autoIntervalZoomRanges,
    Duration? autoIntervalTransitionDuration,
  }) =>
      ChartAxisConfig(
        initialTopBoundQuote: initialTopBoundQuote ?? this.initialTopBoundQuote,
        initialBottomBoundQuote:
            initialBottomBoundQuote ?? this.initialBottomBoundQuote,
        maxCurrentTickOffset: maxCurrentTickOffset ?? this.maxCurrentTickOffset,
        autoIntervalEnabled: autoIntervalEnabled ?? this.autoIntervalEnabled,
        autoIntervalZoomRanges:
            autoIntervalZoomRanges ?? this.autoIntervalZoomRanges,
        autoIntervalTransitionDuration: autoIntervalTransitionDuration ??
            this.autoIntervalTransitionDuration,
      );
}
