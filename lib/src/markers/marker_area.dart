import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/markers/marker_series.dart';
import 'package:deriv_chart/src/gestures/gesture_manager.dart';
import 'package:deriv_chart/src/x_axis/x_axis_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'animated_active_marker.dart';
import 'marker.dart';

/// Layer with markers.
class MarkerArea extends StatefulWidget {
  /// Initializes marker area.
  const MarkerArea({
    @required this.markerSeries,
    // TODO(Rustem): remove when yAxisModel is provided
    @required this.quoteToCanvasY,
    Key key,
  })  : assert(markerSeries != null),
        super(key: key);

  /// The marker serries that contain the active marker.
  final MarkerSeries markerSeries;

  /// Conversion function for converting quote to chart's canvas' Y position.
  final double Function(double) quoteToCanvasY;

  @override
  _MarkerAreaState createState() => _MarkerAreaState();
}

class _MarkerAreaState extends State<MarkerArea> {
  GestureManagerState gestureManager;

  XAxisModel get xAxis => context.read<XAxisModel>();

  @override
  void initState() {
    super.initState();
    gestureManager = context.read<GestureManagerState>()
      ..registerCallback(_onTap);
  }

  @override
  void dispose() {
    gestureManager.removeCallback(_onTap);
    super.dispose();
  }

  void _onTap(TapUpDetails details) {
    final MarkerSeries series = widget.markerSeries;

    if (series.activeMarker != null) {
      if (series.activeMarker.tapArea.contains(details.localPosition)) {
        series.activeMarker.onTap?.call();
      } else {
        series.activeMarker.onTapOutside?.call();
      }
      return;
    }

    for (final Marker marker in series.visibleEntries.reversed) {
      if (marker.tapArea.contains(details.localPosition)) {
        marker.onTap?.call();
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final XAxisModel xAxis = context.watch<XAxisModel>();

    widget.markerSeries.update(xAxis.leftBoundEpoch, xAxis.rightBoundEpoch);

    return Stack(
      children: <Widget>[
        AnimatedOpacity(
          duration: animationDuration,
          opacity: widget.markerSeries.activeMarker != null ? 0.5 : 1,
          child: CustomPaint(
            painter: _MarkerPainter(
                series: widget.markerSeries,
                epochToX: xAxis.xFromEpoch,
                quoteToY: widget.quoteToCanvasY,
                theme: context.watch<ChartTheme>()),
          ),
        ),
        AnimatedActiveMarker(
          markerSeries: widget.markerSeries,
          quoteToCanvasY: widget.quoteToCanvasY,
        ),
      ],
    );
  }
}

class _MarkerPainter extends CustomPainter {
  _MarkerPainter({
    this.series,
    this.epochToX,
    this.quoteToY,
    this.theme,
  });

  final MarkerSeries series;
  final Function epochToX;
  final Function quoteToY;
  final ChartTheme theme;

  @override
  void paint(Canvas canvas, Size size) {
    series.paint(canvas, size, epochToX, quoteToY, null, null, theme);
  }

  @override
  bool shouldRepaint(_MarkerPainter oldDelegate) => true;

  @override
  bool shouldRebuildSemantics(_MarkerPainter oldDelegate) => false;
}
