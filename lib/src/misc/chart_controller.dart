/// ScrollToLastTick callback.

typedef OnScrollToLastTick = Function({required bool animate});

/// Scale callback;
typedef OnScale = Function(double);

/// Get X position callback
typedef GetXFromEpoch = double? Function(int);

/// Get Y position callback
typedef GetYFromQuote = double? Function(double);

/// Get epoch callback
typedef GetEpochFromX = int? Function(double);

/// Get quote callback
typedef GetQuoteFromY = double Function(double);

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

  /// Called to get epoch from x position
  GetEpochFromX? getEpochFromX;

  /// Called to get quote from y position
  GetQuoteFromY? getQuoteFromY;

  /// Scroll chart visible area to the newest data.
  void scrollToLastTick({bool animate = false}) =>
      onScrollToLastTick?.call(animate: animate);

  /// Scroll chart visible area to the newest data.
  void scale(double scale) => onScale?.call(scale);

  /// Gets X position from epoch
  double? xFromEpoch(int epoch) => getXFromEpoch?.call(epoch);

  /// Gets Y position from quote
  double? yFromQuote(double quote) => getYFromQuote?.call(quote);

  /// Gets epoch from X position
  int? epochFromX(double x) => getEpochFromX?.call(x);

  /// Gets quote from Y position
  double? quoteFromY(double y) => getQuoteFromY?.call(y);
}
