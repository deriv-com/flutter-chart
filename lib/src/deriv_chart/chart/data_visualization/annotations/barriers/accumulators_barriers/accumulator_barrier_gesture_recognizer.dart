import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';

/// Recognises a tap on the Accumulators band.
///
/// The target is the whole band, which covers a large part of the chart, so
/// claiming the pointer on touch-down would take panning away from the user
/// everywhere the band is. It waits instead, and gives the pointer up the
/// moment it travels past [kTouchSlop] — a press that turns into a pan is a
/// pan.
class AccumulatorBarrierGestureRecognizer extends OneSequenceGestureRecognizer {
  /// Initializes a gesture recognizer for the Accumulators band.
  AccumulatorBarrierGestureRecognizer({
    required this.bandHitTest,
    required this.onBandTap,
    required this.onBandPress,
    super.debugOwner,
  });

  /// Whether a local position falls on the band.
  bool Function(Offset local, PointerDeviceKind kind) bandHitTest;

  /// Called when the band is tapped.
  VoidCallback onBandTap;

  /// Called when a press lands on the band, before it is known to be a tap.
  VoidCallback onBandPress;

  bool _isBandHit = false;
  Offset? _downPosition;

  /// Swaps in fresh callbacks so the recognizer can be reused across rebuilds.
  void updateCallbacks({
    required bool Function(Offset, PointerDeviceKind) bandHitTest,
    required VoidCallback onBandTap,
    required VoidCallback onBandPress,
  }) {
    this.bandHitTest = bandHitTest;
    this.onBandTap = onBandTap;
    this.onBandPress = onBandPress;
  }

  @override
  void addPointer(PointerDownEvent event) {
    if (!bandHitTest(event.localPosition, event.kind)) {
      _isBandHit = false;
      resolve(GestureDisposition.rejected);
      return;
    }

    _isBandHit = true;
    _downPosition = event.localPosition;
    // Deliberately no `resolve` here: the arena is left open so a press that
    // becomes a pan still reaches the chart.
    //
    // The transform matters: without it the pointer router hands us
    // untransformed events, so `localPosition` on every later move is really
    // the global position and the slop check measures the wrong distance.
    startTrackingPointer(event.pointer, event.transform);
    // Announced on the press rather than on the tap, so a consumer deciding
    // what the gesture means can hear about it in time. See `onPressStart`.
    onBandPress();
  }

  @override
  void handleEvent(PointerEvent event) {
    if (!_isBandHit) {
      return;
    }

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
      onBandTap();
    } else if (event is PointerCancelEvent) {
      _release(event.pointer, GestureDisposition.rejected);
    }
  }

  void _release(int pointer, GestureDisposition disposition) {
    _isBandHit = false;
    _downPosition = null;
    resolve(disposition);
    stopTrackingPointer(pointer);
  }

  @override
  void didStopTrackingLastPointer(int pointer) {
    _isBandHit = false;
    _downPosition = null;
  }

  @override
  String get debugDescription => 'accumulator_barrier_tap';
}
