/// ScrollToLastTick callback
typedef OnScrollToLastTick = Function(bool);

/// Chart widget's controller
class ChartController {
  /// Called to scroll the current display chart to last tick
  OnScrollToLastTick onScrollToLastTick;

  /// Scroll chart visible area to the newest data.
  void scrollToLastTick({bool animate}) => onScrollToLastTick?.call(animate);
}
