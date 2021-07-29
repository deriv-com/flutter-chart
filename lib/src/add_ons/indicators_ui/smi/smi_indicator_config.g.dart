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
    overboughtValue: (json['overboughtValue'] as num).toDouble(),
    oversoldValue: (json['oversoldValue'] as num).toDouble(),
    signalPeriod: json['signalPeriod'] as int,
    maType: _$enumDecode(_$MovingAverageTypeEnumMap, json['maType']),
    showZones: json['showZones'] as bool,
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
      'showZones': instance.showZones,
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
  MovingAverageType.triangular: 'triangular',
  MovingAverageType.doubleExponential: 'doubleExponential',
  MovingAverageType.tripleExponential: 'tripleExponential',
};
