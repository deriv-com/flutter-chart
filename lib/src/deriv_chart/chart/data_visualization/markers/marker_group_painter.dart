import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_data.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/series_painter.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/markers/marker_group.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/markers/marker_group_series.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/markers/marker_icon_painters/marker_group_icon_painter.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/models/animation_info.dart';
import 'package:flutter/material.dart';

/// A specialized painter class responsible for rendering marker groups on a financial chart.
///
/// `MarkerGroupPainter` extends the generic `SeriesPainter` class, specifically for painting
/// `MarkerGroupSeries` data. It acts as a coordinator between the chart's rendering system
/// and the specialized icon painters that know how to render specific types of marker groups.
///
/// This class is part of the chart's visualization pipeline:
/// 1. `MarkerGroupSeries` contains the data to be visualized (marker groups)
/// 2. `MarkerGroupPainter` (this class) is created by the series to handle rendering
/// 3. The painter delegates the actual drawing to a specialized `MarkerGroupIconPainter`
///
/// The painter uses the chart's coordinate conversion functions (`EpochToX` and `QuoteToY`)
/// to map market data points (epoch timestamps and price quotes) to pixel coordinates on
/// the canvas. It also uses the `ChartScaleModel` to obtain rendering properties that
/// affect how markers are displayed at different zoom levels.
class MarkerGroupPainter extends SeriesPainter<MarkerGroupSeries> {
  /// Creates a new `MarkerGroupPainter` instance.
  ///
  /// This constructor initializes the painter with the series it will visualize and
  /// the specialized icon painter that will handle the actual drawing of marker groups.
  ///
  /// @param series The `MarkerGroupSeries` containing the marker groups to be painted.
  /// @param markerGroupIconPainter The specialized painter that knows how to render
  ///        specific types of marker groups (e.g., tick markers, digit markers, etc.).
  MarkerGroupPainter(MarkerGroupSeries series, this.markerGroupIconPainter)
      : super(series);

  /// The specialized painter responsible for rendering specific types of marker groups.
  ///
  /// Different types of marker groups (e.g., "tick", "digit", "accumulator") require
  /// different rendering logic. This field holds a reference to a specialized painter
  /// that knows how to render the specific type of marker groups contained in the series.
  ///
  /// The actual implementation used depends on the type of marker groups being visualized.
  /// For example:
  /// - `TickMarkerIconPainter` for rendering tick-based marker groups
  /// - `DigitMarkerIconPainter` for rendering digit-based marker groups
  /// - `AccumulatorMarkerIconPainter` for rendering accumulator-based marker groups
  final MarkerGroupIconPainter markerGroupIconPainter;

  /// Renders the marker groups on the provided canvas.
  ///
  /// This method is called by the chart's rendering system when the chart needs to be
  /// redrawn. It iterates through all visible marker groups in the series and delegates
  /// the actual drawing of each group to the specialized icon painter.
  ///
  /// The method uses the chart's coordinate conversion functions to map market data points
  /// (epoch timestamps and price quotes) to pixel coordinates on the canvas. It also uses
  /// the `ChartScaleModel` to obtain rendering properties that affect how markers are
  /// displayed at different zoom levels.
  ///
  /// @param canvas The canvas on which to paint.
  /// @param size The size of the drawing area.
  /// @param epochToX A function that converts epoch timestamps to X coordinates.
  /// @param quoteToY A function that converts price quotes to Y coordinates.
  /// @param animationInfo Information about any ongoing animations.
  /// @param chartScaleModel The model containing scaling information for the chart.
  @override
  void onPaint({
    required Canvas canvas,
    required Size size,
    required EpochToX epochToX,
    required QuoteToY quoteToY,
    required AnimationInfo animationInfo,
  }) {
    // Get PainterProps directly from the model
    final props = chartScaleModel.toPainterProps();

    for (final MarkerGroup markerGroup in series.visibleMarkerGroupList) {
      markerGroupIconPainter.paintMarkerGroup(
        canvas,
        size,
        theme,
        markerGroup,
        epochToX,
        quoteToY,
        props,
      );
    }
  }
}
