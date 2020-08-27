import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';

import '../gestures/gesture_manager.dart';
import '../logic/time_grid.dart';
import '../painters/x_grid_painter.dart';
import 'x_axis_model.dart';

class XAxis extends StatefulWidget {
  XAxis({
    Key key,
    @required this.child,
    @required this.firstCandleEpoch,
    @required this.granularity,
  })  : assert(child != null),
        super(key: key);

  final Widget child;
  final int firstCandleEpoch;
  final int granularity;

  @override
  _XAxisState createState() => _XAxisState();
}

class _XAxisState extends State<XAxis> with TickerProviderStateMixin {
  XAxisModel model;
  Ticker ticker;
  AnimationController _rightEpochAnimationController;

  GestureManagerState get gestureManager => context.read<GestureManagerState>();

  @override
  void initState() {
    super.initState();

    _rightEpochAnimationController = AnimationController.unbounded(vsync: this);

    model = XAxisModel(
      firstCandleEpoch: widget.firstCandleEpoch,
      granularity: widget.granularity,
      animationController: _rightEpochAnimationController,
    );

    ticker = createTicker(model.onNewFrame)..start();

    gestureManager
      ..registerCallback(model.onScaleAndPanStart)
      ..registerCallback(model.onScaleUpdate)
      ..registerCallback(model.onPanUpdate)
      ..registerCallback(model.onScaleAndPanEnd);
  }

  @override
  void didUpdateWidget(XAxis oldWidget) {
    super.didUpdateWidget(oldWidget);
    model
      ..updateFirstCandleEpoch(widget.firstCandleEpoch)
      ..updateGranularity(widget.granularity);
  }

  @override
  void dispose() {
    ticker?.dispose();
    _rightEpochAnimationController?.dispose();

    gestureManager
      ..removeCallback(model.onScaleAndPanStart)
      ..removeCallback(model.onScaleUpdate)
      ..removeCallback(model.onPanUpdate)
      ..removeCallback(model.onScaleAndPanEnd);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<XAxisModel>.value(
      value: model,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          context.watch<XAxisModel>().width = constraints.maxWidth;

          return CustomPaint(
            painter: XGridPainter(
              gridTimestamps: gridTimestamps(
                timeGridInterval: timeGridInterval(model.msPerPx),
                leftBoundEpoch: model.leftBoundEpoch,
                rightBoundEpoch: model.rightBoundEpoch,
              ),
              epochToCanvasX: model.xFromEpoch,
            ),
            child: widget.child,
          );
        },
      ),
    );
  }
}
