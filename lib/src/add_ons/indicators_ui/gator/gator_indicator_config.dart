import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/indicators_series/gator_series.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/indicators_series/models/alligator_options.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/series.dart';
import 'package:deriv_chart/src/models/indicator_input.dart';
import 'package:deriv_chart/src/theme/painting_styles/bar_style.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

import '../callbacks.dart';
import '../indicator_config.dart';
import '../indicator_item.dart';
import 'gator_indicator_item.dart';

part 'gator_indicator_config.g.dart';

/// Gator Indicator Config
@JsonSerializable()
class GatorIndicatorConfig extends IndicatorConfig {
  /// Initializes
  const GatorIndicatorConfig({
    this.jawPeriod = 13,
    this.teethPeriod = 8,
    this.lipsPeriod = 5,
    this.jawOffset = 8,
    this.teethOffset = 5,
    this.lipsOffset = 3,
    this.barStyle = const BarStyle(),
    int pipSize = 4,
    String? title,
    super.number,
  }) : super(
          isOverlay: false,
          pipSize: pipSize,
          title: title ?? GatorIndicatorConfig.name,
        );

  /// Initializes from JSON.
  factory GatorIndicatorConfig.fromJson(Map<String, dynamic> json) =>
      _$GatorIndicatorConfigFromJson(json);

  /// Unique name for this indicator.
  static const String name = 'gator';

  @override
  Map<String, dynamic> toJson() => _$GatorIndicatorConfigToJson(this)
    ..putIfAbsent(IndicatorConfig.nameKey, () => name);

  /// Shift to future in jaw series
  final int jawOffset;

  /// Smoothing period for jaw series
  final int jawPeriod;

  /// Shift to future in teeth series
  final int teethOffset;

  /// Smoothing period for teeth series
  final int teethPeriod;

  /// Shift to future in lips series
  final int lipsOffset;

  /// Smoothing period for lips series
  final int lipsPeriod;

  /// Histogram bar style
  final BarStyle barStyle;

  @override
  Series getSeries(IndicatorInput indicatorInput) => GatorSeries(
        indicatorInput,
        gatorConfig: this,
        gatorOptions: AlligatorOptions(
          jawPeriod: jawPeriod,
          teethPeriod: teethPeriod,
          lipsPeriod: lipsPeriod,
        ),
        barStyle: barStyle,
      );

  @override
  IndicatorItem getItem(
    UpdateIndicator updateIndicator,
    VoidCallback deleteIndicator,
  ) =>
      GatorIndicatorItem(
        config: this,
        updateIndicator: updateIndicator,
        deleteIndicator: deleteIndicator,
      );

  @override
  GatorIndicatorConfig copyWith({
    int? jawPeriod,
    int? teethPeriod,
    int? lipsPeriod,
    int? jawOffset,
    int? teethOffset,
    int? lipsOffset,
    BarStyle? barStyle,
    int? pipSize,
    String? title,
    int? number,
    bool? showLastIndicator,
  }) =>
      GatorIndicatorConfig(
        jawPeriod: jawPeriod ?? this.jawPeriod,
        teethPeriod: teethPeriod ?? this.teethPeriod,
        lipsPeriod: lipsPeriod ?? this.lipsPeriod,
        jawOffset: jawOffset ?? this.jawOffset,
        teethOffset: teethOffset ?? this.teethOffset,
        lipsOffset: lipsOffset ?? this.lipsOffset,
        barStyle: barStyle ?? this.barStyle,
        pipSize: pipSize ?? this.pipSize,
        title: title ?? this.title,
        number: number ?? this.number,
      );
}
