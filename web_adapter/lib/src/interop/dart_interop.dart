import 'dart:js';

import 'dart:html' as html;
import 'dart:js_util';

import 'package:deriv_chart/deriv_chart.dart';
import 'package:web_adapter/src/models/chart_config.dart';

/// Refactor the code later with JSExport once the below issue is resolved.
/// https://github.com/dart-lang/sdk/issues/50721

/// Initialize
void initDartInterop(
    ChartConfigModel model, ChartController controller, Function listen) {
  final JsObject dartInterop = JsObject(context['Object']);
  setProperty(dartInterop, 'postMessage', allowInterop(listen));
  setProperty(dartInterop, 'config', _exposeConfig(model));
  setProperty(dartInterop, 'controller', _exposeController(controller));
  setProperty(html.window, 'flutterChart', dartInterop);
}

JsObject _exposeController(ChartController controller) {
  final JsObject jsObject = JsObject(context['Object']);

  setProperty(jsObject, 'getXFromEpoch',
      allowInterop((int epoch) => controller.getXFromEpoch?.call(epoch)));

  setProperty(jsObject, 'getYFromQuote',
      allowInterop((double quote) => controller.getYFromQuote?.call(quote)));

  setProperty(jsObject, 'getEpochFromX',
      allowInterop((double x) => controller.getEpochFromX?.call(x)));

  setProperty(jsObject, 'getQuoteFromY',
      allowInterop((double y) => controller.getQuoteFromY?.call(y)));

  return jsObject;
}

JsObject _exposeConfig(ChartConfigModel model) {
  final JsObject chartConfig = JsObject(context['Object']);

  setProperty(
    chartConfig,
    'updateTheme',
    allowInterop(model.updateTheme),
  );

  setProperty(
    chartConfig,
    'addOrUpdateIndicator',
    allowInterop(model.addOrUpdateIndicator),
  );

  setProperty(
    chartConfig,
    'removeIndicator',
    allowInterop(model.removeIndicator),
  );

  return chartConfig;
}
