import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'gestures/gesture_manager.dart';
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

class _XAxisState extends State<XAxis> with SingleTickerProviderStateMixin {
  XAxisModel model;
  AnimationController _rightEpochAnimationController;

  GestureManagerState get gestureManager => context.read<GestureManagerState>();

  @override
  void initState() {
    super.initState();

    _rightEpochAnimationController = AnimationController.unbounded(
      vsync: this,
      value: model.rightBoundEpoch.toDouble(),
    );

    model = XAxisModel(
      nowEpoch: DateTime.now().millisecondsSinceEpoch,
      firstCandleEpoch: widget.firstCandleEpoch,
      granularity: widget.granularity,
      animationController: _rightEpochAnimationController,
    );

    gestureManager
      ..registerCallback(model.onScaleStart)
      ..registerCallback(model.onScaleUpdate)
      ..registerCallback(model.onPanUpdate);
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
    _rightEpochAnimationController?.dispose();

    gestureManager
      ..removeCallback(model.onScaleStart)
      ..removeCallback(model.onScaleUpdate)
      ..removeCallback(model.onPanUpdate);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<XAxisModel>.value(
      value: model,
      child: widget.child,
    );
  }
}
