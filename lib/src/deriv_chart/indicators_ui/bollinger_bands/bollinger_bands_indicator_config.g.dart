// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bollinger_bands_indicator_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BollingerBandsIndicatorConfig _$BollingerBandsIndicatorConfigFromJson(
    Map<String, dynamic> json) {
  return BollingerBandsIndicatorConfig(
    period: json['period'] as int,
    fieldType: json['fieldType'] as String,
    standardDeviation: (json['standardDeviation'] as num)?.toDouble(),
  );
}

Map<String, dynamic> _$BollingerBandsIndicatorConfigToJson(
        BollingerBandsIndicatorConfig instance) =>
    <String, dynamic>{
      'period': instance.period,
      'fieldType': instance.fieldType,
      'standardDeviation': instance.standardDeviation,
    };
