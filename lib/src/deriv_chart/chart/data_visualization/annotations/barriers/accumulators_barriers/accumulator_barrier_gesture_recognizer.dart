import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';

import 'accumulator_barrier_side.dart';

/// Claims the pointer as soon as it goes down on an Accumulators barrier.
///
/// Modelled on `DrawingToolGestureRecognizer`: accepting eagerly in
/// [addPointer] makes this recognizer the arena's eager winner, which beats the
/// chart's scale/pan recognizer higher up the tree. Unlike the drawing-tool one
/// there is no long press and no `kTouchSlop` wait — a barrier grip is an
/// explicit target, so the drag starts on touch-down.
class AccumulatorBarrierGestureRecognizer extends OneSequenceGestureRecognizer {
  /// Initializes a gesture recognizer for the Accumulators barriers.
  AccumulatorBarrierGestureRecognizer({
    required this.hitTest,
    required this.onBarrierDragStart,
    required this.onBarrierDragUpdate,
    required this.onBarrierDragEnd,
    required this.onBarrierDragCancel,
    super.debugOwner,
  });

  /// Returns the barrier at a local position, or `null` when there is none.
  AccumulatorBarrierSide? Function(Offset local, PointerDeviceKind kind)
      hitTest;

  /// Called when the pointer goes down on a barrier.
  void Function(AccumulatorBarrierSide side, Offset local) onBarrierDragStart;

  /// Called as the pointer moves.
  void Function(Offset local) onBarrierDragUpdate;

  /// Called when the pointer is lifted.
  VoidCallback onBarrierDragEnd;

  /// Called when the gesture is cancelled.
  VoidCallback onBarrierDragCancel;

  bool _isBarrierHit = false;

  /// Swaps in fresh callbacks so the recognizer can be reused across rebuilds.
  void updateCallbacks({
    required AccumulatorBarrierSide? Function(Offset, PointerDeviceKind)
        hitTest,
    required void Function(AccumulatorBarrierSide, Offset) onBarrierDragStart,
    required void Function(Offset) onBarrierDragUpdate,
    required VoidCallback onBarrierDragEnd,
    required VoidCallback onBarrierDragCancel,
  }) {
    this.hitTest = hitTest;
    this.onBarrierDragStart = onBarrierDragStart;
    this.onBarrierDragUpdate = onBarrierDragUpdate;
    this.onBarrierDragEnd = onBarrierDragEnd;
    this.onBarrierDragCancel = onBarrierDragCancel;
  }

  @override
  void addPointer(PointerDownEvent event) {
    final AccumulatorBarrierSide? side =
        hitTest(event.localPosition, event.kind);

    if (side == null) {
      _isBarrierHit = false;
      resolve(GestureDisposition.rejected);
      return;
    }

    _isBarrierHit = true;
    // The transform matters: without it the pointer router hands us untransformed
    // events, so `localPosition` on every later move is really the global
    // position and the barrier follows the wrong quote.
    startTrackingPointer(event.pointer, event.transform);
    resolve(GestureDisposition.accepted);
    onBarrierDragStart(side, event.localPosition);
  }

  @override
  void handleEvent(PointerEvent event) {
    if (!_isBarrierHit) {
      return;
    }

    if (event is PointerMoveEvent) {
      onBarrierDragUpdate(event.localPosition);
    } else if (event is PointerUpEvent) {
      onBarrierDragEnd();
      _isBarrierHit = false;
      stopTrackingPointer(event.pointer);
    } else if (event is PointerCancelEvent) {
      onBarrierDragCancel();
      _isBarrierHit = false;
      stopTrackingPointer(event.pointer);
    }
  }

  @override
  void didStopTrackingLastPointer(int pointer) => _isBarrierHit = false;

  @override
  String get debugDescription => 'accumulator_barrier_drag';
}
