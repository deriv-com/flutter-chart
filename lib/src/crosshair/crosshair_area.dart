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
    // TODO(Rustem): remove when xAxisModel is provided
    @required this.epochToCanvasX,
    @required this.canvasXToEpoch,
    // TODO(Rustem): remove when yAxisModel is provided
    @required this.quoteToCanvasY,
    // TODO(Rustem): remove when chart params are provided
    @required this.style,
    @required this.pipSize,
    this.onCrosshairAppeared,
    this.onCrosshairDisappeared,
  }) : super(key: key);

  final List<Candle> visibleCandles;
  final ChartStyle style;
  final int pipSize;
  final double Function(int) epochToCanvasX;
  final int Function(double) canvasXToEpoch;
  final double Function(double) quoteToCanvasY;
  final VoidCallback onCrosshairAppeared;
  final VoidCallback onCrosshairDisappeared;

  @override
  _CrosshairAreaState createState() => _CrosshairAreaState();
}

class _CrosshairAreaState extends State<CrosshairArea> {
  Candle crosshairCandle;

  GestureManagerState get gestureManager => context.read<GestureManagerState>();

  @override
  void initState() {
    super.initState();
    gestureManager
      ..registerCallback(_handleLongPressStart)
      ..registerCallback(_handleLongPressUpdate)
      ..registerCallback(_handleLongPressEnd);
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
    gestureManager
      ..removeCallback(_handleLongPressStart)
      ..removeCallback(_handleLongPressUpdate)
      ..removeCallback(_handleLongPressEnd);
    super.dispose();
  }

  void _handleLongPressStart(LongPressStartDetails details) {
    // TODO(Rustem): ask yAxisModel to zoom out
    // TODO(Rustem): call callback that was passed to chart
    widget.onCrosshairAppeared?.call();
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
    widget.onCrosshairDisappeared?.call();
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
