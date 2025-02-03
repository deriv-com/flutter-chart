import 'package:deriv_chart/src/add_ons/indicators_ui/indicator_config.dart';
import 'package:deriv_chart/src/add_ons/indicators_ui/oscillator_lines/oscillator_lines_config.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/indicators_series/models/bop_options.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/indicators_series/bop_series.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/series.dart';
import 'package:deriv_chart/src/models/indicator_input.dart';
import 'package:deriv_chart/src/theme/painting_styles/line_style.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

import '../callbacks.dart';
import '../indicator_item.dart';
import 'bop_indicator_item.dart';

part 'bop_indicator_config.g.dart';

/// Balance of Power (BOP) Indicator configurations.
@JsonSerializable()
class BOPIndicatorConfig extends IndicatorConfig {
  /// Initializes
  const BOPIndicatorConfig({
    this.period = 14,
    this.oscillatorLinesConfig = const OscillatorLinesConfig(
      overboughtValue: 0.8,
      oversoldValue: -0.8,
    ),
    this.lineStyle = const LineStyle(color: Colors.blue),
    this.pinLabels = false,
    this.showZones = true,
    int pipSize = 4,
    bool showLastIndicator = false,
    String? title,
    super.number,
  }) : super(
          isOverlay: false,
          pipSize: pipSize,
          showLastIndicator: showLastIndicator,
          title: title ?? BOPIndicatorConfig.name,
        );

  /// Initializes from JSON.
  factory BOPIndicatorConfig.fromJson(Map<String, dynamic> json) =>
      _$BOPIndicatorConfigFromJson(json);

  /// Unique name for this indicator.
  static const String name = 'BOP';

  @override
  Map<String, dynamic> toJson() => _$BOPIndicatorConfigToJson(this)
    ..putIfAbsent(IndicatorConfig.nameKey, () => name);

  /// The period to calculate BOP.
  final int period;

  /// The BOP line style.
  final LineStyle lineStyle;

  /// Whether to always show labels or not.
  /// Default is set to `false`.
  final bool pinLabels;

  /// Config of oscillator lines.
  final OscillatorLinesConfig oscillatorLinesConfig;

  /// Whether to paint [oscillatorLinesConfig] zones fill.
  final bool showZones;

  /// Indicator config summary
  @override
  String get configSummary => '$period';

  @override
  String get title => 'Balance of Power (BOP)';

  @override
  String get shortTitle => 'BOP';

  @override
  Series getSeries(IndicatorInput indicatorInput) => BOPSeries(
        indicatorInput,
        bopOptions: BOPOptions(
          period: period,
          lineStyle: lineStyle,
          showLastIndicator: showLastIndicator,
          pipSize: pipSize,
        ),
      );

  @override
  IndicatorItem getItem(
    UpdateIndicator updateIndicator,
    VoidCallback deleteIndicator,
  ) =>
      BOPIndicatorItem(
        config: this,
        updateIndicator: updateIndicator,
        deleteIndicator: deleteIndicator,
      );

  @override
  BOPIndicatorConfig copyWith({
    int? period,
    LineStyle? lineStyle,
    bool? pinLabels,
    OscillatorLinesConfig? oscillatorLinesConfig,
    bool? showZones,
    int? pipSize,
    bool? showLastIndicator,
    String? title,
    int? number,
  }) =>
      BOPIndicatorConfig(
        period: period ?? this.period,
        lineStyle: lineStyle ?? this.lineStyle,
        pinLabels: pinLabels ?? this.pinLabels,
        oscillatorLinesConfig:
            oscillatorLinesConfig ?? this.oscillatorLinesConfig,
        showZones: showZones ?? this.showZones,
        pipSize: pipSize ?? this.pipSize,
        showLastIndicator: showLastIndicator ?? this.showLastIndicator,
        title: title ?? this.title,
        number: number ?? this.number,
      );
}
