// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chart_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChartConfig _$ChartConfigFromJson(Map<String, dynamic> json) => ChartConfig(
      granularity: json['granularity'] as int,
      pipSize: json['pipSize'] as int? ?? 4,
    );

Map<String, dynamic> _$ChartConfigToJson(ChartConfig instance) =>
    <String, dynamic>{
      'pipSize': instance.pipSize,
      'granularity': instance.granularity,
    };
