import 'package:deriv_chart/src/models/candle.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';

import '../gestures/gesture_manager.dart';
import '../theme/chart_theme.dart';
import 'grid/calc_time_grid.dart';
import 'grid/x_grid_painter.dart';
import 'x_axis_model.dart';

/// X-axis widget.
///
/// Draws x-axis grid and manages [XAxisModel].
/// Exposes the model to all descendants.
class XAxis extends StatefulWidget {
  /// Creates x-axis the size of child.
  const XAxis({
    @required this.candles,
    @required this.child,
    @required this.granularity,
    @required this.isLive,
    Key key,
  })  : assert(child != null),
        super(key: key);

  /// The widget below this widget in the tree.
  final Widget child;

  /// A reference to chart's main candles.
  final List<Candle> candles;

  /// Millisecond difference between two consecutive candles.
  final int granularity;

  /// `True` the chart showing live data
  final bool isLive;

  @override
  _XAxisState createState() => _XAxisState();
}

class _XAxisState extends State<XAxis> with TickerProviderStateMixin {
  XAxisModel _model;
  Ticker _ticker;
  AnimationController _rightEpochAnimationController;

  GestureManagerState get gestureManager => context.read<GestureManagerState>();

  @override
  void initState() {
    super.initState();

    _rightEpochAnimationController = AnimationController.unbounded(vsync: this);

    _model = XAxisModel(
      candles: widget.candles,
      granularity: widget.granularity,
      animationController: _rightEpochAnimationController,
      isLive: widget.isLive,
    );

    _ticker = createTicker(_model.onNewFrame)..start();

    gestureManager
      ..registerCallback(_model.onScaleAndPanStart)
      ..registerCallback(_model.onScaleUpdate)
      ..registerCallback(_model.onPanUpdate)
      ..registerCallback(_model.onScaleAndPanEnd);
  }

  @override
  void didUpdateWidget(XAxis oldWidget) {
    super.didUpdateWidget(oldWidget);
    _model
      ..updateCandles(widget.candles)
      ..updateGranularity(widget.granularity)
      ..updateIsLive(widget.isLive);
  }

  @override
  void dispose() {
    _ticker?.dispose();
    _rightEpochAnimationController?.dispose();

    gestureManager
      ..removeCallback(_model.onScaleAndPanStart)
      ..removeCallback(_model.onScaleUpdate)
      ..removeCallback(_model.onPanUpdate)
      ..removeCallback(_model.onScaleAndPanEnd);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<XAxisModel>.value(
      value: _model,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          context.watch<XAxisModel>().width = constraints.maxWidth;

          return CustomPaint(
            painter: XGridPainter(
              gridTimestamps: gridTimestamps(
                timeGridInterval: timeGridInterval(_model.pxFromMs),
                leftBoundEpoch: _model.leftBoundEpoch,
                rightBoundEpoch: _model.rightBoundEpoch,
              ),
              epochToCanvasX: _model.xFromEpoch,
              style: context.watch<ChartTheme>().gridStyle,
            ),
            child: widget.child,
          );
        },
      ),
    );
  }
}
