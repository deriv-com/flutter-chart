import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'gestures/gesture_manager.dart';
import 'x_axis_model.dart';

class XAxis extends StatefulWidget {
  XAxis({Key key, @required this.child})
      : assert(child != null),
        super(key: key);

  final Widget child;

  @override
  _XAxisState createState() => _XAxisState();
}

class _XAxisState extends State<XAxis> {
  XAxisModel model;

  GestureManagerState get gestureManager => context.read<GestureManagerState>();

  @override
  void initState() {
    super.initState();
    model = XAxisModel();
    gestureManager
      ..registerCallback(model.onScaleStart)
      ..registerCallback(model.onScaleUpdate);
  }

  @override
  void dispose() {
    gestureManager
      ..removeCallback(model.onScaleStart)
      ..registerCallback(model.onScaleUpdate);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: model,
      child: widget.child,
    );
  }
}
