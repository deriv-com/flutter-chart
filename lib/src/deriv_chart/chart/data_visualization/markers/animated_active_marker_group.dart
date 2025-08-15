import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/markers/chart_marker.dart';
import 'package:deriv_chart/src/deriv_chart/chart/x_axis/x_axis_model.dart';
import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:deriv_chart/src/theme/painting_styles/marker_style.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'active_marker_group.dart';
import 'active_marker_group_painter.dart';
import 'animated_active_marker.dart';
import 'marker_group_series.dart';

/// Paints animated active marker for marker groups on top of the chart.
class AnimatedActiveMarkerGroup extends StatefulWidget {
  /// Initializes animated active marker for grouped markers.
  const AnimatedActiveMarkerGroup({
    required this.markerSeries,
    required this.quoteToCanvasY,
    Key? key,
  }) : super(key: key);

  /// The Series that holds groups of markers.
  final MarkerGroupSeries markerSeries;

  /// Conversion function for converting quote to chart's canvas' Y position.
  final double Function(double) quoteToCanvasY;

  @override
  State<AnimatedActiveMarkerGroup> createState() =>
      _AnimatedActiveMarkerGroupState();
}

class _AnimatedActiveMarkerGroupState extends State<AnimatedActiveMarkerGroup>
    with SingleTickerProviderStateMixin {
  ActiveMarkerGroup? _prevActiveMarkerGroup;
  late AnimationController _activeMarkerController;
  late Animation<double> _activeMarkerAnimation;

  @override
  void initState() {
    super.initState();
    _activeMarkerController = AnimationController(
      vsync: this,
      duration: animationDuration,
    );
    _activeMarkerAnimation = CurvedAnimation(
      curve: Curves.easeInOut,
      parent: _activeMarkerController,
    );
  }

  @override
  void didUpdateWidget(AnimatedActiveMarkerGroup oldWidget) {
    super.didUpdateWidget(oldWidget);

    final ActiveMarkerGroup? activeMarkerGroup =
        widget.markerSeries.activeMarkerGroup;
    final ActiveMarkerGroup? prevActiveMarkerGroup =
        oldWidget.markerSeries.activeMarkerGroup;
    final bool activeMarkerChanged = activeMarkerGroup != prevActiveMarkerGroup;

    if (activeMarkerChanged) {
      if (activeMarkerGroup == null) {
        _prevActiveMarkerGroup = prevActiveMarkerGroup;
        _activeMarkerController.reverse();
      } else {
        _activeMarkerController.forward();
      }
    }
  }

  @override
  void dispose() {
    _activeMarkerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ActiveMarkerGroup? markerGroupToShow =
        widget.markerSeries.activeMarkerGroup ?? _prevActiveMarkerGroup;

    // check if the active marker group has a corresponding contractMarker in the base marker group
    final bool hasCorrespondingBaseMarkerGroup =
        widget.markerSeries.markerGroupList?.any((group) =>
                group.id == markerGroupToShow?.id &&
                group.markers.any((marker) =>
                    marker.markerType == MarkerType.contractMarker)) ??
            false;

    if (markerGroupToShow == null || !hasCorrespondingBaseMarkerGroup) {
      return const SizedBox.shrink();
    }

    final XAxisModel xAxis = context.watch<XAxisModel>();

    return AnimatedBuilder(
      animation: _activeMarkerAnimation,
      builder: (BuildContext context, _) => CustomPaint(
        painter: ActiveMarkerGroupPainter(
          activeMarkerGroup: markerGroupToShow,
          style: widget.markerSeries.style as MarkerStyle? ??
              context.watch<ChartTheme>().markerStyle,
          epochToX: xAxis.xFromEpoch,
          quoteToY: widget.quoteToCanvasY,
          animationProgress: _activeMarkerAnimation.value,
          markerGroupIconPainter: widget.markerSeries.markerGroupIconPainter,
        ),
      ),
    );
  }
}
