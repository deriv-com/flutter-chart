// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stochastic_oscillator_indicator_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StochasticOscillatorIndicatorConfig
    _$StochasticOscillatorIndicatorConfigFromJson(Map<String, dynamic> json) =>
        StochasticOscillatorIndicatorConfig(
          period: json['period'] as int? ?? 14,
          fieldType: json['fieldType'] as String? ?? 'close',
          overBoughtPrice: (json['overBoughtPrice'] as num?)?.toDouble() ?? 80,
          overSoldPrice: (json['overSoldPrice'] as num?)?.toDouble() ?? 20,
          showZones: json['showZones'] as bool? ?? false,
          isSmooth: json['isSmooth'] as bool? ?? true,
          lineStyle: json['lineStyle'] == null
              ? const LineStyle(color: Colors.white)
              : LineStyle.fromJson(json['lineStyle'] as Map<String, dynamic>),
          oscillatorLinesConfig: json['oscillatorLinesConfig'] == null
              ? const OscillatorLinesConfig(
                  overboughtValue: 80, oversoldValue: 20)
              : OscillatorLinesConfig.fromJson(
                  json['oscillatorLinesConfig'] as Map<String, dynamic>),
          fastLineStyle: json['fastLineStyle'] == null
              ? const LineStyle(color: Colors.white)
              : LineStyle.fromJson(
                  json['fastLineStyle'] as Map<String, dynamic>),
          slowLineStyle: json['slowLineStyle'] == null
              ? const LineStyle(color: Colors.red)
              : LineStyle.fromJson(
                  json['slowLineStyle'] as Map<String, dynamic>),
        );

Map<String, dynamic> _$StochasticOscillatorIndicatorConfigToJson(
        StochasticOscillatorIndicatorConfig instance) =>
    <String, dynamic>{
      'period': instance.period,
      'overBoughtPrice': instance.overBoughtPrice,
      'overSoldPrice': instance.overSoldPrice,
      'lineStyle': instance.lineStyle,
      'oscillatorLinesConfig': instance.oscillatorLinesConfig,
      'fieldType': instance.fieldType,
      'isSmooth': instance.isSmooth,
      'showZones': instance.showZones,
      'fastLineStyle': instance.fastLineStyle,
      'slowLineStyle': instance.slowLineStyle,
    };
