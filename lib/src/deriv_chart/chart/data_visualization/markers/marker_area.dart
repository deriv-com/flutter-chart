import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_data.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/markers/marker_series.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/models/animation_info.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/models/chart_scale_model.dart';
import 'package:deriv_chart/src/deriv_chart/chart/gestures/gesture_manager.dart';
import 'package:deriv_chart/src/deriv_chart/chart/x_axis/x_axis_model.dart';
import 'package:deriv_chart/src/models/chart_config.dart';
import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'animated_active_marker.dart';
import 'marker.dart';

/// Layer with markers.
class MarkerArea extends StatefulWidget {
  /// Initializes marker area.
  const MarkerArea({
    required this.markerSeries,
    required this.quoteToCanvasY,
    required this.animationInfo,
    Key? key,
  }) : super(key: key);

  /// The Series that holds the list markers.
  final MarkerSeries markerSeries;

  /// Conversion function for converting quote to chart's canvas' Y position.
  final double Function(double) quoteToCanvasY;

  /// Animation information for smooth transitions.
  final AnimationInfo animationInfo;

  @override
  _MarkerAreaState createState() => _MarkerAreaState();
}

class _MarkerAreaState extends State<MarkerArea> {
  late GestureManagerState gestureManager;

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
      if (series.activeMarker!.tapArea.contains(details.localPosition)) {
        series.activeMarker!.onTap?.call();
      } else {
        series.activeMarker!.onTapOutside?.call();
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
          child: RepaintBoundary(
            child: CustomPaint(
              child: Container(),
              painter: _MarkerPainter(
                series: widget.markerSeries,
                epochToX: xAxis.xFromEpoch,
                quoteToY: widget.quoteToCanvasY,
                theme: context.watch<ChartTheme>(),
                chartScaleModel: context.watch<ChartScaleModel>(),
                animationInfo: widget.animationInfo,
              ),
            ),
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
    required this.series,
    required this.epochToX,
    required this.quoteToY,
    required this.theme,
    required this.chartScaleModel,
    required this.animationInfo,
  });

  final MarkerSeries series;
  final EpochToX epochToX;
  final QuoteToY quoteToY;
  final ChartTheme theme;
  final ChartScaleModel chartScaleModel;
  final AnimationInfo animationInfo;

  @override
  void paint(Canvas canvas, Size size) {
    series.paint(
      canvas,
      size,
      epochToX,
      quoteToY,
      animationInfo,
      const ChartConfig(granularity: 1000),
      theme,
      chartScaleModel,
    );
  }

  @override
  bool shouldRepaint(_MarkerPainter oldDelegate) => true;

  @override
  bool shouldRebuildSemantics(_MarkerPainter oldDelegate) => false;
}
