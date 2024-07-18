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
      signalPeriod: json['signalPeriod'] as int? ?? 10,
      smiOscillatorLimits: json['smiOscillatorLimits'] == null
          ? const OscillatorLinesConfig(
              oversoldValue: -40,
              overboughtValue: 40,
              overboughtStyle: LineStyle(),
              oversoldStyle: LineStyle())
          : OscillatorLinesConfig.fromJson(
              json['smiOscillatorLimits'] as Map<String, dynamic>),
      maType: $enumDecodeNullable(_$MovingAverageTypeEnumMap, json['maType']) ??
          MovingAverageType.exponential,
      showZones: json['showZones'] as bool? ?? true,
      lineStyle: json['lineStyle'] == null
          ? null
          : LineStyle.fromJson(json['lineStyle'] as Map<String, dynamic>),
      signalLineStyle: json['signalLineStyle'] == null
          ? null
          : LineStyle.fromJson(json['signalLineStyle'] as Map<String, dynamic>),
      pipSize: json['pipSize'] as int? ?? 4,
      showLastIndicator: json['showLastIndicator'] as bool? ?? false,
      title: json['title'] as String?,
      number: json['number'] as int? ?? 0,
    );

Map<String, dynamic> _$SMIIndicatorConfigToJson(SMIIndicatorConfig instance) =>
    <String, dynamic>{
      'number': instance.number,
      'title': instance.title,
      'showLastIndicator': instance.showLastIndicator,
      'pipSize': instance.pipSize,
      'period': instance.period,
      'smoothingPeriod': instance.smoothingPeriod,
      'doubleSmoothingPeriod': instance.doubleSmoothingPeriod,
      'signalPeriod': instance.signalPeriod,
      'maType': _$MovingAverageTypeEnumMap[instance.maType]!,
      'smiOscillatorLimits': instance.smiOscillatorLimits,
      'showZones': instance.showZones,
      'lineStyle': instance.lineStyle,
      'signalLineStyle': instance.signalLineStyle,
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
