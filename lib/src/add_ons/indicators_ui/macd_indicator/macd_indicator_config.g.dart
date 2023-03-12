// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'macd_indicator_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MACDIndicatorConfig _$MACDIndicatorConfigFromJson(Map<String, dynamic> json) =>
    MACDIndicatorConfig(
      fastMAPeriod: json['fastMAPeriod'] as int? ?? 12,
      slowMAPeriod: json['slowMAPeriod'] as int? ?? 26,
      signalPeriod: json['signalPeriod'] as int? ?? 9,
    );

Map<String, dynamic> _$MACDIndicatorConfigToJson(
        MACDIndicatorConfig instance) =>
    <String, dynamic>{
      'fastMAPeriod': instance.fastMAPeriod,
      'slowMAPeriod': instance.slowMAPeriod,
      'signalPeriod': instance.signalPeriod,
    };
