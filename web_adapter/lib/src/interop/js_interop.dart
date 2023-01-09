// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

import 'dart:js';
import 'dart:js_util';

import 'package:js/js.dart';
import 'package:web_adapter/src/models/chart_config.dart';

/// Listen callback
typedef Listen = Function(String data);

/// Message channel
@JS('window.parent.jsInterop')
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

JsObject _initChartConfig(ChartConfigModel model) {
  final JsObject chartConfig = JsObject(context['Object']);
  setProperty(chartConfig, 'getXFromEpoch', allowInterop(model.getXFromEpoch));
  setProperty(chartConfig, 'getYFromQuote', allowInterop(model.getYFromQuote));
  setProperty(chartConfig, 'getEpochFromX', allowInterop(model.getEpochFromX));
  setProperty(chartConfig, 'getQuoteFromY', allowInterop(model.getQuoteFromY));
  setProperty(chartConfig, 'updateTheme', allowInterop(model.updateTheme));
  setProperty(chartConfig, 'addOrUpdateIndicator',
      allowInterop(model.addOrUpdateIndicator));
  setProperty(
      chartConfig, 'removeIndicator', allowInterop(model.removeIndicator));

  return chartConfig;
}

///
void initInterOp(Listen listen, ChartConfigModel chartConfigModel) {
  final JsObject dartInterop = JsObject(context['Object']);
  setProperty(dartInterop, 'postMessage', allowInterop(listen));
  setProperty(dartInterop, 'chartConfig', _initChartConfig(chartConfigModel));
  setProperty(html.window, 'dartInterop', dartInterop);
}
