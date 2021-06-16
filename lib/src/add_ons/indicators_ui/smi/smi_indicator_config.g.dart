// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'smi_indicator_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SMIIndicatorConfig _$SMIIndicatorConfigFromJson(Map<String, dynamic> json) {
  return SMIIndicatorConfig(
    period: json['period'] as int,
    smoothingPeriod: json['smoothingPeriod'] as int,
    doubleSmoothingPeriod: json['doubleSmoothingPeriod'] as int,
    overboughtValue: (json['overboughtValue'] as num)?.toDouble(),
    oversoldValue: (json['oversoldValue'] as num)?.toDouble(),
    signalPeriod: json['signalPeriod'] as int,
    maType: _$enumDecodeNullable(_$MovingAverageTypeEnumMap, json['maType']),
  );
}

Map<String, dynamic> _$SMIIndicatorConfigToJson(SMIIndicatorConfig instance) =>
    <String, dynamic>{
      'period': instance.period,
      'smoothingPeriod': instance.smoothingPeriod,
      'doubleSmoothingPeriod': instance.doubleSmoothingPeriod,
      'signalPeriod': instance.signalPeriod,
      'maType': _$MovingAverageTypeEnumMap[instance.maType],
      'overboughtValue': instance.overboughtValue,
      'oversoldValue': instance.oversoldValue,
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
};
