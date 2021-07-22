// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rainbow_indicator_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RainbowIndicatorConfig _$RainbowIndicatorConfigFromJson(
    Map<String, dynamic> json) {
  return RainbowIndicatorConfig(
    period: json['period'] as int,
    movingAverageType:
        _$enumDecode(_$MovingAverageTypeEnumMap, json['movingAverageType']),
    fieldType: json['fieldType'] as String,
    bandsCount: json['bandsCount'] as int,
  );
}

Map<String, dynamic> _$RainbowIndicatorConfigToJson(
        RainbowIndicatorConfig instance) =>
    <String, dynamic>{
      'period': instance.period,
      'movingAverageType':
          _$MovingAverageTypeEnumMap[instance.movingAverageType],
      'fieldType': instance.fieldType,
      'bandsCount': instance.bandsCount,
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
  MovingAverageType.wellesWilder: 'wellesWilder',
  MovingAverageType.doubleExponential: 'doubleExponential',
  MovingAverageType.tripleExponential: 'tripleExponential',
};
