// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rainbow_indicator_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RainbowIndicatorConfig _$RainbowIndicatorConfigFromJson(
        Map<String, dynamic> json) =>
    RainbowIndicatorConfig(
      period: json['period'] as int? ?? 50,
      movingAverageType: $enumDecodeNullable(
              _$MovingAverageTypeEnumMap, json['movingAverageType']) ??
          MovingAverageType.simple,
      fieldType: json['fieldType'] as String? ?? 'close',
      bandsCount: json['bandsCount'] as int? ?? 10,
      rainbowLineStyles: (json['rainbowLineStyles'] as List<dynamic>?)
          ?.map((e) => LineStyle.fromJson(e as Map<String, dynamic>))
          .toList(),
      showLastIndicator: json['showLastIndicator'] as bool? ?? false,
    );

Map<String, dynamic> _$RainbowIndicatorConfigToJson(
        RainbowIndicatorConfig instance) =>
    <String, dynamic>{
      'showLastIndicator': instance.showLastIndicator,
      'period': instance.period,
      'movingAverageType':
          _$MovingAverageTypeEnumMap[instance.movingAverageType]!,
      'fieldType': instance.fieldType,
      'bandsCount': instance.bandsCount,
      'rainbowLineStyles': instance.rainbowLineStyles,
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
