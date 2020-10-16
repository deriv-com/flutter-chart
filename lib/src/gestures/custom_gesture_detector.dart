import 'dart:async';

import 'package:flutter/material.dart';

/// Duration for which you have to hold one finger without moving until
/// long press is triggered.
/// (small deviation is allowed, see [longPressHoldRadius])
const longPressHoldDuration = Duration(milliseconds: 200);

/// If contact point is moved by more than [longPressHoldRadius] from
/// its original place and [longPressHoldDuration] hasn't elapsed yet,
/// long press is cancelled.
const longPressHoldRadius = 5;

/// Widget to track pan and scale gestures on one area.
///
/// GestureDetector doesn't allow to track both Pan and Scale gestures
/// at the same time.
///
/// a. Scale is treated as a super set of Pan.
/// b. Scale is triggered even when there is only one finger in contact with the
/// screen.
///
/// Because of (a) and (b) it is possible to keep track of both Pan and Scale by
/// treating ScaleUpdate with 1 finger as PanUpdate.
///
/// Custom long press detection, because adding `onLongPress` callback to
/// GestureDetector will result in a scale/pan delay. It happens because having
/// two gesture callbacks (e.g. "longpress" and "scale") will result in a
/// few moments of delay while GestureDetector is figuring out which gesture is
/// being performed. This delay is quite noticable.
///
/// This widget adds longpress detection without adding delay to scale/pan.
class CustomGestureDetector extends StatefulWidget {
  const CustomGestureDetector({
    Key key,
    this.child,
    this.onScaleAndPanStart,
    this.onScaleUpdate,
    this.onPanUpdate,
    this.onScaleAndPanEnd,
    this.onLongPressStart,
    this.onLongPressMoveUpdate,
    this.onLongPressEnd,
    this.onTapUp,
  }) : super(key: key);

  final Widget child;

  final GestureScaleStartCallback onScaleAndPanStart;

  final GestureScaleUpdateCallback onScaleUpdate;

  final GestureDragUpdateCallback onPanUpdate;

  final GestureScaleEndCallback onScaleAndPanEnd;

  final GestureLongPressStartCallback onLongPressStart;

  final GestureLongPressMoveUpdateCallback onLongPressMoveUpdate;

  final GestureLongPressEndCallback onLongPressEnd;

  final GestureTapUpCallback onTapUp;

  @override
  _CustomGestureDetectorState createState() => _CustomGestureDetectorState();
}

class _CustomGestureDetectorState extends State<CustomGestureDetector> {
  int get pointersDown => _pointersDown;
  int _pointersDown = 0;
  set pointersDown(int value) {
    _onPointersDownWillChange(value);
    _pointersDown = value;
  }

  Offset _startPoint;
  Offset _lastPoint;

  bool _tap = false;
  bool _longPressed = false;
  Timer _longPressTimer;

  @override
  Widget build(BuildContext context) => Listener(
        onPointerDown: (PointerDownEvent event) => pointersDown += 1,
        onPointerCancel: (PointerCancelEvent event) => pointersDown -= 1,
        onPointerUp: (PointerUpEvent event) => pointersDown -= 1,
        child: GestureDetector(
          onScaleStart: _onScaleStart,
          onScaleUpdate: _onScaleUpdate,
          onScaleEnd: widget.onScaleAndPanEnd,
          child: widget.child,
        ),
      );

  void _onPointersDownWillChange(int futureValue) {
    // First pointer down.
    if (_pointersDown == 0 && futureValue == 1) {
      _tap = true;
      _longPressTimer = Timer(
        longPressHoldDuration,
        _onLongPressStart,
      );
    }

    // Added second pointer.
    if (_pointersDown == 1 && futureValue == 2) {
      _tap = false;
      _longPressTimer?.cancel();
      if (_longPressed) {
        _onLongPressEnd();
      }
    }

    // Removed last pointer.
    if (_pointersDown == 1 && futureValue == 0) {
      _longPressTimer?.cancel();
      if (_longPressed) {
        _onLongPressEnd();
      } else if (_tap) {
        widget.onTapUp?.call(TapUpDetails(globalPosition: _startPoint));
      }
    }
  }

  void _onScaleStart(ScaleStartDetails details) {
    _startPoint = details.focalPoint;
    _lastPoint = _startPoint;

    widget.onScaleAndPanStart?.call(details);
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    if (_pointersDown == 1) {
      _onSinglePointerMoveUpdate(details);
    } else {
      widget.onScaleUpdate?.call(details);
    }
  }

  void _onSinglePointerMoveUpdate(ScaleUpdateDetails details) {
    if (_longPressed) {
      _onLongPressMoveUpdate(details);
    } else {
      final double distanceFromStart =
          (_startPoint - details.focalPoint).distance;

      if (distanceFromStart > longPressHoldRadius) {
        _tap = false;
        _longPressTimer?.cancel();
      }
      _onPanUpdate(details);
    }
  }

  void _onPanUpdate(ScaleUpdateDetails details) {
    widget.onPanUpdate?.call(DragUpdateDetails(
      delta: details.focalPoint - _lastPoint,
      globalPosition: details.focalPoint,
      localPosition: details.localFocalPoint,
    ));
    _lastPoint = details.focalPoint;
  }

  void _onLongPressStart() {
    _longPressed = true;
    widget.onLongPressStart?.call(LongPressStartDetails(
      globalPosition: _startPoint,
      localPosition: _startPoint,
    ));
  }

  void _onLongPressMoveUpdate(ScaleUpdateDetails details) {
    widget.onLongPressMoveUpdate?.call(LongPressMoveUpdateDetails(
      localPosition: details.localFocalPoint,
    ));
  }

  void _onLongPressEnd() {
    _longPressed = false;
    widget.onLongPressEnd?.call(null);
  }
}
