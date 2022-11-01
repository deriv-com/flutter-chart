/// ScrollToLastTick callback.

typedef OnScrollToLastTick = Function(bool);

/// Scale callback;
typedef OnScale = Function(double);

/// Chart widget's controller.
class ChartController {
  /// Called to scroll the current display chart to last tick.
  OnScrollToLastTick? onScrollToLastTick;

  /// Called to scale the chart
  OnScale? onScale;

  /// Scroll chart visible area to the newest data.
  void scrollToLastTick({bool animate = false}) =>
      onScrollToLastTick?.call(animate);

  /// Scroll chart visible area to the newest data.
  void scale(double scale) => onScale?.call(scale);
}
