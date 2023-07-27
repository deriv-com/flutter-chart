import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/indicators_series/ma_series.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/indicators_series/models/indicator_options.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/indicators_series/models/smi_options.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/indicators_series/smi_series.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/series.dart';
import 'package:deriv_chart/src/models/indicator_input.dart';
import 'package:deriv_chart/src/theme/painting_styles/line_style.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

import '../callbacks.dart';
import '../indicator_config.dart';
import '../indicator_item.dart';
import 'smi_indicator_item.dart';

part 'smi_indicator_config.g.dart';

/// SMI Indicator configurations.
@JsonSerializable()
class SMIIndicatorConfig extends IndicatorConfig {
  /// Initializes
  const SMIIndicatorConfig({
    this.period = 10,
    this.smoothingPeriod = 3,
    this.doubleSmoothingPeriod = 3,
    this.overboughtValue = 40,
    this.oversoldValue = -40,
    this.signalPeriod = 10,
    this.maType = MovingAverageType.exponential,
    this.showZones = true,
    this.lineStyle,
    this.signalLineStyle,
    int pipSize = 4,
    bool showLastIndicator = false,
    String? title,
  }) : super(
          isOverlay: false,
          pipSize: pipSize,
          showLastIndicator: showLastIndicator,
          title: title ?? SMIIndicatorConfig.name,
        );

  /// Initializes from JSON.
  factory SMIIndicatorConfig.fromJson(Map<String, dynamic> json) =>
      _$SMIIndicatorConfigFromJson(json);

  /// Unique name for this indicator.
  static const String name = 'SMI';

  @override
  Map<String, dynamic> toJson() => _$SMIIndicatorConfigToJson(this)
    ..putIfAbsent(IndicatorConfig.nameKey, () => name);

  /// The period to calculate the average gain and loss.
  final int period;

  /// Smoothing period.
  final int smoothingPeriod;

  /// double smoothing period.
  final int doubleSmoothingPeriod;

  /// The period of SMI signal (D%).
  final int signalPeriod;

  /// /// The Moving Average type of SMI signal (D%).
  final MovingAverageType maType;

  /// Overbought value.
  final double overboughtValue;

  /// Oversold value.
  final double oversoldValue;

  /// Whether to show zones (intersection between indicator and overbought/sold).
  final bool showZones;

  ///  Line style.
  final LineStyle? lineStyle;

  /// Signal line style.
  final LineStyle? signalLineStyle;

  @override
  Series getSeries(IndicatorInput indicatorInput) => SMISeries(
        indicatorInput,
        smiOptions: SMIOptions(
          period: period,
          smoothingPeriod: smoothingPeriod,
          doubleSmoothingPeriod: doubleSmoothingPeriod,
          signalOptions: MAOptions(period: signalPeriod, type: maType),
          lineStyle: lineStyle,
          signalLineStyle: signalLineStyle,
          showLastIndicator: showLastIndicator,
          pipSize: pipSize,
        ),
        overboughtValue: overboughtValue,
        oversoldValue: oversoldValue,
      );

  @override
  IndicatorItem getItem(
    UpdateIndicator updateIndicator,
    VoidCallback deleteIndicator,
  ) =>
      SMIIndicatorItem(
        config: this,
        updateIndicator: updateIndicator,
        deleteIndicator: deleteIndicator,
      );
}
