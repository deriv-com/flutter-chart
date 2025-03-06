import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/markers/marker_icon_painters/painter_props.dart';
import 'package:deriv_chart/src/deriv_chart/chart/helpers/functions/convert_range.dart';

/// Model that holds chart scaling information.
class ChartScaleModel {
  /// Creates a new chart scale model.
  const ChartScaleModel({
    required this.granularity,
    this.msPerPx,
  });

  /// Milliseconds per pixel - the primary scale value of the chart.
  /// Determines how many milliseconds are represented by one pixel on the x-axis.
  final double? msPerPx;

  /// Difference in milliseconds between two consecutive candles/points.
  final int granularity;

  /// Calculates the zoom factor based on msPerPx and granularity.
  /// This is used to scale visual elements appropriately.
  double get zoom => msPerPx == null
      ? 1
      : convertRange(msPerPx! / granularity, 0, 1, 0.8, 1.2);

  /// Creates a PainterProps instance from this model.
  PainterProps toPainterProps() => PainterProps(
        zoom: zoom,
        granularity: granularity,
        msPerPx: msPerPx,
      );

  /// Creates a copy of this model with the specified fields replaced.
  ChartScaleModel copyWith({
    double? msPerPx,
    int? granularity,
  }) {
    return ChartScaleModel(
      msPerPx: msPerPx ?? this.msPerPx,
      granularity: granularity ?? this.granularity,
    );
  }
}
