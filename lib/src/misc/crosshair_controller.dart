import 'types.dart';

// ignore_for_file: avoid_catches_without_on_clauses

/// CrosshairController
class CrosshairController {
  /// Called to get X position from epoch
  GetXFromEpoch? getXFromEpoch_;

  /// Called to get Y position from quote
  GetYFromQuote? getYFromQuote_;

  /// Called to get epoch from x position
  GetEpochFromX? getEpochFromX_;

  /// Called to get quote from y position
  GetQuoteFromY? getQuoteFromY_;

  /// Called to get epoch from x position
  int? getEpochFromX(double x) {
    try {
      return getEpochFromX_?.call(x);
    } catch (_) {
      return null;
    }
  }

  /// Called to get quote from y position
  double? getQuoteFromY(double y) {
    try {
      return getQuoteFromY_?.call(y);
    } catch (_) {
      return null;
    }
  }

  /// Called to get X position from epoch
  double? getXFromEpoch(int epoch) {
    try {
      return getXFromEpoch_?.call(epoch);
    } catch (_) {
      return null;
    }
  }

  /// Called to get Y position from quote
  double? getYFromQuote(double quote) {
    try {
      return getYFromQuote_?.call(quote);
    } catch (_) {
      return null;
    }
  }
}
