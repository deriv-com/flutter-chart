// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ma_env_indicator_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MAEnvIndicatorConfig _$MAEnvIndicatorConfigFromJson(
        Map<String, dynamic> json) =>
    MAEnvIndicatorConfig(
      period: json['period'] as int? ?? 50,
      movingAverageType: $enumDecodeNullable(
              _$MovingAverageTypeEnumMap, json['movingAverageType']) ??
          MovingAverageType.simple,
      fieldType: json['fieldType'] as String? ?? 'close',
      shift: (json['shift'] as num?)?.toDouble() ?? 5,
      shiftType: $enumDecodeNullable(_$ShiftTypeEnumMap, json['shiftType']) ??
          ShiftType.percent,
    );

Map<String, dynamic> _$MAEnvIndicatorConfigToJson(
        MAEnvIndicatorConfig instance) =>
    <String, dynamic>{
      'period': instance.period,
      'movingAverageType':
          _$MovingAverageTypeEnumMap[instance.movingAverageType]!,
      'fieldType': instance.fieldType,
      'shiftType': _$ShiftTypeEnumMap[instance.shiftType]!,
      'shift': instance.shift,
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

const _$ShiftTypeEnumMap = {
  ShiftType.percent: 'percent',
  ShiftType.point: 'point',
};
