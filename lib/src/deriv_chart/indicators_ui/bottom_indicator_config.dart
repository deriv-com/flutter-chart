import 'package:deriv_chart/src/deriv_chart/indicators_ui/indicator_config.dart';
import 'package:flutter/material.dart';

/// Bottom Indicators config
@immutable
abstract class BottomIndicatorConfig extends IndicatorConfig {
  /// Initializes
  const BottomIndicatorConfig({this.hasZeroLine = false})
      : super();

  /// Whether the indicator needs to have horizontal zero line .
  /// Default is set to `false`.
  final bool hasZeroLine;
}
