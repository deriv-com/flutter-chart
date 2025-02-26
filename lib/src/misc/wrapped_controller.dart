import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/misc/crosshair_controller.dart';

// ignore_for_file: avoid_catches_without_on_clauses

/// WrappedController
/// To prevent controller exceptions
class WrappedController {
  /// ChartController
  final ChartController _chartController = ChartController();

  final CrosshairController _crosshairController = CrosshairController();

  /// Gets chart controller
  ChartController getChartController() => _chartController;

  /// Gets crosshair controller
  CrosshairController getCrosshairController() => _crosshairController;

  /// Scales the chart.
  double? scale(double scale) {
    try {
      return _chartController.onScale?.call(scale);
    } catch (_) {
      return null;
    }
  }

  /// Scroll chart visible area.
  void scroll(double pxShift) {
    try {
      _chartController.onScroll?.call(pxShift);
    } catch (_) {
      return;
    }
  }

  /// Scroll chart visible area to the newest data.
  void scrollToLastTick() {
    try {
      _chartController.scrollToLastTick();
    } catch (_) {
      return;
    }
  }

  /// Block/Unblock horizontal scroll on the chart.
  // ignore: avoid_positional_boolean_parameters
  void toggleXScrollBlock(bool isXScrollBlocked) {
    try {
      _chartController.toggleXScrollBlock
          ?.call(isXScrollBlocked: isXScrollBlocked);
    } catch (_) {
      return;
    }
  }

  /// Scroll chart visible area to the newest data.
  // ignore: avoid_positional_boolean_parameters
  void toggleDataFitMode(bool dataFitMode) {
    try {
      _chartController.toggleDataFitMode?.call(enableDataFit: dataFitMode);
    } catch (_) {
      return;
    }
  }

  /// Called to get epoch from x position
  int? getEpochFromX(double x) {
    try {
      return _chartController.getEpochFromX?.call(x);
    } catch (_) {
      return null;
    }
  }

  /// Called to get quote from y position
  double? getQuoteFromY(double y) {
    try {
      return _chartController.getQuoteFromY?.call(y);
    } catch (_) {
      return null;
    }
  }

  /// Called to get X position from epoch
  double? getXFromEpoch(int epoch) {
    try {
      return _chartController.getXFromEpoch?.call(epoch);
    } catch (_) {
      return null;
    }
  }

  /// Called to get Y position from quote
  double? getYFromQuote(double quote) {
    try {
      return _chartController.getYFromQuote?.call(quote);
    } catch (_) {
      return null;
    }
  }

  /// Called to get msPerPx
  double? getMsPerPx() {
    try {
      return _chartController.getMsPerPx?.call();
    } catch (_) {
      return null;
    }
  }

  /// Called to get List of Series
  List<Series>? getSeriesList() {
    try {
      return _chartController.getSeriesList?.call();
    } catch (_) {
      return null;
    }
  }

  /// Called to get List of Configs
  List<AddOnConfig>? getConfigsList() {
    try {
      return _chartController.getConfigsList?.call();
    } catch (_) {
      return null;
    }
  }
}
