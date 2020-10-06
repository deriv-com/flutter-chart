/// ScrollToLastTick callback
typedef OnScrollToLastTick = Function(bool);

/// Chart widget's controller
class ChartController {
  OnScrollToLastTick _onScrollToLastTick;

  /// Sets a listener to get notified when the [scrollToLastTick] is called on the controller.
  // ignore: avoid_setters_without_getters
  set scrollToLastTickListener(OnScrollToLastTick listener) =>
      _onScrollToLastTick = listener;

  /// Scroll chart visible area to the newest data.
  void scrollToLastTick({bool animate}) => _onScrollToLastTick?.call(animate);
}
