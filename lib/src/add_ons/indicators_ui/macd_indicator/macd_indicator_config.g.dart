// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'macd_indicator_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MACDIndicatorConfig _$MACDIndicatorConfigFromJson(Map<String, dynamic> json) {
  return MACDIndicatorConfig(
    fastMAPeriod: json['fastMAPeriod'] as int,
    slowMAPeriod: json['slowMAPeriod'] as int,
    signalPeriod: json['signalPeriod'] as int,
  );
}

Map<String, dynamic> _$MACDIndicatorConfigToJson(
        MACDIndicatorConfig instance) =>
    <String, dynamic>{
      'fastMAPeriod': instance.fastMAPeriod,
      'slowMAPeriod': instance.slowMAPeriod,
      'signalPeriod': instance.signalPeriod,
    };
