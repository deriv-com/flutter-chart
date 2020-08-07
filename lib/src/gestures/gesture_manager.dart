import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'custom_gesture_detector.dart';

class GestureManager extends StatefulWidget {
  GestureManager({Key key, @required this.child})
      : assert(child != null),
        super(key: key);

  final Widget child;

  @override
  GestureManagerState createState() => GestureManagerState();
}

class GestureManagerState extends State<GestureManager> {
  final callbackPool = <Function>{};

  void registerCallback(Function callback) {
    callbackPool.add(callback);
  }

  @override
  Widget build(BuildContext context) {
    return CustomGestureDetector(
      onScaleAndPanStart: (ScaleStartDetails details) => callbackPool
          .whereType<GestureScaleStartCallback>()
          .forEach((f) => f.call(details)),
      onPanUpdate: (DragUpdateDetails details) => callbackPool
          .whereType<GestureDragUpdateCallback>()
          .forEach((f) => f.call(details)),
      onScaleUpdate: (ScaleUpdateDetails details) => callbackPool
          .whereType<GestureScaleUpdateCallback>()
          .forEach((f) => f.call(details)),
      onScaleAndPanEnd: (ScaleEndDetails details) => callbackPool
          .whereType<GestureScaleEndCallback>()
          .forEach((f) => f.call(details)),
      onLongPressStart: (LongPressStartDetails details) => callbackPool
          .whereType<GestureLongPressStartCallback>()
          .forEach((f) => f.call(details)),
      onLongPressMoveUpdate: (LongPressMoveUpdateDetails details) =>
          callbackPool
              .whereType<GestureLongPressMoveUpdateCallback>()
              .forEach((f) => f.call(details)),
      onLongPressEnd: (LongPressEndDetails details) => callbackPool
          .whereType<GestureLongPressEndCallback>()
          .forEach((f) => f.call(details)),
      child: Provider.value(
        value: this,
        child: widget.child,
      ),
    );
  }
}
