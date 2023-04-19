// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bollinger_bands_indicator_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BollingerBandsIndicatorConfig _$BollingerBandsIndicatorConfigFromJson(
        Map<String, dynamic> json) =>
    BollingerBandsIndicatorConfig(
      period: json['period'] as int? ?? 50,
      movingAverageType: $enumDecodeNullable(
              _$MovingAverageTypeEnumMap, json['movingAverageType']) ??
          MovingAverageType.simple,
      fieldType: json['fieldType'] as String? ?? 'close',
      standardDeviation: (json['standardDeviation'] as num?)?.toDouble() ?? 2,
      upperLineStyle: json['upperLineStyle'] == null
          ? const LineStyle(color: Colors.white)
          : LineStyle.fromJson(json['upperLineStyle'] as Map<String, dynamic>),
      middleLineStyle: json['middleLineStyle'] == null
          ? const LineStyle(color: Colors.white)
          : LineStyle.fromJson(json['middleLineStyle'] as Map<String, dynamic>),
      lowerLineStyle: json['lowerLineStyle'] == null
          ? const LineStyle(color: Colors.white)
          : LineStyle.fromJson(json['lowerLineStyle'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$BollingerBandsIndicatorConfigToJson(
        BollingerBandsIndicatorConfig instance) =>
    <String, dynamic>{
      'period': instance.period,
      'movingAverageType':
          _$MovingAverageTypeEnumMap[instance.movingAverageType]!,
      'fieldType': instance.fieldType,
      'standardDeviation': instance.standardDeviation,
      'upperLineStyle': instance.upperLineStyle,
      'middleLineStyle': instance.middleLineStyle,
      'lowerLineStyle': instance.lowerLineStyle,
    };

const _$MovingAverageTypeEnumMap = {
  MovingAverageType.simple: 'simple',
  MovingAverageType.exponential: 'exponential',
  MovingAverageType.weighted: 'weighted',
  MovingAverageType.hull: 'hull',
  MovingAverageType.zeroLag: 'zeroLag',
  MovingAverageType.timeSeries: 'timeSeries',
  MovingAverageType.wellesWilder: 'wellesWilder',
  MovingAverageType.variable: 'variable',
  MovingAverageType.triangular: 'triangular',
  MovingAverageType.doubleExponential: 'doubleExponential',
  MovingAverageType.tripleExponential: 'tripleExponential',
};
