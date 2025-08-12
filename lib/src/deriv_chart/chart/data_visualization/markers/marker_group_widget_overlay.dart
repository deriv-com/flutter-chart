import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:deriv_chart/src/deriv_chart/chart/x_axis/x_axis_model.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/markers/marker_series.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/markers/marker_group_series.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/markers/marker_group.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/markers/chart_marker.dart';
import 'package:deriv_chart/src/widgets/profit_and_loss_label.dart';

/// Widget overlay that positions profit and loss labels over marker groups.
///
/// This overlay detects marker groups with ended contracts (those containing
/// profitAndLossLabel markers) and positions ProfitAndLossLabel widgets
/// at the appropriate chart coordinates.
///
/// The ProfitAndLossLabel widgets are positioned using screen coordinates calculated
/// from the marker's epoch (x-position) and quote (y-position).
class MarkerGroupWidgetOverlay extends StatelessWidget {
  /// Creates a marker group widget overlay.
  const MarkerGroupWidgetOverlay({
    required this.markerSeries,
    required this.quoteToCanvasY,
    super.key,
  });

  /// The marker series containing marker groups.
  final MarkerSeries markerSeries;

  /// Function to convert quote (price) to canvas Y coordinate.
  final double Function(double) quoteToCanvasY;

  @override
  Widget build(BuildContext context) {
    final XAxisModel xAxis = context.watch<XAxisModel>();

    // If this is not a grouped series, there is nothing to render.
    if (markerSeries is! MarkerGroupSeries) {
      return const SizedBox.shrink();
    }

    final MarkerGroupSeries groupSeries = markerSeries as MarkerGroupSeries;

    final List<Widget> positionedLabels = <Widget>[];

    // Iterate over all visible marker groups and find the first profit and loss label marker.
    for (final MarkerGroup group in groupSeries.visibleMarkerGroupList) {
      ChartMarker? profitLossMarker;
      for (final ChartMarker marker in group.markers) {
        if (marker.markerType == MarkerType.profitAndLossLabel) {
          profitLossMarker = marker;
          break;
        }
      }

      if (profitLossMarker == null) {
        continue;
      }

      final double x = xAxis.xFromEpoch(profitLossMarker.epoch);
      final double y = quoteToCanvasY(profitLossMarker.quote);

      positionedLabels.add(
        Positioned(
          left: x,
          top: y,
          child: FractionalTranslation(
            translation: const Offset(-0.5, -0.5),
            child: ProfitAndLossLabel(
              text: group.profitAndLossText ?? '',
              isProfit: group.isProfit,
            ),
          ),
        ),
      );
    }

    return Stack(children: positionedLabels);
  }
}
