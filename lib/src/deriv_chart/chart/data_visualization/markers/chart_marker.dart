import 'package:flutter/material.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/markers/marker.dart';

/// Defines the various types of markers that can be displayed on a financial chart.
///
/// Each enum value represents a specific type of point or event in a trading context,
/// which determines how the marker is rendered and positioned on the chart, as well
/// as how it interacts with other chart elements.
enum MarkerType {
  /// Represents a contract marker with circular duration display.
  ///
  /// This marker is used to indicate the trade type and duration of the contract
  /// (such as Rise/Fall contracts). It typically displays a circular representation
  /// of the contract duration and serves as a visual anchor for other contract-related
  /// markers like entry points, exit points, and barrier levels.
  contractMarker,

  /// Represents the start time of a contract with a vertical dashed line and a clock icon at the bottom.
  ///
  /// This marker visually indicates the contract's start time on the chart using a vertical dashed line
  /// extending from near the top to near the bottom of the chart, with a clock icon
  /// centered at the bottom of the line.
  startTime,

  /// Represents a standard starting point marker.
  ///
  /// This indicates the beginning of a trade, contract, or other significant chart event.
  /// It serves as a reference point for the start of a trading activity.
  start,

  /// Represents an entry point marker.
  ///
  /// This indicates where a trade or position was entered. It marks the price and time
  /// at which a trader initiated a position in the market.
  entry,

  /// Represents a specific tick that marks an entry point.
  ///
  /// This is more precise than a general entry marker and is tied to a specific price tick.
  /// It's often used in tick-based contracts to mark the exact tick where the contract started.
  entrySpot,

  /// Represents the most recent tick marker.
  ///
  /// This is used to highlight the latest price update on the chart. It helps traders
  /// quickly identify the current market price.
  latestTick,

  /// Represents the tick immediately before the latest tick.
  ///
  /// This can be used for comparison or to show price movement between the previous
  /// and latest ticks. It's useful for visualizing short-term price changes.
  previousTick,

  /// Represents a standard tick marker.
  ///
  /// This is a generic marker for any price tick that needs to be highlighted.
  /// It can be used to mark significant price points that don't fall into other categories.
  tick,

  /// Represents an ending point marker.
  ///
  /// This indicates the conclusion of a trade, contract, or other significant chart event.
  /// It serves as a reference point for the end of a trading activity.
  exitSpot,

  /// Represents an exit point marker.
  ///
  /// This indicates where a trade or position was exited. It marks the price and time
  /// at which a trader closed a position in the market.
  exit,

  /// Represents the exit time of a contract with a vertical dashed/solid line and a flag icon at the bottom.
  ///
  /// This marker visually indicates the exit time of a contract or trade on the chart.
  /// It is rendered as a vertical dashed or solid line extending from near the top to near the bottom
  /// of the chart, with a flag icon centered at the bottom of the line.
  exitTime,

  /// Represents a compact solid start-time connector line.
  ///
  /// Draws a short, solid vertical line segment near the price to indicate
  /// the start time in a condensed layout.
  startTimeCollapsed,

  /// Represents a compact solid end-time connector line.
  ///
  /// Draws a short, solid vertical line segment near the price to indicate
  /// the end time in a condensed layout.
  exitTimeCollapsed,

  /// Represents the latest tick point specifically in relation to a barrier.
  ///
  /// This is used in barrier-based contracts to show the current price relative to the barrier.
  /// It helps traders visualize how close the current price is to crossing a barrier.
  latestTickBarrier,

  /// Represents a high barrier marker.
  ///
  /// In barrier-based contracts, this indicates the upper price threshold. If the price
  /// crosses above this barrier, it may trigger specific contract outcomes.
  highBarrier,

  /// Represents a low barrier marker.
  ///
  /// In barrier-based contracts, this indicates the lower price threshold. If the price
  /// crosses below this barrier, it may trigger specific contract outcomes.
  lowBarrier,

  /// Represents a profit and loss label marker.
  ///
  /// This marker is used to display profit and loss information when a trading contract ends.
  /// It appears as a pill-shaped label with rounded corners containing an icon and the profit/loss
  /// amount.
  profitAndLossLabel,

  /// Represents a profit and loss label marker with a fixed position anchored to the contract marker.
  ///
  /// This marker is used to display profit and loss information when a trading contract ends.
  /// It appears as a pill-shaped label with rounded corners containing an icon and the profit/loss
  /// amount.
  profitAndLossLabelFixed,

  /// Represents a checkpoint line marker for multi-stage contracts.
  ///
  /// This marker renders as a vertical dashed line similar to start/end time markers.
  /// It can display optional text (e.g., "1", "2") at the bottom of the line to indicate
  /// checkpoint sequence. Used for intermediate evaluation points in contracts like
  /// Double Rise/Fall where multiple checkpoints need to be visualized.
  checkpointLine,

  /// Represents a compact solid checkpoint vertical line.
  ///
  /// Draws a short, solid vertical line segment to indicate
  /// a checkpoint time in a condensed layout. Similar to startTimeCollapsed and exitTimeCollapsed,
  /// but used for intermediate checkpoints in multi-stage contracts.
  checkpointLineCollapsed,

  /// Represents the spot price at a checkpoint time line for multi-stage contracts.
  ///
  /// This marker indicates the price value at the moment a checkpoint is evaluated.
  /// Visually identical to [exitSpot] (rendered as a solid filled circle), but
  /// semantically distinct — it marks an intermediate checkpoint price rather
  /// than the final exit price of a contract.
  ///
  /// Used in multi-stage contracts (e.g., Double Rise/Fall) where each checkpoint
  /// line has a corresponding price spot that needs to be highlighted.
  checkpointSpot,
}

/// Determines how the [ChartMarker.text] is styled.
enum MarkerTextType {
  /// Renders the text in a uniform style.
  plain,

  /// Renders the text as a progress counter (e.g. `"2/10"`).
  ///
  /// The text must contain a `/` separator. The part before `/` is rendered
  /// prominently to indicate the current value, while the `/` and the part
  /// after it are rendered smaller to indicate the total.
  counter,
}

/// A specialized marker class for displaying various types of markers on a financial chart.
///
/// `ChartMarker` extends the base `Marker` class to provide additional functionality
/// for displaying different types of markers on a chart. It represents a specific point
/// on the chart with additional properties that determine its appearance and behavior.
///
/// This class is part of an inheritance hierarchy:
/// - `Tick` (base class): Provides basic data point functionality with epoch (timestamp) and quote (price).
/// - `Marker` (parent class): Extends `Tick` to add direction (up/down) and tap functionality.
/// - `ChartMarker` (this class): Extends `Marker` to add marker type, text, and color.
///
/// `ChartMarker` objects are typically grouped into `MarkerGroup` objects, which organize
/// related markers into logical units (e.g., all markers related to a specific trade or contract).
/// These marker groups are then rendered on the chart by specialized painter classes.
// ignore: must_be_immutable
class ChartMarker extends Marker {
  /// Creates a new `ChartMarker` instance with the specified properties.
  ///
  /// The marker's position on the chart is determined by its `epoch` (horizontal position)
  /// and `quote` (vertical position). The `direction` parameter determines whether the
  /// marker points up or down, affecting its visual appearance.
  ///
  /// The `markerType` parameter specifies the type of marker, which determines its role
  /// and how it's rendered on the chart. If null, the marker is treated as a generic marker.
  ///
  /// The `text` parameter provides optional text to display on or near the marker, which
  /// can provide additional context or information.
  ///
  /// The `color` parameter allows for customization of the marker's color, which can be
  /// used to visually distinguish different types of markers or to highlight specific markers.
  ///
  /// The [epoch] is the timestamp of the marker in epoch format (milliseconds since Unix epoch).
  /// The [quote] is the price value of the marker.
  /// The [direction] is the direction in which the marker is pointing (up or down).
  /// The [onTap] is an optional callback function invoked when the marker is tapped.
  /// The [markerType] determines the type of marker, which determines its role and rendering.
  /// The [text] is the text to display on or near the marker.
  /// The [color] is the color of the marker.
  /// The [hasReducedOpacity] determines whether the marker should be rendered with reduced opacity by 50%.
  /// The [displayOffset] is an optional pixel offset applied to the marker's rendered position.
  ChartMarker({
    required int epoch,
    required double quote,
    required MarkerDirection direction,
    VoidCallback? onTap,
    this.markerType,
    this.text,
    this.textType = MarkerTextType.plain,
    this.color,
    this.hasReducedOpacity = false,
    this.displayOffset = Offset.zero,
  }) : super(epoch: epoch, quote: quote, direction: direction, onTap: onTap);

  /// The type of marker, which determines its role and how it's rendered on the chart.
  ///
  /// This property is used by various painter classes to determine the appropriate visual
  /// representation for the marker. Different types of markers (as defined by the `MarkerType`
  /// enum) are rendered differently on the chart. For example:
  /// - Entry and exit markers might be rendered as arrows pointing up or down.
  /// - Barrier markers might be rendered as horizontal lines with labels.
  /// - Tick markers might be rendered as small dots or circles.
  ///
  /// If null, the marker is treated as a generic marker and rendered according to default rules.
  final MarkerType? markerType;

  /// The text to display on or near the marker.
  ///
  /// This can provide additional context or information about the marker, such as a price
  /// value, a label, or a description. The exact positioning and styling of the text depends
  /// on the marker type and the painter implementation.
  ///
  /// If null, no text is displayed for the marker.
  final String? text;

  /// Controls how [text] is styled.
  final MarkerTextType textType;

  /// The color of the marker.
  ///
  /// If provided, this color overrides the default direction-based coloring.
  /// If null, uses [style.upColor] for [MarkerDirection.up] or [style.downColor] for [MarkerDirection.down].
  final Color? color;

  /// Whether marker should be rendered with reduced opacity by 50%.
  ///
  /// When set to true, marker will be rendered at half opacity. This is useful for indicating markers that represent
  /// future or unreached checkpoints in multi-stage contracts.
  ///
  /// Defaults to false (full opacity).
  final bool hasReducedOpacity;

  /// An optional pixel offset applied to the marker's rendered position on the canvas.
  ///
  /// Defaults to [Offset.zero] (no offset). The offset is applied **after** the
  /// epoch/quote → canvas coordinate conversion, so it is expressed in logical
  /// pixels and is independent of zoom level.
  ///
  /// Use this to nudge a marker visually without changing its underlying
  /// epoch/quote data. For example, set `displayOffset: Offset(0, -8)` on a
  /// `profitAndLossLabel` marker to position the pill 8 pixels above the exit
  /// spot dot when they share the same quote value and would otherwise overlap.
  final Offset displayOffset;
}
