import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/add_ons/indicators_ui/oscillator_lines/oscillator_lines_config.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/indicators_series/models/rsi_options.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/indicators_series/rsi_series.dart';
import 'package:deriv_chart/src/models/indicator_input.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

import '../callbacks.dart';
import '../indicator_config.dart';
import '../indicator_item.dart';
import 'rsi_indicator_item.dart';

part 'rsi_indicator_config.g.dart';

/// RSI Indicator configurations.
@JsonSerializable()
class RSIIndicatorConfig extends IndicatorConfig {
  /// Initializes
  const RSIIndicatorConfig({
    this.period = 14,
    this.fieldType = 'close',
    this.oscillatorLinesConfig = const OscillatorLinesConfig(
      overboughtValue: 80,
      oversoldValue: 20,
    ),
    this.lineStyle = const LineStyle(color: Colors.white),
    this.pinLabels = false,
    this.showZones = true,
    String? title,
  }) : super(isOverlay: false, title: title ?? RSIIndicatorConfig.name);

  /// Initializes from JSON.
  factory RSIIndicatorConfig.fromJson(Map<String, dynamic> json) =>
      _$RSIIndicatorConfigFromJson(json);

  /// Unique name for this indicator.
  static const String name = 'RSI';

  @override
  Map<String, dynamic> toJson() => _$RSIIndicatorConfigToJson(this)
    ..putIfAbsent(IndicatorConfig.nameKey, () => name);

  /// The period to calculate the average gain and loss.
  final int period;

  /// The RSI line style.
  final LineStyle lineStyle;

  /// Field type
  final String fieldType;

  /// Wether to always show labels or not.
  /// Default is set to `false`.
  final bool pinLabels;

  /// Config of overbought and oversold.
  final OscillatorLinesConfig oscillatorLinesConfig;

  /// Whether to paint [oscillatorLinesConfig] zones fill.
  final bool showZones;

  @override
  Series getSeries(IndicatorInput indicatorInput) => RSISeries.fromIndicator(
        IndicatorConfig.supportedFieldTypes[fieldType]!(indicatorInput),
        this,
        rsiOptions: RSIOptions(period: period),
        showZones: showZones,
      );

  @override
  IndicatorItem getItem(
    UpdateIndicator updateIndicator,
    VoidCallback deleteIndicator,
  ) =>
      RSIIndicatorItem(
        config: this,
        updateIndicator: updateIndicator,
        deleteIndicator: deleteIndicator,
      );
}
