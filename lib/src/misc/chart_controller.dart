import 'package:deriv_chart/deriv_chart.dart';

/// ScrollToLastTick callback.
typedef OnScrollToLastTick = Function({required bool animate});

/// Callback to complete the current tick animation immediately.
typedef OnCompleteTickAnimation = void Function();

/// Scale callback;
typedef OnScale = double? Function(double);

/// Scroll callback;
typedef OnScroll = Function(double);

/// To get X position
typedef GetXFromEpoch = double? Function(int);

/// To get Y position
typedef GetYFromQuote = double? Function(double);

/// To get epoch
typedef GetEpochFromX = int? Function(double);

/// To get quote
typedef GetQuoteFromY = double? Function(double);

/// To get overlay/bottom series
typedef GetSeriesList = List<Series>? Function();

/// To get overlay/bottom configs
typedef GetConfigsList = List<AddOnConfig>? Function();

/// Toggles a horizontal scroll block
typedef ToggleXScrollBlock = Function({required bool isXScrollBlocked});

/// Toggles data fit mode
typedef ToggleDataFitMode = Function({required bool enableDataFit});

/// To get msPerPx
typedef GetMsPerPx = double Function();

/// Chart widget's controller.
class ChartController {
  /// Called to scroll the current display chart to last tick.
  OnScrollToLastTick? onScrollToLastTick;

  /// Called to complete the current tick animation immediately.
  /// Used when resuming from background to skip stale animations.
  OnCompleteTickAnimation? onCompleteTickAnimation;

  /// Called to scale the chart
  OnScale? onScale;

  /// Called to scroll the chart
  OnScroll? onScroll;

  /// Called to toggle a horizontal scroll block
  ToggleXScrollBlock? toggleXScrollBlock;

  /// Called to toggle data fit mode
  ToggleDataFitMode? toggleDataFitMode;

  /// Called to get X position from epoch
  GetXFromEpoch? getXFromEpoch;

  /// Called to get Y position from quote
  GetYFromQuote? getYFromQuote;

  /// Called to get epoch from x position
  GetEpochFromX? getEpochFromX;

  /// Called to get quote from y position
  GetQuoteFromY? getQuoteFromY;

  /// Called to get overlay and bottom series
  GetSeriesList? getSeriesList;

  /// Called to get overlay and bottom configs
  GetConfigsList? getConfigsList;

  /// Called to get msPerPx
  GetMsPerPx? getMsPerPx;

  /// Scroll chart visible area to the newest data.
  void scrollToLastTick({bool animate = false}) =>
      onScrollToLastTick?.call(animate: animate);

  /// Scales the chart.
  double? scale(double scale) => onScale?.call(scale);

  /// Scroll chart visible area.
  void scroll(double pxShift) => onScroll?.call(pxShift);
}
