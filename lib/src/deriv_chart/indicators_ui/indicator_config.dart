import 'callbacks.dart';

/// Indicator config
abstract class IndicatorConfig {
  /// Initializes
  const IndicatorConfig(this.builder);

  /// Indicator series builder
  final IndicatorBuilder builder;
}
