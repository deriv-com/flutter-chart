import 'package:js/js.dart';

/// JS Interop
@JS('window.jsInterop')
class JsInterop {
  /// postMessage
  external static void postMessage(dynamic object);

  /// Called when the chart has loaded
  external static void onChartLoad();

  /// Called when visible area is change
  external static void onVisibleAreaChanged(int leftEpoch, int rightEpoch);

  /// Called when visible quote area is change
  external static void onQuoteAreaChanged(double topQuote, double bottomQuote);
}
