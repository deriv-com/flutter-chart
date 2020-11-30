import 'indicator_config.dart';

/// Holds indicators that were added to the [ChartPackage] during runtime.
class IndicatorsRepository {
  /// Initializes
  IndicatorsRepository() : _indicators = <String, IndicatorConfig>{};

  final Map<String, IndicatorConfig> _indicators;

  /// Gets the indicators
  Map<String, IndicatorConfig> get indicators => _indicators;

  /// Whether this indicator for the give [key] is added to the chart
  bool isIndicatorActive(String key) => _indicators[key] != null;

  /// Gets the indicator for the given [key]
  IndicatorConfig getIndicator(String key) => _indicators[key];
}
