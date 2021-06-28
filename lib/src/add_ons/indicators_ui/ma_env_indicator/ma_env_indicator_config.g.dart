// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ma_env_indicator_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MAEnvIndicatorConfig _$MAEnvIndicatorConfigFromJson(Map<String, dynamic> json) {
  return MAEnvIndicatorConfig(
    period: json['period'] as int,
    movingAverageType:
        _$enumDecode(_$MovingAverageTypeEnumMap, json['movingAverageType']),
    fieldType: json['fieldType'] as String,
    shift: (json['shift'] as num).toDouble(),
    shiftType: _$enumDecode(_$ShiftTypeEnumMap, json['shiftType']),
  );
}

Map<String, dynamic> _$MAEnvIndicatorConfigToJson(
        MAEnvIndicatorConfig instance) =>
    <String, dynamic>{
      'period': instance.period,
      'movingAverageType':
          _$MovingAverageTypeEnumMap[instance.movingAverageType],
      'fieldType': instance.fieldType,
      'shiftType': _$ShiftTypeEnumMap[instance.shiftType],
      'shift': instance.shift,
    };

K _$enumDecode<K, V>(
  Map<K, V> enumValues,
  Object? source, {
  K? unknownValue,
}) {
  if (source == null) {
    throw ArgumentError(
      'A value must be provided. Supported values: '
      '${enumValues.values.join(', ')}',
    );
  }

  return enumValues.entries.singleWhere(
    (e) => e.value == source,
    orElse: () {
      if (unknownValue == null) {
        throw ArgumentError(
          '`$source` is not one of the supported values: '
          '${enumValues.values.join(', ')}',
        );
      }
      return MapEntry(unknownValue, enumValues.values.first);
    },
  ).key;
}

const _$MovingAverageTypeEnumMap = {
  MovingAverageType.simple: 'simple',
  MovingAverageType.exponential: 'exponential',
  MovingAverageType.weighted: 'weighted',
  MovingAverageType.hull: 'hull',
  MovingAverageType.zeroLag: 'zeroLag',
  MovingAverageType.timeSeries: 'timeSeries',
};

const _$ShiftTypeEnumMap = {
  ShiftType.percent: 'percent',
  ShiftType.point: 'point',
};
