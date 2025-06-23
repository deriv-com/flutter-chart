import 'package:flutter/gestures.dart';

/// A custom gesture recognizer that prioritizes drawing tool interactions.
///
/// This recognizer will win the gesture arena if a drawing tool is hit,
/// ensuring that drawing tool interactions take precedence over other gestures
/// like crosshair interactions.
class DrawingToolGestureRecognizer extends OneSequenceGestureRecognizer {
  /// Creates a gesture recognizer for drawing tool interactions.
  DrawingToolGestureRecognizer({
    required this.onDrawingToolPanStart,
    required this.onDrawingToolPanUpdate,
    required this.onDrawingToolPanEnd,
    required this.onDrawingToolPanCancel,
    required this.hitTest,
    required this.onCrosshairCancel,
    Object? debugOwner,
  }) : super(debugOwner: debugOwner);

  /// Called when a pan gesture starts on a drawing tool.
  void Function(DragStartDetails) onDrawingToolPanStart;

  /// Called when a pan gesture updates on a drawing tool.
  void Function(DragUpdateDetails) onDrawingToolPanUpdate;

  /// Called when a pan gesture ends on a drawing tool.
  void Function(DragEndDetails) onDrawingToolPanEnd;

  /// Called when a pan gesture is canceled on a drawing tool.
  void Function() onDrawingToolPanCancel;

  /// Function to test if a point hits a drawing tool.
  bool Function(Offset) hitTest;

  /// Function to cancel any active crosshair.
  void Function() onCrosshairCancel;

  /// Updates the recognizer with new callback functions.
  ///
  /// This allows reusing the same recognizer instance when the callbacks
  /// need to be updated, instead of creating a new instance.
  void updateCallbacks({
    required void Function(DragStartDetails) onDrawingToolPanStart,
    required void Function(DragUpdateDetails) onDrawingToolPanUpdate,
    required void Function(DragEndDetails) onDrawingToolPanEnd,
    required void Function() onDrawingToolPanCancel,
    required bool Function(Offset) hitTest,
    required void Function() onCrosshairCancel,
  }) {
    this.onDrawingToolPanStart = onDrawingToolPanStart;
    this.onDrawingToolPanUpdate = onDrawingToolPanUpdate;
    this.onDrawingToolPanEnd = onDrawingToolPanEnd;
    this.onDrawingToolPanCancel = onDrawingToolPanCancel;
    this.hitTest = hitTest;
    this.onCrosshairCancel = onCrosshairCancel;
  }

  /// Whether a drawing tool was hit at the start of the gesture.
  bool _isDrawingToolHit = false;

  /// The global position where the gesture started.
  Offset? _globalStartPosition;

  /// The timestamp when the gesture started.
  Duration? _startTimeStamp;

  @override
  void addPointer(PointerDownEvent event) {
    _globalStartPosition = event.position;
    _startTimeStamp = event.timeStamp;
    _isDrawingToolHit = hitTest(event.localPosition);

    if (_isDrawingToolHit) {
      // If a drawing tool is hit, this recognizer should win
      startTrackingPointer(event.pointer);
      resolve(GestureDisposition.accepted);

      // Call the pan start callback with properly constructed DragStartDetails
      onDrawingToolPanStart(DragStartDetails(
        sourceTimeStamp: event.timeStamp,
        globalPosition: event.position,
        localPosition: event.localPosition,
      ));

      // Cancel any active crosshair
      onCrosshairCancel();
    } else {
      // Otherwise, let other recognizers compete
      resolve(GestureDisposition.rejected);
    }
  }

  @override
  void handleEvent(PointerEvent event) {
    if (!_isDrawingToolHit) {
      // If no drawing tool was hit, don't handle the event
      return;
    }

    if (event is PointerMoveEvent) {
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
    } else if (event is PointerUpEvent) {
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

      stopTrackingPointer(event.pointer);
      _isDrawingToolHit = false;
      _globalStartPosition = null;
      _startTimeStamp = null;
    } else if (event is PointerCancelEvent) {
      onDrawingToolPanCancel();
      stopTrackingPointer(event.pointer);
      _isDrawingToolHit = false;
      _globalStartPosition = null;
      _startTimeStamp = null;
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

  @override
  void didStopTrackingLastPointer(int pointer) {
    _isDrawingToolHit = false;
    _globalStartPosition = null;
    _startTimeStamp = null;
  }

  @override
  void dispose() {
    _isDrawingToolHit = false;
    _globalStartPosition = null;
    _startTimeStamp = null;
    super.dispose();
  }
}
