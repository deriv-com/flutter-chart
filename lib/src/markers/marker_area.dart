import 'package:deriv_chart/src/markers/marker_series.dart';
import 'package:deriv_chart/src/gestures/gesture_manager.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:deriv_chart/src/x_axis/x_axis_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Layer with markers.
class MarkerArea extends StatefulWidget {
  MarkerArea({
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

class _MarkerAreaState extends State<MarkerArea> {
  Tick crosshairTick;

  GestureManagerState get gestureManager => context.read<GestureManagerState>();
  XAxisModel get xAxis => context.read<XAxisModel>();

  @override
  void initState() {
    super.initState();
    gestureManager.registerCallback(_onTap);
  }

  @override
  void dispose() {
    gestureManager.removeCallback(_onTap);
    super.dispose();
  }

  void _onTap(TapUpDetails details) {
    final MarkerSeries series = widget.markerSeries;

    for (int i = series.visibleEntries.length - 1; i >= 0; i--) {
      final Rect tapArea = series.tapAreas[i];
      if (tapArea.contains(details.localPosition)) {
        series.visibleEntries[i].onTap?.call();
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final XAxisModel xAxis = context.watch<XAxisModel>();

    widget.markerSeries.update(xAxis.leftBoundEpoch, xAxis.rightBoundEpoch);

    return CustomPaint(
      painter: _Painter(
        series: widget.markerSeries,
        epochToX: xAxis.xFromEpoch,
        quoteToY: widget.quoteToCanvasY,
      ),
    );
  }
}

class _Painter extends CustomPainter {
  _Painter({
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
  bool shouldRepaint(_Painter oldDelegate) => true;

  @override
  bool shouldRebuildSemantics(_Painter oldDelegate) => false;
}
