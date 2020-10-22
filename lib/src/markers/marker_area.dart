import 'package:deriv_chart/src/markers/marker_series.dart';
import 'package:deriv_chart/src/gestures/gesture_manager.dart';
import 'package:deriv_chart/src/x_axis/x_axis_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'active_marker.dart';
import 'active_marker_painter.dart';
import 'marker.dart';

/// Duration of active marker transition.
const Duration animationDuration = Duration(seconds: 1);

/// Layer with markers.
class MarkerArea extends StatefulWidget {
  /// Initializes marker area.
  const MarkerArea({
    @required this.markerSeries,
    // TODO(Rustem): remove when yAxisModel is provided
    @required this.quoteToCanvasY,
    Key key,
  }) : super(key: key);

  final MarkerSeries markerSeries;
  final double Function(double) quoteToCanvasY;

  @override
  _MarkerAreaState createState() => _MarkerAreaState();
}

class _MarkerAreaState extends State<MarkerArea>
    with SingleTickerProviderStateMixin {
  ActiveMarker _prevActiveMarker;
  AnimationController _activeMarkerController;
  Animation<double> _activeMarkerAnimation;

  GestureManagerState get gestureManager => context.read<GestureManagerState>();
  XAxisModel get xAxis => context.read<XAxisModel>();

  @override
  void initState() {
    super.initState();
    gestureManager.registerCallback(_onTap);

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
  void didUpdateWidget(MarkerArea oldWidget) {
    super.didUpdateWidget(oldWidget);
    final ActiveMarker activeMarker = widget.markerSeries.activeMarker;
    final ActiveMarker prevActiveMarker = oldWidget.markerSeries.activeMarker;
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
    gestureManager.removeCallback(_onTap);

    _activeMarkerController.dispose();
    super.dispose();
  }

  void _onTap(TapUpDetails details) {
    final MarkerSeries series = widget.markerSeries;

    if (series.activeMarker != null) {
      if (series.activeMarker.tapArea.contains(details.localPosition)) {
        series.activeMarker.onTap?.call();
        return;
      }
    }

    for (final Marker marker in series.visibleEntries.reversed) {
      if (marker.tapArea.contains(details.localPosition)) {
        marker.onTap?.call();
        return;
      }
    }

    if (series.activeMarker != null) {
      series.activeMarker.onTapOutside?.call();
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
            ),
          ),
        ),
        CustomPaint(
          painter: ActiveMarkerPainter(
            activeMarker: widget.markerSeries.activeMarker ?? _prevActiveMarker,
            style: widget.markerSeries.style,
            epochToX: xAxis.xFromEpoch,
            quoteToY: widget.quoteToCanvasY,
            animationProgress: _activeMarkerAnimation.value,
          ),
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
  });

  final MarkerSeries series;
  final Function epochToX;
  final Function quoteToY;

  @override
  void paint(Canvas canvas, Size size) {
    series.paint(canvas, size, epochToX, quoteToY, null, null, null);
  }

  @override
  bool shouldRepaint(_MarkerPainter oldDelegate) => true;

  @override
  bool shouldRebuildSemantics(_MarkerPainter oldDelegate) => false;
}
