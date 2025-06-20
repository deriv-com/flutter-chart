/// Defines the visual and behavioral variants of the crosshair component in charts.
///
/// The crosshair is an interactive element that appears when users interact with
/// the chart (via long press or hover) and displays information about data points.
/// Different variants are optimized for different screen sizes and interaction models.
enum CrosshairVariant {
  /// Optimized for mobile devices and smaller screens.
  ///
  /// Characteristics:
  /// * Displays a vertical gradient line at the selected data point
  /// * Shows a dot at the intersection with the data series
  /// * Presents a compact information box with combined date and time
  /// * Designed for touch interactions and limited screen real estate
  /// * Simplified visual appearance to avoid cluttering small screens
  smallScreen,

  /// Optimized for desktop/web applications and larger screens.
  ///
  /// Characteristics:
  /// * Displays both horizontal and vertical dashed lines that span the entire chart
  /// * Shows additional labels on the axes (price on right side, time on bottom)
  /// * Presents a more detailed information box with separated date and time
  /// * Designed for precise mouse interactions and hover events
  /// * Enhanced visual elements that utilize the additional screen space
  /// * Information box positioned with more sophisticated logic to avoid overlapping with cursor
  largeScreen,
}
