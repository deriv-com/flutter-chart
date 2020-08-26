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
  }) : super(key: key);

  final Widget child;

  final GestureScaleStartCallback onScaleAndPanStart;

  final GestureScaleUpdateCallback onScaleUpdate;

  final GestureDragUpdateCallback onPanUpdate;

  final GestureScaleEndCallback onScaleAndPanEnd;

  final GestureLongPressStartCallback onLongPressStart;

  final GestureLongPressMoveUpdateCallback onLongPressMoveUpdate;

  final GestureLongPressEndCallback onLongPressEnd;

  @override
  _CustomGestureDetectorState createState() => _CustomGestureDetectorState();
}

class _CustomGestureDetectorState extends State<CustomGestureDetector> {
  int _fingersOnScreen = 0;
  Offset _lastContactPoint;

  bool _longPressed = false;
  Timer _longPressTimer;
  Offset _longPressStartPosition;

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (event) {
        _fingersOnScreen += 1;
        _afterNumberOfFingersOnScreenChanged();
      },
      onPointerCancel: (event) {
        _fingersOnScreen -= 1;
        _afterNumberOfFingersOnScreenChanged();
      },
      onPointerUp: (event) {
        _fingersOnScreen -= 1;
        _afterNumberOfFingersOnScreenChanged();
      },
      child: GestureDetector(
        onScaleStart: _onScaleStart,
        onScaleUpdate: _onScaleUpdate,
        onScaleEnd: widget.onScaleAndPanEnd,
        child: widget.child,
      ),
    );
  }

  void _afterNumberOfFingersOnScreenChanged() {
    switch (_fingersOnScreen) {
      case 0:
        _longPressTimer?.cancel();
        if (_longPressed) _onLongPressEnd();
        break;
      case 1:
        if (!_longPressed)
          _longPressTimer = Timer(
            longPressHoldDuration,
            _onLongPressStart,
          );
        break;
      default:
        _longPressTimer?.cancel();
    }
  }

  void _onLongPressStart() {
    _longPressed = true;
    widget.onLongPressStart?.call(LongPressStartDetails(
      globalPosition: _lastContactPoint,
      localPosition: _lastContactPoint,
    ));
  }

  void _onLongPressEnd() {
    _longPressed = false;
    widget.onLongPressEnd?.call(null);
  }

  void _onScaleStart(ScaleStartDetails details) {
    _lastContactPoint = details.focalPoint;
    _longPressStartPosition = details.focalPoint;

    widget.onScaleAndPanStart?.call(details);
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    if (_longPressed) {
      _onLongPressMoveUpdate(details);
    } else if (_fingersOnScreen == 1) {
      _cancelLongPressIfMovedTooFar(details.focalPoint);
      _onPanUpdate(details);
    } else {
      widget.onScaleUpdate?.call(details);
    }
  }

  void _onLongPressMoveUpdate(ScaleUpdateDetails details) {
    widget.onLongPressMoveUpdate?.call(LongPressMoveUpdateDetails(
      localPosition: details.localFocalPoint,
    ));
  }

  void _cancelLongPressIfMovedTooFar(Offset contactPoint) {
    if (_longPressStartPosition == null) return;

    final distanceFromStartPosition =
        (_longPressStartPosition - contactPoint).distance;

    if (distanceFromStartPosition > longPressHoldRadius)
      _longPressTimer?.cancel();
  }

  void _onPanUpdate(ScaleUpdateDetails details) {
    final currentContactPoint = details.focalPoint;
    final dragUpdateDetails = DragUpdateDetails(
      delta: currentContactPoint - _lastContactPoint,
      globalPosition: currentContactPoint,
      localPosition: details.localFocalPoint,
    );
    _lastContactPoint = details.focalPoint;

    widget.onPanUpdate?.call(dragUpdateDetails);
  }
}
