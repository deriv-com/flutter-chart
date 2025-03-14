import 'package:flutter/material.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/markers/marker.dart';

/// Defines the various types of markers that can be displayed on a financial chart.
///
/// Each enum value represents a specific type of point or event in a trading context,
/// which determines how the marker is rendered and positioned on the chart, as well
/// as how it interacts with other chart elements.
enum MarkerType {
  /// Represents an active starting point marker.
  ///
  /// This is typically used to highlight the beginning of an active trade or contract.
  /// It may be rendered differently from a standard start marker to indicate its active status.
  activeStart,

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
  entryTick,

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
  end,

  /// Represents an exit point marker.
  ///
  /// This indicates where a trade or position was exited. It marks the price and time
  /// at which a trader closed a position in the market.
  exit,

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
  /// @param epoch The timestamp of the marker in epoch format (milliseconds since Unix epoch).
  /// @param quote The price value of the marker.
  /// @param direction The direction in which the marker is pointing (up or down).
  /// @param markerType The type of marker, which determines its role and rendering.
  /// @param text The text to display on or near the marker.
  /// @param color The color of the marker.
  ChartMarker({
    required int epoch,
    required double quote,
    required MarkerDirection direction,
    this.markerType,
    this.text,
    this.color,
  }) : super(epoch: epoch, quote: quote, direction: direction);

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

  /// The color of the marker.
  ///
  /// This can be used to visually distinguish different types of markers or to highlight
  /// specific markers. The exact usage of the color depends on the marker type and the
  /// painter implementation.
  ///
  /// If null, a default color is typically used based on the marker type and theme.
  final Color? color;
}
