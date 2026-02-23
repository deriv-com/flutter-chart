/// Lite public entry point for consumers that manage their own
/// [indicatorsRepo] and [drawingToolsRepo].
///
/// Exports the same surface as [deriv_chart.dart] but uses
/// [deriv_chart_lite.dart] under the hood, which omits the built-in indicator/
/// drawing-tool dialog imports and shared_preferences. This keeps the Flutter
/// web bundle smaller by allowing dart2js to tree-shake those dependencies.
///
/// Use [package:deriv_chart/deriv_chart.dart] instead if you need the built-in
/// dialog UI.
library core_chart;

export 'package:deriv_chart/src/deriv_chart/deriv_chart_lite.dart';

// Re-export everything else from the full library except DerivChart itself.
export 'package:deriv_chart/deriv_chart.dart'
    hide DerivChart;
