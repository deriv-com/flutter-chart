// @dart=2.9

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'custom_gesture_detector.dart';

/// Top level gesture detector that allows all descendants to register/remove gesture callbacks.
///
/// It is needed because there must be one instance of [CustomGestureDetector].
/// This manager allows extracting features that depend on touch gestures into
/// separate modules.
class GestureManager extends StatefulWidget {
  /// Initialises the top level gesture detector that allows all descendants to register/remove gesture callbacks.
  GestureManager({Key key, @required this.child})
      : assert(child != null),
        super(key: key);

  /// The widget below this widget in the tree.
  final Widget child;

  @override
  GestureManagerState createState() => GestureManagerState();
}

/// The state of the top level gesture detector that allows all descendants to register/remove gesture callbacks.
class GestureManagerState extends State<GestureManager> {
  final _callbackPool = <Function>{};

  /// Registers a callback funtion to the pool of functions in GestureManager.
  void registerCallback(Function callback) {
    _callbackPool.add(callback);
  }

  /// Removes a callback funtion from the pool of functions in GestureManager.
  void removeCallback(Function callback) {
    _callbackPool.remove(callback);
  }

  void _callAll<T extends Function>(dynamic details) {
    _callbackPool.whereType<T>().forEach((f) => f(details));
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
      onTapUp: (d) => _callAll<GestureTapUpCallback>(d),
      child: Provider.value(
        value: this,
        child: widget.child,
      ),
    );
  }
}
