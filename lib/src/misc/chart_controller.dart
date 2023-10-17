/// ScrollToLastTick callback.

typedef OnScrollToLastTick = Function({required bool animate});

/// Chart widget's controller.
class ChartController {
  /// Called to scroll the current display chart to last tick.
  OnScrollToLastTick? onScrollToLastTick;

  /// Scroll chart visible area to the newest data.
  void scrollToLastTick({bool animate = false}) =>
      onScrollToLastTick?.call(animate: animate);
}
