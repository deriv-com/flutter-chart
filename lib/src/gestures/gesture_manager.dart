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
  final _callbackPool = <Function>{};

  void registerCallback(Function callback) {
    _callbackPool.add(callback);
  }

  void removeCallback(Function callback) {
    _callbackPool.remove(callback);
  }

  void _callAll<T extends Function>(dynamic details) {
    _callbackPool.whereType<T>().forEach((f) => f.call(details));
  }

  @override
  Widget build(BuildContext context) {
    return CustomGestureDetector(
      onScaleAndPanStart: (d) => _callAll<GestureScaleStartCallback>(d),
      onPanUpdate: (d) => _callAll<GestureDragUpdateCallback>(d),
      onScaleUpdate: (d) => _callAll<GestureScaleUpdateCallback>(d),
      onScaleAndPanEnd: (d) => _callAll<GestureScaleEndCallback>(d),
      onLongPressStart: (d) => _callAll<GestureLongPressStartCallback>(d),
      onLongPressMoveUpdate: (d) =>
          _callAll<GestureLongPressMoveUpdateCallback>(d),
      onLongPressEnd: (d) => _callAll<GestureLongPressEndCallback>(d),
      child: Provider.value(
        value: this,
        child: widget.child,
      ),
    );
  }
}
