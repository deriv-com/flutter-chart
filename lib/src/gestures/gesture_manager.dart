import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'custom_gesture_detector.dart';

/// Top level gesture detector that allows all descendants to register/remove gesture callbacks.
///
/// It is needed because there must be one instance of [CustomGestureDetector].
/// This manager allows extracting features that depend on touch gestures into
/// separate modules.
class GestureManager extends StatefulWidget {
  const GestureManager({
    @required this.child,
    Key key,
  })  : assert(child != null),
        super(key: key);

  final Widget child;

  @override
  GestureManagerState createState() => GestureManagerState();
}

class GestureManagerState extends State<GestureManager> {
  final Set<Function> _callbackPool = <Function>{};

  void registerCallback(Function callback) {
    _callbackPool.add(callback);
  }

  void removeCallback(Function callback) {
    _callbackPool.remove(callback);
  }

  void _callAll<T extends Function>(dynamic details) {
    _callbackPool.whereType<T>().forEach((T f) => f.call(details));
  }

  @override
  Widget build(BuildContext context) => CustomGestureDetector(
        onScaleAndPanStart: (ScaleStartDetails d) =>
            _callAll<GestureScaleStartCallback>(d),
        onPanUpdate: (DragUpdateDetails d) =>
            _callAll<GestureDragUpdateCallback>(d),
        onScaleUpdate: (ScaleUpdateDetails d) =>
            _callAll<GestureScaleUpdateCallback>(d),
        onScaleAndPanEnd: (ScaleEndDetails d) =>
            _callAll<GestureScaleEndCallback>(d),
        onLongPressStart: (LongPressStartDetails d) =>
            _callAll<GestureLongPressStartCallback>(d),
        onLongPressMoveUpdate: (LongPressMoveUpdateDetails d) =>
            _callAll<GestureLongPressMoveUpdateCallback>(d),
        onLongPressEnd: (LongPressEndDetails d) =>
            _callAll<GestureLongPressEndCallback>(d),
        onTapUp: (TapUpDetails d) => _callAll<GestureTapUpCallback>(d),
        child: Provider<GestureManagerState>.value(
          value: this,
          child: widget.child,
        ),
      );
}
