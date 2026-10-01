import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';

import 'accumulator_barrier_side.dart';

/// Recognises interaction with the Accumulators barriers.
///
/// Two modes, picked by [tapOnly]:
///
/// * **Drag** (grips on). Modelled on `DrawingToolGestureRecognizer`: accepting
///   eagerly in [addPointer] makes this the arena's eager winner, which beats
///   the chart's scale/pan recognizer higher up the tree. There is no long press
///   and no `kTouchSlop` wait — a grip is an explicit target, so the drag starts
///   on touch-down.
/// * **Tap** (grips off). The target is the whole band, which covers a large
///   part of the chart, so claiming it on touch-down would take panning away
///   from the user everywhere the band is. It waits instead, and gives the
///   pointer up the moment it travels past [kTouchSlop] — a press that turns
///   into a pan is a pan.
class AccumulatorBarrierGestureRecognizer extends OneSequenceGestureRecognizer {
  /// Initializes a gesture recognizer for the Accumulators barriers.
  AccumulatorBarrierGestureRecognizer({
    required this.hitTest,
    required this.onBarrierDragStart,
    required this.onBarrierDragUpdate,
    required this.onBarrierDragEnd,
    required this.onBarrierDragCancel,
    this.tapOnly = false,
    this.onBandTap,
    this.onBandPress,
    this.bandHitTest,
    super.debugOwner,
  });

  /// Whether the band is a tap target rather than the grips being draggable.
  bool tapOnly;

  /// Called when the band is tapped. Only used while [tapOnly].
  VoidCallback? onBandTap;

  /// Called when a press lands on the band, before it is known to be a tap.
  VoidCallback? onBandPress;

  /// Whether a local position falls on the band. Only used while [tapOnly].
  bool Function(Offset local, PointerDeviceKind kind)? bandHitTest;

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
  Offset? _downPosition;

  /// Swaps in fresh callbacks so the recognizer can be reused across rebuilds.
  void updateCallbacks({
    required AccumulatorBarrierSide? Function(Offset, PointerDeviceKind)
        hitTest,
    required void Function(AccumulatorBarrierSide, Offset) onBarrierDragStart,
    required void Function(Offset) onBarrierDragUpdate,
    required VoidCallback onBarrierDragEnd,
    required VoidCallback onBarrierDragCancel,
    required bool tapOnly,
    required bool Function(Offset, PointerDeviceKind) bandHitTest,
    required VoidCallback onBandTap,
    required VoidCallback onBandPress,
  }) {
    this.hitTest = hitTest;
    this.onBarrierDragStart = onBarrierDragStart;
    this.onBarrierDragUpdate = onBarrierDragUpdate;
    this.onBarrierDragEnd = onBarrierDragEnd;
    this.onBarrierDragCancel = onBarrierDragCancel;
    this.tapOnly = tapOnly;
    this.bandHitTest = bandHitTest;
    this.onBandTap = onBandTap;
    this.onBandPress = onBandPress;
  }

  @override
  void addPointer(PointerDownEvent event) {
    if (tapOnly) {
      _addTapPointer(event);
      return;
    }

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

  void _addTapPointer(PointerDownEvent event) {
    if (!(bandHitTest?.call(event.localPosition, event.kind) ?? false)) {
      _isBarrierHit = false;
      resolve(GestureDisposition.rejected);
      return;
    }

    _isBarrierHit = true;
    _downPosition = event.localPosition;
    // Deliberately no `resolve` here: the arena is left open so a press that
    // becomes a pan still reaches the chart.
    startTrackingPointer(event.pointer, event.transform);
    // Announced on the press rather than on the tap, so a consumer deciding
    // what the gesture means can hear about it in time. See `onPressStart`.
    onBandPress?.call();
  }

  @override
  void handleEvent(PointerEvent event) {
    if (!_isBarrierHit) {
      return;
    }

    if (tapOnly) {
      _handleTapEvent(event);
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

  void _handleTapEvent(PointerEvent event) {
    if (event is PointerMoveEvent) {
      final Offset? down = _downPosition;
      if (down != null && (event.localPosition - down).distance > kTouchSlop) {
        // Travelled too far to be a tap — hand the pointer back so the chart
        // can pan with it.
        _release(event.pointer, GestureDisposition.rejected);
      }
      return;
    }

    if (event is PointerUpEvent) {
      _release(event.pointer, GestureDisposition.accepted);
      onBandTap?.call();
    } else if (event is PointerCancelEvent) {
      _release(event.pointer, GestureDisposition.rejected);
    }
  }

  void _release(int pointer, GestureDisposition disposition) {
    _isBarrierHit = false;
    _downPosition = null;
    resolve(disposition);
    stopTrackingPointer(pointer);
  }

  @override
  void didStopTrackingLastPointer(int pointer) {
    _isBarrierHit = false;
    _downPosition = null;
  }

  @override
  String get debugDescription => 'accumulator_barrier_drag';
}
