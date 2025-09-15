import 'dart:async';
import 'package:flutter/gestures.dart';

/// A custom gesture recognizer that prioritizes drawing tool interactions.
///
/// This recognizer will win the gesture arena if a drawing tool is hit,
/// ensuring that drawing tool interactions take precedence over other gestures
/// like crosshair interactions. It also supports long press detection.
class DrawingToolGestureRecognizer extends OneSequenceGestureRecognizer {
  /// Creates a gesture recognizer for drawing tool interactions.
  DrawingToolGestureRecognizer({
    required this.onDrawingToolPanStart,
    required this.onDrawingToolPanUpdate,
    required this.onDrawingToolPanEnd,
    required this.onDrawingToolPanCancel,
    required this.onDrawingToolLongPress,
    required this.onDrawingToolLongPressEnd,
    required this.hitTest,
    required this.onCrosshairCancel,
    Object? debugOwner,
    this.longPressDuration = const Duration(milliseconds: 300),
  }) : super(debugOwner: debugOwner);

  /// Called when a pan gesture starts on a drawing tool.
  void Function(DragStartDetails) onDrawingToolPanStart;

  /// Called when a pan gesture updates on a drawing tool.
  void Function(DragUpdateDetails) onDrawingToolPanUpdate;

  /// Called when a pan gesture ends on a drawing tool.
  void Function(DragEndDetails) onDrawingToolPanEnd;

  /// Called when a pan gesture is canceled on a drawing tool.
  void Function() onDrawingToolPanCancel;

  /// Called when a long press is detected on a drawing tool.
  void Function(Offset) onDrawingToolLongPress;

  /// Called when a long press ends on a drawing tool.
  void Function() onDrawingToolLongPressEnd;

  /// Function to test if a point hits a drawing tool.
  bool Function(Offset) hitTest;

  /// Function to cancel any active crosshair.
  void Function() onCrosshairCancel;

  /// Duration required for a long press to be detected.
  final Duration longPressDuration;

  /// Updates the recognizer with new callback functions.
  ///
  /// This allows reusing the same recognizer instance when the callbacks
  /// need to be updated, instead of creating a new instance.
  void updateCallbacks({
    required void Function(DragStartDetails) onDrawingToolPanStart,
    required void Function(DragUpdateDetails) onDrawingToolPanUpdate,
    required void Function(DragEndDetails) onDrawingToolPanEnd,
    required void Function() onDrawingToolPanCancel,
    required void Function(Offset) onDrawingToolLongPress,
    required void Function() onDrawingToolLongPressEnd,
    required bool Function(Offset) hitTest,
    required void Function() onCrosshairCancel,
  }) {
    this.onDrawingToolPanStart = onDrawingToolPanStart;
    this.onDrawingToolPanUpdate = onDrawingToolPanUpdate;
    this.onDrawingToolPanEnd = onDrawingToolPanEnd;
    this.onDrawingToolPanCancel = onDrawingToolPanCancel;
    this.onDrawingToolLongPress = onDrawingToolLongPress;
    this.onDrawingToolLongPressEnd = onDrawingToolLongPressEnd;
    this.hitTest = hitTest;
    this.onCrosshairCancel = onCrosshairCancel;
  }

  /// Whether a drawing tool was hit at the start of the gesture.
  bool _isDrawingToolHit = false;

  /// The global position where the gesture started.
  Offset? _globalStartPosition;

  /// The local position where the gesture started.
  Offset? _localStartPosition;

  /// The timestamp when the gesture started.
  Duration? _startTimeStamp;

  /// Timer for long press detection.
  Timer? _longPressTimer;

  /// Whether a long press has been detected.
  bool _longPressDetected = false;

  /// Whether the pointer has moved significantly (indicating drag, not long press).
  bool _hasMovedSignificantly = false;

  /// Threshold for determining if the pointer has moved significantly.
  static const double _kTouchSlop = 18;

  @override
  void addPointer(PointerDownEvent event) {
    _globalStartPosition = event.position;
    _localStartPosition = event.localPosition;
    _startTimeStamp = event.timeStamp;
    _isDrawingToolHit = hitTest(event.localPosition);
    _longPressDetected = false;
    _hasMovedSignificantly = false;

    if (_isDrawingToolHit) {
      // If a drawing tool is hit, this recognizer should win
      startTrackingPointer(event.pointer);
      resolve(GestureDisposition.accepted);

      // Start long press timer
      _startLongPressTimer();

      // Don't call pan start immediately - wait to see if it's a long press
      // onDrawingToolPanStart will be called later if it's not a long press

      // Cancel any active crosshair
      onCrosshairCancel();
    } else {
      // Otherwise, let other recognizers compete
      resolve(GestureDisposition.rejected);
    }
  }

  /// Starts the long press timer.
  void _startLongPressTimer() {
    _longPressTimer?.cancel();
    _longPressTimer = Timer(longPressDuration, () {
      if (_isDrawingToolHit && !_hasMovedSignificantly && !_longPressDetected) {
        _longPressDetected = true;
        onDrawingToolLongPress(_localStartPosition ?? Offset.zero);
      }
    });
  }

  /// Cancels the long press timer.
  void _cancelLongPressTimer() {
    _longPressTimer?.cancel();
    _longPressTimer = null;
  }

  @override
  void handleEvent(PointerEvent event) {
    if (!_isDrawingToolHit) {
      // If no drawing tool was hit, don't handle the event
      return;
    }

    if (event is PointerMoveEvent) {
      // Check if the pointer has moved significantly
      if (_globalStartPosition != null) {
        final distance = (event.position - _globalStartPosition!).distance;
        if (distance > _kTouchSlop && !_hasMovedSignificantly) {
          _hasMovedSignificantly = true;
          _cancelLongPressTimer();

          // Now that we know it's a drag, call pan start
          onDrawingToolPanStart(DragStartDetails(
            sourceTimeStamp: _startTimeStamp ?? event.timeStamp,
            globalPosition: _globalStartPosition!,
            localPosition: _localStartPosition ?? event.localPosition,
          ));
        }
      }

      // Only send pan update if we've moved significantly (started dragging)
      if (_hasMovedSignificantly) {
        final localOffset = event.localPosition;
        final delta = event.delta;

        // We need to set primaryDelta correctly to avoid assertion errors
        // primaryDelta should be null, or equal to delta.dx (with delta.dy = 0),
        // or equal to delta.dy (with delta.dx = 0)
        double? primaryDelta;
        if (delta.dx == 0.0) {
          primaryDelta = delta.dy;
        } else if (delta.dy == 0.0) {
          primaryDelta = delta.dx;
        }

        onDrawingToolPanUpdate(DragUpdateDetails(
          sourceTimeStamp: event.timeStamp,
          globalPosition: event.position,
          localPosition: localOffset,
          delta: delta,
          primaryDelta: primaryDelta,
        ));
      }
    } else if (event is PointerUpEvent) {
      _cancelLongPressTimer();

      // If long press was detected, call the end callback
      if (_longPressDetected) {
        onDrawingToolLongPressEnd();
      } else if (!_hasMovedSignificantly) {
        // If no significant movement and no long press, it's a tap
        // Call pan start and immediately pan end for tap handling
        onDrawingToolPanStart(DragStartDetails(
          sourceTimeStamp: _startTimeStamp ?? event.timeStamp,
          globalPosition: _globalStartPosition ?? event.position,
          localPosition: _localStartPosition ?? event.localPosition,
        ));
      }

      // Only call pan end if we had movement or it was a tap
      if (_hasMovedSignificantly || !_longPressDetected) {
        final velocity = _calculateVelocity(event);

        // Similarly, primaryVelocity needs to be set correctly
        double? primaryVelocity;
        if (velocity.pixelsPerSecond.dx == 0.0) {
          primaryVelocity = velocity.pixelsPerSecond.dy;
        } else if (velocity.pixelsPerSecond.dy == 0.0) {
          primaryVelocity = velocity.pixelsPerSecond.dx;
        }

        onDrawingToolPanEnd(DragEndDetails(
          velocity: velocity,
          primaryVelocity: primaryVelocity,
        ));
      }

      _resetState();
      stopTrackingPointer(event.pointer);
    } else if (event is PointerCancelEvent) {
      _cancelLongPressTimer();

      // If long press was detected, call the end callback
      if (_longPressDetected) {
        onDrawingToolLongPressEnd();
      }

      onDrawingToolPanCancel();
      _resetState();
      stopTrackingPointer(event.pointer);
    }
  }

  /// Calculates the velocity of the gesture.
  Velocity _calculateVelocity(PointerUpEvent event) {
    // Simple velocity calculation
    final duration = event.timeStamp - (_startTimeStamp ?? event.timeStamp);
    if (duration == Duration.zero) {
      return Velocity.zero;
    }

    final distance = event.position - (_globalStartPosition ?? event.position);
    final seconds = duration.inMicroseconds / Duration.microsecondsPerSecond;

    return Velocity(
      pixelsPerSecond: Offset(
        distance.dx / seconds,
        distance.dy / seconds,
      ),
    );
  }

  @override
  String get debugDescription => 'drawing_tool_gesture_recognizer';

  /// Resets the internal state of the gesture recognizer.
  void _resetState() {
    _isDrawingToolHit = false;
    _globalStartPosition = null;
    _localStartPosition = null;
    _startTimeStamp = null;
    _longPressDetected = false;
    _hasMovedSignificantly = false;
  }

  @override
  void didStopTrackingLastPointer(int pointer) {
    _cancelLongPressTimer();
    _resetState();
  }

  @override
  void dispose() {
    _cancelLongPressTimer();
    _resetState();
    super.dispose();
  }
}
