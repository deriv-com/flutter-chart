// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stochastic_oscillator_indicator_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StochasticOscillatorIndicatorConfig
    _$StochasticOscillatorIndicatorConfigFromJson(Map<String, dynamic> json) {
  return StochasticOscillatorIndicatorConfig(
    period: json['period'] as int,
    fieldType: json['fieldType'] as String,
    overBoughtPrice: (json['overBoughtPrice'] as num)?.toDouble(),
    overSoldPrice: (json['overSoldPrice'] as num)?.toDouble(),
    showZones: json['showZones'] as bool,
    isSmooth: json['isSmooth'] as bool,
    lineStyle: json['lineStyle'] == null
        ? null
        : LineStyle.fromJson(json['lineStyle'] as Map<String, dynamic>),
    mainHorizontalLinesStyle: json['mainHorizontalLinesStyle'] == null
        ? null
        : LineStyle.fromJson(
            json['mainHorizontalLinesStyle'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$StochasticOscillatorIndicatorConfigToJson(
        StochasticOscillatorIndicatorConfig instance) =>
    <String, dynamic>{
      'period': instance.period,
      'overBoughtPrice': instance.overBoughtPrice,
      'overSoldPrice': instance.overSoldPrice,
      'lineStyle': instance.lineStyle,
      'mainHorizontalLinesStyle': instance.mainHorizontalLinesStyle,
      'fieldType': instance.fieldType,
      'isSmooth': instance.isSmooth,
      'showZones': instance.showZones,
    };
