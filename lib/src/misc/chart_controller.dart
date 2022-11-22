/// ScrollToLastTick callback.
typedef OnScrollToLastTick = Function(bool);

/// Scale callback;
typedef OnScale = Function(double);

/// Get X position callback
typedef GetXFromEpoch = double? Function(int);

/// Get Y position callback
typedef GetYFromQuote = double? Function(double);

/// Chart widget's controller.
class ChartController {
  /// Called to scroll the current display chart to last tick.
  OnScrollToLastTick? onScrollToLastTick;

  /// Called to scale the chart
  OnScale? onScale;

  /// Called to get X position from epoch
  GetXFromEpoch? getXFromEpoch;

  /// Called to get Y position from quote
  GetYFromQuote? getYFromQuote;

  /// Scroll chart visible area to the newest data.
  void scrollToLastTick({bool animate = false}) =>
      onScrollToLastTick?.call(animate);

  /// Scroll chart visible area to the newest data.
  void scale(double scale) => onScale?.call(scale);

  /// Gets X position from epoch
  double? xFromEpoch(int epoch) => getXFromEpoch?.call(epoch);

  /// Gets Y position from quote
  double? yFromQuote(double quote) => getYFromQuote?.call(quote);
}
