import 'callbacks.dart';

/// Indicator config
abstract class IndicatorConfig {
  /// Initializes
  IndicatorConfig(this.builder);

  /// Indicator series builder
  final IndicatorBuilder builder;
}
