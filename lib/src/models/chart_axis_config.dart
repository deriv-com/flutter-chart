import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'chart_axis_config.g.dart';

/// Default top bound quote.
const double defaultTopBoundQuote = 60;

/// Default bottom bound quote.
const double defaultBottomBoundQuote = 30;

/// Default Max distance between [rightBoundEpoch] and [_nowEpoch] in pixels.
/// Limits panning to the right.
const double defaultMaxCurrentTickOffset = 150;

/// Configuration for the chart axis.
@immutable
@JsonSerializable()
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
  });

  /// Initializes from JSON.
  factory ChartAxisConfig.fromJson(Map<String, dynamic> json) =>
      _$ChartAxisConfigFromJson(json);

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

  /// Converts to JSON.
  Map<String, dynamic> toJson() => _$ChartAxisConfigToJson(this);

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
