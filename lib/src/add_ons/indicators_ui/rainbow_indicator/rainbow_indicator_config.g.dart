// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rainbow_indicator_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RainbowIndicatorConfig _$RainbowIndicatorConfigFromJson(
    Map<String, dynamic> json) {
  return RainbowIndicatorConfig(
    period: json['period'] as int,
    movingAverageType: _$enumDecodeNullable(
        _$MovingAverageTypeEnumMap, json['movingAverageType']),
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

T _$enumDecode<T>(
  Map<T, dynamic> enumValues,
  dynamic source, {
  T unknownValue,
}) {
  if (source == null) {
    throw ArgumentError('A value must be provided. Supported values: '
        '${enumValues.values.join(', ')}');
  }

  final value = enumValues.entries
      .singleWhere((e) => e.value == source, orElse: () => null)
      ?.key;

  if (value == null && unknownValue == null) {
    throw ArgumentError('`$source` is not one of the supported values: '
        '${enumValues.values.join(', ')}');
  }
  return value ?? unknownValue;
}

T _$enumDecodeNullable<T>(
  Map<T, dynamic> enumValues,
  dynamic source, {
  T unknownValue,
}) {
  if (source == null) {
    return null;
  }
  return _$enumDecode<T>(enumValues, source, unknownValue: unknownValue);
}

const _$MovingAverageTypeEnumMap = {
  MovingAverageType.simple: 'simple',
  MovingAverageType.exponential: 'exponential',
  MovingAverageType.weighted: 'weighted',
  MovingAverageType.hull: 'hull',
  MovingAverageType.zeroLag: 'zeroLag',
  MovingAverageType.twoExponential: 'twoExponential',
  MovingAverageType.threeExponential: 'threeExponential',
};
