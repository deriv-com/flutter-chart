// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ma_indicator_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MAIndicatorConfig _$MAIndicatorConfigFromJson(Map<String, dynamic> json) {
  return MAIndicatorConfig(
    period: json['period'] as int,
    movingAverageType:
        _$enumDecode(_$MovingAverageTypeEnumMap, json['movingAverageType']),
    fieldType: json['fieldType'] as String,
    lineStyle: LineStyle.fromJson(json['lineStyle'] as Map<String, dynamic>),
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
  MovingAverageType.wellesWilder: 'wellesWilder',
};
