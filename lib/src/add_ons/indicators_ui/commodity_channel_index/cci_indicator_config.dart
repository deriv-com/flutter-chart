import 'package:deriv_chart/src/add_ons/indicators_ui/oscillator_lines/oscillator_lines_config.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/indicators_series/cci_series.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/indicators_series/models/cci_options.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/series.dart';
import 'package:deriv_chart/src/models/indicator_input.dart';
import 'package:deriv_chart/src/theme/painting_styles/line_style.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

import '../callbacks.dart';
import '../indicator_config.dart';
import '../indicator_item.dart';
import 'cci_indicator_item.dart';

part 'cci_indicator_config.g.dart';

/// Commodity Channel Index Indicator configurations.
@JsonSerializable()
class CCIIndicatorConfig extends IndicatorConfig {
  /// Initializes.
  const CCIIndicatorConfig({
    this.period = 20,
    this.oscillatorLinesConfig = const OscillatorLinesConfig(
      overboughtValue: 100,
      oversoldValue: -100,
    ),
    this.showZones = true,
    this.lineStyle = const LineStyle(color: Colors.white),
    int pipSize = 4,
    bool showLastIndicator = false,
    String? title,
  }) : super(
          isOverlay: false,
          pipSize: pipSize,
          showLastIndicator: showLastIndicator,
          title: title ?? CCIIndicatorConfig.name,
        );

  /// Initializes from JSON.
  factory CCIIndicatorConfig.fromJson(Map<String, dynamic> json) =>
      _$CCIIndicatorConfigFromJson(json);

  /// Unique name for this indicator.
  static const String name = 'commodity_channel_index';

  @override
  Map<String, dynamic> toJson() => _$CCIIndicatorConfigToJson(this)
    ..putIfAbsent(IndicatorConfig.nameKey, () => name);

  /// The period to calculate the average gain and loss.
  final int period;

  /// The config of overbought/sold.
  final OscillatorLinesConfig oscillatorLinesConfig;

  /// The CCI line style.
  final LineStyle lineStyle;

  /// Whether to paint overbought/sold zones fill.
  final bool showZones;

  @override
  Series getSeries(IndicatorInput indicatorInput) => CCISeries(
        indicatorInput,
        CCIOptions(period),
        overboughtValue: oscillatorLinesConfig.overboughtValue,
        oversoldValue: oscillatorLinesConfig.oversoldValue,
        overboughtLineStyle: oscillatorLinesConfig.overboughtStyle,
        oversoldLineStyle: oscillatorLinesConfig.oversoldStyle,
        showZones: showZones,
        cciLineStyle: lineStyle,
        showLastIndicator: showLastIndicator,
      );

  @override
  IndicatorItem getItem(
    UpdateIndicator updateIndicator,
    VoidCallback deleteIndicator,
  ) =>
      CCIIndicatorItem(
        config: this,
        updateIndicator: updateIndicator,
        deleteIndicator: deleteIndicator,
      );
}
