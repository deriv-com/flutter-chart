import 'package:deriv_chart/src/gestures/gesture_manager.dart';
import 'package:deriv_chart/src/logic/chart_series/data_series.dart';
import 'package:deriv_chart/src/logic/find.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:deriv_chart/src/x_axis/x_axis_model.dart';
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
    @required this.pipSize,
    this.onCrosshairAppeared,
    this.onCrosshairDisappeared,
  }) : super(key: key);

  final DataSeries mainSeries;
  final int pipSize;
  final double Function(double) quoteToCanvasY;
  final VoidCallback onCrosshairAppeared;
  final VoidCallback onCrosshairDisappeared;

  @override
  _CrosshairAreaState createState() => _CrosshairAreaState();
}

class _CrosshairAreaState extends State<CrosshairArea> {
  Tick crosshairTick;

  GestureManagerState gestureManager;

  XAxisModel get xAxis => context.read<XAxisModel>();

  @override
  void initState() {
    super.initState();
    gestureManager = context.read<GestureManagerState>()
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
    if (crosshairTick == null ||
        widget.mainSeries.visibleEntries == null ||
        widget.mainSeries.visibleEntries.isEmpty) return;

    final lastTick = widget.mainSeries.visibleEntries.last;
    if (crosshairTick.epoch == lastTick.epoch) {
      crosshairTick = lastTick;
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
      crosshairTick = _getClosestTick(details.localPosition.dx);
    });
  }

  void _onLongPressUpdate(LongPressMoveUpdateDetails details) {
    setState(() {
      crosshairTick = _getClosestTick(details.localPosition.dx);
    });
  }

  Tick _getClosestTick(double canvasX) {
    final epoch = xAxis.epochFromX(canvasX);
    return findClosestToEpoch(epoch, widget.mainSeries.visibleEntries);
  }

  void _onLongPressEnd(LongPressEndDetails details) {
    // TODO(Rustem): ask yAxisModel to zoom in
    widget.onCrosshairDisappeared?.call();

    xAxis.enableAutoPan();

    setState(() {
      crosshairTick = null;
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
              mainSeries: widget.mainSeries,
              crosshairTick: crosshairTick,
              epochToCanvasX: xAxis.xFromEpoch,
              quoteToCanvasY: widget.quoteToCanvasY,
            ),
          ),
          if (crosshairTick != null)
            Positioned(
              top: 0,
              bottom: 0,
              width: constraints.maxWidth,
              left: xAxis.xFromEpoch(crosshairTick.epoch) -
                  constraints.maxWidth / 2,
              child: Container(
                alignment: Alignment.topCenter,
                child: CrosshairDetails(
                  mainSeries: widget.mainSeries,
                  crosshairTick: crosshairTick,
                  pipSize: widget.pipSize,
                ),
              ),
            )
        ],
      );
    });
  }
}
