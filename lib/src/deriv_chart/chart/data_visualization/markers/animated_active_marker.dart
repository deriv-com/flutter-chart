import 'package:deriv_chart/src/deriv_chart/chart/x_axis/x_axis_model.dart';
import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:deriv_chart/src/theme/painting_styles/marker_style.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'active_marker.dart';
import 'active_marker_painter.dart';
import 'marker_series.dart';

/// Duration of active marker transition.
const Duration animationDuration = Duration(milliseconds: 250);

/// Paints animated active marker on top of the chart.
class AnimatedActiveMarker extends StatefulWidget {
  /// Initializes active marker.
  const AnimatedActiveMarker({
    required this.markerSeries,
    required this.quoteToCanvasY,
    Key? key,
  }) : super(key: key);

  /// The Series that holds the list markers.
  final MarkerSeries markerSeries;

  /// Conversion function for converting quote to chart's canvas' Y position.
  final double Function(double) quoteToCanvasY;

  @override
  _AnimatedActiveMarkerState createState() => _AnimatedActiveMarkerState();
}

class _AnimatedActiveMarkerState extends State<AnimatedActiveMarker>
    with SingleTickerProviderStateMixin {
  ActiveMarker? _prevActiveMarker;
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
  void didUpdateWidget(AnimatedActiveMarker oldWidget) {
    super.didUpdateWidget(oldWidget);
    final ActiveMarker? activeMarker = widget.markerSeries.activeMarker;
    final ActiveMarker? prevActiveMarker = oldWidget.markerSeries.activeMarker;
    final bool activeMarkerChanged = activeMarker != prevActiveMarker;

    if (activeMarkerChanged) {
      if (activeMarker == null) {
        _prevActiveMarker = prevActiveMarker;
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
    if ((widget.markerSeries.activeMarker ?? _prevActiveMarker) == null) {
      return const SizedBox.shrink();
    }

    final XAxisModel xAxis = context.watch<XAxisModel>();

    return AnimatedBuilder(
      animation: _activeMarkerAnimation,
      builder: (BuildContext context, _) => CustomPaint(
        painter: ActiveMarkerPainter(
          activeMarker: widget.markerSeries.activeMarker ?? _prevActiveMarker!,
          style: widget.markerSeries.style as MarkerStyle? ??
              context.watch<ChartTheme>().markerStyle,
          epochToX: xAxis.xFromEpochSnapped,
          quoteToY: widget.quoteToCanvasY,
          animationProgress: _activeMarkerAnimation.value,
          markerIconPainter: widget.markerSeries.markerIconPainter,
        ),
      ),
    );
  }
}
