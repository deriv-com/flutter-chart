// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ma_indicator_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MAIndicatorConfig _$MAIndicatorConfigFromJson(Map<String, dynamic> json) {
  return MAIndicatorConfig(
    period: json['period'] as int,
    movingAverageType: _$enumDecodeNullable(
        _$MovingAverageTypeEnumMap, json['movingAverageType']),
    fieldType: json['fieldType'] as String,
    lineStyle: json['lineStyle'] == null
        ? null
        : LineStyle.fromJson(json['lineStyle'] as Map<String, dynamic>),
    offset: json['offset'] as int,
  );
}

Map<String, dynamic> _$MAIndicatorConfigToJson(MAIndicatorConfig instance) =>
    <String, dynamic>{
      'period': instance.period,
      'movingAverageType':
          _$MovingAverageTypeEnumMap[instance.movingAverageType],
      'fieldType': instance.fieldType,
      'lineStyle': instance.lineStyle,
      'offset': instance.offset,
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
  MovingAverageType.wellesWilder: 'wellesWilder',
};
