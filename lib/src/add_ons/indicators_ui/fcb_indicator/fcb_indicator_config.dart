import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/indicators_series/fcb_series.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/series.dart';
import 'package:deriv_chart/src/deriv_chart/chart/helpers/color_converter.dart';
import 'package:deriv_chart/src/models/indicator_input.dart';
import 'package:deriv_chart/src/theme/painting_styles/line_style.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

import '../callbacks.dart';
import '../indicator_config.dart';
import '../indicator_item.dart';
import 'fcb_indicator_item.dart';

part 'fcb_indicator_config.g.dart';

/// Fractal Chaos Band Indicator Config
@JsonSerializable()
@ColorConverter()
class FractalChaosBandIndicatorConfig extends IndicatorConfig {
  /// Initializes
  const FractalChaosBandIndicatorConfig({
    this.highLineStyle = const LineStyle(color: Colors.blue),
    this.lowLineStyle = const LineStyle(color: Colors.blue),
    this.fillColor = Colors.white12,
    this.showChannelFill = false,
    bool showLastIndicator = false,
    String? title,
    super.number,
    super.pipSize,
  }) : super(
          showLastIndicator: showLastIndicator,
          title: title ?? FractalChaosBandIndicatorConfig.name,
        );

  /// Initializes from JSON.
  factory FractalChaosBandIndicatorConfig.fromJson(Map<String, dynamic> json) =>
      _$FractalChaosBandIndicatorConfigFromJson(json);

  /// Upper line style.
  final LineStyle highLineStyle;

  /// Lower line style.
  final LineStyle lowLineStyle;

  /// Fill color.
  final Color fillColor;

  /// if it's true the channel between two lines will be filled
  final bool showChannelFill;

  @override
  Series getSeries(IndicatorInput indicatorInput) => FractalChaosBandSeries(
        indicatorInput,
        config: this,
      );

  /// Unique name for this indicator.
  static const String name = 'fcb';

  @override
  Map<String, dynamic> toJson() => _$FractalChaosBandIndicatorConfigToJson(this)
    ..putIfAbsent(IndicatorConfig.nameKey, () => name);

  @override
  IndicatorItem getItem(
    UpdateIndicator updateIndicator,
    VoidCallback deleteIndicator,
  ) =>
      FractalChaosBandIndicatorItem(
        config: this,
        updateIndicator: updateIndicator,
        deleteIndicator: deleteIndicator,
      );

  @override
  FractalChaosBandIndicatorConfig copyWith({
    LineStyle? highLineStyle,
    LineStyle? lowLineStyle,
    Color? fillColor,
    bool? showChannelFill,
    bool? showLastIndicator,
    String? title,
    int? number,
    int? pipSize,
  }) =>
      FractalChaosBandIndicatorConfig(
        highLineStyle: highLineStyle ?? this.highLineStyle,
        lowLineStyle: lowLineStyle ?? this.lowLineStyle,
        fillColor: fillColor ?? this.fillColor,
        showChannelFill: showChannelFill ?? this.showChannelFill,
        showLastIndicator: showLastIndicator ?? this.showLastIndicator,
        title: title ?? this.title,
        number: number ?? this.number,
        pipSize: pipSize ?? this.pipSize,
      );
}
