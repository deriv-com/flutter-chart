// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ma_indicator_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MAIndicatorConfig _$MAIndicatorConfigFromJson(Map<String, dynamic> json) =>
    MAIndicatorConfig(
      period: json['period'] as int?,
      movingAverageType: $enumDecodeNullable(
          _$MovingAverageTypeEnumMap, json['movingAverageType']),
      fieldType: json['fieldType'] as String?,
      lineStyle: json['lineStyle'] == null
          ? null
          : LineStyle.fromJson(json['lineStyle'] as Map<String, dynamic>),
      offset: json['offset'] as int?,
      isOverlay: json['isOverlay'] as bool? ?? true,
      pipSize: json['pipSize'] as int? ?? 4,
      showLastIndicator: json['showLastIndicator'] as bool? ?? false,
      title: json['title'] as String?,
    );

Map<String, dynamic> _$MAIndicatorConfigToJson(MAIndicatorConfig instance) =>
    <String, dynamic>{
      'isOverlay': instance.isOverlay,
      'title': instance.title,
      'showLastIndicator': instance.showLastIndicator,
      'pipSize': instance.pipSize,
      'period': instance.period,
      'movingAverageType':
          _$MovingAverageTypeEnumMap[instance.movingAverageType]!,
      'fieldType': instance.fieldType,
      'lineStyle': instance.lineStyle,
      'offset': instance.offset,
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
