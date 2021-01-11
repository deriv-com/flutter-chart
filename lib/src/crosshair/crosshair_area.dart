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
  /// Initializes a  widget to display candle/point details on longpress in a chart.
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

  /// The main series of the chart.
  final DataSeries mainSeries;

  /// The size of the pip in the crosshair.
  final int pipSize;

  /// Conversion function for converting quote to chart's canvas' Y position.
  final double Function(double) quoteToCanvasY;

  /// Called on longpress to show candle/point details.
  final VoidCallback onCrosshairAppeared;

  /// Called when canlde or point is dismissed.
  final VoidCallback onCrosshairDisappeared;

  @override
  _CrosshairAreaState createState() => _CrosshairAreaState();
}

class _CrosshairAreaState extends State<CrosshairArea> {
  Tick crosshairTick;

  double _lastLongPressPosition;
  int _lastLongPressPositionEpoch = -1;

  double _panSpeed = 0.08;
  static const double _closeDistance = 60.00;

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
    _lastLongPressPosition = details.localPosition.dx;
    _updatePanSpeed();
  }

  void _onLongPressUpdate(LongPressMoveUpdateDetails details) {
    _lastLongPressPosition = details.localPosition.dx;
    _updatePanSpeed();
  }

  void _updatePanSpeed() {
    if (_lastLongPressPosition == null) return;

    if (_lastLongPressPosition < _closeDistance) {
      xAxis.pan(-_panSpeed);
    } else if (xAxis.width - _lastLongPressPosition < _closeDistance) {
      xAxis.pan(_panSpeed);
    } else {
      xAxis.pan(0);
    }
  }

  Tick _getClosestTick() {
    return findClosestToEpoch(
        _lastLongPressPositionEpoch, widget.mainSeries.visibleEntries);
  }

  void _onLongPressEnd(LongPressEndDetails details) {
    // TODO(Rustem): ask yAxisModel to zoom in
    widget.onCrosshairDisappeared?.call();

    xAxis.pan(0);
    xAxis.enableAutoPan();

    setState(() {
      crosshairTick = null;
      _lastLongPressPosition = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_lastLongPressPosition != null) {
      _lastLongPressPosition = _lastLongPressPosition.clamp(
          _closeDistance, context.watch<XAxisModel>().width - _closeDistance);
      final int newLongPressEpoch =
          context.watch<XAxisModel>().epochFromX(_lastLongPressPosition);
      if (newLongPressEpoch != _lastLongPressPositionEpoch) {
        // Only update closest tick if position epoch has changed.
        _lastLongPressPositionEpoch = newLongPressEpoch;
        crosshairTick = _getClosestTick();
      }
    }
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
              top: 8,
              bottom: 0,
              width: constraints.maxWidth,
              left: xAxis.xFromEpoch(crosshairTick.epoch) -
                  constraints.maxWidth / 2,
              child: Align(
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
