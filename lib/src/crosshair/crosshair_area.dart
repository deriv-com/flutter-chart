import 'package:deriv_chart/src/gestures/gesture_manager.dart';
import 'package:deriv_chart/src/logic/find.dart';
import 'package:deriv_chart/src/models/candle.dart';
import 'package:deriv_chart/src/models/chart_style.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'crosshair_details.dart';
import 'crosshair_painter.dart';

class CrosshairArea extends StatefulWidget {
  CrosshairArea({
    Key key,
    @required this.visibleCandles,
    @required this.style,
    @required this.pipSize,
    // TODO(Rustem): remove when xAxisModel is provided
    @required this.epochToCanvasX,
    @required this.canvasXToEpoch,
    // TODO(Rustem): remove when yAxisModel is provided
    @required this.quoteToCanvasY,
  }) : super(key: key);

  final List<Candle> visibleCandles;
  final ChartStyle style;
  final int pipSize;
  final double Function(int) epochToCanvasX;
  final int Function(double) canvasXToEpoch;
  final double Function(double) quoteToCanvasY;

  @override
  _CrosshairAreaState createState() => _CrosshairAreaState();
}

class _CrosshairAreaState extends State<CrosshairArea> {
  Candle crosshairCandle;

  GestureManagerState get gestureManager => context.read<GestureManagerState>();

  @override
  void initState() {
    super.initState();
    gestureManager.registerCallback(_handleLongPressStart);
    gestureManager.registerCallback(_handleLongPressUpdate);
    gestureManager.registerCallback(_handleLongPressEnd);
  }

  @override
  void didUpdateWidget(CrosshairArea oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateCrosshairCandle();
  }

  void _updateCrosshairCandle() {
    if (crosshairCandle == null ||
        widget.visibleCandles == null ||
        widget.visibleCandles.isEmpty) return;

    final lastCandle = widget.visibleCandles.last;
    if (crosshairCandle.epoch == lastCandle.epoch) {
      crosshairCandle = lastCandle;
    }
  }

  @override
  void dispose() {
    gestureManager.removeCallback(_handleLongPressStart);
    gestureManager.removeCallback(_handleLongPressUpdate);
    gestureManager.removeCallback(_handleLongPressEnd);
    super.dispose();
  }

  void _handleLongPressStart(LongPressStartDetails details) {
    // TODO(Rustem): call this callback when provided
    // widget.onCrosshairAppeared?.call();
    // TODO(Rustem): ask yAxisModel to zoom out
    // _crosshairZoomOutAnimationController.forward();
    setState(() {
      crosshairCandle = _getClosestCandle(details.localPosition.dx);
    });
  }

  void _handleLongPressUpdate(LongPressMoveUpdateDetails details) {
    setState(() {
      crosshairCandle = _getClosestCandle(details.localPosition.dx);
    });
  }

  Candle _getClosestCandle(double canvasX) {
    final epoch = widget.canvasXToEpoch(canvasX);
    return findClosestToEpoch(epoch, widget.visibleCandles);
  }

  void _handleLongPressEnd(LongPressEndDetails details) {
    // TODO(Rustem): ask yAxisModel to zoom in
    // _crosshairZoomOutAnimationController.reverse();
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
              epochToCanvasX: widget.epochToCanvasX,
              quoteToCanvasY: widget.quoteToCanvasY,
            ),
          ),
          if (crosshairCandle != null)
            Positioned(
              top: 0,
              bottom: 0,
              width: constraints.maxWidth,
              left: widget.epochToCanvasX(crosshairCandle.epoch) -
                  constraints.maxWidth / 2,
              child: Align(
                alignment: Alignment.center,
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
