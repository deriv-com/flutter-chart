import 'package:deriv_chart/src/gestures/gesture_manager.dart';
import 'package:deriv_chart/src/logic/chart_series/base_series.dart';
import 'package:deriv_chart/src/logic/find.dart';
import 'package:deriv_chart/src/models/candle.dart';
import 'package:deriv_chart/src/x_axis/x_axis_model.dart';
import 'package:deriv_chart/src/theme/painting_styles/chart_paiting_style.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'crosshair_details.dart';
import 'crosshair_painter.dart';

/// Place this area on top of the chart to display candle/point details on longpress.
class CrosshairArea extends StatefulWidget {
  CrosshairArea({
    Key key,
    @required this.mainSeries,
    // TODO(Rustem): remove when yAxisModel is provided
    @required this.quoteToCanvasY,
    // TODO(Rustem): remove when chart params are provided
    @required this.style,
    @required this.pipSize,
    this.onCrosshairAppeared,
    this.onCrosshairDisappeared,
  }) : super(key: key);

  final BaseSeries mainSeries;
  final ChartPaintingStyle style;
  final int pipSize;
  final double Function(double) quoteToCanvasY;
  final VoidCallback onCrosshairAppeared;
  final VoidCallback onCrosshairDisappeared;

  @override
  _CrosshairAreaState createState() => _CrosshairAreaState();
}

class _CrosshairAreaState extends State<CrosshairArea> {
  Candle crosshairCandle;

  GestureManagerState get gestureManager => context.read<GestureManagerState>();
  XAxisModel get xAxis => context.read<XAxisModel>();

  @override
  void initState() {
    super.initState();
    gestureManager
      ..registerCallback(_onLongPressStart)
      ..registerCallback(_onLongPressUpdate)
      ..registerCallback(_onLongPressEnd);
  }

  @override
  void didUpdateWidget(CrosshairArea oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateCrosshairCandle();
  }

  void _updateCrosshairCandle() {
    if (crosshairCandle == null ||
        widget.mainSeries.visibleEntries == null ||
        widget.mainSeries.visibleEntries.isEmpty) return;

    final lastCandle = widget.mainSeries.visibleEntries.last;
    if (crosshairCandle.epoch == lastCandle.epoch) {
      crosshairCandle = lastCandle;
    }
  }

  @override
  void dispose() {
    gestureManager
      ..removeCallback(_onLongPressStart)
      ..removeCallback(_onLongPressUpdate)
      ..removeCallback(_onLongPressEnd);
    super.dispose();
  }

  void _onLongPressStart(LongPressStartDetails details) {
    // TODO(Rustem): ask yAxisModel to zoom out
    // TODO(Rustem): call callback that was passed to chart
    widget.onCrosshairAppeared?.call();

    // Stop auto-panning to make it easier to select candle or tick.
    xAxis.disableAutoPan();

    setState(() {
      crosshairCandle = _getClosestCandle(details.localPosition.dx);
    });
  }

  void _onLongPressUpdate(LongPressMoveUpdateDetails details) {
    setState(() {
      crosshairCandle = _getClosestCandle(details.localPosition.dx);
    });
  }

  Candle _getClosestCandle(double canvasX) {
    final epoch = xAxis.epochFromX(canvasX);
    return findClosestToEpoch(epoch, widget.mainSeries.visibleEntries);
  }

  void _onLongPressEnd(LongPressEndDetails details) {
    // TODO(Rustem): ask yAxisModel to zoom in
    widget.onCrosshairDisappeared?.call();

    xAxis.enableAutoPan();

    setState(() {
      crosshairCandle = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Stack(
        fit: StackFit.expand,
        children: <Widget>[
          CustomPaint(
            size: Size.infinite,
            painter: CrosshairPainter(
              crosshairCandle: crosshairCandle,
              style: widget.style,
              epochToCanvasX: xAxis.xFromEpoch,
              quoteToCanvasY: widget.quoteToCanvasY,
            ),
          ),
          if (crosshairCandle != null)
            Positioned(
              top: 0,
              bottom: 0,
              width: constraints.maxWidth,
              left: xAxis.xFromEpoch(crosshairCandle.epoch) -
                  constraints.maxWidth / 2,
              child: Center(
                child: CrosshairDetails(
                  style: widget.style,
                  crosshairCandle: crosshairCandle,
                  pipSize: widget.pipSize,
                ),
              ),
            )
        ],
      );
    });
  }
}
