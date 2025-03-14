import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/markers/marker_icon_painters/painter_props.dart';
import 'package:deriv_chart/src/deriv_chart/chart/helpers/functions/convert_range.dart';

/// A model class that encapsulates chart scaling information.
///
/// `ChartScaleModel` holds essential scaling parameters that determine how chart
/// data is mapped to the visual space. It provides the foundation for consistent
/// scaling across different components of the chart visualization system.
///
/// This model is used by various chart components to ensure that visual elements
/// (such as candles, lines, markers, and annotations) are rendered at the appropriate
/// scale and position. It helps maintain visual consistency as the user zooms,
/// pans, or otherwise interacts with the chart.
///
/// The primary scaling parameters are:
/// - `msPerPx`: The horizontal scale (milliseconds per pixel)
/// - `granularity`: The time interval between consecutive data points
///
/// From these primary parameters, derived values like the zoom factor can be calculated,
/// which are used to scale visual elements appropriately.
class ChartScaleModel {
  /// Creates a new chart scale model with the specified scaling parameters.
  ///
  /// @param granularity The time interval (in milliseconds) between consecutive data points.
  ///        This is a required parameter as it's fundamental to the chart's time scale.
  /// @param msPerPx The number of milliseconds represented by one pixel on the x-axis.
  ///        This can be null in contexts where the horizontal scale is determined by
  ///        other means.
  const ChartScaleModel({
    required this.granularity,
    this.msPerPx,
  });

  /// The number of milliseconds represented by one pixel on the x-axis.
  ///
  /// This is the primary horizontal scale parameter of the chart. It determines
  /// how many milliseconds of time are represented by each pixel of horizontal space.
  /// Lower values result in a more "zoomed in" view (more pixels per time unit),
  /// while higher values result in a more "zoomed out" view (fewer pixels per time unit).
  ///
  /// For example:
  /// - A value of 60000 means each pixel represents 1 minute
  /// - A value of 3600000 means each pixel represents 1 hour
  ///
  /// This property may be null in certain contexts where the horizontal scale
  /// is determined by other means.
  final double? msPerPx;

  /// The time interval (in milliseconds) between consecutive data points.
  ///
  /// This value represents the time difference between adjacent data points on the chart.
  /// It affects how densely packed visual elements appear on the chart and is used
  /// in conjunction with `msPerPx` to calculate the zoom factor.
  ///
  /// Common granularity values include:
  /// - 1000: 1 second between points
  /// - 60000: 1 minute between points
  /// - 3600000: 1 hour between points
  /// - 86400000: 1 day between points
  final int granularity;

  /// Calculates the zoom factor based on the relationship between `msPerPx` and `granularity`.
  ///
  /// The zoom factor is a derived value that represents the relative scale of visual
  /// elements on the chart. It's calculated by taking the ratio of `msPerPx` to `granularity`
  /// and mapping it to a range that's appropriate for visual scaling (0.8 to 1.2).
  ///
  /// This value is used to scale visual elements (like markers, candles, and annotations)
  /// appropriately at different zoom levels. Higher zoom values make elements appear
  /// larger, while lower values make them smaller.
  ///
  /// If `msPerPx` is null, a default zoom factor of 1 is returned.
  double get zoom => msPerPx == null
      ? 1
      : convertRange(msPerPx! / granularity, 0, 1, 0.8, 1.2);

  /// Creates a `PainterProps` instance from this model's scaling parameters.
  ///
  /// This method provides a convenient way to convert the chart's scaling information
  /// into a format that can be used by various painter classes in the chart visualization
  /// system. It encapsulates the zoom factor, granularity, and msPerPx values into
  /// a single object that can be passed to painting methods.
  ///
  /// @return A `PainterProps` instance containing this model's scaling parameters.
  PainterProps toPainterProps() => PainterProps(
        zoom: zoom,
        granularity: granularity,
        msPerPx: msPerPx,
      );

  /// Creates a copy of this model with the specified fields replaced.
  ///
  /// This method provides a convenient way to create a new `ChartScaleModel` instance
  /// that's identical to this one, except for the fields specified in the parameters.
  /// It's useful for updating the chart's scale without having to recreate the entire
  /// model from scratch.
  ///
  /// @param msPerPx The new milliseconds per pixel value, or null to keep the current value.
  /// @param granularity The new granularity value, or null to keep the current value.
  /// @return A new `ChartScaleModel` instance with the specified fields replaced.
  ChartScaleModel copyWith({
    double? msPerPx,
    int? granularity,
  }) {
    return ChartScaleModel(
      msPerPx: msPerPx ?? this.msPerPx,
      granularity: granularity ?? this.granularity,
    );
  }

  @override
  String toString() {
    return 'ChartScaleModel(msPerPx: $msPerPx, granularity: $granularity)';
  }
}
