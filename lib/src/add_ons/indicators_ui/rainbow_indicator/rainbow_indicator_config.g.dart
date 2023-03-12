// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rainbow_indicator_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RainbowIndicatorConfig _$RainbowIndicatorConfigFromJson(
        Map<String, dynamic> json) =>
    RainbowIndicatorConfig(
      period: json['period'] as int? ?? 50,
      movingAverageType: $enumDecodeNullable(
              _$MovingAverageTypeEnumMap, json['movingAverageType']) ??
          MovingAverageType.simple,
      fieldType: json['fieldType'] as String? ?? 'close',
      bandsCount: json['bandsCount'] as int? ?? 10,
    );

Map<String, dynamic> _$RainbowIndicatorConfigToJson(
        RainbowIndicatorConfig instance) =>
    <String, dynamic>{
      'period': instance.period,
      'movingAverageType':
          _$MovingAverageTypeEnumMap[instance.movingAverageType]!,
      'fieldType': instance.fieldType,
      'bandsCount': instance.bandsCount,
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
