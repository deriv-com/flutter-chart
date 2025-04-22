/// A data class that encapsulates properties used for rendering chart elements.
///
/// `PainterProps` serves as a container for various properties that affect how
/// chart elements (such as markers, series, and annotations) are rendered on the
/// canvas. It provides a convenient way to pass multiple rendering properties
/// as a single object to painting methods.
///
/// This class is typically created by the `ChartScaleModel` and passed to various
/// painter classes in the chart visualization system. It helps ensure consistent
/// rendering of chart elements across different components of the chart.
///
/// The properties in this class primarily relate to the scale and granularity
/// of the chart, which affect the size, spacing, and appearance of visual elements.
class PainterProps {
  /// Creates a new `PainterProps` instance with the specified properties.
  ///
  /// @param granularity The difference in milliseconds between consecutive data points.
  /// @param msPerPx The number of milliseconds represented by one pixel on the x-axis.
  /// @param zoom The zoom factor that affects the scale of visual elements.
  PainterProps({
    required this.granularity,
    required this.msPerPx,
    required this.zoom,
  });

  /// The zoom factor that affects the scale of visual elements.
  ///
  /// This value is derived from the relationship between `msPerPx` and `granularity`
  /// and is used to scale visual elements appropriately at different zoom levels.
  /// Higher zoom values make elements appear larger, while lower values make them smaller.
  ///
  /// For example, when rendering markers, the marker size is often multiplied by
  /// this zoom factor to ensure markers appear at an appropriate size regardless
  /// of the chart's zoom level.
  final double zoom;

  /// The difference in milliseconds between consecutive data points.
  ///
  /// This value represents the time interval between adjacent data points on the chart.
  /// For example, a granularity of 60000 means data points are spaced one minute apart.
  /// This affects how densely packed visual elements appear on the chart.
  ///
  /// Common granularity values include:
  /// - 1000: 1 second between points
  /// - 60000: 1 minute between points
  /// - 3600000: 1 hour between points
  /// - 86400000: 1 day between points
  final int granularity;

  /// The number of milliseconds represented by one pixel on the x-axis.
  ///
  /// This value determines the horizontal scale of the chart - how many milliseconds
  /// of time are represented by each pixel of horizontal space. Lower values result
  /// in a more "zoomed in" view (more pixels per time unit), while higher values
  /// result in a more "zoomed out" view (fewer pixels per time unit).
  ///
  /// Specifies the zoom level of the chart.
  final double msPerPx;

  @override
  String toString() {
    return 'PainterProps{zoom: $zoom, granularity: $granularity, msPerPx: $msPerPx}';
  }
}
