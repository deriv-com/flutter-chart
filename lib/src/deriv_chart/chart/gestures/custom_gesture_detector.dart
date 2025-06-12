import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';

/// Duration for which you have to hold one finger without moving until
/// long press is triggered.
/// (small deviation is allowed, see [longPressHoldRadius])
const Duration longPressHoldDuration = Duration(milliseconds: 500);

/// If contact point is moved by more than [longPressHoldRadius] from
/// its original place and [longPressHoldDuration] hasn't elapsed yet,
/// long press is cancelled.
const int longPressHoldRadius = 5;

/// If contact point is moved by more than [tapRadius] from its original place,
/// tap is cancelled.
const double tapRadius = 5;

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
  /// Creates a widget to track pan and scale gestures on one area.
  const CustomGestureDetector({
    required this.child,
    Key? key,
    this.onScaleAndPanStart,
    this.onScaleUpdate,
    this.onPanUpdate,
    this.onScaleAndPanEnd,
    this.onLongPressStart,
    this.onLongPressMoveUpdate,
    this.onLongPressEnd,
    this.onTapUp,
  }) : super(key: key);

  /// The widget below this widget in the tree.
  final Widget child;

  /// The pointers in contact with the screen have established a focal point and
  /// initial scale of 1.0.
  final GestureScaleStartCallback? onScaleAndPanStart;

  /// The pointers in contact with the screen have indicated a new focal point and/or scale.
  final GestureScaleUpdateCallback? onScaleUpdate;

  /// Called when a pointer that triggered an `onPointerDown` is no longer in
  /// contact with the screen.
  final GestureDragUpdateCallback? onPanUpdate;

  /// The pointers are no longer in contact with the screen.
  final GestureScaleEndCallback? onScaleAndPanEnd;

  /// Called when a long press gesture with a primary button has been
  /// recognized.
  ///
  /// Triggered when a pointer has remained in contact with the screen at the
  /// same location for a long period of time.
  final GestureLongPressStartCallback? onLongPressStart;

  /// A pointer has been drag-moved after a long press with a primary button.
  final GestureLongPressMoveUpdateCallback? onLongPressMoveUpdate;

  /// Called when a long press gesture with a primary button has been
  /// recognized.
  ///
  /// Triggered when a pointer has remained in contact with the screen at the
  /// same location for a long period of time.
  final GestureLongPressEndCallback? onLongPressEnd;

  /// A pointer that will trigger a tap with a primary button has stopped
  /// contacting the screen at a particular location.
  /// This triggers immediately before `onTap` in the case of the tap gesture
  /// winning. If the tap gesture did not win, `onTapCancel` is called instead.
  final GestureTapUpCallback? onTapUp;

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

  Offset _localStartPoint = Offset.zero;
  Offset _localLastPoint = Offset.zero;

  bool _tap = false;
  bool _longPressed = false;
  Timer? _longPressTimer;

  @override
  Widget build(BuildContext context) => Listener(
        onPointerDown: (PointerDownEvent event) => pointersDown += 1,
        onPointerCancel: (PointerCancelEvent event) => pointersDown -= 1,
        onPointerUp: (PointerUpEvent event) {
          // Update the last point with the current position when pointer is lifted
          _localLastPoint = event.localPosition;
          pointersDown -= 1;
        },
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
        final double distance = (_localStartPoint - _localLastPoint).distance;

        // Only trigger tap if the distance is within the threshold
        if (distance <= tapRadius) {
          widget.onTapUp?.call(TapUpDetails(
            globalPosition: _localStartPoint,
            localPosition: _localLastPoint,
            kind: PointerDeviceKind.touch,
          ));
        }
      }
    }
  }

  void _onScaleStart(ScaleStartDetails details) {
    _localStartPoint = details.localFocalPoint;
    _localLastPoint = _localStartPoint;

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
          (_localStartPoint - details.localFocalPoint).distance;

      if (distanceFromStart > longPressHoldRadius) {
        _tap = false;
        _longPressTimer?.cancel();
      }
      _onPanUpdate(details);
    }
  }

  void _onPanUpdate(ScaleUpdateDetails details) {
    widget.onPanUpdate?.call(DragUpdateDetails(
      delta: details.localFocalPoint - _localLastPoint,
      globalPosition: details.focalPoint,
      localPosition: details.localFocalPoint,
    ));
    _localLastPoint = details.localFocalPoint;
  }

  void _onLongPressStart() {
    _longPressed = true;
    widget.onLongPressStart?.call(LongPressStartDetails(
      globalPosition: _localStartPoint,
      localPosition: _localStartPoint,
    ));
  }

  void _onLongPressMoveUpdate(ScaleUpdateDetails details) {
    widget.onLongPressMoveUpdate?.call(LongPressMoveUpdateDetails(
      localPosition: details.localFocalPoint,
    ));
  }

  void _onLongPressEnd() {
    _longPressed = false;
    widget.onLongPressEnd?.call(const LongPressEndDetails());
  }
}
