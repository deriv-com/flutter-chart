// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'smi_indicator_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SMIIndicatorConfig _$SMIIndicatorConfigFromJson(Map<String, dynamic> json) =>
    SMIIndicatorConfig(
      period: json['period'] as int? ?? 10,
      smoothingPeriod: json['smoothingPeriod'] as int? ?? 3,
      doubleSmoothingPeriod: json['doubleSmoothingPeriod'] as int? ?? 3,
      overboughtValue: (json['overboughtValue'] as num?)?.toDouble() ?? 40,
      oversoldValue: (json['oversoldValue'] as num?)?.toDouble() ?? -40,
      signalPeriod: json['signalPeriod'] as int? ?? 10,
      maType: $enumDecodeNullable(_$MovingAverageTypeEnumMap, json['maType']) ??
          MovingAverageType.exponential,
      showZones: json['showZones'] as bool? ?? true,
      title: json['title'] as String?,
    );

Map<String, dynamic> _$SMIIndicatorConfigToJson(SMIIndicatorConfig instance) =>
    <String, dynamic>{
      'title': instance.title,
      'period': instance.period,
      'smoothingPeriod': instance.smoothingPeriod,
      'doubleSmoothingPeriod': instance.doubleSmoothingPeriod,
      'signalPeriod': instance.signalPeriod,
      'maType': _$MovingAverageTypeEnumMap[instance.maType]!,
      'overboughtValue': instance.overboughtValue,
      'oversoldValue': instance.oversoldValue,
      'showZones': instance.showZones,
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
