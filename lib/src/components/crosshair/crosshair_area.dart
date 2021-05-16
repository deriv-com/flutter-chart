import 'package:deriv_chart/src/components/data_visualization/chart_series/data_series.dart';
import 'package:deriv_chart/src/gestures/gesture_manager.dart';
import 'package:deriv_chart/src/logic/find.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:deriv_chart/src/x_axis/x_axis_model.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'crosshair_details.dart';
import 'crosshair_dot_painter.dart';
import 'crosshair_line_painter.dart';

/// Place this area on top of the chart to display candle/point details on longpress.
class CrosshairArea extends StatefulWidget {
  /// Initializes a  widget to display candle/point details on longpress in a chart.
  const CrosshairArea({
    @required this.mainSeries,
    @required this.quoteToCanvasY,
    @required this.pipSize,
    Key key,
    this.onCrosshairAppeared,
    this.onCrosshairDisappeared,
  }) : super(key: key);

  /// The main series of the chart.
  final DataSeries<Tick> mainSeries;

  /// Number of decimal digits when showing prices.
  final int pipSize;

  /// Conversion function for converting quote to chart's canvas' Y position.
  final double Function(double) quoteToCanvasY;

  /// Called on longpress to show candle/point details.
  final VoidCallback onCrosshairAppeared;

  /// Called when candle or point is dismissed.
  final VoidCallback onCrosshairDisappeared;

  @override
  _CrosshairAreaState createState() => _CrosshairAreaState();
}

class _CrosshairAreaState extends State<CrosshairArea> {
  Tick crosshairTick;

  double _lastLongPressPosition;
  int _lastLongPressPositionEpoch = -1;

  final double _panSpeed = 0.08;
  static const double _closeDistance = 60;

  GestureManagerState gestureManager;

  XAxisModel get xAxis => context.read<XAxisModel>();
  DateTime _timer;
  final VelocityTracker _dragVelocityTracker =
      VelocityTracker.withKind(PointerDeviceKind.touch);
  VelocityEstimate _dragVelocity = const VelocityEstimate(
      confidence: 1,
      pixelsPerSecond: Offset.zero,
      duration: Duration.zero,
      offset: Offset.zero);

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
        widget.mainSeries.visibleEntries.isEmpty) {
      return;
    }

    final Tick lastTick = widget.mainSeries.visibleEntries.last;
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
    widget.onCrosshairAppeared?.call();

    // Stop auto-panning to make it easier to select candle or tick.
    xAxis.disableAutoPan();
    _lastLongPressPosition = details.localPosition.dx;
    _updatePanSpeed();
    _timer = DateTime.now();
  }

  void _onLongPressUpdate(LongPressMoveUpdateDetails details) {
    _lastLongPressPosition = details.localPosition.dx;
    setState(() => _updatePanSpeed());

    final DateTime now = DateTime.now();
    final Duration passedTime = now.difference(_timer);
    _timer = DateTime.now();
    _dragVelocityTracker.addPosition(passedTime, details.localPosition);
    _dragVelocity = _dragVelocityTracker.getVelocityEstimate();
  }

  void _updatePanSpeed() {
    if (_lastLongPressPosition == null) {
      return;
    }

    if (_lastLongPressPosition < _closeDistance) {
      xAxis.pan(-_panSpeed);
    } else if (xAxis.width - _lastLongPressPosition < _closeDistance) {
      xAxis.pan(_panSpeed);
    } else {
      xAxis.pan(0);
    }
  }

  Tick _getClosestTick() => findClosestToEpoch(
      _lastLongPressPositionEpoch, widget.mainSeries.visibleEntries.entries);

  Duration get animationDuration {
    double dragXVelocity;

    dragXVelocity = _dragVelocity.pixelsPerSecond.dx.abs().roundToDouble();

    if (dragXVelocity == 0) {
      return const Duration(milliseconds: 5);
    }

    if (dragXVelocity > 3000) {
      return const Duration(milliseconds: 5);
    }

    if (dragXVelocity < 500) {
      return const Duration(milliseconds: 80);
    }

    final double durationInRange = (dragXVelocity - 500) / (2500) * 75 + 5;
    return Duration(milliseconds: durationInRange.toInt());
  }

  void _onLongPressEnd(LongPressEndDetails details) {
    widget.onCrosshairDisappeared?.call();

    xAxis
      ..pan(0)
      ..enableAutoPan();

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
      }
      crosshairTick = _getClosestTick();
    }
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      if (crosshairTick != null) {
        return Stack(
          children: <Widget>[
            AnimatedPositioned(
              duration: animationDuration,
              left: xAxis.xFromEpoch(crosshairTick.epoch),
              child: CustomPaint(
                size: Size(1, constraints.maxHeight),
                painter: const CrosshairLinePainter(),
              ),
            ),
            AnimatedPositioned(
              top: widget.quoteToCanvasY(crosshairTick.quote),
              left: xAxis.xFromEpoch(crosshairTick.epoch),
              duration: animationDuration,
              child: CustomPaint(
                size: Size(1, constraints.maxHeight),
                painter: const CrosshairDotPainter(),
              ),
            ),
            AnimatedPositioned(
              duration: animationDuration,
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
            ),
          ],
        );
      } else {
        return const SizedBox.shrink();
      }
    });
  }
}
