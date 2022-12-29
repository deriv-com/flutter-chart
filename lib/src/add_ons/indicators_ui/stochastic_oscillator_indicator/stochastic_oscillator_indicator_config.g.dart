// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stochastic_oscillator_indicator_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StochasticOscillatorIndicatorConfig
    _$StochasticOscillatorIndicatorConfigFromJson(Map<String, dynamic> json) {
  return StochasticOscillatorIndicatorConfig(
    id: json['id'] as String?,
    period: json['period'] as int,
    fieldType: json['fieldType'] as String,
    overBoughtPrice: (json['overBoughtPrice'] as num).toDouble(),
    overSoldPrice: (json['overSoldPrice'] as num).toDouble(),
    showZones: json['showZones'] as bool,
    isSmooth: json['isSmooth'] as bool,
    lineStyle: LineStyle.fromJson(json['lineStyle'] as Map<String, dynamic>),
    oscillatorLinesConfig: OscillatorLinesConfig.fromJson(
        json['oscillatorLinesConfig'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$StochasticOscillatorIndicatorConfigToJson(
        StochasticOscillatorIndicatorConfig instance) =>
    <String, dynamic>{
      'id': instance.id,
      'period': instance.period,
      'overBoughtPrice': instance.overBoughtPrice,
      'overSoldPrice': instance.overSoldPrice,
      'lineStyle': instance.lineStyle,
      'oscillatorLinesConfig': instance.oscillatorLinesConfig,
      'fieldType': instance.fieldType,
      'isSmooth': instance.isSmooth,
      'showZones': instance.showZones,
    };
