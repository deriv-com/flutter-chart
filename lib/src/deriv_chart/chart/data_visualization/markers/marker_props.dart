/// A configuration class that holds properties for chart markers.
///
/// `MarkerProps` serves as a container for various properties that affect how
/// markers are rendered and behave on the chart. It provides a platform-agnostic
/// way to configure marker behavior, ensuring consistent appearance and functionality
/// across different platforms (web, mobile, desktop).
///
/// This class is designed to be extensible, allowing for additional properties
/// to be added in the future as marker functionality evolves. It includes methods
/// for serialization and deserialization to/from maps, which facilitates data
/// transfer between different parts of the application.
///
/// `MarkerProps` instances are typically associated with `MarkerGroup` objects,
/// which use these properties to determine how their markers should be rendered
/// and behave on the chart.
class MarkerProps {
  /// Creates a new `MarkerProps` instance with the specified properties.
  ///
  /// @param hasPersistentBorders Whether barriers associated with this marker should
  ///        be drawn even when they're outside the visible area of the chart.
  ///        Default is false, meaning barriers are only drawn when visible.
  const MarkerProps({
    this.hasPersistentBorders = false,
  });

  /// Whether barriers associated with this marker should be drawn even when
  /// they're outside the visible area of the chart.
  ///
  /// When set to true, barriers (such as horizontal or vertical lines) will be
  /// drawn even if they extend beyond the visible area of the chart. This is
  /// useful for ensuring that important barriers are always visible to the user,
  /// regardless of the current view position or zoom level.
  ///
  /// When set to false (the default), barriers are only drawn when they fall
  /// within the visible area of the chart, which can improve performance by
  /// reducing the number of elements that need to be rendered.
  final bool hasPersistentBorders;
}
